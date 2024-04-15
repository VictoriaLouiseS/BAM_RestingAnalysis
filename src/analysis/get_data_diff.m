function diff_table = get_data_diff(pre_table,post_table)
    diff_table = [];

    data_varnames = pre_table.Properties.VariableNames;
    frontal_varnames = [];
    parietal_varnames = [];

    for i=1:length(data_varnames)
        varname = data_varnames{i};

        if regexp(varname,'Frontal*')
            frontal_varnames = [frontal_varnames; {varname}];
        elseif regexp(varname,'Parietal*')
            parietal_varnames = [parietal_varnames; {varname}];
        end
    end

    for i=1:height(pre_table)
        pre_data = pre_table(i,:);
        participant_id = pre_data.ID{1};
        post_data = post_table(strcmp(post_table.ID,pre_data.ID),:);

        participant_data = table;
        participant_data.ID = string(participant_id);

        for j=1:length(frontal_varnames)
            data_diff = post_data.(frontal_varnames{j}) - pre_data.(frontal_varnames{j});

            participant_data.(frontal_varnames{j}) = data_diff;
        end

        for j=1:length(parietal_varnames)
            data_diff = post_data.(parietal_varnames{j}) - pre_data.(parietal_varnames{j});

            participant_data.(parietal_varnames{j}) = data_diff;
        end

        diff_table = [diff_table; participant_data];
    end
end