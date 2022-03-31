function trial_type = lose_shift_cued(trial_data)

% LOSE_SHIFT_CUED checks if subject shifted from cued option again after no
% reward from choosing cued option
% TYPE = LOSE_SHIFT_CUED(TRIAL_DATA) takes the Table of data TRIAL_DATA up to the current trial, and
% returns the TYPE ('success','failure','null')
%
% Mark Humphries 31/3/2022

% default is that trial did not meet criteria for win-stay 
trial_type = "null";

% if chose cued option AND was NOT rewarded on the previous trial then
% candidate for lose-shift
if trial_data.Choice(end-1) == trial_data.CuePosition(end-1) && ...
        trial_data.Reward(end-1) == "no"
    if trial_data.Choice(end) ~= trial_data.CuePosition(end)       
        % and did NOT choose the cued option this time
        trial_type = "success";
    else
        % chose the cued option again this time
        trial_type = "failure"; 
    end
end
