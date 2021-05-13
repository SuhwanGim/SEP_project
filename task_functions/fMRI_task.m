function main_task1(SID, ts, runNumber, varargin)
%
%  :: WORKING ON::
%       : Suhwan Gim ( Feb. 22. 2021)
%
%  :: Purpose of this study ::
%       : Participants will be told that you are going to experience
%       thermal stimulus and interact with someone who can control the next
%       trial's thermal stimulus intensity. The aim of this study is to
%       exmaine observing the expression when given thermal stimulus. To
%       achieve this goal, the trial can be automatically or passiveley
%       determined by a person. In this phase, they will determine by
%       evaluedting your facial expression, physiological responses, and
%       pain ratings.
%
%   :: The things you should know on this functions
%       - This function is for running experimental paradigm for Suhwan's
%       project (disdaq = 10 secs).
%
%       1) Thermal_stimulus
%                           : various intensity will be incldued here
%       2) rating and interaction
%                               : report expression about pain stimulus and
%                               do interaction with experimenter
%       3) Feedback
%                   : display the experimenter's decision for the next
%                   trial
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
%       - 'fmri': If you run this script in sMRI . This option can
%       receive 's' trigger from sync box.
%       - 'biopac'
%   ====================================================================
% Written by Suhwan Gim
%% SETUP: DEFAULTS
testmode = false;
dofmri = false;
doBiopac = false;
doFace = false;
start_trial = 1;
%iscomp = 3; % default: macbook keyboard
%% SETUP: Parse varargin
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch lowser(varargin{i})
            case {'test','testmode'}
                testmode = true;
            case {'fmri','mri'}
                dofmri = true;
            case {'button_box'}
            case {'bio','biopac','biopack'}
                doBiopac = true;
                % IT IS FOR MAC-OS
                %             case {'macbook'}
                %                 iscomp = 3;
                %             case {'imac'}
                %                 iscomp = 1;
            otherwise
                disp('Unknown method.')
        end
    end
end


%% SETUP: GLOBAL variables
global theWindow W H window_num;                  % window screen property
global white red red_Alpha orange bgcolor yellow; % set color
global window_rect lb rb tb bb scale_H            % scale size parameter
global fontsize;                                  % fontsize
%global Participant; % response box
%% SETUP: DATA and Subject INFO
savedir = 'behavior_data';
[fname,trial_previous, ~] = subjectinfo_check(SID,runNumber,savedir); % subfunction %start_trial

if exist(fname, 'file')
    % load previous dat files
    load(fname);
    start_trial = trial_previous; % start with this trial
