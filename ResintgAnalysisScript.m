% Preprocessing (artifact rejection) script for BAM Resting EEG data

% Load file and add initial pre-processing
clear; clc;


% Change this
DATADIR = '~/Dropbox/BAM_KET_SOFAR/Raw_EEGs/G13/G13 Baseline/';
FILENAMEROOT = 'G13_rest_open_BA.eeg';

cd(DATADIR);

P = mfilename('fullpath');
[P,~,~,]=fileparts(P);
addpath(P);

% no changes below here....
%---------------------------------------------------------------
SAVEDIR = pwd;%'/data/mals946/NEWCAT/LTP/'; %Change to your own
channels = {'all' '-ECG'};
Dataset=FILENAMEROOT;

elecfile = 'Acticap_slim_standard.mat';
load elec_implicit.mat


name = strrep(FILENAMEROOT,'.eeg','');
Savename = ['RestingClean_' name];

%Create definition of trials - ft_definetrial alters the cfg struture
cfg.dataset = [Dataset];

% Baseline correction
cfg.demean = 'yes';
data       = ft_preprocessing(cfg);


% Artifact identification
%------------------------------------------------------------------------
% semi-authomated muscle tool turned EOG tool :D

cfg            = [];
cfg.continuous ='yes';

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel = {'Fp1', 'Fp2', 'AF7', 'AF8'}; % if the channels are bad - change to AF7 and AF8
cfg.artfctdef.zvalue.cutoff      = 5;
cfg.artfctdef.zvalue.trlpadding  = -0.15; % constrains the window to -.05 s before and 0.35 s after the onset of the stimulus (we only care about when people's eyes are closed while stim is on)
cfg.artfctdef.zvalue.fltpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.1;

% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter    = 'yes';
cfg.artfctdef.zvalue.bpfreq      = [0.3 1]; % toggle these if needed - 0.3 Hz to 1 Hz seems to catch blinks nicely
cfg.artfctdef.zvalue.bpfiltord   = 2;
cfg.artfctdef.zvalue.bpfilttype  = 'but';
cfg.artfctdef.zvalue.hilbert     = 'yes';
cfg.artfctdef.zvalue.boxcar      = 0.2;

% make the process interactive
cfg.artfctdef.zvalue.interactive = 'no';

[cfg, artifact_blink] = ft_artifact_zvalue(cfg, data);

cfg.artfctdef.reject = 'partial';
data_forsum = ft_rejectartifact(cfg, data);

cfg        = [];
cfg.metric = 'zvalue';  % use by default zvalue method
cfg.method = 'summary'; % use by default summary method
cfg.channel = {'all' '-Fp1' '-Fp2'}; %all EEG channels - fine if there's no other channel types
% All channels except FP1 and FP2 to reduce double dipping on
% blink deletion and missing other sources of variance

% cfg.latency     = [-0.2 0.350];
[artifact_sumvar]       = ft_rejectvisual(cfg,data_forsum);
artifact_sumvar = artifact_sumvar.cfg.artfctdef.summary.artifact;

% % % Manual artifact rejection
% % 
% % % Plots and reject
% cfg = [];
% cfg.viewmode = 'vertical';
% cfg.blocksize  = 1; %Time base
% cfg.channel = channels; %
% cfg.colorgroups  = 'allblack';
% cfg.ylim = [ -10 10 ];
% % cfg.continuous = 'yes';
% cfg.artfctdef.blink.artifact = artifact_blink;
% cfg.artfctdef.sumvar.artifact = artifact_sumvar;
% allart = ft_databrowser(cfg, data);

cfg = [];
cfg.artfctdef = artifact_sumvar;
cfg.artfctdef.reject = 'partial';
data_kepoch = ft_rejectartifact(cfg, data);

% Select good channels - remember to remove Exeter's dodgy CPz ...
%--------------------------------------------------------------------
labs = data.hdr.label;
bad = find(contains(labs,'CPz')); % always remove CPz
labs(bad)=[];
goodchannel = ft_channelselection(labs, data_kepoch.label);

cfg = [];
cfg.channel = goodchannel;
data_kchans = ft_selectdata(cfg, data_kepoch);
BadChans = setdiff(elec_implicit.label, data_kchans.label);
GoodChans = setdiff(elec_implicit.label, BadChans);

%Lowpass filter
%--------------------------------------------------------------------
cfg = [];
cfg.lpfilter = 'yes';
cfg.lpfreq = 150;

data_filt = ft_preprocessing(cfg, data_kchans);

% Save
%--------------------------------------------------------------------
OrigDataset = Dataset;
fprintf('Saving data.......');
save(Savename, 'data', 'data_filt', 'GoodChans', 'allart', 'BadChans', 'OrigDataset');
fprintf('Done\n')

