% starter script to demonstrate Bayesian strategy analysis 
% - analyses one strategy (go left)
% - using data from one example rat from Peyrache Y-maze data-set
% 
% Mark Humphries 31/3/2022

clearvars; close all;

addpath ../Strategy_models/        % must add this path to access strategy models
addpath ../Functions/

load ../Processed_data/PeyracheDataTables.mat   % a struct PeyracheData containing 4 Tables as fields, one per rat
testData = PeyracheData.Rat_1;

%% choose type of prior
prior_type = "Uniform";

%% set decay rate: gamma parameter
decay_rate = 0.9;

%% initialise storage
Output.go_left = table;

%% define priors
[alpha0,beta0] = set_Beta_prior(prior_type);

%% main loop: for each trial, update strategy probability estimates
number_of_trials = numel(testData.TrialIndex);

% create storage
alpha = zeros(number_of_trials,1); beta = alpha; 
MAPprobability = zeros(number_of_trials,1); precision = MAPprobability;
old_MAPprobability = zeros(number_of_trials,1); old_precision = MAPprobability;
success_total = 0; failure_total = 0;  % initialise totals to zero

for index_trial = 1:number_of_trials
    % test strategy model
    trial_type = go_left(testData(1:index_trial,:));
    
    % update probability of strategy using original (alpha, beta) decay
    % versions
    if index_trial == 1  % use prior on the first trial
        [alpha(index_trial),beta(index_trial)] = old_update_strategy_posterior_probability(trial_type,decay_rate,alpha0,beta0);
    else  % otherwise posterior on trial t-1 becomes prior on trial t
        [alpha(index_trial),beta(index_trial)] = ...
            old_update_strategy_posterior_probability(trial_type,decay_rate,alpha(index_trial-1),beta(index_trial-1));
    end
    % compute estimators (MAP probability, and precision)
    old_MAPprobability(index_trial) = Summaries_of_Beta_distribution(alpha(index_trial),beta(index_trial),'MAP');
    old_precision(index_trial) = Summaries_of_Beta_distribution(alpha(index_trial),beta(index_trial),'Precision');

    % update using relax-to-prior version    
    [alpha(index_trial),beta(index_trial),success_total,failure_total] = ...
            update_strategy_posterior_probability(trial_type,decay_rate,success_total,failure_total,alpha0,beta0);
    
    MAPprobability(index_trial) = Summaries_of_Beta_distribution(alpha(index_trial),beta(index_trial),'MAP');
    precision(index_trial) = Summaries_of_Beta_distribution(alpha(index_trial),beta(index_trial),'Precision');
  
end

Output.go_left.alpha = alpha;
Output.go_left.beta = beta;
Output.go_left.old_MAPprobability = old_MAPprobability;
Output.go_left.old_precision = precision;

Output.go_left.MAPprobability = MAPprobability;
Output.go_left.precision = precision;

%% plot time-series of MAP probability estimates and precision

new_session_trials = find(testData.NewSessionTrials);
rule_change_trials = find(testData.RuleChangeTrials);
sequence_of_rules = [testData.TargetRule(1); testData.TargetRule(rule_change_trials)];

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules); hold on
plot(Output.go_left.MAPprobability);
plot(Output.go_left.old_MAPprobability,'k');
line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
xlabel('Trials'); ylabel('P(strategy)')

