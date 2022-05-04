% script to demonstrate one approach to dealing with Null trials:
% constant interpolation
%
% Null trials are those in which a strategy could not be evaluated because
% its conditions were not met (e.g. a win-stay strategy cannot be evaluated
% on a trial following a loss trial).
% 
% Null trials are assigned NaNs for their alpha and beta values.
%
% Here we demonstrate the constant interpolation approach: all trials are assigned
% an alpha and beta value by giving any NaN trial the last updated value. 
% This is implemented in the function "interpolate_null_trials"
% 
%
% 4/5/2022

clearvars; close all;

addpath Strategy_models/        % must add this path to access strategy models
addpath Functions/

load Processed_data/PeyracheDataTables.mat   % a struct PeyracheData containing 4 Tables as fields, one per rat
testData = PeyracheData.Rat_2;

%% choose strategies to evaluate
% list of function names in Strategy_models/ folder - choosing here to use
% 2 exploratory strategies that cannot always be evaluated
strategies = ["win_stay_spatial","lose_shift_spatial"];

%% choose type of prior
prior_type = "Uniform";

%% set decay rate: gamma parameter
decay_rate = 0.9;

%% define priors
[alpha0,beta0] = set_Beta_prior(prior_type);

%% main loop: for each trial, update strategy probability estimates
number_of_trials = numel(testData.TrialIndex);
number_of_strategies = numel(strategies);

% create storage, using dynamic field names in struct
% struct Output will have a field per strategy
for index_strategy = 1:number_of_strategies
    charStrategy = char(strategies(index_strategy)); % cast as Char for old MATLAB < 2018
    Output.(charStrategy).alpha = zeros(number_of_trials,1);
    Output.(charStrategy).beta = zeros(number_of_trials,1);
    Output.(charStrategy).MAPprobability = zeros(number_of_trials,1);
    Output.(charStrategy).precision = zeros(number_of_trials,1);
    Output.(charStrategy).success_total = 0;
    Output.(charStrategy).failure_total = 0;
end

% loop over trials and update each
for index_trial = 1:number_of_trials
    for index_strategy = 1:number_of_strategies
        charStrategy = char(strategies(index_strategy)); % cast as Char for old MATLAB < 2018

        % test current strategy model
        trial_type = evaluate_strategy(strategies(index_strategy),testData(1:index_trial,:));

        % update its alpha, beta  
        [Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),Output.(charStrategy).success_total,Output.(charStrategy).failure_total] = ...
               update_strategy_posterior_probability(trial_type,decay_rate,Output.(charStrategy).success_total,Output.(charStrategy).failure_total,alpha0,beta0);
        % compute MAP and precision
        Output.(charStrategy).MAPprobability(index_trial) = Summaries_of_Beta_distribution(Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),'MAP');
        Output.(charStrategy).precision(index_trial) = Summaries_of_Beta_distribution(Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),'Precision');
    
    end
end


%% THE MAIN EVENT FOR THIS SCRIPT: function "interpolate_null_trials"
%% For any strategies with NaNs, interpolate the (alpha,beta) values

for index_strategy = 1:number_of_strategies
    charStrategy = char(strategies(index_strategy)); % cast as Char for old MATLAB < 2018
    % if alpha time-series has any NaNs, then interpolate
    if any(isnan(Output.(charStrategy).alpha))
        [Output.(charStrategy).alpha_interpolated,Output.(charStrategy).beta_interpolated,...
            Output.(charStrategy).MAPprob_interpolated,Output.(charStrategy).precision_interpolated] = ...
            interpolate_null_trials(Output.(charStrategy).alpha,Output.(charStrategy).beta,alpha0,beta0);
    end
end

%% plot the original and interpolated values

% information needed to plot the session structure
new_session_trials = find(testData.NewSessionTrials);
rule_change_trials = find(testData.RuleChangeTrials);
sequence_of_rules = [testData.TargetRule(1); testData.TargetRule(rule_change_trials)];

% compare the original and interpolated alpha values for lose-shift-spatial
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
plot(Output.lose_shift_spatial.alpha,'o','Color',[0.7 0.4 0.7]);
plot(Output.lose_shift_spatial.alpha_interpolated,'Color',[0.7 0.7 0.7]);
title('Lose-shift-spatial');
xlabel('Trials'); ylabel('alpha')

% compare the original and interpolated MAP probability values for win-stay-spatial
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules); hold on
% line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
plot(Output.win_stay_spatial.MAPprobability,'o','Color',[0.7 0.4 0.7]);
plot(Output.win_stay_spatial.MAPprob_interpolated,'Color',[0.7 0.7 0.7]);
title('Win-stay-spatial');
xlabel('Trials'); ylabel('P(strategy)')

% compare the original and interpolated MAP probability values for lose-shift-spatial
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules); hold on
% line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
plot(Output.lose_shift_spatial.MAPprobability,'o','Color',[0.7 0.4 0.7]);
plot(Output.lose_shift_spatial.MAPprob_interpolated,'Color',[0.7 0.7 0.7]);
title('Lose-shift-spatial');
xlabel('Trials'); ylabel('P(strategy)')