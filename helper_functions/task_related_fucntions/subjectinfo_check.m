function [fname,start_trial,SID] = subjectinfo_check(SID, runNumber,savedir, varargin)

% Get subject information, and check if the data file exists?
%
% :Usage:
% ::
%     [fname, start_line, SID] = subjectinfo_check(savedir, run_number,varargin)
%
%
% :Inputs:
%
%   **savedir:**
%       The directory where you save the data
%
%
% ..
%    Copyright (C) 2017  Wani Woo (Cocoan lab)
% ..

%% Parse varargin
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
%             case {'Mot'}
%                 mot = true;
        end
    end
end
%%

% Get Subject ID
fprintf('\n');
% SID = input('Subject ID? ','s');

% check if the data file exists
fname = fullfile(savedir, [SID sprintf('_RUN%02d',runNumber) '_' date '.mat']); % 'SID_RUN001_2019-02-02.mat'

% What to do if the file exits?
if ~exist(savedir, 'dir')
    mkdir(savedir);
    whattodo = 1;
else
    if exist(fname, 'file')
        str = ['The Subject ' SID ' data file exists and not first trial. Press a button for the follwing options'];
        disp(str);
        whattodo = input('1:Replace, 2:Save the data from where we left off, Ctrl+C: Abort? ');
    else
        whattodo = 1;
    end
end

if whattodo == 2
    load(fname);
else
    start_trial = 1;
end

end