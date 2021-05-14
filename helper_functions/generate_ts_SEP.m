function ts = generate_ts_SEP(cond)

% ts = generate_ts_SEP

% total run = 6;
% total trial = 16;
rng('shuffle');


if contains(cond,'fMRI')
    % conditions
    % Per run
    S1{1} = repmat({'LV1'; 'LV2'; 'LV3'; 'LV4'}, 4, 1);  % stimulus intensity
    % Per trial
    T1{1} = repmat({'intensity','unpleasantness'},2,1);
    T2{2} = repmat({4,4,4}, {3,4,5},2,1);
    condname = 'fMRI';
elseif contains(cond,'obser')
    % Per trial
    T1{1} = repmat({'intensity','unpleasantness'},2,1);
    T2{2} = repmat({4,4,4}, {3,4,5},2,1);
    condname = 'observers';
else
    error('Please check the condition name')
end

%% shuffle
temp_int = [];
ts = [];
ts.cond_type = condname;
ts.time_generated = datestr(clock, 0);
for run_i = 1:6
    temp_int = S1{1}(randperm(16));
    
    temp_rating = [];
    temp_ISI = [];
    for trial_i = 1:16
        ts.t{run_i}{trial_i}.stimlv = temp(trial_i);
        
        temp_ISI = T2{1}(randperm(2));
        ts.t{run_i}{trial_i}.ITI = temp_ISI(1);
        ts.t{run_i}{trial_i}.ISI1 = temp_ISI(2);
        ts.t{run_i}{trial_i}.ISI2 = temp_ISI(3);
        
        temp_rating = T1{1}(randperm(2));
        ts.t{run_i}{trial_i}.rating1 = temp_rating(1);
        ts.t{run_i}{trial_i}.rating2 = temp_rating(2);
        
        
    end
end

disp('Trial sequences is generated');