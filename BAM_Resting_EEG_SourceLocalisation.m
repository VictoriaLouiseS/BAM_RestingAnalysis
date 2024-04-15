function BAM_Resting_EEG_SourceLocalisation(datafile,prefix)
    % BAM_Resting_EEG_SourceLocalisation    Performs source localisation
    %   Accepts raw EEG datafile input and saves a new file containing
    %   source localised data for the frontal and parietal coordinates.
    %
    %   Input:
    %       datafile - path to input datafile
    %       prefix   - prefix for output file

    % Load in raw EEG data file and use filtered data
    data      = load(datafile);
    data_filt = data.data_filt;
    clear data

    % Load source model template
    template        = 'New_58cortical_AALROI_6mm.mat';
    template_struct = load(template)
    sourcemodel     = template_struct.template_sourcemodel;
    %AAL_Labels = template_struct.AAL_Labels;
    %all_roi_tissueindex = template_struct.all_roi_tissueindex;
    clear template_struct

    % Read in head model
    headmodel = ft_read_headmodel('standard_bem.mat')

    % Modify pos value to ensure it doesn't sit in the skull
    for i = 1:3
        headmodel.bnd(i).pos = headmodel.bnd(i).pos * .99;
    end

    % Preprocess the EEG data
    cfg               = [];
    cfg.reref         = 'yes';
    cfg.refchannel    = 'all';
    cfg.implicitref   = 'FCz';
    data_filt_preproc = ft_preprocessing(cfg, data_filt);

    % Ensure variables we want to save are kept
    data_label   = data_filt_preproc.label
    data_trial   = data_filt_preproc.trial
    data_fsample = data_filt_preproc.fsample
    data_time    = data_filt_preproc.time

    clear cfg
    clear data_filt

    % Get data covariance matrix and timelocked average
    cfg = [];
    cfg.covariance='yes';
    cfg.covariancewindow = [0 2];%[-.2 .3];
    avg = ft_timelockanalysis(cfg,data_filt_preproc);

    clear cfg
    clear data_filt_preproc

    % Electrode info filename
    elecfile = 'Acticap_slim_standard.mat';

    % Create forward model of EEG data
    cfg                 = [];
    cfg.channel         = avg.label; % ensure that rejected sensors are not present
    cfg.elec            = elecfile;
    cfg.headmodel       = headmodel;
    cfg.lcmv.reducerank = 3; % default for MEG is 2, for EEG is 3
    cfg.grid            = sourcemodel;
    [grid]              = ft_prepare_leadfield(cfg);

    clear cfg
    clear sourcemodel

    % Setup data required for source analysis
    cfg                 = [];
    cfg.method          = 'lcmv';
    cfg.grid            = grid;
    cfg.elec            = elecfile;
    cfg.headmodel       = headmodel;
    cfg.lcmv.keepfilter = 'yes';
    cfg.channel         = data_label;

    % Frontal and parietal MNI coords
    coords = [-12 36 60; -24 -66 66];

    % Get the voxel coordinates closest to coordinates of interest using
    % MNI coordinates
    [~,frontal_ind] = mink(cdist(grid.pos,coords(1,:)),5);
    [~,parietal_ind] = mink(cdist(grid.pos,coords(2,:)),5);
    
%     [~,frontal_ind] = min(cdist(grid.pos,coords(1,:)));
%     [~,parietal_ind] = min(cdist(grid.pos,coords(2,:)));
%     
    data_coords.frontal.target = [-12 36 60];
    data_coords.frontal.coords = grid.pos(frontal_ind,:);
    data_coords.parietal.target = [-24 -66 66];
    data_coords.parietal.coords = grid.pos(parietal_ind,:);

    clear grid
    clear headmodel

    % Perform source analysis
    sourceavg=ft_sourceanalysis(cfg, avg);

    % Get data from coordinates of interest
    I = [frontal_ind parietal_ind];
    VEfilt = cat(3,sourceavg.avg.filter{I});

    for ik = 1:size(VEfilt,3)

        for i = 1:length(data_trial)

            VE3 = squeeze(VEfilt(:,:,ik))*data_trial{i};

            C = cov(VE3');
            [u,s,v] = svd(C);
            triali(ik,i,:) = u(:,1)'*VE3;
        end

    end

    % Split datafile path to create output filename
    [dir, file, ext] = fileparts(datafile);
    outputfile = [prefix file ext];

    if dir ~= ""
        outputpath = dir + "/" + outputfile;
    else
        outputpath = outputfile;
    end

    % Combine data to save and save to file
    ftdata         = [];
    ftdata.fsample = data_fsample;
    ftdata.time    = data_time;
    ftdata.trial   = {squeeze(triali)};
    ftdata.coords  = data_coords;

    save(outputpath,'ftdata')

end