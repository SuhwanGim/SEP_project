%% SETTING: PATH
exp_dir = pwd; %project folder
addpath(genpath(pwd));
cd(pwd);
%% SETTINGS: IP
IPs = []; 
IPs.IP_path = ''; % Pathway
IPs.port_path = '';

IPs.IP_obs = ''; % Out-PC
IPs.port_obs = '';
%% SETTINGS: Communication test
main(ip,port,1,76); %select the program 
WaitSecs(1);
main(ip,port,2); %ready to pre-start
WaitSecs(1);
main(ip,port,2); %START
%% SETTINGS: Options
opts = [];
opts.testmode = 1;    % do test mode (not full screens)
opts.fMRI = 0;        % do fMRI (get fMRI signal)
opts.obs = 0;         % do sending trigger to observer's computer 
opts.doFace = 0;      % do webcam mode
opts.Pathway = 0;     % do using pathway 
%% SETTINGS: IDs
IDs.ExpID = '';           % ID for fMRI scanner participants
IDs.ObsID = '';           % ID for observer participants
%% generate ts
% This ts will be genereated before fMRI sessiosn for both estimating task and pain task. 
% ts = generate_ts_SEP('fMRI'); 
%% START 
runnumber = 1;
fMRI_task(IDs, ts, runnumber, IPs, opts)

%%
runnumber = 2;
fMRI_task(IDs, ts, runnumber, IPs, opts)

%%  
runnumber = 3;
fMRI_task(IDs, ts, runnumber, IPs, opts)

%% 
runnumber = 4;
fMRI_task(IDs, ts, runnumber, IPs, opts)

%% 
runnumber = 5;
fMRI_task(IDs, ts, runnumber, IPs, opts)

%% 
runnumber = 6;
fMRI_task(IDs, ts, runnumber, IPs, opts)

%% Movie runs 
movie_number=1;
movie_task(IDs, movie_number, opts)