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
%       project (disdaq = 10 secs).
%
%       1) Thermal_stimulus
%                           : various intensity will be incldued here
%       2) rating
%                           : report expression about pain stimulus
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
dofmri = opts.dofmri;
doMRCam = opts.doFace;
doGetTrigger = opts.obs;
doBiopac = opts.biopac;
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
%global Participant; % response box
%% SETUP: DATA and Subject INFO
savedir = fullfile(pwd, 'data');
[fname,trial_previous, ~] = subjectinfo_check_SEP(SID.ObsID,savedir, sessionNumber,runNumber,'Obs'); % subfunction %start_trial

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
    dat.session_number = sessionNumbber;
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
    imaqreset;
    info=imaqhwinfo;
    vid = videoinput(info.InstalledAdaptors{1}, 1,'NTSC_M:RGB24 (640x480)' );
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
    window_rect = [0 0 1920 1080];
    %window_rect = [0 0 window_info.width window_info.height]; % full screen
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
    %% SETUP: biopac
    
    %% do fMRI (disdac_sec = 10)
    if dofmri
        dat.disdaq_sec = 10;
        fmri_t = GetSecs;
        % gap between 5 key push and the first stimuli (disdaqs: dat.disdaq_sec)
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        DrawFormattedText(theWindow, double('시작합니다...'), 'center', 'center', white, [], [], [], 1.2); % 4 seconds
        Screen('Flip', theWindow);
        dat.runscan_starttime = GetSecs;
        waitsec_fromstarttime(fmri_t, 4);
        
        % 4 seconds: Blank
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(fmri_t, dat.disdaq_sec); % ADJUST THIS
    end
    %% PREP: do biopac
    % I guess it works on only Window OS
    if doBiopac
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
    for trial_i = ((runNumber-1)*5+1):((runNumber)*5) % start_trial:30
        
        % Start of Trial
        trial_t = GetSecs;
        dat.dat{trial_i}.TrialStartTimestamp=trial_t;
        % --------------------------------------------------------- %
        %         1. ITI (fixPoint)
        % --------------------------------------------------------- %
        fixPoint(trial_t, ts.ITI(trial_i,1), white, '+') % ITI
        dat.dat{trial_i}.ITI_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         2. Estimating pain experience with doMRcam
        % --------------------------------------------------------- %
        %moive_files(trial_i) = fullfile(pwd,'examples1.mov');
        movie_files = ts.mv_name{trial_i};
        [starttime, endtime] = run_movie(movie_files);
        dat.dat{trial_i}.Movie_dura = endtime - starttime;
        dat.dat{trial_i}.Movie_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         3. ISI1  
        % --------------------------------------------------------- %
        ttp = ts.ITI(trial_i,2) + ts.ITI(trial_i,1) + dat.dat{trial_i}.Movie_dura;
        fixPoint(trial_t, ttp , white, '+') % ITI
        dat.dat{trial_i}.ISI1_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         4. Ratings 1 (ratings)
        % --------------------------------------------------------- %
        secs = 30;
        [dat.dat{trial_i}.math_response_keyCode, dat.dat{trial_i}.rt, dat.dat{trial_i}.Math_StartTime, dat.dat{trial_i}.Math_EndTime] ...
            = showMath(ts.math_img{trial_i}, ts.math_alt(trial_i,:), secs); % showMath(mathpath, secs, varargin)
        %dat.dat{trial_i}.Math_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         5. ISI2 
        % --------------------------------------------------------- %
        tts = ts.ITI(trial_i,3)  + ts.ITI(trial_i,2) + ts.ITI(trial_i,1) + dat.dat{trial_i}.Movie_dura + secs ;
        fixPoint(trial_t, tts , white, '+') % ITI
        dat.dat{trial_i}.ISI2_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         6. Ratings 2 
        % --------------------------------------------------------- %
        %fixPoint(trial_t, ts.ITI(trial_i,3), white, '+') % ITI
        resting_time(10);
        dat.dat{trial_i}.resting_EndTime=GetSecs;        
        
        % ------------------------------------ %
        %  End of trial (save data) 5 secs
        % ------------------------------------ %
        
        dat.dat{trial_i}.TrialEndTimestamp=GetSecs;
        save(dat.datafile, '-append', 'dat');
        
    end
    %% %End BIOPAC
    if doBiopac 
        dat.biopac_endtime = GetSecs;% biopac end timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(bio_t, 0.5);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    %% FINALZING EXPERIMENT
    dat.RunEndTime = GetSecs;
    DrawFormattedText(theWindow, double(stimText), 'center', 'center', white, [], [], [], 1.2);
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
%% ------------------------------------------ %
%           TASK                              %
%  ------------------------------------------ %



function giveStimulus
end


function getRatings
end