else
    % generate and save data
    dat.ver= 'SEP_V001_Feb-22-2021_Suhwan';
    dat.subject = SID;
    dat.datafile = fname; % filename
    dat.starttime = datestr(clock, 0); % date-time
    dat.starttime_getsecs = GetSecs; % in the same format of timestamps for each trial
    dat.runNumber = runNumber;
    dat.ts = ts; % trial sequences (predefiend)
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
            [~,~,keyCode] = KbCheck(scanner);                                  % ???????????????????????????????????????????????????
            [~,~,keyCode2] = KbCheck; % experiment
            if keyCode(KbName('s'))==1
                break
            elseif keyCode2(KbName('q'))==1
                abort_experiment;
            end
        else
            [~,~,keyCode] = KbCheck;
            if keyCode(KbName('r'))==1
                break
            elseif keyCode(KbName('q'))==1
                abort_experiment;
            end
        end
        display_runmessage(1, 1, dofmri); % until 5 or r; see subfunctions
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
    
    %% ========================================================= %
    %                   TRIAL START
    % ========================================================== %
    dat.RunStartTime = GetSecs;
    for trial_i = ((runNumber-1)*5+1):((runNumber)*5) % start_trial:30
                
        % Start of Trial
        trial_t = GetSecs;
        dat.dat{trial_i}.TrialStartTimestamp=trial_t;
        % --------------------------------------------------------- %
        %         1. ITI
        % --------------------------------------------------------- %
        fixPoint(trial_t, ts.ITI(trial_i,1), white, '+') % ITI
        dat.dat{trial_i}.ITI_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         2. MOVIE CLIP
        % --------------------------------------------------------- %
        %moive_files(trial_i) = fullfile(pwd,'examples1.mov');
        movie_files = ts.mv_name{trial_i};
        [starttime, endtime] = run_movie(movie_files);
        dat.dat{trial_i}.Movie_dura = endtime - starttime;
        dat.dat{trial_i}.Movie_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         3. ISI1  (ts.ITI(trial_i,2))
        % --------------------------------------------------------- %
        ttp = ts.ITI(trial_i,2) + ts.ITI(trial_i,1) + dat.dat{trial_i}.Movie_dura;
        fixPoint(trial_t, ttp , white, '+') % ITI
        dat.dat{trial_i}.ISI1_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         4. MATH PROBLEM
        % --------------------------------------------------------- %
        secs = 30;
        [dat.dat{trial_i}.math_response_keyCode, dat.dat{trial_i}.rt, dat.dat{trial_i}.Math_StartTime, dat.dat{trial_i}.Math_EndTime] ...
            = showMath(ts.math_img{trial_i}, ts.math_alt(trial_i,:), secs); % showMath(mathpath, secs, varargin)
        %dat.dat{trial_i}.Math_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         5. ISI2 ts.ITI(trial_i,3)
        % --------------------------------------------------------- %
        tts = ts.ITI(trial_i,3)  + ts.ITI(trial_i,2) + ts.ITI(trial_i,1) + dat.dat{trial_i}.Movie_dura + secs ;
        fixPoint(trial_t, tts , white, '+') % ITI
        dat.dat{trial_i}.ISI2_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         6. Resting-state
        % --------------------------------------------------------- %
        %fixPoint(trial_t, ts.ITI(trial_i,3), white, '+') % ITI
        resting_time(10);
        dat.dat{trial_i}.resting_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         7. ISI3 ts.ITI(trial_i,4)
        % --------------------------------------------------------- %
        tts = ts.ITI(trial_i,4) + ts.ITI(trial_i,3) + ts.ITI(trial_i,2) + ts.ITI(trial_i,1) + dat.dat{trial_i}.Movie_dura + secs + 10;
        fixPoint(trial_t, tts, white, '+') % ITI
        dat.dat{trial_i}.ISI3_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %         8. Short Quiz
        % --------------------------------------------------------- %
        [starttime, response , dura_t, endtime] = movie_quiz(ts.quiz_cond{trial_i});
        dat.dat{trial_i}.ShortQuiz_response = response;
        dat.dat{trial_i}.ShortQuiz_response_duration = dura_t;
        dat.dat{trial_i}.ShortQuiz_Dration = endtime - starttime;
        dat.dat{trial_i}.ShortQuiz_EndTime = GetSecs;
        % --------------------------------------------------------- %
        %         9. ISI4 (ts.ITI(trial_i,5))
        % --------------------------------------------------------- %
        tts = ts.ITI(trial_i,5) + ts.ITI(trial_i,4) + ts.ITI(trial_i,3) + ts.ITI(trial_i,2) + ts.ITI(trial_i,1) + dat.dat{trial_i}.Movie_dura + secs + 10;
        fixPoint(trial_t, tts, white, '+') % ITI
        dat.dat{trial_i}.ISI4_EndTime=GetSecs;
        
        % --------------------------------------------------------- %
        %        10. REPORT level of stress  (one to ten)
        % --------------------------------------------------------- %
        dat.dat{trial_i}.ReportStress_EndTime=GetSecs;
        
        % ------------------------------------ %
        %  End of trial (save data) 5 secs
        % ------------------------------------ %
        
        dat.dat{trial_i}.TrialEndTimestamp=GetSecs;
        save(dat.datafile, '-append', 'dat');
        %waitsec_fromstarttime(dat.dat{trial_i}.TrialEndTimestamp,5);
    end
    
    %% FINALZING EXPERIMENT
    dat.RunEndTime = GetSecs;
    DrawFormattedText(theWindow, double(stimText), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    
    waitsec_fromstarttime(dat.RunEndTime, 10);
    save(dat.datafile, '-append', 'dat');
    waitsec_fromstarttime(GetSecs, 2);
    %% END MESSAGE
    if runNumber == 6
        str = '실험이 종료되었습니다.\n 잠시만 기다려주세요 (space)';
    else
        str = '잠시만 기다려주세요 (space)';
    end
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

function display_runmessage(run_i, run_num, dofmri)

% MESSAGE FOR EACH RUN

% HERE: YOU CAN ADD MESSAGES FOR EACH RUN USING RUN_NUM and RUN_I

global theWindow white bgcolor window_rect; % rating scale

if dofmri
    if run_i <= run_num % you can customize the run start message using run_num and run_i
        Run_start_text = double('참가자가 준비되었으면 이미징을 시작합니다 (s).');
    end
else
    if run_i <= run_num
        Run_start_text = double('참가자가 준비되었으면, r을 눌러주세요.');
    end
end

% display
Screen(theWindow,'FillRect',bgcolor, window_rect);
DrawFormattedText(theWindow, Run_start_text, 'center', 'center', white, [], [], [], 1.5);
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

function display_expmessage(msg)
% diplay_expmessage("");
% type each MESSAGE

global theWindow white bgcolor window_rect; % rating scale

EXP_start_text = double(msg);

% display
Screen(theWindow,'FillRect',bgcolor, window_rect);
DrawFormattedText(theWindow, EXP_start_text, 'center', 'center', white, [], [], [], 1.5);
Screen('Flip', theWindow);

end

%% ------------------------------------------ %
%           TASK                              %
%  ------------------------------------------ %
function fixPoint(t_time, seconds, color, stimText)
% fixation point
global theWindow;
% stimText = '+';
% Screen(theWindow,'FillRect', bgcolor, window_rect);
DrawFormattedText(theWindow, double(stimText), 'center', 'center', color, [], [], [], 1.2);
Screen('Flip', theWindow);
waitsec_fromstarttime(t_time, seconds);
end


function giveStimulus
end


function getRatings
end


