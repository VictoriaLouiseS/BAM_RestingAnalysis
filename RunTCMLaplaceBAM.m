function RunTCMLaplaceBAM(dataset_path)
% Top level script showing how to apply the thalamo-cortical neural mass
% model decribed in Shaw et al 2020 NeuroImage, to M/EEG data.
%
% This version using a linearisation and transfer function (numerical
% Laplace) rather than brute numerical integration.
%
% Requires atcm (thalamo cortical modelling package) and aoptim
% (optimisation package)
%
% atcm: https://github.com/alexandershaw4/atcm
% aoptim: https://github.com/alexandershaw4/aoptim
%
% Overview of contents
%--------------------------------------------------
% - atcm. contains:
%         - the equations of motion for an 8 pop thalamo-cortical
%           model described by parameterised Morris-Lecar/Hodgkin-Hux
%           conductance ODEs
%         - numerical integration (Euler, RK, Newton-Cotes +) and spectral
%           response functions
%         - lots of helper functions (integration, differentiation,
%           continuation, decomposition methods etc)
% - aoptim contains:
%          - a second order gradient descent optimisation routine that
%          includes both free energy and orther objective functions
%          - n-th order numerical differentiation functions (parallelised)
%
%
% AS

% EXAMPLE ONE NODE SETUP:
%==========================================================================

dataset_struct = dir(dataset_path)
dataset_list = []

for i=1:length(dataset_struct)
    name = dataset_struct(i).name
    folder = dataset_struct(i).folder

    if ~(strcmp(name,'.')) & ~(strcmp(name,'..'))
        [path, name, ext] = fileparts(name)

        if ext == ".mat"
            dataset_list = [dataset_list, {fullfile(folder, name)}];
        end
    end
end

% Data & Design
%--------------------------------------------------------------------------
%Data.Datasets     = 'NewMeansSZ.txt';%'MeanSZDatasets.txt';%'AllSZNoMerge.txt'; % textfile list of LFP SPM datasets (.txt)
Data.Design.X     = [];                % design matrix
Data.Design.name  = {'undefined'};     % condition names
Data.Design.tCode = [1];               % condition codes in SPM
Data.Design.Ic    = [1 2];          % channel indices
Data.Design.Sname = {'Frontal' 'Parietal'};  % channel (node) names

Data.Prefix       = 'LM_Laplace_TCM_';      % outputted DCM prefix
% Data.Datasets     = atcm.fun.ReadDatasets(Data.Datasets);
% Data.Datasets     = {'./datasets/SPM_LCMV_RestingClean_G112_rest_open_MSV.mat'};
Data.Datasets     = dataset_list;
                
% Model space - T = ns x ns, where 1 = Fwd, 2 = Bkw
%--------------------------------------------------------------------------
T = [...
    0 1 ;
    2 0 ];

F = (T==1);      % Forward
B = (T==2);      % Backward
C = [1 1]';      % inputs
L = sparse(2,2); 

[p]=fileparts(which('atcm.integrate_1'));p=strrep(p,'+atcm','');addpath(p);


