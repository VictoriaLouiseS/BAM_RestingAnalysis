function spectrum_table = get_power_spectrum(indir)
    % find the DCM files
    f = dir([indir,'/LM_Lapl*']);
    f = {f.name}';
    % frequency resolution: number of steps per hertz
    step = 1/10;
    % frequency window
    w = 1:step:90;

    % frontal_psd = []
    % parietal_psd = []
    for i = 1:length(f)
        % load DCM using the SPM MEEG loader (memory maps file)
        load([indir,'/',f{i}],'DCM');
        % use the DCM to find the original SPM dataset
        D = spm_eeg_load(DCM.xY.Dfile);
        % FFT at freqs of interest
        X = atcm.fun.Afft(squeeze(D(:,:,:)),D.fsample,w);
        % Gaussian kernel smoothing on spectra (N*2*2) width =4
        for j = 1:2
            for k = 1:2
                %
                    F(:,j,k) = atcm.fun.agauss_smooth(X(:,j,k),4);
                    F(:,k,j) = F(:,j,k);
                    
                %end
            end
        end
        % extract PSD of the two regions
        frontal_psd(i,:) = squeeze(F(:,1,1));
        parietal_psd(i,:) = squeeze(F(:,2,2));
    end
    spectrum_table = table;
    spectrum_table.Subject = f;
    spectrum_table.Frontal = frontal_psd;
    spectrum_table.Parietal = parietal_psd;

    writetable(spectrum_table,'spectrum_table.csv');
end