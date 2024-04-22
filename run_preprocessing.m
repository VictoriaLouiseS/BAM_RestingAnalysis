function run_preprocessing(indir,outdir,target_files)
    %RUN_PREPROCESSING Run preprocessing script
    %   Taking input of input directory, output directory and strings to
    %   target in file names, iterate through matching filenames in the
    %   provided input directory and allow the user to choose whether they
    %   wish to preprocess matching files.
    addpath('src/preprocessing')
    files_and_dirs = dir(indir);
    
    if ischar(target_files)
        target_files = [{target_files}]
    end
    
    for i=1:length(files_and_dirs)
        name = files_and_dirs(i).name;
        
        if ~strcmp(name,'.') && ~strcmp(name,'..');
            folder = files_and_dirs(i).folder;
            file_dir = fullfile(folder,name);

            if isdir(file_dir);
                run_preprocessing(file_dir,outdir,target_files);
            else isfile(file_dir);
                [~,filename,ext] = fileparts(file_dir);

                if strcmp(ext,'.eeg');
                    match = 1;
                    for j=1:length(target_files)
                        if ~contains(filename,target_files{j});
                            match = 0;
                            break
                        end
                    end
                    if match;
                        fprintf("FILE FOR PROCESSING: ");
                        fprintf(filename);
                        fprintf("\n");
                        prompt = strcat("Do you wish to preprocess file\n",filename,"\nY/N [Y]: ");
                        txt = input(prompt,"s");
                        if isempty(txt)
                            txt = 'Y';
                        end
                        if strcmp(txt,'Y') || strcmp(txt,'y')
                            % Run preprocessing
                            [data, data_filt, GoodChans, allart, BadChans, OrigDataset] = preprocess_eeg(folder,filename);
                            
                            output_file = strcat(outdir,"/RestingClean_",filename);
                            fprintf('Saving data.......');
                            save(output_file, 'data', 'data_filt', 'GoodChans', 'allart', 'BadChans', 'OrigDataset');
                            fprintf('Done\n')
                        end
                    end
                end
            end
        end
    end
end