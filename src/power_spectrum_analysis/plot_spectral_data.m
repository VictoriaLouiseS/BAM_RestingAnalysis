function plot_spectral_data(open,closed,varnames,test)
    pre_open = open{1};
    post_open = open{2};
    diff_open = open{3};

    pre_closed = closed{1};
    post_closed= closed{2};
    diff_closed= closed{3};


    range_bounds = [4.0,8.0,12.0,35.0];
    x_vals = 1:1/10:90;

    % Plot data
    fig = figure();
    t = tiledlayout(height(pre_open),2);
    % h = gobjects(1,2);


    for i=1:height(pre_open.ID)
        participant_id = pre_open.ID{i};
        pre_open_array = table2array(pre_open(strcmp(pre_open.ID,participant_id),varnames));
        post_open_array = table2array(post_open(strcmp(post_open.ID,participant_id),varnames));
        diff_open_array = table2array(diff_open(strcmp(diff_open.ID,participant_id),varnames));

        pre_closed_array = table2array(pre_closed(strcmp(pre_closed.ID,participant_id),varnames));
        post_closed_array = table2array(post_closed(strcmp(post_closed.ID,participant_id),varnames));
        diff_closed_array = table2array(diff_closed(strcmp(diff_closed.ID,participant_id),varnames));
        nexttile
        hold on
        plot(x_vals,pre_open_array,Color=[0,1,0]);
        plot(x_vals,post_open_array,Color=[1,0,0]);
        plot(x_vals,diff_open_array,'--',Color=[0,0,0]);
        xline(range_bounds);
        title([participant_id ' Open']);
        hold off

        nexttile
        hold on
        plot(x_vals,pre_closed_array,Color=[0,1,0]);
        plot(x_vals,post_closed_array,Color=[1,0,0]);
        plot(x_vals,diff_closed_array,'--',Color=[0,0,0]);
        xline(range_bounds);
        title([participant_id ' Closed']);
        hold off
    end

    lg = legend('Pre','Post','Diff');

    title(t,test);

    test = strrep(test," ","_");
    test = lower(test);
    

    saveas(fig,strcat(test,'_spectrum_plot.fig'));
end