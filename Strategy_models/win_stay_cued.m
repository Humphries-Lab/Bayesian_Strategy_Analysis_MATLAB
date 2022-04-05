function trial_type = win_stay_cued(trial_data)

% WIN_STAY_CUED checks if subject chose cued option again after a reward on
% cued option
% TYPE = WIN_STAY_CUED(TRIAL_DATA) takes the Table of data TRIAL_DATA up to the current trial, and
% returns the TYPE ('success','failure','null')
%
% Mark Humphries 31/3/2022

% default is that trial did not meet criteria for win-stay 
trial_type = "null";
number_trials = size(trial_data,1);

% if more than one trial, AND chose cued option AND was rewarded on the previous trial then candidate for win-stay
if number_trials > 1 && trial_data.Choice(end-1) == trial_data.CuePosition(end-1) && ... 
        trial_data.Reward(end-1) == "yes"
    if trial_data.Choice(end) == trial_data.CuePosition(end)       
        % and chose cued option this time
        trial_type = "success";
    else
        % chose the uncued option this time
        trial_type = "failure"; 
    end
end
