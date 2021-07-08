


%%
%% SETTING: PATH
exp_dir = pwd; %project folder
addpath(genpath(pwd));
cd(pwd);
%% SETTINGS: IP
IPs = []; 
IPs.fMRI_ip = '192.168.0.3'; % Out-PC
IPs.fMRI_port = 30000;
%% SETTINGS: Communication test 
% 1. Pathway test
%main();
  
%% SETTINGS: Options
opts = [];
opts.testmode = 1;    % do test mode (not full screens)
opts.doFace = 1;      % do getting MR participant's face 
opts.biopac = 0;      % do getting biocpac 
opts.obs = 1;         % do getting trigger to observer's computer 
opts.fmri_pc = IPs.fMRI_ip;
opts.fmri_pot = IPs.fMRI_port;



%% SETTINGS: IDs
SID.ExpID = 'TEST_210707_Suhwan';           % ID for fMRI scanner participants
SID.ObsID = 'TEST_210707_Suhwan2';           % ID for observer participants
%% generate ts
ts = generate_ts_SEP('fMRI'); % generate trial sequences 
% ts should be made before fMRI experiments 
sessionNumber = 1;
%% START 
runNumber = 1;
out_task(SID, ts, sessionNumber, runNumber, IPs, opts)
%out_task(IDs, ts, runNumber, IPs, opts)

%%
runNumber = 2;
out_task(SID, ts, sessionNumber, runNumber, IPs, opts)

%%  
runNumber = 3;
out_task(SID, ts, sessionNumber, runNumber, IPs, opts)

%% 
runNumber = 4;
out_task(SID, ts, sessionNumber, runNumber, IPs, opts)

%% 
runNumber = 5;
out_task(SID, ts, sessionNumber, runNumber, IPs, opts)

%% 
runNumber = 6;
out_task(SID, ts, sessionNumber, runNumber, IPs, opts)

%%
