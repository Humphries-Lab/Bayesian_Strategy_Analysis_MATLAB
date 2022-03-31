function trial_type = alternate(trial_data)

% ALTERNATE checks if subject chose different spatial options on consecutive trials
% TYPE = ALTERNATE(TRIAL_DATA) takes the Table of data TRIAL_DATA up to the current trial, and
% returns the TYPE ('success','failure')
%
% Mark Humphries 31/3/2022

    
if trial_data.Choice(end) ~= trial_data.Choice(end-1)
    % chose different spatial option on consecutive trials, so is a success
    trial_type = "success";
else
    % chose the same option on consecutive trials
    trial_type = "failure"; 
end
