classdef ParticipantData
    %PARTICIPANTDATA Class to contain participant data
    %   Data from each participant is extracted from the source localised
    %   data format and stored
    
    properties
        id = '';
        has_pre = false;
        has_post= false;
        has_open = false;
        has_closed = false;
        is_drug = false;
        is_placebo = false;
        data = [];
        n_datasets = 0;
    end
    
    methods
        function obj = ParticipantData(id)
            %PARTICIPANTDATA Construct an instance of this class
            %   Detailed explanation goes here
            obj.id = id;
        end
        
        function obj = set_data(obj,filename)
            time = obj.get_data_time(filename);
            obj = obj.set_data_time(time);
            eyes = obj.get_eyes(filename);
            obj = obj.set_eyes(eyes);
            
            load(filename);
            
            data = obj.data;
            
            data.coords.frontal = ftdata.coords.frontal.coords;
            data.coords.parietal = ftdata.coords.parietal.coords;

            time_idx = "";
            eyes_idx = "";
            frontal_idx = [];
            parietal_idx = [];
            
            if strcmp(time,'BA')
                time_idx = 'pre';
            elseif strcmp(time,'MSV')
                time_idx = 'post';
            end
            
            eyes_idx = eyes;
            
            % Set indices for frontal and parietal data
            % If using the source localisation script in this repo, it
            % will always be frontal first then parietal
            frontal_min_idx = 1;
            frontal_max_idx = frontal_min_idx + length(data.coords.frontal) - 1;
            parietal_min_idx = frontal_max_idx + 1;
            parietal_max_idx = parietal_min_idx + length(data.coords.parietal) - 1;
            
            trials = ftdata.trial{1};
            
            data.(time_idx).(eyes).frontal = []
            data.(time_idx).(eyes).parietal = []
            data.(time_idx).(eyes).time = []
             
            
            for i=1:length(trials)
                data.(time_idx).(eyes).frontal = [data.(time_idx).(eyes).frontal,ftdata.trial{1}{i}(frontal_min_idx:frontal_max_idx,:)];
                data.(time_idx).(eyes).parietal = [data.(time_idx).(eyes).parietal,ftdata.trial{1}{i}(parietal_min_idx:parietal_max_idx,:)];
                data.(time_idx).(eyes).time = [data.(time_idx).(eyes).time,ftdata.time{i}];
            end
            
            obj.data = data;
        end

        function id = get_id(obj, str)
            id = obj.id;
        end
        
        function time = get_data_time(obj, str)
            pre_expr = '_BA';
            post_expr = '_MSV';
            expr = [{pre_expr} {post_expr}];
            
            time = obj.check_filename(str,expr);
        end
        
        function obj = set_data_time(obj,time)
            if strcmp(time,'BA')
                obj.has_pre = true;
            elseif strcmp(time,'MSV')
                obj.has_post = true;
            end
        end
        
        function eyes = get_eyes(obj, str)
            open_expr = 'open';
            closed_expr = 'closed';
            expr = [{open_expr} {closed_expr}];
            
            eyes = obj.check_filename(str,expr);
        end
        
        function obj = set_eyes(obj, eyes)
            if strcmp(eyes,'open')
                obj.has_open = true;
            elseif strcmp(eyes, 'closed')
                obj.has_closed = true;
            end
        end
        
        function found = check_filename(obj, str, expr)
            if iscell(expr)
                for i=1:length(expr)
                    found_str = strrep(regexp(str,expr{i},'match'), '_', '');
                    if length(found_str) > 0
                        found = string(found_str);
                        return
                    end
                end
            elseif ischar(expr)
                found = string(strrep(regexp(str,expr,'match'), '_', ''));
                return
            end
        end
    end
end

