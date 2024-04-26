function spectrum_table = get_power_spectrum(indir,prefix)
    % find the input files, this could be SPM or DCM format
    f = dir(strcat(indir,"/",prefix,'*.mat'));
    f = {f.name}';

    % frequency resolution for analysis: number of steps per hertz
    step = 1/10;
    % frequency window for analysis
    w = 1:step:90;

    psd = [];

    orig_dir=pwd;
    cd(indir);

    for i = 1:length(f)
%         % load DCM using the SPM MEEG loader (memory maps file)
%         load([indir,'/',f{i}],'DCM');
%         % use the DCM to find the original SPM dataset
%         D = spm_eeg_load(DCM.xY.Dfile);

        filename = f{i};
        outfilename = strcat('PSD_',filename);

        % Load SPM file
        D = spm_eeg_load(f{i});

        % FFT at freqs of interest
        X = atcm.fun.Afft(squeeze(D(:,:,:)),D.fsample,w);
        % Gaussian kernel smoothing on spectra (N*2*2) width =4
        
        size_X = size(X);
        for j = 1:size_X(2)
            for k = 1:size_X(3)
                %
                F(:,j,k) = atcm.fun.agauss_smooth(X(:,j,k),size_X(2)*size_X(3));
                F(:,k,j) = F(:,j,k);
                    
                %end
            end
        end
        % extract PSD of the two regions
        for j = 1:size_X(2)
            psd(j,:) = squeeze(F(:,j,j));
        end
        
        save(outfilename,"psd");
    end

    cd(orig_dir);
%     spectrum_table = table;
%     spectrum_table.Subject = f;
%     spectrum_table.Frontal = frontal_psd;
%     spectrum_table.Parietal = parietal_psd;
% 
%     writetable(spectrum_table,'spectrum_table.csv');
end