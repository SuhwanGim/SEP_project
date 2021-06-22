function PainCalibration(SID, ip, port, varargin)
%%INFORMATION
% This function is for finding each participant's a pain space. There are
% sub-fucntions and cali_regression function. This functino is for
% calculating a linear line.
% : A calibraition for heat-pain machine
%
% Last updated 2021. May 25, Suhwan Gim
%
% See also cali_regression

%%
%% Parse varargin
testmode = false;
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'test'}
                testmode = true;
        end
    end
end
%% Global variable
global theWindow W H; % window property
global white red orange bgcolor; % color
global window_rect prompt_ex lb rb tb bb scale_H promptW promptH; % rating scale
global lb1 rb1 lb2 rb2;% % For larger semi-circular
global fontsize anchor_y anchor_y2 anchor anchor_xl anchor_xr anchor_yu anchor_yd; % anchors
global reg; % regression data
%% SETUP: DATA and Subject INFO
savedir = fullfile(pwd,'data');
[fname, start_trial] = subjectinfo_check_SEP(SID, savedir,1,1,'Calibration'); % subfunction %start_trial
% save data using the canlab_dataset object
reg.version = 'SEP_Calibration_v1_25-05-2021_Cocoanlab';
reg.subject = SID;
reg.datafile = fname;
reg.starttime = datestr(clock, 0); % date-time
reg.starttime_getsecs = GetSecs; % in the same format of timestamps for each trial
%% SETUP: SCREEN
Screen('Clear');
Screen('CloseAll');
window_num = 0;
if testmode
    window_rect = [1 1 1280 720]; % in the test mode, use a little smaller screen
    fontsize = 20;
else
    screens = Screen('Screens');
    window_num = screens(end); % the last window
    Screen('Preference', 'SkipSyncTests', 1);
    window_info = Screen('Resolution', window_num);
    window_rect = [0 0 window_info.width window_info.height]; % full screen
    fontsize = 32;
    HideCursor();
end
W = window_rect(3); %width of screen
H = window_rect(4); %height of screen

font = 'NanumBarunGothic';

bgcolor = 80;
white = 255;
red = [255 0 0];
orange = [255 164 0];
yellow = [255 220 0];

% rating scale left and right bounds 1/5 and 4/5
lb = 1.5*W/5; % in 1280, it's 384
rb = 3.5*W/5; % in 1280, it's 896 rb-lb = 512

% For cont rating scale
lb1 = 1*W/18; %
rb1 = 17*W/18; %

% For overall rating scale
lb2 = 5*W/18; %
rb2 = 13*W/18; %s


% rating scale upper and bottom bounds
tb = H/5+100;           % in 800, it's 310
bb = H/2+100;           % in 800, it's 450, bb-tb = 340
scale_H = (bb-tb).*0.25;

anchor_xl = lb-80; % 284
anchor_xr = rb+20; % 916
anchor_yu = tb-40; % 170
anchor_yd = bb+20; % 710

% y location for anchors of rating scales -
anchor_y = H/2+10+scale_H;
% anchor_semic = [0.1000 0.2881 0.5966 0.9000] % adjusted for SEMIC
% anchor_lms = [0.014 0.061 0.172 0.354 0.533].*(rb-lb)+lb; for VAS

%% SETUP: Parameter
% number of motor practice trial % based on number of skin sites
NumOfTr = 18;
stimText = '+';
init_stim = {'00101111' '00111001' '01000011'}; % Initial degrees of a heat pain [43.4 45.4 47.4] % SEMIC

start_value =1;
% save FIRST
save(reg.datafile,'reg','init_stim');
%%
% cir_center = [(rb+lb)/2, bb];
% radius = (rb-lb)/2; % radius
cir_center = [(lb2+rb2)/2, H*3/4+100];
radius = (rb2-lb2)/2;

deg = 180-normrnd(0.5, 0.1, 20, 1)*180; % convert 0-1 values to 0-180 degree
deg(deg > 180) = 180;
deg(deg < 0) = 0;
th = deg2rad(deg);
% x = radius*cos(th)+cir_center(1);
% y = cir_center(2)-radius*sin(th);
%% SETUP: the pathway program
PathPrg = load_PathProgram('MPC');
%% Setup: generate sequence of skin site and LMH (Low, middle and high)
rng('shuffle');
reg.skin_site = zeros(NumOfTr,1);

reg.skin_LMH = repmat(1:3, 6,1)';
reg.skin_LMH = reg.skin_LMH(:);

reg.skin_site = zeros(NumOfTr,1);
for i = 1:3
    reg.skin_site(reg.skin_LMH == i) = [randperm(3) randperm(3)];
