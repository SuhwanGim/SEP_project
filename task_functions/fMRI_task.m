function fMRI_task(SID, ts, sessionNumber, runNumber, ips, opts)
%
%  :: WORKING ON::
%       : Suhwan Gim (suhwan.gim.psych@gmail.com)
%               Last updated (May. 13. 2021)
%
%  :: Purpose of this study ::
%       : Participants will be told that you are going to experience
%       thermal stimulus and report how you feel.
%
%       The aim of this study is to exmaine the extent to which observing
%       effects on pain expression.
%
%   :: The things you should know on this functions
%       - This function is for running experimental paradigm for Suhwan's
%       project (disdaq = 10 secs).
%
%       1) Thermal_stimulus
%       2) rating
%       3) displaying other's facial expression
%
%   :: Requirements for this experiments and fucntions ::
%       1) Latest version of PsychophysicsToolbox3
%       2) Recommeded version of Gstreamer (see help GStreamer)
%       3) Webcam (In this exp, Logi 1080p)
%       4) Pathway with ATS thermode
%       5) Imaging Acquisitions Toolboxes in MATLAB
%       6) Additional Webcam driver
%
%   ====================================================================%
%   ** Usage **
%
%   ** In singal **
%       - Scanner trigger
%       - obserber's webcam
%   ** Out singal **
%       - Scanner trigger to obs computer
%       - Pathway trigger to path computer
%   ** Optional Input **
%       - 'test': Lower reslutions. (1600 900 px)
%       - 'fmri': If you run this script in sMRI . This option can
%       receive 's' trigger from sync box.
%       - 'obs' : sent fMRI trigger to observer task computer
%       - 'pathway':
%       - 'webcam':
%
%   ====================================================================
%% SETUP: Check OPTIONS
% if (~isfield(opts,'dofmri')) | (~isfield(opts,'doBiopac'))  | (~isfield(opts,'testmode'))
%     error('Check options');
% end
%% SETUP: OPTIONS
testmode = opts.testmode;
dofmri = opts.dofmri;
doWebcam = opts.doFace;
doPathway = opts.Pathway;
doSendTrigger = opts.obs;
start_trial = 1;
% for pathway
ip = ips.pathway_IP;
port = ips.pathway_port;
% for MY PC ip and port
% it is for sending trigger packet
my_ip = ips.my_IP;
my_port = ips.my_port;

%% SETUP: GLOBAL variables
global theWindow W H window_num;                  % window screen property
global white red red_Alpha orange bgcolor yellow; % set color
global window_rect lb rb tb bb scale_H            % scale size parameter
global lb1 rb1 lb2 rb2;
global fontsize;                                  % fontsize
global anchor_y anchor_y2 anchor anchor_xl anchor_xr anchor_yu anchor_yd anchor_lms anchor_lms_y anchor_lms_x; % anchors
global cir_center
%global Participant; % response box
%% SETUP: DATA and Subject INFO
savedir = fullfile(pwd,'data');
% subfunction %start_trial
[fname,trial_previous] = subjectinfo_check_SEP(SID.ExpID, savedir, sessionNumber,runNumber, 'fMRI');

% Load calibration
load(fullfile(savedir, 'PainCali_data',sprintf('SEP_PainCali_data_Sub-%s_session01_run01.mat',SID.ExpID)),'reg');
if exist(fname, 'file')
    % load previous dat files
    load(fname);
    start_trial = trial_previous; % start with this trial
else
    % generate and save data
    dat.ver= 'SEP_V001_May-13-2021_Suhwan';
    dat.subjects = SID;     % subject name
    dat.datafile = fname;  % filename
    dat.starttime = datestr(clock, 0); % date-time
    dat.starttime_getsecs = GetSecs; % in the same format of timestamps for each trial
    dat.session_number = sessionNumber;
    dat.run_umber = runNumber;
    dat.ts = ts; % trial sequences (predefiend)
    save(dat.datafile,'dat');
end
%% SETUP: Webcam
if doWebcam
    CAMLIST = webcamlist;
    camObj = webcam(find(contains(CAMLIST,'HD'))); % The resoultion of webcam can be modified in WinOS
    %camObj.Resolution = {''};
