


%%
%% SETTING: PATH
exp_dir = pwd; %project folder
addpath(genpath(pwd));
cd(pwd);
%% SETTINGS: IP
IPs = []; 
IPs.fMRI_ip = ''; % Out-PC
IPs.fMRI_port = '';
%% SETTINGS: Communication test 
% 1. Pathway test
main();
% 2. Trigger test  
%% SETTINGS: Options
opts = [];
opts.testmode = 1;    % do test mode (not full screens)
opts.doFace = 0;      % do getting MR participant's face 
opts.biopac = 0;      % do getting biocpac 
opts.obs = 0;         % do getting trigger to observer's computer 
opts.fmri_pc = '';
opts.fmri_pot = '';


%% SETTINGS: IDs
IDs.ExpID = '';           % ID for fMRI scanner participants
IDs.ObsID = '';           % ID for observer participants
%% generate ts
ts = generate_ts_SEP('obser'); % generate trial sequences 
%% START 
% runnumber = 1;
% out_task(IDs, ts, runNumber, IPs, opts)

%%
runnumber = 2;
out_task(IDs, ts, runNumber, IPs, opts)

%%  
runnumber = 3;
out_task(IDs, ts, runNumber, IPs, opts)

%% 
runnumber = 4;
out_task(IDs, ts, runNumber, IPs, opts)

%% 
runnumber = 5;
out_task(IDs, ts, runNumber, IPs, opts)

%% 
runnumber = 6;
out_task(IDs, ts, runNumber, IPs, opts)