end
for i = 1:6
    idx = (i-1) * 3+1:(i-1) * 3+ 3;
    rand_num = randperm(3);
    
    temp_LMH = reg.skin_LMH(idx);
    temp_SKIN = reg.skin_site(idx);
    
    reg.skin_site(idx) = temp_SKIN(rand_num);
    reg.skin_LMH(idx) = temp_LMH(rand_num);
    
end
%% START: Screen
theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect); % start the screen
Screen('BlendFunction', theWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % For alpha value of e.g.,[R G B alpha]
Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
%Screen('TextFont', theWindow, font); % setting font
Screen('TextSize', theWindow, fontsize);
%% START: Experiment
try
    if start_trial == 1
        %% PART0. Washout trials for each skin sites and scale explanation 
        % 1. pathwaty test
        pathway_test(ip, port, 'SEP_basic');
        
        % 2. Moving dot part        
        % -1.1. Fixation point
        
        fixPoint(GetSecs, 2, white, stimText);
        % -1.2. Moving dot part
        ready = 0;
               
        x=[]; y=[];
        moving_start_timestamp = GetSecs;
        SetMouse(cir_center(1), cir_center(2));
        while GetSecs - moving_start_timestamp < 10
            while ~ready                
                [x,y,button]=GetMouse(theWindow);                                
                draw_scale('overall_predict_semicircular');
                Screen('DrawDots', theWindow, [x y]', 14, [255 164 0 130], [0 0], 1);  % Cursor
                % if the point goes further than the semi-circle, move the point to
                % the closest point
                radius = (rb2-lb2)/2;%radius = (rb-lb)/2; % radius
                theta = atan2(cir_center(2)-y,x-cir_center(1));
                if y > cir_center(2) %bb
                    y = cir_center(2);
                    SetMouse(x,y);
                end
                % send to arc of semi-circle
                if sqrt((x-cir_center(1))^2+ (y-cir_center(2))^2) > radius
                    x = radius*cos(theta)+cir_center(1);
                    y = cir_center(2)-radius*sin(theta);
                    SetMouse(x,y);
                end
                Screen('Flip',theWindow);
                
                if button(1)                    
                    draw_scale('overall_predict_semicircular');
                    Screen('DrawDots', theWindow, [x y]', 18, red, [0 0], 1);  % Feedback
                    Screen('Flip',theWindow);
                    WaitSecs(.5);
                    ready = 1;
                    break;
                end
            end
            fixPoint(GetSecs,0, white, '');
            Screen('Flip', theWindow);
        end        
    end    
    start_value = start_trial;   
    %% PART1. Calibrtaion
    % 0. Instructions
    display_expmessage('지금부터는 캘리브레이션을 시작하겠습니다.\n참가자는 편안하게 계시고 진행자의 지시를 따라주시기 바랍니다.');
    WaitSecs(3);
    random_value = randperm(3); %randomized order for 1st, 2nd and 3rd stimulus
    for i=start_value:NumOfTr %Total trial
        reg.trial_start_timestamp{i,1}=GetSecs; % trial_star_timestamp
        % manipulate the current stim
        if i<4 %first three trials
            current_stim=bin2dec(init_stim{random_value(i)});
        else
            % current_stim=reg.cur_heat_LMH(i,rn); % random
            for iiii=1:length(PathPrg) %find degree
                if reg.cur_heat_LMH(i,reg.skin_LMH(i)) == PathPrg{iiii,1}
                    current_stim = bin2dec(PathPrg{iiii,2});
                else
                    % do nothing
                end
            end
        end
        
        % 1. Display where the skin site stimulates (1-3)
        WaitSecs(2);
        main(ip,port,1,current_stim); % Select the program
        WaitSecs(1);
        main(ip,port,2,current_stim); % Pre-start
        msg = strcat('연구자는 다음 위치의 열패드를 이동하신 후 SPACE 키를 누르십시오 :  ', num2str(reg.skin_site(i)));
        while (1)
            [~,~,keyCode] = KbCheck;
            if keyCode(KbName('space'))==1
                break;
            elseif keyCode(KbName('q'))==1
                abort_experiment;
            end
            display_expmessage(msg);
        end
        
        % 2. Fixation
        start_fix = GetSecs; % Start_time_of_Fixation_Stimulus
        DrawFormattedText(theWindow, double(stimText), 'center', 'center', white , [], [], [], 1.2);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(start_fix, 2);
        
        % 3. Stimulation
        start_while=GetSecs;
        ready=0;
        while GetSecs - start_while < 12.5 % same as the test,
            Screen('Flip', theWindow);
            if ~ready
                main(ip,port,2); % start thermal pain
                ready=1;
            end
        end
        
        % Fixation
        start_fix = GetSecs; % Start_time_of_Fixation_Stimulus
        DrawFormattedText(theWindow, double(stimText), 'center', 'center', white , [], [], [], 1.2);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(start_fix, 2);
        
        % 4. Ratings
        start_ratings=GetSecs;
        SetMouse(cir_center(1), cir_center(2));
        x=cir_center(1); y=cir_center(2);
        
        while GetSecs - start_ratings < 10 % Under 10 seconds,            
            
            [x,y,button]=GetMouse(theWindow);                       
            msg = double('얼마나 아팠나요?');
            Screen('TextSize', theWindow, fontsize);
            DrawFormattedText(theWindow, msg, 'center', 1/2*H-100, white, [], [], [], 2);
            draw_scale('overall_predict_semicircular');
            Screen('DrawDots', theWindow, [x y]', 14, [255 164 0 130], [0 0], 1);  %dif color
            
            % if the point goes further than the semi-circle, move the
            % point to the closest point
            radius = (rb2-lb2)/2; %radius = (rb-lb)/2; % radius
            theta = atan2(cir_center(2)-y,x-cir_center(1));
            if y > cir_center(2) %bb
                y = cir_center(2);
                SetMouse(x,y);
            end
            % send to arc of semi-circle
            if sqrt((x-cir_center(1))^2+ (y-cir_center(2))^2) > radius
                x = radius*cos(theta)+cir_center(1);
                y = cir_center(2)-radius*sin(theta);
                SetMouse(x,y);
            end
            
            Screen('Flip',theWindow);
            
            % Feedback
            if button(1)
                draw_scale('overall_predict_semicircular');
                Screen('DrawDots', theWindow, [x y]', 18, red, [0 0], 1);  % Feedback
                Screen('Flip',theWindow);
                WaitSecs(1);
                break; % break for "if"
            end
        end
        while GetSecs - start_ratings < 10
            if button(1)
                Screen('Flip',theWindow);
            end
        end
        
        % 5. Inter-stimulus inteval, 3 seconds
        start_fix = GetSecs; % Start_time_of_Fixation_Stimulus
        DrawFormattedText(theWindow, double(stimText), 'center', 'center', white, [], [], [], 1.2);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(start_fix, 3);
        
        theta = rad2deg(theta);
        theta = 180-theta;
        vas_rating = theta/180*100; % [0 180] to [0 100]
        
        for iii=1:length(PathPrg) %find degree
            if str2double(dec2bin(current_stim)) == str2double(PathPrg{iii,2})
                degree = PathPrg{iii,1};
            else
                % do nothing
            end
        end
        
        %Calculating regression line
        reg.trial_end_timestamp{i,1}=GetSecs;
        cali_regression (degree, vas_rating, i, NumOfTr); % cali_regression (stim_degree in this trial, rating, order of trial, Number of Trial)
        save(reg.datafile, '-append', 'reg');
    end %trial
    
    
    
    % End of calibration
    %reg.stduySkinSite_ts = [reg.stduySkinSite reg.stduySkinSite];
    reg.endtime_getsecs = GetSecs;
    
    reg.skinSite_rs = [0,0,0,0,0,0];
    
    
    while ~((numel(find(diff(reg.skinSite_rs)==0))) < 1)
        rng('shuffle');
        reg.skinSite_rs = [reg.studySkinSite reg.studySkinSite];
        reg.skinSite_rs=reg.skinSite_rs(randperm(6));
    end
    
    
    save(reg.datafile, '-append', 'reg');
    msg='캘리브레이션이 종료되었습니다\n이제 연구자의 지시를 따라주시기 바랍니다';
    display_expmessage(msg);
    waitsec_fromstarttime(reg.endtime_getsecs, 10);
    sca;
    ShowCursor();
    Screen('CloseAll');
    
    % disp(best skin site)
    % disp(reg.studySkinSite);
    %
    % ---------------------------------------------------------------------
    % IF Rsquared value of fitted line was below 0.4, display this message
    % This value is our criteria for screen experiment .
    % ---------------------------------------------------------------------
    if reg.total_fit.Rsquared.Ordinary <= 0.4
        disp("===================WARNING=======================");
        disp("=================================================");
        disp("PLEASE, check calibration data carefully.");
        disp("This participant may inappripriate for pain experiment");
        disp("=================================================");
    end
    
    
catch err
    % ERROR
    disp(err);
    for i = 1:numel(err.stack)
        disp(err.stack(i));
    end
    abort_experiment;
end
end

