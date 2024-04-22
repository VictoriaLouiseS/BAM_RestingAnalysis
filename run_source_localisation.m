function run_source_localisation(indir,prefix,ncoords,outdir)
    % run   Runs source localisation on single file or files in a folder
    %
    addpath('./src/source_localisation')

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
    else
        % Call source localisation script
        files = [indir];
    end
    
    if ~isfolder(outdir)
        mkdir(outdir)
    end 
    
    % For each file in folder, call source localisation script
    for i = 1:length(files)
        file = files(i);
        filedir = file.folder;
        filename = file.name;

        filepath = fullfile(filedir,filename);

        ftdata = BAM_Resting_EEG_SourceLocalisation(filepath,ncoords);

        % Split datafile path to create output filename
        [~, file, ext] = fileparts(filepath);
        outputfile = strcat(prefix,file,ext);

        outputpath = strcat(outdir,"/",outputfile);

        save(outputpath,'ftdata')
    end
end
