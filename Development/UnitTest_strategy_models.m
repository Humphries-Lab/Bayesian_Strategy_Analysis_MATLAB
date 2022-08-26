% script to unit test strategy models
% latest version: 26/8/2022

clearvars; close all;

addpath ../Strategy_models/        % must add this path to access strategy models
addpath ../Functions/

% import test data CSV as Table
TestData = readtable('UnitTestData.csv','TextType','string');

% strategies to test
strategies = ["go_left", "go_right", "go_cued","go_uncued",...
                "win_stay_spatial","win_stay_cued","lose_shift_cued","lose_shift_spatial",...
                   "alternate","sticky"];

% storage
TestResults = array2table(zeros(height(TestData),numel(strategies)));  
TestResults.Properties.VariableNames = cellstr(strategies);

% run all strategy models on Table data
for iTrials = 1:height(TestData)
    row_data = TestData(1:iTrials,:);
    for index_strategy = 1:numel(strategies)
        charStrategy = char(strategies(index_strategy)); % cast as Char for old MATLAB < 2018

        % test current strategy model
        trial_type = evaluate_strategy(strategies(index_strategy),row_data);
        
        % compare to target result
        TestResults.(char(strategies(index_strategy)))(iTrials) = trial_type == TestData.(char(strategies(index_strategy))){iTrials};
    end
end

% report any errors
for index_strategy = 1:numel(strategies)
    disp([string(TestResults.Properties.VariableNames{index_strategy}) ' passed? ' string(all(TestResults.(char(strategies(index_strategy)))))])
end