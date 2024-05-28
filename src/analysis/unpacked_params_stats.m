function unpacked_params_stats(data)
    % data = readtable(data_csv)
    load(data)

    data = joined_table
    data.Drug = string(data.Drug)
    data.Baslne = string(data.Baslne)
    % Group data into individual participants
    id_expr = '_G[0-9]+_';

    % all_participant_data = [];
    ids = {};

    subject_filenames = data.Subject

    drug_data_pre = [];
    pla_data_pre = [];
    drug_data_post = [];
    pla_data_post = [];

    for i=1:length(subject_filenames)
        file = subject_filenames{i};
        participant_id = strrep(regexp(file,id_expr,'match'), '_', '');

        if ~any(strcmp(ids, participant_id))
            ids = [ids; participant_id];
            participant_data = []
            participant_data.id = participant_id
            participant_data.data = data(contains(data.Subject,['_' participant_id{1} '_']),:)

            % all_participant_data = [all_participant_data;participant_data]

            if strcmp(participant_data.data.Drug(1),'KET')
                drug_data_pre = [drug_data_pre;participant_data.data(contains(participant_data.data.Baslne,'BA'),:)]
                drug_data_post = [drug_data_post;participant_data.data(contains(participant_data.data.Baslne,'MSV'),:)]

            elseif strcmp(participant_data.data.Drug(1),'PLA')
                pla_data_pre = [pla_data_pre;participant_data.data(contains(participant_data.data.Baslne,'BA'),:)]
                pla_data_post = [pla_data_post;participant_data.data(contains(participant_data.data.Baslne,'MSV'),:)]
            end


        end
    end

    for i=1:8
        for j=1:8
            
            
    drug_diff_vals = drug_data_pre(:,3);
    pla_diff_vals = pla_data_pre(:,3);

    i_pval_sig = []

    for i=4:275
        [h,p]=ttest2(drug_data_post{:,i}-drug_data_pre{:,i},pla_data_post{:,i}-pla_data_pre{:,i})

        if p < 0.05
            i_pval_sig = [i_pval_sig i]
        end
    end
    % Get stats for spectral data
    % Drug
    drug_frontal_alpha_stats = []
    drug_frontal_alpha_stats.pre = get_var_stats(drug_data_pre.FrontalAlpha)
    drug_frontal_alpha_stats.post = get_var_stats(drug_data_post.FrontalAlpha)
    drug_diff_vals.FrontalAlpha_diff = drug_data_post.FrontalAlpha-drug_data_pre.FrontalAlpha

    drug_frontal_beta_stats = []
    drug_frontal_beta_stats.pre = get_var_stats(drug_data_pre.FrontalBeta)
    drug_frontal_beta_stats.post = get_var_stats(drug_data_post.FrontalBeta)
    drug_diff_vals.FrontalBeta_diff = drug_data_post.FrontalBeta-drug_data_pre.FrontalBeta

    drug_frontal_delta_stats = []
    drug_frontal_delta_stats.pre = get_var_stats(drug_data_pre.FrontalDelta)
    drug_frontal_delta_stats.post = get_var_stats(drug_data_post.FrontalDelta)
    drug_diff_vals.FrontalDelta_diff = drug_data_post.FrontalDelta-drug_data_pre.FrontalDelta

    drug_frontal_theta_stats = []
    drug_frontal_theta_stats.pre = get_var_stats(drug_data_pre.FrontalTheta)
    drug_frontal_theta_stats.post = get_var_stats(drug_data_post.FrontalTheta)
    drug_diff_vals.FrontalTheta_diff = drug_data_post.FrontalTheta-drug_data_pre.FrontalTheta

    drug_frontal_lgamma_stats = []
    drug_frontal_lgamma_stats.pre = get_var_stats(drug_data_pre.FrontalLowGamma)
    drug_frontal_lgamma_stats.post = get_var_stats(drug_data_post.FrontalLowGamma)
    drug_diff_vals.FrontalLowGamma_diff = drug_data_post.FrontalLowGamma-drug_data_pre.FrontalLowGamma

    drug_frontal_hgamma_stats = []
    drug_frontal_hgamma_stats.pre = get_var_stats(drug_data_pre.FrontalHighGamma)
    drug_frontal_hgamma_stats.post = get_var_stats(drug_data_post.FrontalHighGamma)
    drug_diff_vals.FrontalHighGamma_diff = drug_data_post.FrontalHighGamma-drug_data_pre.FrontalHighGamma

    drug_parietal_alpha_stats = []
    drug_parietal_alpha_stats.pre = get_var_stats(drug_data_pre.ParietalAlpha)
    drug_parietal_alpha_stats.post = get_var_stats(drug_data_post.ParietalAlpha)
    drug_diff_vals.ParietalAlpha_diff = drug_data_post.ParietalAlpha-drug_data_pre.ParietalAlpha

    drug_parietal_beta_stats = []
    drug_parietal_beta_stats.pre = get_var_stats(drug_data_pre.ParietalBeta)
    drug_parietal_beta_stats.post = get_var_stats(drug_data_post.ParietalBeta)
    drug_diff_vals.ParietalBeta_diff = drug_data_post.ParietalBeta-drug_data_pre.ParietalBeta

    drug_parietal_delta_stats = []
    drug_parietal_delta_stats.pre = get_var_stats(drug_data_pre.ParietalDelta)
    drug_parietal_delta_stats.post = get_var_stats(drug_data_post.ParietalDelta)
    drug_diff_vals.ParietalDelta_diff = drug_data_post.ParietalDelta-drug_data_pre.ParietalDelta

    drug_parietal_theta_stats = []
    drug_parietal_theta_stats.pre = get_var_stats(drug_data_pre.ParietalTheta)
    drug_parietal_theta_stats.post = get_var_stats(drug_data_post.ParietalTheta)
    drug_diff_vals.ParietalTheta_diff = drug_data_post.ParietalTheta-drug_data_pre.ParietalTheta

    drug_parietal_lgamma_stats = []
    drug_parietal_lgamma_stats.pre = get_var_stats(drug_data_pre.ParietalLowGamma)
    drug_parietal_lgamma_stats.post = get_var_stats(drug_data_post.ParietalLowGamma)
    drug_diff_vals.ParietalLowGamma_diff = drug_data_post.ParietalLowGamma-drug_data_pre.ParietalLowGamma

    drug_parietal_hgamma_stats = []
    drug_parietal_hgamma_stats.pre = get_var_stats(drug_data_pre.ParietalHighGamma)
    drug_parietal_hgamma_stats.post = get_var_stats(drug_data_post.ParietalHighGamma)
    drug_diff_vals.ParietalHighGamma_diff = drug_data_post.ParietalHighGamma-drug_data_pre.ParietalHighGamma

    % Placebo
    pla_frontal_alpha_stats = []
    pla_frontal_alpha_stats.pre = get_var_stats(pla_data_pre.FrontalAlpha)
    pla_frontal_alpha_stats.post = get_var_stats(pla_data_post.FrontalAlpha)
    pla_diff_vals.FrontalAlpha_diff = pla_data_post.FrontalAlpha-pla_data_pre.FrontalAlpha

    pla_frontal_beta_stats = []
    pla_frontal_beta_stats.pre = get_var_stats(pla_data_pre.FrontalBeta)
    pla_frontal_beta_stats.post = get_var_stats(pla_data_post.FrontalBeta)
    pla_diff_vals.FrontalBeta_diff = pla_data_post.FrontalBeta-pla_data_pre.FrontalBeta

    pla_frontal_delta_stats = []
    pla_frontal_delta_stats.pre = get_var_stats(pla_data_pre.FrontalDelta)
    pla_frontal_delta_stats.post = get_var_stats(pla_data_post.FrontalDelta)
    pla_diff_vals.FrontalDelta_diff = pla_data_post.FrontalDelta-pla_data_pre.FrontalDelta

    pla_frontal_theta_stats = []
    pla_frontal_theta_stats.pre = get_var_stats(pla_data_pre.FrontalTheta)
    pla_frontal_theta_stats.post = get_var_stats(pla_data_post.FrontalTheta)
    pla_diff_vals.FrontalTheta_diff = pla_data_post.FrontalTheta-pla_data_pre.FrontalTheta

    pla_frontal_lgamma_stats = []
    pla_frontal_lgamma_stats.pre = get_var_stats(pla_data_pre.FrontalLowGamma)
    pla_frontal_lgamma_stats.post = get_var_stats(pla_data_post.FrontalLowGamma)
    pla_diff_vals.FrontalLowGamma_diff = pla_data_post.FrontalLowGamma-pla_data_pre.FrontalLowGamma

    pla_frontal_hgamma_stats = []
    pla_frontal_hgamma_stats.pre = get_var_stats(pla_data_pre.FrontalHighGamma)
    pla_frontal_hgamma_stats.post = get_var_stats(pla_data_post.FrontalHighGamma)
    pla_diff_vals.FrontalHighGamma_diff = pla_data_post.FrontalHighGamma-pla_data_pre.FrontalHighGamma

    pla_parietal_alpha_stats = []
    pla_parietal_alpha_stats.pre = get_var_stats(pla_data_pre.ParietalAlpha)
    pla_parietal_alpha_stats.post = get_var_stats(pla_data_post.ParietalAlpha)
    pla_diff_vals.ParietalAlpha_diff = pla_data_post.ParietalAlpha-pla_data_pre.ParietalAlpha

    pla_parietal_beta_stats = []
    pla_parietal_beta_stats.pre = get_var_stats(pla_data_pre.ParietalBeta)
    pla_parietal_beta_stats.post = get_var_stats(pla_data_post.ParietalBeta)
    pla_diff_vals.ParietalBeta_diff = pla_data_post.ParietalBeta-pla_data_pre.ParietalBeta

    pla_parietal_delta_stats = []
    pla_parietal_delta_stats.pre = get_var_stats(pla_data_pre.ParietalDelta)
    pla_parietal_delta_stats.post = get_var_stats(pla_data_post.ParietalDelta)
    pla_diff_vals.ParietalDelta_diff = pla_data_post.ParietalDelta-pla_data_pre.ParietalDelta

    pla_parietal_theta_stats = []
    pla_parietal_theta_stats.pre = get_var_stats(pla_data_pre.ParietalTheta)
    pla_parietal_theta_stats.post = get_var_stats(pla_data_post.ParietalTheta)
    pla_diff_vals.ParietalTheta_diff = pla_data_post.ParietalTheta-pla_data_pre.ParietalTheta

    pla_parietal_lgamma_stats = []
    pla_parietal_lgamma_stats.pre = get_var_stats(pla_data_pre.ParietalLowGamma)
    pla_parietal_lgamma_stats.post = get_var_stats(pla_data_post.ParietalLowGamma)
    pla_diff_vals.ParietalLowGamma_diff = pla_data_post.ParietalLowGamma-pla_data_pre.ParietalLowGamma

    pla_parietal_hgamma_stats = []
    pla_parietal_hgamma_stats.pre = get_var_stats(pla_data_pre.ParietalHighGamma)
    pla_parietal_hgamma_stats.post = get_var_stats(pla_data_post.ParietalHighGamma)
    pla_diff_vals.ParietalHighGamma_diff = pla_data_post.ParietalHighGamma-pla_data_pre.ParietalHighGamma

    % Get stats for spectral data difference
    % Drug
    drug_frontal_alpha_stats.diff = get_var_stats(drug_data_post.FrontalAlpha-drug_data_pre.FrontalAlpha)

    drug_frontal_beta_stats.diff = get_var_stats(drug_data_post.FrontalBeta-drug_data_pre.FrontalBeta)

    drug_frontal_delta_stats.diff = get_var_stats(drug_data_post.FrontalDelta-drug_data_pre.FrontalDelta)

    drug_frontal_theta_stats.diff = get_var_stats(drug_data_post.FrontalTheta-drug_data_pre.FrontalTheta)

    drug_frontal_lgamma_stats.diff = get_var_stats(drug_data_post.FrontalLowGamma-drug_data_pre.FrontalLowGamma)

    drug_frontal_hgamma_stats.diff = get_var_stats(drug_data_post.FrontalHighGamma-drug_data_pre.FrontalHighGamma)

    drug_parietal_alpha_stats.diff = get_var_stats(drug_data_post.ParietalAlpha-drug_data_pre.ParietalAlpha)

    drug_parietal_beta_stats.diff = get_var_stats(drug_data_post.ParietalBeta-drug_data_pre.ParietalBeta)

    drug_parietal_delta_stats.diff = get_var_stats(drug_data_post.ParietalDelta-drug_data_pre.ParietalDelta)

    drug_parietal_theta_stats.diff = get_var_stats(drug_data_post.ParietalTheta-drug_data_pre.ParietalTheta)

    drug_parietal_lgamma_stats.diff = get_var_stats(drug_data_post.ParietalLowGamma-drug_data_pre.ParietalLowGamma)

    drug_parietal_hgamma_stats.diff = get_var_stats(drug_data_post.ParietalHighGamma-drug_data_pre.ParietalHighGamma)

    % Placebo
    pla_frontal_alpha_stats.diff = get_var_stats(pla_data_post.FrontalAlpha-pla_data_pre.FrontalAlpha)

    pla_frontal_beta_stats.diff = get_var_stats(pla_data_post.FrontalBeta-pla_data_pre.FrontalBeta)

    pla_frontal_delta_stats.diff = get_var_stats(pla_data_post.FrontalDelta-pla_data_pre.FrontalDelta)

    pla_frontal_theta_stats.diff = get_var_stats(pla_data_post.FrontalTheta-pla_data_pre.FrontalTheta)

    pla_frontal_lgamma_stats.diff = get_var_stats(pla_data_post.FrontalLowGamma-pla_data_pre.FrontalLowGamma)

    pla_frontal_hgamma_stats.diff = get_var_stats(pla_data_post.FrontalHighGamma-pla_data_pre.FrontalHighGamma)

    pla_parietal_alpha_stats.diff = get_var_stats(pla_data_post.ParietalAlpha-pla_data_pre.ParietalAlpha)

    pla_parietal_beta_stats.diff = get_var_stats(pla_data_post.ParietalBeta-pla_data_pre.ParietalBeta)

    pla_parietal_delta_stats.diff = get_var_stats(pla_data_post.ParietalDelta-pla_data_pre.ParietalDelta)

    pla_parietal_theta_stats.diff = get_var_stats(pla_data_post.ParietalTheta-pla_data_pre.ParietalTheta)

    pla_parietal_lgamma_stats.diff = get_var_stats(pla_data_post.ParietalLowGamma-pla_data_pre.ParietalLowGamma)

    pla_parietal_hgamma_stats.diff = get_var_stats(pla_data_post.ParietalHighGamma-pla_data_pre.ParietalHighGamma)


    % Get AMPA_FWD data
    drug_ampa_fwd_stats = []
    drug_ampa_fwd_stats.pre = get_var_stats(drug_data_pre.AMPA_FWD)
    drug_ampa_fwd_stats.post = get_var_stats(drug_data_post.AMPA_FWD)
    drug_ampa_fwd_stats.diff = get_var_stats(drug_data_post.AMPA_FWD-drug_data_pre.AMPA_FWD)
    drug_ampa_fwd_diff = drug_data_post.AMPA_FWD-drug_data_pre.AMPA_FWD
    drug_diff_vals.AMPA_FWD_diff = drug_ampa_fwd_diff

    pla_ampa_fwd_stats = []
    pla_ampa_fwd_stats.pre = get_var_stats(pla_data_pre.AMPA_FWD)
    pla_ampa_fwd_stats.post = get_var_stats(pla_data_post.AMPA_FWD)
    pla_ampa_fwd_stats.diff = get_var_stats(pla_data_post.AMPA_FWD-pla_data_pre.AMPA_FWD)
    pla_ampa_fwd_diff = pla_data_post.AMPA_FWD-pla_data_pre.AMPA_FWD
    pla_diff_vals.AMPA_FWD_diff = pla_ampa_fwd_diff

    % Get AMPA_BKW data
    drug_ampa_bkw_stats = []
    drug_ampa_bkw_stats.pre = get_var_stats(drug_data_pre.AMPA_BKW)
    drug_ampa_bkw_stats.post = get_var_stats(drug_data_post.AMPA_BKW)
    drug_ampa_bkw_stats.diff = get_var_stats(drug_data_post.AMPA_BKW-drug_data_pre.AMPA_BKW)
    drug_ampa_bkw_diff = drug_data_post.AMPA_BKW-drug_data_pre.AMPA_BKW
    drug_diff_vals.AMPA_BKW_diff = drug_ampa_bkw_diff

    pla_ampa_bkw_stats = []
    pla_ampa_bkw_stats.pre = get_var_stats(pla_data_pre.AMPA_BKW)
    pla_ampa_bkw_stats.post = get_var_stats(pla_data_post.AMPA_BKW)
    pla_ampa_bkw_stats.diff = get_var_stats(pla_data_post.AMPA_BKW-pla_data_pre.AMPA_BKW)
    pla_ampa_bkw_diff = pla_data_post.AMPA_BKW-pla_data_pre.AMPA_BKW
    pla_diff_vals.AMPA_BKW_diff = pla_ampa_bkw_diff

    % Get NMDA_FWD data
    drug_nmda_fwd_stats = []
    drug_nmda_fwd_stats.pre = get_var_stats(drug_data_pre.NMDA_FWD)
    drug_nmda_fwd_stats.post = get_var_stats(drug_data_post.NMDA_FWD)
    drug_nmda_fwd_stats.diff = get_var_stats(drug_data_post.NMDA_FWD-drug_data_pre.NMDA_FWD)
    drug_nmda_fwd_diff = drug_data_post.NMDA_FWD-drug_data_pre.NMDA_FWD
    drug_diff_vals.NMDA_FWD_diff = drug_nmda_fwd_diff

    pla_nmda_fwd_stats = []
    pla_nmda_fwd_stats.pre = get_var_stats(pla_data_pre.NMDA_FWD)
    pla_nmda_fwd_stats.post = get_var_stats(pla_data_post.NMDA_FWD)
    pla_nmda_fwd_stats.diff = get_var_stats(pla_data_post.NMDA_FWD-pla_data_pre.NMDA_FWD)
    pla_nmda_fwd_diff = pla_data_post.NMDA_FWD-pla_data_pre.NMDA_FWD
    pla_diff_vals.NMDA_FWD_diff = pla_nmda_fwd_diff

    % Get NMDA_BKW data
    drug_nmda_bkw_stats = []
    drug_nmda_bkw_stats.pre = get_var_stats(drug_data_pre.NMDA_BKW)
    drug_nmda_bkw_stats.post = get_var_stats(drug_data_post.NMDA_BKW)
    drug_nmda_bkw_stats.diff = get_var_stats(drug_data_post.NMDA_BKW-drug_data_pre.NMDA_BKW)
    drug_nmda_bkw_diff = drug_data_post.NMDA_BKW-drug_data_pre.NMDA_BKW
    drug_diff_vals.NMDA_BKW_diff = drug_nmda_bkw_diff

    pla_nmda_bkw_stats = []
    pla_nmda_bkw_stats.pre = get_var_stats(pla_data_pre.NMDA_BKW)
    pla_nmda_bkw_stats.post = get_var_stats(pla_data_post.NMDA_BKW)
    pla_nmda_bkw_stats.diff = get_var_stats(pla_data_post.NMDA_BKW-pla_data_pre.NMDA_BKW)
    pla_nmda_bkw_diff = pla_data_post.NMDA_BKW-pla_data_pre.NMDA_BKW
    pla_diff_vals.NMDA_BKW_diff = pla_nmda_bkw_diff

    all_diff_vals = [drug_diff_vals;pla_diff_vals]

    for i=2:17
        % colname = get(drug_diff_vals(:,i),'columnname')

        [h,p] = ttest2(drug_diff_vals{:,i},pla_diff_vals{:,i})
    end
end