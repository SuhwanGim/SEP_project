function movie_watch(SID, sessionNumber, opts)
%% Movie watching in a scanner without ratings 

%% Which movie?
switch sessionNumber
    case 11
        moviename = '';
        moviefiledir
    case 12
        moviename = '';
        moviefiledir
    case 21       
        moviename = '';
        moviefiledir
    case 22
        moviename = '';
        moviefiledir
    case 31
        moviename = '';
        moviefiledir
    case 32 
        moviename = '';
        moviefiledir
    otherwise
        error('ERROR');
end
%% SETUP: OPTIONS
testmode = opts.testmode;
dofmri = opts.dofmri;
doBiopac = opts.doBiopac;
doMRCam = opts.doFace;  % MR-compatible camera 
%iscomp = 3; % default: macbook keyboard
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
fname = subjectinfo_check_SEP(SID.ExpID, savedir, sessionNumber,run_number, 'movie_watch');
if exist(fname, 'file')
    % load previous dat files
    load(fname);    
else
    % generate and save data
    dat.ver= 'SEP_V001_Jun-23-2021_Suhwan';
    dat.subjects = SID;     % subject name
    dat.datafile = fname;  % filename
    dat.starttime = datestr(clock, 0); % date-time
    dat.starttime_getsecs = GetSecs; % in the same format of timestamps for each trial
    dat.session_number = sessionNumber;
    dat.moive_name = moviename; 
    dat.movie_dir = moviefiledir;
    save(dat.datafile,'dat');
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
%% SETUP: Webcam
if doMRCam
    %camObj = webcam; % The resoultion of webcam can be modified in WinOS
    %camObj.Resolution = {''};
end
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
        dat.disdaq_sec = 10; % 18 TRs
        fmri_t = GetSecs;
        % gap between 5 key push and the first stimuli (disdaqs: dat.disdaq_sec)
        display_expmessage('시작합니다...');
%         Screen(theWindow, 'FillRect', bgcolor, window_rect);
%         DrawFormattedText(theWindow, double('시작합니다...'), 'center', 'center', white, [], [], [], 1.2); % 4 seconds
        Screen('Flip', theWindow);
        dat.runscan_starttime = GetSecs;
        waitsec_fromstarttime(fmri_t, 4);
        
        % 4 seconds: Blank
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(fmri_t, dat.disdaq_sec); % ADJUST THIS
    end
    
    %% ========================================================= %
    %                   MOVIE START
    % ========================================================== %
    dat.RunStartTime = GetSecs;    
    [moviePtr,dur]=Screen('OpenMovie', theWindow, moviefiledir);
    Screen('PlayMovie', moviePtr, 1); %Screen('PlayMovie?')% 0 == Stop playback, 1 == Normal speed forward, -1 == Normal speed backward,
    %dur = 1;
    t = GetSecs;
    dat.dat.movie_start_timestamp = t;
    l = 0;
    while (GetSecs - t) < dur
        l = l+1;
        dat.dat.t_timestamp(l) = GetSecs;        
        % Wait for next movie frame, retrieve texture handle to it
        tex = Screen('GetMovieImage', theWindow, moviePtr);
        Screen('DrawTexture', theWindow, tex);
        % Valid texture returned? A negative value means end of movie reached:
        if tex<=0
            % We're done, break out of loop:
            break;
        end
                        
        % Update display:
        Screen('Flip', theWindow)
        Screen('Close', tex);         
    end    
    dat.dat.movie_end_timestamp = GetSecs;
    Screen('CloseMovie',moviePtr); % close movie     
    %% FINALZING EXPERIMENT
    dat.RunEndTime = GetSec;
    %DrawFormattedText(theWindow, double(' '), 'center', 'center', white, [], [], [], 1.2);
    %Screen('Flip', theWindow);
    display_expmessage('');
    
    waitsec_fromstarttime(dat.RunEndTime, 5);
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
    % ERROR
    disp(err);
    ShowCursor();
    for i = 1:numel(err.stack)
        disp(err.stack(i));
    end
    abort_experiment;
end

    