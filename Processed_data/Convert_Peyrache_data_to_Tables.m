% script to convert Peyrache et al data into Table for use in Bayesian 
% analysis toolbox examples
%
% Data is currently in matrix form, with columns:
% 1st column : Animal ID (from 1 to 4)
% 2nd column : Session (from 1 to 46)
% 3rd column : Direction (0=right, 1=left)
% 4th column : Reward (0=incorrect/no reward, 1=correct/reward)
% 5th column : Rule (1=go right, 2=go to the lit arm, 3=go left, 4=go to the dark arm)
% 6th column : Light (0=right, 1=left)
% (7) Session name (Rat_Month_Day)
% 8 : learning session - per trial (1/0)
%
% Target code will read one Table per subject; so this will create a struct
% of Tables, to contain all the data for the experiment
%
% Mark Humphries 31/3/2022

clearvars;
load  SummaryDataTable_AllSessions %% data file

%% create string arrays for conversion of numerical indices
rules = ["go right","go to the lit arm","go left","go to the dark arm"];
choices = ["right","left"];
light_positions = ["right","left"];
rewarded = ["no","yes"];

%% create one Table per rat
RatIDs = unique(Data(:,1));
nRats = numel(RatIDs);

for iR = 1:nRats
    
    % create empty table for this rat
    Table_name = ['Rat_' num2str(RatIDs(iR))];
    PeyracheData.(Table_name) = table;
    
    % get row indices of data matrix for all this rat's data
    row_indices = find(Data(:,1)==RatIDs(iR));
    nTrials = numel(row_indices);
    
    % create table columns
    PeyracheData.(Table_name).TrialIndex = [1:nTrials]';
    % session number of trial
    PeyracheData.(Table_name).SessionIndex = Data(row_indices,2);
    % enforced rule (give explicitly: look up rule numbers (1,2,3,4) in Data matrix
    % and use as indices into string array
    PeyracheData.(Table_name).TargetRule = rules(Data(row_indices,5))';
    % choice: convert to 'left', 'right': add 1 to encoded variable as is
    % (0,1)n
    PeyracheData.(Table_name).Choice = choices(Data(row_indices,3)+1)';
    % light:
    PeyracheData.(Table_name).CuePosition = light_positions(Data(row_indices,6)+1)';
    % reward: 'yes','no'
    PeyracheData.(Table_name).Reward = rewarded(Data(row_indices,4)+1)';
    
    % add metadata for ease of plotting and aligning later:
    % rule-change trials
    changes = zeros(nTrials,1);
    rules_sequence = Data(row_indices,5);
    PeyracheData.(Table_name).RuleChangeTrials = [0; diff(rules_sequence) ~= 0]; % first trial of new rule
    % session-change trials
    PeyracheData.(Table_name).NewSessionTrials = [0; diff(PeyracheData.(Table_name).SessionIndex)>0]; % first trial of new session    
end

save PeyracheDataTables PeyracheData