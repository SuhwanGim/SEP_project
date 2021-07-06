%% FIRST-SESSION
% Written by Suhwan Gim
%% SETTING: PATH
exp_dir = pwd; % ~/SEP_project
addpath(genpath(pwd));
%% SETTINGS: IP
% should put the PC Pathway's labtop IP and port
ip = '192.168.0.2';
port = 20121;
%% SETTINGS: Communication test
main(ip,port,1,76); %select the program 
WaitSecs(1);
main(ip,port,2); %ready to pre-start
WaitSecs(1);
main(ip,port,2); %START
% main(ip,port,5) <- close
%% SETTINGS: IDs
SID = 'TEST_GEONWOO';
%% SETTINGS: Options
testmode = 0;
%% ========================================================================
%
PainCalibration(SID, ip, port); % run calibration task 

% ========================================================================%
 