end
%% SETUP: Load pathway program
path_prog = load_PathProgram('MPC');
for i = 1:numel(reg.FinalLMH_5Level)
    for ii = 1:length(path_prog)
        if reg.FinalLMH_5Level(i) == path_prog{ii,1}
            degree{i,1} = bin2dec(path_prog{ii,2});
        else
            %do nothing
        end
    end
end
stim_degree=cell2mat(degree);
%% SETUP: envrioemnt for set
if doSendTrigger
    %set TCP/IP environment    
    trg_dat = 100;
    trg_dat = im2double(trg_dat);
    s = whos('data');
    tcpipServer = tcpip(my_ip, my_port, 'NetworkRole','server');
    set(tcpipServer, 'OutputBufferSize',s.bytes);
end
%% SETUP: Screen size
Screen('Clear');
Screen('CloseAll');
window_num = 0;
Screen('Preference', 'SkipSyncTests', 1);
if testmode
    window_rect = [0 0 1600 900]; % in the test mode, use a little smaller screen [but, wide resoultions]
    fontsize = 32;
else
    screens = Screen('Screens');
    window_num = screens(end); % the last window
    window_info = Screen('Resolution', window_num);
    %window_rect = [0 0 1920 1080];
    window_rect = [0 0 window_info.width window_info.height]; % full screen
    fontsize = 36;
    HideCursor();
end
W = window_rect(3); %width of screen
H = window_rect(4); %height of screen


tb = H/5+100;           % in 800, it's 310
bb = H/2+100;           % in 800, it's 450, bb-tb = 340
scale_H = (bb-tb).*0.25;

anchor_xl = lb-80; % 284
anchor_xr = rb+20; % 916
anchor_yu = tb-40; % 170
anchor_yd = bb+20; % 710

% y location for anchors of rating scales -
anchor_y = H/2+10+scale_H;

% For rating scale
lb = 5*W/18;            % left bound
rb = 13*W/18;           % right bound

% For cont rating scale
lb1 = 1*W/18; %
rb1 = 17*W/18; %

% For overall rating scale
lb2 = 5*W/18; %
rb2 = 13*W/18; %s


cir_center = [(lb1+rb1)/2 H*3/4+100];

