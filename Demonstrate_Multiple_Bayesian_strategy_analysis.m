% starter script to demonstrate Bayesian strategy analysis 
% - analyses one strategy (go left)
% - using data from one example rat from Peyrache Y-maze data-set
% 
% Mark Humphries 31/3/2022

clearvars; close all;

addpath Strategy_models/        % must add this path to access strategy models

load Processed_data/PeyracheDataTables.mat   % a struct PeyracheData containing 4 Tables as fields, one per rat

%% choose set of strategies to analyse
% string names used here must match the function names in the Strategy_models/
% folder


%% choose type of prior
prior_type = "Uniform";

%% set decay rate: gamma parameter
decay_rate = 0.9;

%% initialise storage
Output.go_left = table;

%% define priors
[alpha0,beta0] = set_Beta_prior(prior_type);

%% main loop: for each trial, update strategy probability estimates
number_of_trials = numel(PeyracheData.Rat_1.TrialIndex);
alpha = zeros(number_of_trials,1); beta = alpha; MAPprobability = alpha; precision = alpha;

for index_trial = 1:number_of_trials
    % test strategy model
    trial_type = go_left(PeyracheData.Rat_1(1:index_trial,:));
    
    % update probability of strategy
    if index_trial == 1
        [alpha(index_trial),beta(index_trial)] = update_strategy_posterior_probability(trial_type,decay_rate,alpha0,beta0);
    else
        [alpha(index_trial),beta(index_trial)] = ...
            update_strategy_posterior_probability(trial_type,decay_rate,alpha(index_trial-1),beta(index_trial-1));
    end
    
    % compute estimators (MAP probability, and precision)
    MAPprobability(index_trial) = Summaries_of_Beta_distribution(alpha(index_trial),beta(index_trial),'MAP');
    precision(index_trial) = Summaries_of_Beta_distribution(alpha(index_trial),beta(index_trial),'Precision');
   
end

Output.go_left.alpha = alpha;
Output.go_left.beta = beta;
Output.go_left.MAPprobability = MAPprobability;
Output.go_left.precision = precision;

%% save output

%% plot time-series of MAP probability estimates and precision

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 15 5]);
%plotSessionsRules(gca,Rat,iR,rules,strRules,[0.5 1]);   % set to chance for P(rule-strategy) 
plot(Output.go_left.MAPprobability);
line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
xlabel('Trials'); ylabel('P(strategy)')

