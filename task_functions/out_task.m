function out_task(SID, ts, sessionNumber, runNumber, ips, opts)
%
%
%  :: WORKING ON::
%       : Suhwan Gim ( Feb. 22. 2021)
%
%  :: Purpose of this study ::
%       : Participants will be told that you are going to experience
%       thermal stimulus
%
%   :: The things you should know on this functions
%       - This function is for running experimental paradigm for Suhwan's
%       project (disdaq = 10 secs)
%
%   :: Requirements for this experiments and fucntions ::
%    1) Latest version of PsychophysicsToolbox3
%    2) Pathway
%    3) Imaging Acquisitions Toolboxes in MATLAB
%
%   ====================================================================%
%   ** Usage **
%       main_task('EST001', 'fmri','test');
%   ** Input **
%       - SID: name of subject
%       - ts: trial sequencs
%       - runNumber
%   ** Optional Input **
%       - 'test': Lower reslutions. (1600 900 px)
%       - 'biopac'
%   ====================================================================
% Written by Suhwan Gim
%% SETUP: OPTIONS
testmode = opts.testmode;
doMRCam = opts.doFace;
doGetTrigger = opts.obs;
doBIOPAC = opts.biopac;
% for MY PC ip and port
% it is for sending trigger packet
fmri_ip = ips.fMRI_ip;
fmri_port = ips.fMRI_port;
%%
start_trial = 1;
%% SETUP: GLOBAL variables
global theWindow W H window_num;                  % window screen property
global white red red_Alpha orange bgcolor yellow; % set color
global window_rect lb rb tb bb scale_H            % scale size parameter
global fontsize;                                  % fontsize
global cir_center
global lb1 rb1 lb2 rb2;
global anchor_y anchor_y2 anchor anchor_xl anchor_xr anchor_yu anchor_yd anchor_lms anchor_lms_y anchor_lms_x; % anchors

%global Participant; % response box
%% SETUP: DATA and Subject INFO
savedir = fullfile(pwd, 'data');
[fname,trial_previous] = subjectinfo_check_SEP(SID.ObsID,savedir, sessionNumber,runNumber,'Obs'); % subfunction %start_trial

if exist(fname, 'file')
    % load previous dat files
    load(fname);
    start_trial = trial_previous; % start with this trial
else
    % generate and save data
    dat.ver= 'SEP_V001_May-13-2021_Suhwan';
    dat.subjects = SID;
    dat.datafile = fname; % filename
    dat.starttime = datestr(clock, 0); % date-time
    dat.starttime_getsecs = GetSecs; % in the same format of timestamps for each trial
    dat.session_number = sessionNumber;
    dat.runNumber = runNumber;
    dat.ts = ts; % trial sequences (predefiend)
    save(dat.datafile,'dat');
end
%% SETUP: BIOPAC
if doBIOPAC
    channel_n = 3;
    biopac_channel = 0;
    ljHandle = BIOPAC_setup(channel_n); % BIOPAC SETUP
end
%% SETUP: frame grabbber
if doMRCam
    global vid frame frame_idx video
    frame_idx = 1;
    frame = [];
    imaqreset;
    info=imaqhwinfo;
    vid = videoinput(info.InstalledAdaptors{1}, 1,'NTSC_M:RGB24 (640x480)' );
    video = VideoWriter(fullfile(savedir,'fMRI_VID',sprintf('fMRI_FACE_%s_SESS%02d_RUN%02d.mp4',SID.ExpID,sessionNumber,runNumber)),'MPEG-4'); %create the video object    
