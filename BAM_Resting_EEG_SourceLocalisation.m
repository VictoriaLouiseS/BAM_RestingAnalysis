function BAM_Resting_EEG_SourceLocalisation(datafile,prefix)


data = load(datafile);
data_filt = data.data_filt;

template = 'New_58cortical_AALROI_6mm.mat';
load(template)
sourcemodel = template_sourcemodel;

%head model
headmodel = ft_read_headmodel('standard_bem.mat')

for i = 1:3
    headmodel.bnd(i).pos = headmodel.bnd(i).pos * .99;
end

% electodes
elecfile = 'Acticap_slim_standard.mat';
elec = load(elecfile);

%Then average reference
cfg = [];
cfg.reref         = 'yes';
cfg.refchannel = 'all';
cfg.implicitref = 'FCz';
data_filt = ft_preprocessing(cfg, data_filt);


% covariance
cfg = [];
cfg.covariance='yes';
cfg.covariancewindow = [0 2];%[-.2 .3];
avg = ft_timelockanalysis(cfg,data_filt);

% lead field
cfg                 = [];
cfg.channel         = avg.label; % ensure that rejected sensors are not present
cfg.elec            = elecfile;
cfg.headmodel       = headmodel;
cfg.lcmv.reducerank = 3; % default for MEG is 2, for EEG is 3
cfg.grid = sourcemodel;
[grid] = ft_prepare_leadfield(cfg);


% filters
cfg=[];
cfg.method='lcmv';
cfg.grid = grid;
cfg.elec = elecfile;
cfg.headmodel=headmodel;
cfg.lcmv.keepfilter='yes';
cfg.channel = data_filt.label;
sourceavg=ft_sourceanalysis(cfg, avg);


% frontal and parietal coords
coords = [-12 36 60; -24 -66 66];

[~,frontal_ind] = min(cdist(grid.pos,coords(1,:)));
[~,parietal_ind] = min(cdist(grid.pos,coords(2,:)));

I = [frontal_ind parietal_ind];

VEfilt = cat(3,sourceavg.avg.filter{I});

for ik = 1:size(VEfilt,3)

    for i = 1:length(data_filt.trial)
    
        VE3 = squeeze(VEfilt(:,:,ik))*data_filt.trial{i};

        C = cov(VE3');
        [u,s,v]=svd(C);
        triali(ik,i,:) = u(:,1)'*VE3;
    end
    

end

ftdata = [];
ftdata.fsample = data.data_filt.fsample;
ftdata.time = data.data_filt.time;
ftdata.trial = {squeeze(triali)};
ftdata.label = {'Frontal'; 'Parietal'};

save([prefix datafile],'ftdata')