% Set up, over subjects
%--------------------------------------------------------------------------
for i = 1:length(Data.Datasets)

    % Data Naming & Design Matrix
    %----------------------------------------------------------------------
    DCM          = [];
    [fp fn fe]   = fileparts(Data.Datasets{i});
    DCM.name     = fullfile(fp,[Data.Prefix fn],fe);


    if startsWith(fn,Data.Prefix) | exist(DCM.name,'file');
        fprintf('Skipping model %d/%d - already exists!\n( %s )\n',i,length(Data.Datasets),DCM.name);
        continue;
    end

    DCM.xY.Dfile = Data.Datasets{i};  % original spm datafile
    Ns           = length(F);         % number of regions / modes
    DCM.xU.X     = Data.Design.X;     % design matrix
    DCM.xU.name  = Data.Design.name;  % condition names
    tCode        = Data.Design.tCode; % condition index (in SPM)
    DCM.xY.Ic    = Data.Design.Ic;    % channel indices
    DCM.Sname    = Data.Design.Sname; % channel names

    % Extrinsic Connectivity - Model Space
    %----------------------------------------------------------------------
    DCM.A{1} = F;
    DCM.A{2} = B;
    DCM.A{3} = L;
    DCM.B{1} = DCM.A{1} | DCM.A{2};
    DCM.B(2:length(DCM.xU.X)) = DCM.B;
    DCM.C    = C;
    
    % Function Handles
    %----------------------------------------------------------------------
    DCM.M.f  = @atcm.tc_hilge2;              % model function handle
    DCM.M.IS = @atcm.fun.alex_tf;            % Alex integrator/transfer function
    DCM.options.SpecFun = @atcm.fun.Afft;    % fft function for IS
    
    % Print Progress
    %----------------------------------------------------------------------
    fprintf('Running Dataset %d / %d\n',i,length(Data.Datasets));
    
    % Frequency range of interest
    fq =  [1 90];
    
    % Prepare Data
    %----------------------------------------------------------------------
    DCM.M.U            = sparse(diag(ones(Ns,1)));  %... ignore [modes]
    DCM.options.trials = tCode;                     %... trial code [GroupDataLocs]
    DCM.options.Tdcm   = [0 2000];                  %... peristimulus time
    DCM.options.Fdcm   = fq;                        %... frequency window
    DCM.options.D      = 1;                         %... downsample
    DCM.options.han    = 1;                         %... apply hanning window
    DCM.options.h      = 4;                         %... number of confounds (DCT)
    DCM.options.DoData = 1;                         %... leave on [custom]
    %DCM.options.baseTdcm   = [-200 0];             %... baseline times [new!]
    DCM.options.Fltdcm = fq;                        %... bp filter [new!]
    DCM.options.UseButterband = fq;

    DCM.options.analysis      = 'CSD';              %... analyse type
    DCM.xY.modality           = 'LFP';              %... ECD or LFP data? [LFP]
    DCM.options.spatial       = 'LFP';              %... spatial model [LFP]
    DCM.options.model         = 'tc6';              %... neural model
    DCM.options.Nmodes        = length(DCM.M.U);    %... number of modes
    
    DCM.options.UseWelch      = 1010;
    DCM.options.FFTSmooth     = 0;
    DCM.options.BeRobust      = 0;
    DCM.options.FrequencyStep = 1;
    
    DCM.xY.name = DCM.Sname;
    DCM = atcm.fun.prepcsd(DCM);
    DCM.options.DATA = 1 ;

    for is = 1:Ns
        DCM.xY.y{:}(:,is,is) = DCM.xY.y{:}(:,is,is) ./ max(DCM.xY.y{:}(:,is,is));
    end

    for is = 1:Ns
        for js = 1:Ns
            if is ~= js
                DCM.xY.y{:}(:,is,js) = DCM.xY.y{:}(:,is,is) .* conj( DCM.xY.y{:}(:,js,js) );
            end
        end
    end

    % Gaussian kernel smoothing
    for is = 1:Ns
        for js = 1:Ns
            DCM.xY.y{:}(:,is,js)  = agauss_smooth(abs(DCM.xY.y{:}(:,is,js)),1);
        end
    end
        
    % Subfunctions and default priors
    %----------------------------------------------------------------------
    DCM = atcm.parameters(DCM,Ns,[p '/newpoints3.mat']);
            
    % other model options
    %----------------------------------------------------------------------
    DCM.M.solvefixed=0;      
    DCM.M.x = zeros(Ns,8,7);  
    DCM.M.x(:,:,1)=-70;      % init pop membrane pot [mV]
        
    pE=DCM.M.pE;
    pC=DCM.M.pC;

    pC.ID = pC.ID * 0;
    pC.T  = pC.T *0;
    
    pE.J = pE.J-1000;    
    pE.J(1:8) = log([.6 .8 .4 .6 .4 .6 .4 .4]);
    pE.L = 0;

    pC.S = pC.S + 1/8;

    pC.J(1:8)=1/8;
    pC.d(1) = 1/8;

    pE.L = [0 0];
    pC.L = [1 1]./8;

    %NEW = load('SurrogateOptEp','Ep')
    %pE = NEW.Ep;
            
    DCM.M.pE = pE;
    DCM.M.pC = pC;

    % store things where functions can find them
    w   = DCM.xY.Hz;
    Y   = DCM.xY.y{:};
    DCM.M.y  = DCM.xY.y;
    DCM.M.Hz = DCM.xY.Hz;

    ppE = DCM.M.pE;
    ppC = DCM.M.pC;
    

    % Search for a fixed point using Newton-Raphson
    %---------------------------------------------------------------------
    fprintf('--------------- STATE ESTIMATION ---------------\n');
    fprintf('Search for a stable fixed point\n');

    load('init_14dec','x');
    DCM.M.x = spm_unvec(spm_vec(repmat(x,[1 Ns])'),DCM.M.x);

    % x = atcm.fun.alexfixed(DCM.M.pE,DCM.M,1e-10);
    load('bam_2node_tcm_fixedpoint','x')
    DCM.M.x = spm_unvec(x,DCM.M.x);

    norm(DCM.M.f(DCM.M.x,0,DCM.M.pE,DCM.M))
    fprintf('Finished...\n');
          
    
    % Alex's version of the Levenberg-Marquard routine
    %---------------------------------------------------------------------
    fprintf('--------------- PARAM ESTIMATION ---------------\n');
    M = AODCM(DCM);

    M.alex_lm;
    M.compute_free_energy(M.Ep);

    % save in DCM structures after fitting, also compute LFPs etc
    %----------------------------------------------------------------------
    DCM.M.pE = ppE;
    DCM.Ep = spm_unvec(M.Ep,DCM.M.pE);
    DCM.Cp = [];

    DCM.M.sim.dt  = 1./600;
    DCM.M.sim.pst = 1000*((0:DCM.M.sim.dt:(2)-DCM.M.sim.dt)');

    [y,w,G,s] = feval(DCM.M.IS,DCM.Ep,DCM.M,DCM.xU);

    DCM.pred = y;
    DCM.w = w;
    DCM.G = G;
    DCM.series = s;
    
    DCM.F  = M.FreeEnergyF;
    DCM.Cp = M.CP;
    save(DCM.name); close all; clear global;
    
end

end
