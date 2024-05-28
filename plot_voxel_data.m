function plot_voxel_data(indir,outdir)
    %%% Script to plot source localised voxel data %%%
    addpath src/participants;
    addpath src/participants/tools;
    files = [];

    if isfolder(indir)
        files = dir(indir);
    elseif isfile(indir)
        files = [indir];
    end
    
    % Have outdir as optional, set default
    if ~exist('outdir', 'var')
        if isfolder(indir)
            outdir = indir;
        else
            [filedir, ~, ~] = fileparts(indir);
            outdir = filedir;
        end
    end
    
    if ~isfolder(outdir)
        mkdir(outdir)
    end
    
    participant_ids = [];
    all_participant_data = [];
    
    for i=1:length(files)
        filename = files(i).name;
        filepath = files(i).folder;
        [folder name ext] = fileparts(filename);

        if strcmp(ext,'.mat')
            id = get_id(name);

            if length(participant_ids) == 0 || ~ismember(id,participant_ids)
                participant_data = ParticipantData(id);
                participant_data = participant_data.set_data(fullfile(filepath,filename));
                participant_ids = [participant_ids; id];
                all_participant_data.(id) = participant_data;
            else
                participant_data = all_participant_data.(id);
                participant_data = participant_data.set_data(fullfile(filepath,filename));
                all_participant_data.(id) = participant_data;
            end
        end
    end
    
    drug_data = readtable('drug_data.csv');
    drug_data = unique(drug_data);
    
    ket_dir = strcat(outdir,'/ket');
    pla_dir = strcat(outdir,'/pla');
    
    mkdir(ket_dir);
    mkdir(pla_dir);
    
    for i=1:length(participant_ids)
        id = participant_ids(i)
        participant_data = all_participant_data.(id);
        
        drug = string(drug_data.Drug(strcmp(string(drug_data.ID),id)));
        if length(drug) == 0
            drug = "?";
        end

        n_coords = length(participant_data.data.coords.frontal);
        
        fig = figure();
        fig.Position = [10,10,1100,1200];
        tiledlayout(n_coords,4);

        fig_title = strcat(id," ",drug);
        sgtitle(fig_title);
        
        for j=1:n_coords
            frontal_coords = strcat(string(participant_data.data.coords.frontal(j,1)), ...
                    ",",string(participant_data.data.coords.frontal(j,2)), ...
                    ",",string(participant_data.data.coords.frontal(j,3)));
            parietal_coords = strcat(string(participant_data.data.coords.parietal(j,1)), ...
                    ",",string(participant_data.data.coords.parietal(j,2)), ...
                    ",",string(participant_data.data.coords.parietal(j,3)));
            nexttile;

            if participant_data.has_open
                hold on
                if participant_data.has_pre
                    plot(participant_data.data.pre.open.time(:),participant_data.data.pre.open.frontal(j,:),'g');
                end
                if participant_data.has_post
                    plot(participant_data.data.post.open.time(:),participant_data.data.post.open.frontal(j,:),'r');
                end

                t = title(["Frontal Open ", frontal_coords]);
            
                hold off
            end
            
            nexttile;
            
            if participant_data.has_closed
                hold on
                if participant_data.has_pre
                    plot(participant_data.data.pre.closed.time(:),participant_data.data.pre.closed.frontal(j,:),'g');
                end
                if participant_data.has_post
                    plot(participant_data.data.post.closed.time(:),participant_data.data.post.closed.frontal(j,:),'r');
                end

                t = title(["Frontal Closed ", frontal_coords]);
                
                hold off
            end
            
            
            nexttile;
            
            
            if participant_data.has_open
                hold on
                if participant_data.has_pre
                    plot(participant_data.data.pre.open.time(:),participant_data.data.pre.open.parietal(j,:),'g');
                end
                if participant_data.has_post
                    plot(participant_data.data.post.open.time(:),participant_data.data.post.open.parietal(j,:),'r');
                end
                
                t = title(["Parietal Open", parietal_coords]);
                
                hold off
            end
            
            nexttile;
            
            
            if participant_data.has_closed
                hold on
                if participant_data.has_pre
                    plot(participant_data.data.pre.closed.time(:),participant_data.data.pre.closed.parietal(j,:),'g');
                end
                if participant_data.has_post
                    plot(participant_data.data.post.closed.time(:),participant_data.data.post.closed.parietal(j,:),'r');
                end
                
                t = title(["Parietal Closed", parietal_coords]);

                hold off
            end
        end

        if participant_data.has_pre && participant_data.has_post
            legend("Pre","Post",Location="southeastoutside");
        elseif participant_data.has_pre
            legend("Pre",Location="southeastoutside");
        elseif participant_data.has_post
            legend("Post",Location="southeastoutside");
        end
        
        save_dir = strcat(outdir,"/",id);
        
        if strcmp(drug,"KET")
            save_dir = strcat(ket_dir,"/",id);
        elseif strcmp(drug,"PLA")
            save_dir = strcat(pla_dir,"/",id);
        end
        
        saveas(fig,save_dir,'jpg');
        close(fig);
    end
end