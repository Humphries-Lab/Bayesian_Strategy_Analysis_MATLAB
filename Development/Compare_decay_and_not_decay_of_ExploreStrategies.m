% compare effects of decaying or not decaying (alpha,beta) on Null trials
% when updating using relax-to-prior
% Peyrache Rat2 at the moment
% Mark Humphries

clearvars; close all;

addpath ../Strategy_models/        % must add this path to access strategy models
addpath ../Functions/

load ../Processed_data/PeyracheDataTables.mat   % a struct PeyracheData containing 4 Tables as fields, one per rat
testData = PeyracheData.Rat_2;

%% choose strategies to evaluate
% list of function names in Strategy_models/ folder - runs all of them to
% check they work...
strategies = ["go_left", "go_right", "go_cued","go_uncued",...
                "win_stay_spatial","win_stay_cued","lose_shift_cued","lose_shift_spatial",...
                   "alternate","sticky"];

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
    OutputDecay.(charStrategy).alpha = zeros(number_of_trials,1);
    OutputDecay.(charStrategy).beta = zeros(number_of_trials,1);
    OutputDecay.(charStrategy).MAPprobability = zeros(number_of_trials,1);
    OutputDecay.(charStrategy).precision = zeros(number_of_trials,1);
    OutputDecay.(charStrategy).success_total = 0;
    OutputDecay.(charStrategy).failure_total = 0;

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

           
        % update its alpha, beta, with decay of null trials  
        [OutputDecay.(charStrategy).alpha(index_trial),OutputDecay.(charStrategy).beta(index_trial),OutputDecay.(charStrategy).success_total,OutputDecay.(charStrategy).failure_total] = ...
                update_strategy_posterior_probability(trial_type,decay_rate,OutputDecay.(charStrategy).success_total,OutputDecay.(charStrategy).failure_total,alpha0,beta0,'DecayNull');
        
            
        OutputDecay.(charStrategy).MAPprobability(index_trial) = Summaries_of_Beta_distribution(OutputDecay.(charStrategy).alpha(index_trial),OutputDecay.(charStrategy).beta(index_trial),'MAP');
        OutputDecay.(charStrategy).precision(index_trial) = Summaries_of_Beta_distribution(OutputDecay.(charStrategy).alpha(index_trial),OutputDecay.(charStrategy).beta(index_trial),'Precision');
    end  
end


%% plot time-series of MAP probability estimates and precision

new_session_trials = find(testData.NewSessionTrials);
rule_change_trials = find(testData.RuleChangeTrials);
sequence_of_rules = [testData.TargetRule(1); testData.TargetRule(rule_change_trials)];

% rule strategies: should be identical 
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules); hold on
line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
plot(OutputDecay.go_left.MAPprobability,'o','Color',[0.5 0.5 0.5]);
plot(Output.go_left.MAPprobability);

% plot(Output.go_cued.MAPprobability,'Color',[0.8 0.6 0.5]);
% plot(Output.go_right.MAPprobability,'Color',[0.4 0.8 0.5]); 
xlabel('Trials'); ylabel('P(strategy)')

% explore strategies...
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules); hold on
% line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
plot(OutputDecay.win_stay_cued.MAPprobability,'Color',[0.5 0.5 0.5]);
plot(Output.win_stay_cued.MAPprobability,'o','Color',[0.7 0.4 0.7]);
title('Win-stay-cued');
xlabel('Trials'); ylabel('P(strategy)')

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules); hold on
% line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
plot(OutputDecay.lose_shift_cued.MAPprobability,'Color',[0.5 0.5 0.5]);
plot(Output.lose_shift_cued.MAPprobability,'o','Color',[0.7 0.4 0.7]);
title('Lose-shift-cued');
xlabel('Trials'); ylabel('P(strategy)')

% odd behaviour: when including null-trial decay, lose-shift-cued has
% increasing MAP when not being used?
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules); hold on
% line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
plot(OutputDecay.lose_shift_cued.alpha,'Color',[0.8 0.3 0.2]);
plot(OutputDecay.lose_shift_cued.beta,'Color',[0.6 0.6 0.6]);
title('Lose-shift-cued: alpha and beta');
xlabel('Trials'); ylabel('parameter values')


figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules); hold on
% line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
plot(OutputDecay.lose_shift_spatial.MAPprobability,'Color',[0.5 0.5 0.5]);
plot(Output.lose_shift_spatial.MAPprobability,'o','Color',[0.7 0.4 0.7]);
title('Lose-shift-spatial');
xlabel('Trials'); ylabel('P(strategy)')


