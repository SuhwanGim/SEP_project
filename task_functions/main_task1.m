function main_task1(SID, ts, runNumber, varargin)
% 
%  :: WORKING ::
%
%   ** DESCRIPTION ** 
%
% This function is for running experimental paradigm for Suhwan's project.
% (disdaq = 10 secs).
%
%    1) Thermal_stimulus: Various level 
%    2) Rating and interactin(?): get expression for pain stimulus and do
%    interaction with experimenter
%    3) Feedback: display the experimenter's decision for neexct trials
%
%   ** Requirements **
%    1) Latest version PsychophysicsToolbox3
%    2) Pathway 
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
%       - 'fmri': If you run this script in MRI . This option can
%       receive 's' trigger from sync box.   
%   ====================================================================

%% Parse varargin
testmode = false;
dofmri = false;
doBiopac = false;
doFace = false; 
start_trial = 1;
%iscomp = 3; % default: macbook keyboard

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'test'}
                testmode = true;
            case {'fmri'}
                dofmri = true;
            case {'macbook'}
                iscomp = 3;
            case {'imac'}
                iscomp = 1;
            case {'button_box'}            
           
        end
    end
end

%% GLOBAL vaiable
global theWindow W H window_num; % window property
global white red red_Alpha orange bgcolor yellow; % color
global window_rect lb rb tb bb scale_H % rating scale
global fontsize;
global Participant; % response box
%% SETUP: DATA and Subject INFO
savedir = 'results_data';
[fname,~, SID] = subjectinfo_check(SID,runNumber,savedir); % subfunction %start_trial
if exist(fname, 'file'), load(fname); end

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


