


%% EXTRA EXPERIMENTS 
% report their experience and evaluations for each movie 
%% SETTING: PATH
exp_dir = pwd; %project folder
addpath(genpath(pwd));
cd(pwd);

%% SETTINGS: Options
opts = [];
opts.testmode = 1;    % do test mode (not full screens)
%% SETTINGS: IDs
IDs = '';           % ID for fMRI scanner participants
%% SETTINGS: 
moive_idx= 99999;
%% START 
% runnumber = 1;
% out_task(IDs, ts, runNumber, IPs, opts)

movie_watch(SID, moive_idx, opts)