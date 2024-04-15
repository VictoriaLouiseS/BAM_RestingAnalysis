function analyse_power_spectrum(infile)
    % Read in data as table
    data = readtable(infile,'Delimiter',',');

    [drug_data_pre_open,drug_data_pre_closed,drug_data_post_open,drug_data_post_closed,pla_data_pre_open,pla_data_pre_closed,pla_data_post_open,pla_data_post_closed] = separate_data_group(data);

    % Get area variable names
    data_varnames = drug_data_pre_open.Properties.VariableNames;
    frontal_varnames = [];
    % frontal_idx = [];
    parietal_varnames = [];
    % parietal_idx = [];
    varnames = [];

    for i=1:length(data_varnames)
        varname = data_varnames{i};

        if regexp(varname,'Frontal*')
            frontal_varnames = [frontal_varnames; {varname}];
            % frontal_idx = [frontal_idx; i];
            varnames = [varnames; {varname}];
        elseif regexp(varname,'Parietal*')
            parietal_varnames = [parietal_varnames; {varname}];
            % parietal_idx = [parietal_idx; i];
            varnames = [varnames; {varname}];
        end
    end

    % Normalise parietal data
    drug_data_pre_open{:,parietal_varnames} = drug_data_pre_open{:,parietal_varnames} / 10^10;
    drug_data_post_open{:,parietal_varnames} = drug_data_post_open{:,parietal_varnames} / 10^10;
    drug_data_pre_closed{:,parietal_varnames} = drug_data_pre_closed{:,parietal_varnames} / 10^10;
    drug_data_post_closed{:,parietal_varnames} = drug_data_post_closed{:,parietal_varnames} / 10^10;
    pla_data_pre_open{:,parietal_varnames} = pla_data_pre_open{:,parietal_varnames} / 10^10;
    pla_data_post_open{:,parietal_varnames} = pla_data_post_open{:,parietal_varnames} / 10^10;
    pla_data_pre_closed{:,parietal_varnames} = pla_data_pre_closed{:,parietal_varnames} / 10^10;
    pla_data_post_closed{:,parietal_varnames} = pla_data_post_closed{:,parietal_varnames} / 10^10;

    drug_open_diff_table.ID = drug_data_pre_open.ID;
    drug_closed_diff_table.ID = drug_data_pre_closed.ID;
    pla_open_diff_table.ID = pla_data_pre_open.ID;
    pla_closed_diff_table.ID = pla_data_pre_closed.ID;

    drug_open_diff_table = get_data_diff(drug_data_pre_open,drug_data_post_open);
    drug_closed_diff_table = get_data_diff(drug_data_pre_closed,drug_data_post_closed);
    pla_open_diff_table = get_data_diff(pla_data_pre_open,pla_data_post_open);
    pla_closed_diff_table = get_data_diff(pla_data_pre_closed,pla_data_post_closed);

    plot_spectral_data( ...
        [{drug_data_pre_open},{drug_data_post_open},{drug_open_diff_table}], ...
        [{drug_data_pre_closed},{drug_data_post_closed},{drug_closed_diff_table}], ...
        frontal_varnames, ...
        'Ketamine Frontal');

    plot_spectral_data( ...
        [{pla_data_pre_open},{pla_data_post_open},{pla_open_diff_table}], ...
        [{pla_data_pre_closed},{pla_data_post_closed},{pla_closed_diff_table}], ...
        frontal_varnames, ...
        'Placebo Frontal');
   

    plot_spectral_data( ...
        [{drug_data_pre_open},{drug_data_post_open},{drug_open_diff_table}], ...
        [{drug_data_pre_closed},{drug_data_post_closed},{drug_closed_diff_table}], ...
        parietal_varnames, ...
        'Ketamine Parietal');

    plot_spectral_data( ...
        [{pla_data_pre_open},{pla_data_post_open},{pla_open_diff_table}], ...
        [{pla_data_pre_closed},{pla_data_post_closed},{pla_closed_diff_table}], ...
        parietal_varnames, ...
        'Placebo Parietal');
    % % Plot data
    % fig = figure();
    % t_ket = tiledlayout(height(drug_data_pre_open),2);
    % % h = gobjects(1,2);
    % 
    % 
    % for i=1:height(drug_data_pre_open.ID)
    %     participant_id = drug_data_pre_open.ID{i};
    %     pre_open_array = table2array(drug_data_pre_open(strcmp(drug_data_pre_open.ID,participant_id),frontal_varnames));
    %     post_open_array = table2array(drug_data_post_open(strcmp(drug_data_post_open.ID,participant_id),frontal_varnames));
    %     diff_open_array = table2array(drug_open_diff_table(strcmp(drug_open_diff_table.ID,participant_id),frontal_varnames));
    % 
    %     pre_closed_array = table2array(drug_data_pre_closed(strcmp(drug_data_pre_closed.ID,participant_id),frontal_varnames));
    %     post_closed_array = table2array(drug_data_post_closed(strcmp(drug_data_post_closed.ID,participant_id),frontal_varnames));
    %     diff_closed_array = table2array(drug_closed_diff_table(strcmp(drug_closed_diff_table.ID,participant_id),frontal_varnames));
    %     nexttile
    %     hold on
    %     plot(x_vals,pre_open_array,Color=[1,0,0]);
    %     plot(x_vals,post_open_array,Color=[0,1,0]);
    %     plot(x_vals,diff_open_array,'--',Color=[0,0,0]);
    %     xline(range_bounds);
    %     title([participant_id ' Open']);
    %     % xticklabels(1:90);
    %     hold off
    % 
    %     nexttile
    %     hold on
    %     plot(x_vals,pre_closed_array,Color=[1,0,0]);
    %     plot(x_vals,post_closed_array,Color=[0,1,0]);
    %     plot(x_vals,diff_closed_array,'--',Color=[0,0,0]);
    %     xline(range_bounds);
    %     title([participant_id ' Closed']);
    %     % xticklabels(1:90);
    %     hold off
    % end
    % 
    % lg = legend('Pre','Post','Diff');
    % 
    % title(t_ket,'Ketamine');
    % 
    % saveas(fig,'ket_pre_post.fig');

    %     % Plot data
    % fig = figure();
    % t_pla = tiledlayout(height(pla_data_pre_open),2);
    % % h = gobjects(1,2);
    % 
    % 
    % for i=1:height(pla_data_pre_open.ID)
    %     participant_id = pla_data_pre_open.ID{i};
    %     pre_open_array = table2array(pla_data_pre_open(strcmp(pla_data_pre_open.ID,participant_id),frontal_varnames));
    %     post_open_array = table2array(pla_data_post_open(strcmp(pla_data_post_open.ID,participant_id),frontal_varnames));
    %     diff_open_array = table2array(pla_open_diff_table(strcmp(pla_open_diff_table.ID,participant_id),frontal_varnames));
    % 
    %     pre_closed_array = table2array(pla_data_pre_closed(strcmp(pla_data_pre_closed.ID,participant_id),frontal_varnames));
    %     post_closed_array = table2array(pla_data_post_closed(strcmp(pla_data_post_closed.ID,participant_id),frontal_varnames));
    %     diff_closed_array = table2array(pla_closed_diff_table(strcmp(pla_closed_diff_table.ID,participant_id),frontal_varnames));
    %     nexttile
    %     hold on
    %     plot(x_vals,pre_open_array,Color=[1,0,0]);
    %     plot(x_vals,post_open_array,Color=[0,1,0]);
    %     plot(x_vals,post_open_array,'--',Color=[0,0,0]);
    %     xline(range_bounds);
    %     title([participant_id ' Open']);
    %     hold off
    % 
    %     nexttile
    %     hold on
    %     plot(x_vals,pre_closed_array,Color=[1,0,0]);
    %     plot(x_vals,post_closed_array,Color=[0,1,0]);
    %     plot(x_vals,post_closed_array,'--',Color=[0,0,0]);
    %     xline(range_bounds);
    %     title([participant_id ' Closed']);
    %     hold off
    % end
    % 
    % lg = legend('Pre','Post','Diff');
    % 
    % title(t_pla,'Placebo');
    % 
    % saveas(fig,'pla_pre_post.fig');

    closed_significant_diffs = [];
    closed_tstats = [];
    for i=1:length(varnames)
        varname = varnames{i};
        [h,p,ci,stats] = ttest2(drug_closed_diff_table.(varname),pla_closed_diff_table.(varname));

        closed_tstats = [closed_tstats; stats.tstat];

        if p<0.05
            closed_significant_diffs = [closed_significant_diffs;{varname}];
        end
    end

    open_significant_diffs = [];
    open_tstats = [];
    for i=1:length(varnames)
        varname = varnames{i};
        [h,p,ci,stats] = ttest2(drug_open_diff_table.(varname),pla_open_diff_table.(varname));

        open_tstats = [open_tstats; stats.tstat];

        if p<0.05
            open_significant_diffs = [open_significant_diffs;{varname}];
        end
    end

    % Plot t-value which is in stats structure from ttest2
    % Use function from aoptim, shuffle
    % nperms 5000
    % alphathresh 0.05
    % Marc normalises difference, normalise everyone by dividing parietal
    % by 10^11/12
    % COuld be because of MNI location in relation to sensor or gyrus
    combined_significant_diffs = [];
    combined_tstats = [];
    for i=1:length(varnames)
        varname = varnames{i};
        [h,p,ci,stats] = ttest2([drug_open_diff_table.(varname);drug_closed_diff_table.(varname)],[pla_open_diff_table.(varname);pla_closed_diff_table.(varname)]);

        combined_tstats = [combined_tstats; stats.tstat];

        if p<0.05
            combined_significant_diffs = [combined_significant_diffs;{varname}];
        end
    end

    range_bounds = [4.0,8.0,12.0,35.0];

    fig = figure();
    t = tiledlayout(3,2);
    nexttile;
    plot(1:1/10:90,closed_tstats(1:891));
    xline(range_bounds);
    yline(0,'--');
    title('Closed T-Value Frontal');

    nexttile;
    plot(1:1/10:90,closed_tstats(892:end));
    xline(range_bounds);
    yline(0,'--');
    title('Closed T-Value Parietal');

    nexttile;
    plot(1:1/10:90,open_tstats(1:891));
    xline(range_bounds);
    yline(0,'--');
    title('Open T-Value Frontal');

    nexttile;
    plot(1:1/10:90,open_tstats(892:end));
    xline(range_bounds);
    yline(0,'--');
    title('Open T-Value Parietal');

    nexttile;
    plot(1:1/10:90,combined_tstats(1:891));
    xline(range_bounds);
    yline(0,'--');
    title('Combined T-Value Frontal');

    nexttile;
    plot(1:1/10:90,combined_tstats(892:end));
    xline(range_bounds);
    yline(0,'--');
    title('Combined T-Value Parietal');

    title(t,"MATLAB ttest2");

    % Use different method
    combined_frontal_rand = orig_kRandTest([drug_open_diff_table{:,frontal_varnames};drug_closed_diff_table{:,frontal_varnames}],[pla_open_diff_table{:,frontal_varnames};pla_closed_diff_table{:,frontal_varnames}], 0.05,  5000, 0);
    combined_parietal_rand = orig_kRandTest([drug_open_diff_table{:,parietal_varnames};drug_closed_diff_table{:,parietal_varnames}],[pla_open_diff_table{:,parietal_varnames};pla_closed_diff_table{:,parietal_varnames}], 0.05,  5000, 0);

    open_frontal_rand = orig_kRandTest(drug_open_diff_table{:,frontal_varnames},pla_open_diff_table{:,frontal_varnames}, 0.05,  5000, 0);
    open_parietal_rand = orig_kRandTest(drug_open_diff_table{:,parietal_varnames},pla_open_diff_table{:,parietal_varnames}, 0.05,  5000, 0);

    closed_frontal_rand = orig_kRandTest(drug_closed_diff_table{:,frontal_varnames},pla_closed_diff_table{:,frontal_varnames}, 0.05,  5000, 0);
    closed_parietal_rand = orig_kRandTest(drug_closed_diff_table{:,parietal_varnames},pla_closed_diff_table{:,parietal_varnames}, 0.05,  5000, 0);

    fig = figure();
    t = tiledlayout(3,2);
    nexttile;
    plot(1:1/10:90,closed_frontal_rand.tseries,"Color",[0,1,0]);
    plot(1:1/10:90,closed_frontal_rand.tseries_corr,"Color",[1,0,0]);
    xline(range_bounds);
    yline(0,'--');
    title('Closed T-Value Frontal');

    nexttile;
    plot(1:1/10:90,closed_parietal_rand.tseries,"Color",[0,1,0]);
    plot(1:1/10:90,closed_parietal_rand.tseries_corr,"Color",[1,0,0]);
    xline(range_bounds);
    yline(0,'--');
    title('Closed T-Value Parietal');

    nexttile;
    plot(1:1/10:90,open_frontal_rand.tseries,"Color",[0,1,0]);
    plot(1:1/10:90,open_frontal_rand.tseries_corr,"Color",[1,0,0]);
    xline(range_bounds);
    yline(0,'--');
    title('Open T-Value Frontal');

    nexttile;
    plot(1:1/10:90,open_parietal_rand.tseries,"Color",[0,1,0]);
    plot(1:1/10:90,open_parietal_rand.tseries_corr,"Color",[1,0,0]);
    xline(range_bounds);
    yline(0,'--');
    title('Open T-Value Parietal');

    nexttile;
    plot(1:1/10:90,combined_frontal_rand.tseries,"Color",[0,1,0]);
    plot(1:1/10:90,combined_frontal_rand.tseries_corr,"Color",[1,0,0]);
    xline(range_bounds);
    yline(0,'--');
    title('Combined T-Value Frontal');

    nexttile;
    plot(1:1/10:90,closed_parietal_rand.tseries,"Color",[0,1,0]);
    plot(1:1/10:90,closed_parietal_rand.tseries_corr,"Color",[1,0,0]);
    xline(range_bounds);
    yline(0,'--');
    title('Combined T-Value Parietal');

    title(t,"kRandTest");
end