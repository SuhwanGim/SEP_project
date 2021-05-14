%% SETTING: PATH
exp_dir = pwd; %project folder
addpath(genpath(pwd));
cd(pwd);
%% SETTINGS: IP
IP1 = ''; % Pathway
IP2 = ''; % Out-PC
%% SETTINGS: Communication test 
% 1. Pathway test
main();
% 2. Trigger test  
%% SETTINGS: Options
opts = [];
opts.testmode = 1;
opts.biopac = 1;
opts.fMRI = f;
opts.interaction = f; % communcating with others
opts.cams_fMRI = f;
opts.cams_Obs = f;
%% SETTINGS: IDs
ExpID = '';
ObsID = '';
%% generate ts
ts = generate_ts_SEP('fMRI');
sessionNumber = NaN;
%% START 
runnumber = 1;
fMRI_task(SID, ts, sessionNumber, runNumber, ip, port, opts)


