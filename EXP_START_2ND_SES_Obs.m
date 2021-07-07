


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
  
%% SETTINGS: Options
opts = [];
opts.testmode = 0;    % do test mode (not full screens)
opts.doFace = 1;      % do getting MR participant's face 
opts.biopac = 0;      % do getting biocpac 
opts.obs = 0;         % do getting trigger to observer's computer 
opts.fmri_pc = '';
opts.fmri_pot = '';
opts.dofmri = 0;


%% SETTINGS: IDs
SID.ExpID = 'TEST_____';           % ID for fMRI scanner participants
SID.ObsID = 'TEST_SUHWAN222233333_210706';           % ID for observer participants
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
