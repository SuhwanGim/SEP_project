%% SETTING: PATH
exp_dir = pwd; %project folder
addpath(genpath(pwd));
cd(pwd);
%% SETTINGS: IP
IPs = []; 
IPs.pathway_IP = '192.168.0.2'; % Pathway
IPs.pathway_port = 20121;

IPs.my_IP = '0.0.0.0';      % Out-PC
IPs.my_port = 30000; % observer computer PORT
%% TEST: PATHWAY
main(IPs.pathway_IP ,IPs.pathway_port ,1,76); %select the program 
WaitSecs(1);
main(ip,port,2); %ready to pre-start
WaitSecs(1);
main(ip,port,2); %START
%% TEST: other behav PC
%IPs.my_IP 
%% SETTINGS: Options
opts = [];

opts.testmode = 0;    % do test mode (not full screens)
opts.dofmri = 1;        % do fMRI (get fMRI signal)
opts.obs = 1;         % do sending trigger to observer's computer 
opts.doFace = 1;      % get webcam mode
opts.Pathway = 1;     % do using pathway 
%% SETTINGS: IDs
% should be different
IDs.ExpID = 'TEST_LME';           % ID for fMRI scanner participants
IDs.ObsID = 'TEST_200714_Jihoon';           % ID for observer participants
%% generate ts
% This ts will be genereated before fMRI sessiosn for both estimating task and pain task. 
ts = generate_ts_SEP('fMRI'); 
%% sessionNumber
sessionNumber = 1; 
%% START WITH RESTING-state 

%% START 
runnumber = 1;
fMRI_task(IDs, ts, sessionNumber, runnumber, IPs, opts)

%%
runnumber = 2;
fMRI_task(IDs, ts, sessionNumber, runnumber, IPs, opts)
 
%%  
runnumber = 3;
fMRI_task(IDs, ts, sessionNumber, runnumber, IPs, opts)

%% 
runnumber = 4;
fMRI_task(IDs, ts, runnumber, IPs, opts)

%% 
runnumber = 5;
fMRI_task(IDs, ts, runnumber, IPs, opts)

%% 
runnumber = 6;
fMRI_task(IDs, ts, runnumber, IPs, opts)
%% See this scripts for next sessions
edit EXP_START_3RD_SES_rating_movies.m
% %% Movie runs 
% movie_number=1;
% movie_task(IDs, movie_number, opts)