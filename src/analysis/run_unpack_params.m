function run_unpack_params(indir)
    %%% Script to run unpack_parameters.m script and create table %%%

    data_struct = dir(indir)
    data_list = []

    all_data = [[{'Filename'},{'K_AMPA'},{'K_GABAA'},{'K_NMDA'},{'K_GABAB'},{'K_M'},{'K_HCN'},{'AMPA_FWD'},{'AMPA_BKW'},{'NMDA_FWD'},{'NMDA_BKW'},{'H'},{'Hn'}]]
    filename = []
    k_ampa = []
    k_gabaa = []
    k_nmda = []
    k_gabab = []
    k_m = []
    k_hcn = []
    ampa_fwd = []
    ampa_bkw = []
    nmda_fwd = []
    nmda_bkw = []
    h_frontal = []
    h_parietal = []
    hn_frontal = []
    hn_parietal = []

    data_table = []
    
    for i=1:length(data_struct)
        name = data_struct(i).name
        folder = data_struct(i).folder
    
        if ~(strcmp(name,'.')) & ~(strcmp(name,'..'))
            [path, name, ext] = fileparts(name)
    
            if ext == ".mat"
                if startsWith(name, 'LM_Laplace_')
                    data_file = fullfile(folder, name)
                    data = load(data_file);

                    DCM = data.DCM
                    Ep = DCM.Ep


                    p = get_parameters(Ep);

                    p.filename = name;

                    filename = [filename; {[name ext]}];
                    k_ampa = [k_ampa; p.K_AMPA];
                    k_gabaa = [k_gabaa; p.K_GABAA];
                    k_nmda = [k_nmda; p.K_NMDA];
                    k_gabab = [k_gabab; p.K_GABAB];
                    k_m = [k_m; p.K_M];
                    k_hcn = [k_hcn; p.K_HCN];
                    ampa_fwd = [ampa_fwd; p.AMPA_FWD];
                    ampa_bkw = [ampa_bkw; p.AMPA_BKW];
                    nmda_fwd = [nmda_fwd; p.NMDA_FWD];
                    nmda_bkw = [nmda_bkw; p.NMDA_BKW];
                    h_frontal = [h_frontal; {p.H_frontal}];
                    h_parietal= [h_parietal; {p.H_parietal}];
                    hn_frontal = [hn_frontal; {p.Hn_frontal}];
                    hn_parietal= [hn_parietal; {p.Hn_parietal}];

                    
                end
            end
        end
    end

    data_table = table(filename,k_ampa,k_gabaa,k_nmda,k_gabab,k_m,k_hcn,ampa_fwd,ampa_bkw,nmda_fwd,nmda_bkw,h_frontal,h_parietal,hn_frontal,hn_parietal)

end