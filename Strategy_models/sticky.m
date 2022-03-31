function trial_type = sticky(trial_data)

% STICKY checks if subject chose same spatial option on consecutive trials
% TYPE = STICKY(TRIAL_DATA) takes the Table of data TRIAL_DATA up to the current trial, and
% returns the TYPE ('success','failure')
%
% Mark Humphries 31/3/2022

    
if trial_data.Choice(end) == trial_data.Choice(end-1)
    % chose same spatial option on consecutive trials, so is a success
    trial_type = "success";
else
    % chose a different option on this trial
    trial_type = "failure"; 
end