end
%% SETUP: getting trigger from fRMI experiment PC
if doGetTrigger
    tcpipClient = tcpip(fmri_ip, fmri_port);
    set(tcpipClient,'InputBufferSize',300);
    set(tcpipClient,'Timeout',1); %Waiting time in seconds to complete read and write operations
    fopen(tcpipClient);
    get(tcpipClient, 'BytesAvailable');
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
stimText = '+';
%% START: Screen
theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect);       % start the screen
Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');                  % text encoding
Screen('BlendFunction', theWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % For using transparent color e.g., alpha value of [R G B alpha]
Screen('TextSize', theWindow, fontsize);
Screen('TextFont', theWindow, font); % setting font
%% START: SCREEN FOR PARTICIPANTS
try
    %% INSTRUCTION before task
    while (1)
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('space'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_experiment;
        end
        display_expmessage('준비되었는지 체크해주세요 (Biopac and trigger). \n 모두 준비되었으면 SPACE BAR를 눌러주세요.'); % until space; see subfunctions
    end
    
    %% Wating trigger            
    dat.run_starttime = GetSecs;    
    % gap between 5 key push and the first stimuli (disdaqs: dat.disdaq_sec)    
    if doGetTrigger
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        DrawFormattedText(theWindow, double('싱크 중...'), 'center', 'center', white, [], [], [], 1.2); % 4 seconds
        Screen('Flip', theWindow);  
        
        %
        DataReceived =[];
        dat.get_trigger_wait_timestamp = GetSecs;    
        rawData = fread(tcpipClient,300/8,'double');
        dat.get_trigger_received_timestamp = GetSecs; % sync onset
        DataReceived = [DataReceived rawData];
        disp('received');
                       
    end
    
    %% PREP: do biopac
    % I guess it works on only Window OS
    if doBIOPAC
        bio_t = GetSecs;
        dat.biopac_triggertime = bio_t; %BIOPAC timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(bio_t, 2); % ADJUST THIS
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    %% ========================================================= %
    %                   TRIAL START
    % ========================================================== %
    dat.RunStartTime = GetSecs;
    for trial_i = start_trial:16 % start_trial:30
        %% PREP: START with getting MRcam
        if doMRCam
            temp_imgs=getsnapshot(vid);
            frame{frame_idx} = temp_imgs;
            writeVideo(video,temp_imgs);
            frame_idx = frame_idx +1;
        end
        
        % Start of Trial
        trial_t = GetSecs;
        dat.dat{trial_i}.TrialStartTimestamp = trial_t;
        % --------------------------------------------------------- %
        %         1. ITI (fixPoint)
        % --------------------------------------------------------- %
        DrawFormattedText(theWindow, double('+'), 'center', 'center', white, [], [], [], 1.2); % as exactly same as function fixPoint(trial_t, ttp , white, '+') % ITI
        Screen('Flip', theWindow);
        waitsec_fromstarttime_SEP(trial_t, ts.t{runNumber}{trial_i}.ITI);
        dat.dat{trial_i}.ITI_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         2. Estimating pain experience with doMRcam
        %               Continuous estimating
        % --------------------------------------------------------- %
        rec_i = 0;
        
        t=GetSecs;
        xc = [];
        yc = [];
        SetMouse(cir_center(1),cir_center(2));
        radius = ((12*W/18)-(6*W/18))/2; % radius
%         lb3 = 6*W/18; %
%         rb3 = 12*W/18; %s
        while true
            rec_i=rec_i+1;
            if (GetSecs - trial_t) >= (ts.t{runNumber}{trial_i}.ITI + 12)
                break;
            end
            dat.dat{trial_i}.webcam_timestamp(rec_i) = GetSecs-t;
            
            % IMAGE
            if doMRCam
                ima = getsnapshot(vid);
                writeVideo(video,ima);
                frame{frame_idx} = ima;                
                frame_idx = frame_idx + 1;
                %show webcam images on Screen
                tex1 = Screen('MakeTexture', theWindow, ima, [], [],[],[],[]);
                Screen('DrawTexture', theWindow,tex1 ,[], [5*W/18 1*H/18 13*W/18 9*H/18],[],[],[],[],[],[]);
            end
            % Get Mouse
            %rec=rec+1;
            [x,y,button] = GetMouse(theWindow);
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
            
            
            % Draw Scale
            draw_scale('overall_predict_semicircular_SEP');
            Screen('DrawDots', theWindow, [x y]', 20, [255 164 0 130], [0 0], 1);  %dif color
            Screen('Flip',theWindow);
            
            
            %dat.dat{trial_i}.ratings1_end_timestamp = GetSecs;
            dat.dat{trial_i}.ratings1_con_time_fromstart(rec_i,1) = GetSecs-t;
            dat.dat{trial_i}.ratings1_con_xy(rec_i,:) = [x-cir_center(1) cir_center(2)-y]./radius;
            dat.dat{trial_i}.ratings1_con_clicks(rec_i,:) = button;
            dat.dat{trial_i}.ratings1_con_r_theta(rec_i,:) = [curr_r/radius curr_theta/180]; %radius and degree?
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
        temp_ratings = get_ratings2(ts.t{runNumber}{trial_i}.rating1, ttp, trial_t); % get_ratings(rating_type, total_secs, start_t )
        
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
        temp_ratings = get_ratings2(ts.t{runNumber}{trial_i}.rating2, ttp, trial_t); % get_ratings(rating_type, total_secs, start_t )
        
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
    DrawFormattedText(theWindow, double('  '), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    % End BIOPAC
    if doBIOPAC
        dat.biopac_endtime = GetSecs;% biopac end timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(bio_t, 1);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    if doMRCam
        close(video);
        %dat.frame_grabber = frame;    
        frame = []; 
        frame_idx = 1; 
        % Remove the video input object from memory:
        delete(vid);
    end
    waitsec_fromstarttime(dat.RunEndTime, 2);
    save(dat.datafile, '-append', 'dat');
    waitsec_fromstarttime(GetSecs, 10);    
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
    % ERROR
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

global theWindow white bgcolor window_rect fontsize; % rating scale

if dofmri
    Run_start_text = double('참가자가 준비되었으면 이미징을 시작합니다 (s).');
else
    Run_start_text = double('참가자가 준비되었으면, r을 눌러주세요.');
end
msg = Run_start_text;
% display
DrawFormattedText2([double(sprintf('<size=%d><font=-:lang=ko><color=ffffff>',fontsize)) msg],'win',theWindow,'sx','center','sy','center','xalign','center','yalign','center');
Screen('Flip', theWindow);

end

function abort_experiment(varargin)

% ABORT the experiment
%
% abort_experiment(varargin)

str = 'Experiment aborted.';

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'error'}
                str = 'Experiment aborted by error.';
            case {'manual'}
                str = 'Experiment aborted by the experimenter.';
        end
    end
end


ShowCursor; %unhide mouse
Screen('CloseAll'); %relinquish screen control
disp(str); %present this text in command window

end

function waitsec_fromstarttime_SEP(starttime, duration)
% Using this function instead of WaitSecs()
% function waitsec_fromstarttime(starttime, duration)
global frame frame_idx vid

while true
    ima = getsnapshot(vid);
    frame{frame_idx} = ima;
    writeVideo(video,ima);
    frame_idx = frame_idx + 1;
    if GetSecs - starttime >= duration
        break;
    end
end

end

%% ------------------------------------------ %
%           TASK                              %
%  ------------------------------------------ %
function temp_ratings = get_ratings2(rating_type, total_secs, start_t )

global theWindow W H window_num;                  % window screen property
global white red red_Alpha orange bgcolor yellow; % set color
global window_rect lb rb tb bb scale_H            % scale size parameter
global lb1 rb1 lb2 rb2;
global cir_center
global frame frame_idx vid video 
global fontsize

%%
if contains(rating_type, 'Intensity')
    msg = '통증 세기';
elseif contains(rating_type, 'Unpleasantness')
    msg = '불쾌';
end


rec_i = 0;
start_while = GetSecs;
radius = (rb2-lb2)/2; % radius
SetMouse(cir_center(1),cir_center(2));
while GetSecs - start_t < total_secs
    % getting imgaes
    ima = getsnapshot(vid);
    frame{frame_idx} = ima;
    writeVideo(video,ima);    
    frame_idx = frame_idx + 1;
    
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
