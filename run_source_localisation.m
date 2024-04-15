function run_source_localisation(indir,prefix,outdir)
    % run   Runs source localisation on single file or files in a folder
    %

    % Have outdir as optional, set default
    if ~exist('outdir', 'var')
        if isfolder(indir)
            outdir = indir;
        else
            [filedir, ~, ~] = fileparts(indir);
            outdir = filedir;
        end
    end

    if isfolder(indir)
        % Get files in folder
        files = dir(indir + "/*.mat");

        % For each file in folder, call source localisation script
        for i = 1:length(files)
            file = files(i);
            filedir = file.folder;
            filename = file.name;

            filepath = fullfile(filedir,filename);

            BAM_Resting_EEG_SourceLocalisation(filepath,prefix)
        end
    else
        % Call source localisation script
        BAM_Resting_EEG_SourceLocalisation(indir,prefix)
    end

end