%% SETUP: Screen color
bgcolor = 80;
white = 255;
red = [255 0 0];
red_Alpha = [255 164 0 130]; % RGB + A(Level of tranceprency)
orange = [255 164 0];
yellow = [255 220 0];
%% SETUP: Screen parameters
font = 'NanumBarunGothic';
%font = 'D2Coding';
stimText = '+';
rating_type = 'semicircular';
%% START: Screen
theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect);       % start the screen
Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');                  % text encoding
Screen('BlendFunction', theWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % For using transparent color e.g., alpha value of [R G B alpha]
Screen('TextSize', theWindow, fontsize);
Screen('TextFont', theWindow, font); % setting font
%% START: SCREEN FOR PARTICIPANTS
try
    %% PREP: INSTRUCTION before task
    while (1)
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('space'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_experiment;
        end
        display_expmessage('실험자는 모든 것이 잘 준비되었는지 체크해주세요 (Biopac,trigger, USB, etc). \n 모두 준비되었으면 SPACE BAR를 눌러주세요.'); % until space; see subfunctions
    end
    
    while (1)
        % if this is for fMRI experiment, it will start with "s",
        % but if behavioral, it will start with "r" key.
        
        if dofmri
            [~,~,keyCode] = KbCheck; % experiment
            if keyCode(KbName('s'))==1 % get 's' from a sync box
                break
            elseif keyCode(KbName('q'))==1
                abort_experiment;
            end
        else % for behavior
            [~,~,keyCode] = KbCheck;
            if keyCode(KbName('r'))==1
                break
            elseif keyCode(KbName('q'))==1
                abort_experiment;
            end
        end
        display_runmessage(dofmri); % until 5 or r; see subfunctions
    end
    
    
    %% PREP: do fMRI (disdaq_sec = about 10)
    if dofmri
        dat.disdaq_sec = 10 + 8 ; % 18 TRs
        fmri_t = GetSecs;
        % gap between 5 key push and the first stimuli (disdaqs: dat.disdaq_sec)
        %Screen(theWindow, 'FillRect', bgcolor, window_rect);
        %DrawFormattedText(theWindow, double('시작합니다...'), 'center', 'center', white, [], [], [], 1.2); % 4 seconds
        display_expmessage('시작합니다...');
        Screen('Flip', theWindow);
    end            
    %% PREP: Wait 4 and 14 secs more 
    if dofmri
        dat.runscan_starttime = GetSecs;
        waitsec_fromstarttime(fmri_t, 4);
        
        % 4 seconds: Blank
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(fmri_t, dat.disdaq_sec); % ADJUST THIS
    end
    %% 
    % waitsec_fromstarttime(GetSecs, 8);
    %% PREP : send trigger to the observation computer
    if doSendTrigger
        dat.sendTriggerStart_timestamp = GetSecs;
        fopen(tcpipServer);
        fwrite(tcpipServer, trg_dat(:), 'double'); % send data
        fclose(tcpipServer);
        dat.sendTriggerEnd_timestamp = GetSecs;
    end
    %% ========================================================= %
    %                   TRIAL START
    % ========================================================== %
    dat.RunStartTime = GetSecs;
    for trial_i = start_trial:16 % length(ts.t{1})        
            
        % Trial begins
        trial_t = GetSecs;
        dat.dat{trial_i}.TrialStartTimestamp = trial_t;
        % --------------------------------------------------------- %
        %         1. ITI (fixPoint)
        % --------------------------------------------------------- %
        DrawFormattedText(theWindow, double('+'), 'center', 'center', white, [], [], [], 1.2); % as exactly same as function fixPoint(trial_t, ttp , white, '+') % ITI
        Screen('Flip', theWindow);
        if doPathway
            %-------------Ready for Pathway------------------
            main(ip,port,1,stim_degree(ts.t{runNumber}{trial_i}.stimlv+1)); %select the program
            WaitSecs(1);
            main(ip,port,2); %ready to pre-start
        end
        
        if doWebcam
            vidnames = fullfile(savedir,'OBS_VID',sprintf('vid_%s_R_%02d_T%02d_thermal_stim.mp4', SID.ObsID, runNumber, trial_i)); %  R00_T00_thermal_stim.mp4 
            video = VideoWriter(vidnames ,'MPEG-4'); %create the video object
            open(video); % open the file for writing
        end
        %-------------------------------------------------
        waitsec_fromstarttime(trial_t, ts.t{runNumber}{trial_i}.ITI);
        dat.dat{trial_i}.ITI_EndTime = GetSecs;
        %fixPoint(trial_t, ts.t{runNumber}{trial_i}.ITI, white, '+') % ITI
        
        
        % --------------------------------------------------------- %
        %         2. Thermal stimulus (thermal_stim)
        % --------------------------------------------------------- %
        % black screen
        Screen('Flip',theWindow); % black screen 
        if doPathway
            toc;
            dat.dat{trial_i}.heat_start_txt = main(ip,port,2); % start heat signal
            dat.dat{trial_i}.heat_onsets_timestamp = GetSecs;
            dat.dat{trial_i}.heat_trigger_duration = toc;
        end
        if doWebcam
            i=1;         % timestamp for video
            t = GetSecs;
            while true
                if (GetSecs - trial_t) >= (ts.t{runNumber}{trial_i}.ITI + 12)
                    break;
                end
                dat.dat{trial_i}.webcam_timestamp(i) = GetSecs-t;
                i=i+1;
                ima = snapshot(camObj);
                %ima = imresize(ima,0.5,'nearest');                % for low resolution?
                
                %write the image to file
                writeVideo(video,ima);
                
                %show webcam images on Screen
                tex1 = Screen('MakeTexture', theWindow, ima, [], [],[],[],[]);
                Screen('DrawTexture', theWindow,tex1 ,[], [5*W/18 5*H/18 13*W/18 13*H/18],[],[],[],[],[],[]);
                Screen('Flip', theWindow);
            end
            close(video)
        else
            DrawFormattedText(theWindow, double(''), 'center', 'center', white, [], [], [], 1.2); % as exactly same as function fixPoint(trial_t, ttp , white, '+') % ITI
            Screen('Flip', theWindow);
            waitsec_fromstarttime(trial_t, ts.t{runNumber}{trial_i}.ITI + 12); % From start + ITI + thermal (12 sec)
        end
        
        % --------------------------------------------------------- %
        %         3. ISI1
        % --------------------------------------------------------- %
        ttp = []; % total
        ttp = ts.t{runNumber}{trial_i}.ITI + 12 + ts.t{runNumber}{trial_i}.ISI1;
        fixPoint(trial_t, ttp , white, '+') % ITI
        dat.dat{trial_i}.ISI1_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         4. Ratings 1 (ratings)
        % --------------------------------------------------------- %
        ttp = ttp + 5;
        temp_ratings = [];
        temp_ratings = get_ratings(ts.t{runNumber}{trial_i}.rating1, ttp, trial_t); % get_ratings(rating_type, total_secs, start_t )
        
        dat.dat{trial_i}.ratings1_end_timestamp = GetSecs;
        dat.dat{trial_i}.ratings1_con_time_fromstart = temp_ratings.con_time_fromstart;
        dat.dat{trial_i}.ratings1_con_xy = temp_ratings.con_xy;
        dat.dat{trial_i}.ratings1_con_clicks = temp_ratings.con_clicks;
        dat.dat{trial_i}.ratings1_con_r_theta = temp_ratings.con_r_theta;
        
        
        % --------------------------------------------------------- %
        %         5. ISI2
        % --------------------------------------------------------- %
        ttp = ttp + ts.t{runNumber}{trial_i}.ISI2;
        fixPoint(trial_t, ttp , white, '+') % ISI2
        dat.dat{trial_i}.ISI2_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         6. Ratings 2
        % --------------------------------------------------------- %
        %fixPoint(trial_t, ts.ITI(trial_i,3), white, '+') % ITI
        ttp = ttp + 5;
        temp_ratings = [];
        temp_ratings = get_ratings(ts.t{runNumber}{trial_i}.rating2, ttp, trial_t); % get_ratings(rating_type, total_secs, start_t )
        
        dat.dat{trial_i}.ratings2_end_timestamp = GetSecs;
        dat.dat{trial_i}.ratings2_con_time_fromstart = temp_ratings.con_time_fromstart;
        dat.dat{trial_i}.ratings2_con_xy = temp_ratings.con_xy;
        dat.dat{trial_i}.ratings2_con_clicks = temp_ratings.con_clicks;
        dat.dat{trial_i}.ratings2_con_r_theta = temp_ratings.con_r_theta;
        
        % ------------------------------------ %
        %  End of trial (save data)
        % ------------------------------------ %
        dat.dat{trial_i}.TrialEndTimestamp=GetSecs;
        if mod(trial_i,2)
            save(dat.datafile, '-append', 'dat');
        end
    end
    
    %% FINALZING EXPERIMENT
    dat.RunEndTime = GetSecs;
    DrawFormattedText(theWindow, double(' '), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    
    waitsec_fromstarttime(dat.RunEndTime, 10);
    save(dat.datafile, '-append', 'dat');
    waitsec_fromstarttime(GetSecs, 2);
    %% END MESSAGE    
    str = '잠시만 기다려주세요 (space)';    
    display_expmessage(str);    
    while (1)
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('q'))==1
            break
        elseif keyCode(KbName('space'))== 1
            break
        end
    end        
    ShowCursor();
    Screen('Clear');    
    Screen('CloseAll');
catch err
    % print ERROR   
    disp(err);
    ShowCursor();
    for i = 1:numel(err.stack)
        disp(err.stack(i));
    end
    abort_experiment;
end
end % function end
%% ====================================================================== %
%                   IN-LINE FUNCTION                                      %
% ======================================================================= %

function display_runmessage(dofmri)

% MESSAGE FOR EACH RUN

% HERE: YOU CAN ADD MESSAGES FOR EACH RUN USING RUN_NUM and RUN_I

global theWindow white bgcolor window_rect; % rating scale

if dofmri
    Run_start_text = double('참가자가 준비되었으면 이미징을 시작합니다 (s).');
else
    Run_start_text = double('참가자가 준비되었으면, r을 눌러주세요.');
end
msg = Run_start_text;
% display
%Screen(theWindow,'FillRect',bgcolor, window_rect);
%DrawFormattedText(theWindow, Run_start_text, 'center', 'center', white, [], [], [], 1.5);
DrawFormattedText2([double(sprintf('<size=%d><font=-:lang=ko><color=ffffff>',fontsize)) msg],'win',theWindow,'sx','center','sy','center','xalign','center','yalign','center');
Screen('Flip', theWindow);

end



%% ------------------------------------------ %
%           TASK                              %
%  ------------------------------------------ %
function temp_ratings = get_ratings(rating_type, total_secs, start_t )

global theWindow W H window_num;                  % window screen property
global white red red_Alpha orange bgcolor yellow; % set color
global window_rect lb rb tb bb scale_H            % scale size parameter
global lb1 rb1 lb2 rb2;
global cir_center
%%
if contains(rating_type, 'Intensity')
    msg = '이번 자극이 얼마나 아팠나요?';
elseif contains(rating_type, 'Unpleasantness')
    msg = '이번 자극이 얼마나 불쾌했나요?';
end


rec_i = 0;
start_while = GetSecs;
radius = (rb2-lb2)/2; % radius
SetMouse(cir_center(1),cir_center(2));
while GetSecs - start_t < total_secs
    [x,y,button]=GetMouse(theWindow);
    rec_i= rec_i+1;
    % if the point goes further than the semi-circle, move the point to
    % the closest point
    
    theta = atan2(cir_center(2)-y,x-cir_center(1));
    % current euclidean distance
    curr_r = sqrt((x-cir_center(1))^2+ (y-cir_center(2))^2);
    % current angle (0 - 180 deg)
    curr_theta = rad2deg(-theta+pi);
    % For control a mouse cursor:
    % send to diameter of semi-circle
    if y > cir_center(2) %bb
        y = cir_center(2); %bb;
        SetMouse(x,y);
    end
    % send to arc of semi-circle
    if sqrt((x-cir_center(1))^2+ (y-cir_center(2))^2) > radius
        x = radius*cos(theta)+cir_center(1);
        y = cir_center(2)-radius*sin(theta);
        SetMouse(x,y);
    end
    
    msg = double(msg);
    %DrawFormattedText(theWindow, msg, 'center', 150, orange, [], [], [], 2);
    DrawFormattedText2([double(sprintf('<size=%d><font=-:lang=ko><color=ffffff>',fontsize)) msg],'win',theWindow,'sx','center','sy','center','xalign','center','yalign','center');
    draw_scale('overall_predict_semicircular');
    Screen('DrawDots', theWindow, [x y], 15, orange, [0 0], 1);
    Screen('Flip', theWindow);
    
    % recording
    temp_ratings.con_time_fromstart(rec_i,1) = GetSecs-start_while;
    temp_ratings.con_xy(rec_i,:) = [x-cir_center(1) cir_center(2)-y]./radius;
    temp_ratings.con_clicks(rec_i,:) = button;
    temp_ratings.con_r_theta(rec_i,:) = [curr_r/radius curr_theta/180]; %radius and degree?
    
    
    if button(1)
        draw_scale('overall_predict_semicircular');
        Screen('DrawDots', theWindow, [x y]', 18, red, [0 0], 1);  % Feedback
        Screen('Flip',theWindow);
        WaitSecs(min(0.5, 5-(GetSecs-start_while)));
        ready3=0;
        while ~ready3 %GetSecs - sTime> 5
            msg = double(' ');
            DrawFormattedText(theWindow, msg, 'center', 150, white, [], [], [], 1.2);
            Screen('Flip',theWindow);
            if  GetSecs - start_while > 5
                break
            end
        end
        break;
    else
        %do nothing
    end
    
end

end