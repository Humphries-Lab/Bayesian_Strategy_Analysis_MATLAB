% script to demonstrate the posterior-based learning criterion for the Bayesian strategy analysis
% - using data from one example rat from Peyrache Y-maze data-set
% - computes the posteriors for the four rule strategies (go left, go
% right, go to the cued arm, go to the uncued arm)
% - computes the probability that each P(strategy) exceeds chance
% - defines the learning trial as the first trial for which that
% probability is above some threshold
%
% Stores results in dynamically-created struct; users may want to recast as
% Tables to save data
%
% Initial version 21/9/2023
% Mark Humphries 

clearvars; close all;

addpath Strategy_models/        % must add this path to access strategy models
addpath Functions/              % must add this path to access functions that implement analysis

% load data into a Table - strategy models will use variable names stored with Table to
% access each column's data
testData = readtable('Processed_data/Peyrache_Rat2_data.csv','TextType','string');

%% choose strategies to evaluate
% list of function names in Strategy_models/ folder - choose the rule
% strategies
strategies = ["go_left", "go_right", "go_cued","go_uncued"];

%% choose type of prior
prior_type = "Uniform";

%% set decay rate: gamma parameter
decay_rate = 0.9;

%% define priors
[alpha0,beta0] = set_Beta_prior(prior_type);

%% define parameters for the learning criterion
p_chance = 0.5;  % the chance level of executing the correct rule (typically 1/[number of options])
learning_threshold = 0.95;  % the probability that the posterior proability of P(strategy) exceeds chance level

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
        
        % compute current MAP probability and precision    
        Output.(charStrategy).MAPprobability(index_trial) = Summaries_of_Beta_distribution(Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),'MAP');
        Output.(charStrategy).precision(index_trial) = Summaries_of_Beta_distribution(Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),'Precision');
    
        % compute probability that posterior exceeds chance
        Output.(charStrategy).P_exceed_chance(index_trial) = ...
                P_strategy_exceeds_chance(Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial),p_chance);
    end  
end

%% compute learning trials for each strategy
for index_strategy = 1:number_of_strategies
    charStrategy = char(strategies(index_strategy)); % cast as Char for old MATLAB < 2018
    Output.(charStrategy).learning_trial = find(Output.(charStrategy).P_exceed_chance > learning_threshold,1); % find first trial where posterior exceed chance by more than threshold
end

%% plot time-series of MAP probability estimates and overlay learning trials

go_left_colour = [0.4 0.4 0.8];
go_right_colour = [0.4 0.8 0.5];
go_cued_colour = [0.8 0.6 0.5];

new_session_trials = find(testData.NewSessionTrials);
rule_change_trials = find(testData.RuleChangeTrials);
sequence_of_rules = [testData.TargetRule(1); testData.TargetRule(rule_change_trials)];


% rule strategies
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 20 9]);
plotSessionStructure(gca,number_of_trials,new_session_trials,rule_change_trials,sequence_of_rules); hold on
line([1,number_of_trials],[0.5 0.5],'Color',[0.7 0.7 0.7]) % chance
plot(Output.go_left.MAPprobability,'Color',go_left_colour);
plot(Output.go_cued.MAPprobability,'Color',go_cued_colour);
plot(Output.go_right.MAPprobability,'Color',go_right_colour); 
xlabel('Trials'); ylabel('P(strategy)')

% learning trials - in order of experienced rules [go uncued was not
% learnt]
line([Output.go_right.learning_trial Output.go_right.learning_trial],[0 1],'Color',go_right_colour)
line([Output.go_cued.learning_trial Output.go_cued.learning_trial],[0 1],'Color',go_cued_colour)
line([Output.go_left.learning_trial Output.go_left.learning_trial],[0 1],'Color',go_left_colour)

% label stuff
strLabel = {'go left','go cued','go right'};
t = text([400,400,400],[0.8,0.7,0.6],strLabel);
t(1).Color = go_left_colour;
t(2).Color = go_cued_colour;
t(3).Color = go_right_colour;

%% plot full posteriors of each rule strategy
x = 0:0.01:1; % range to evaluate PDF of beta distribution

for index_strategy = 1:number_of_strategies
    charStrategy = char(strategies(index_strategy)); % cast as Char for old MATLAB < 2018
    Output.(charStrategy).full_posterior = zeros(numel(x),number_of_trials);
    for index_trial = 1:number_of_trials
        Output.(charStrategy).full_posterior (:,index_trial) = betapdf(x,Output.(charStrategy).alpha(index_trial),Output.(charStrategy).beta(index_trial));
    end
    figure
    imagesc(1:number_of_trials,x,Output.(charStrategy).full_posterior)
    set(gca,'YDir','normal')
    xlabel('Trials'); ylabel('P(strategy)')
    title(['Rule strategy: ' charStrategy])
    
    if ~isempty(Output.(charStrategy).learning_trial) 
        line([Output.(charStrategy).learning_trial Output.(charStrategy).learning_trial],[0 1],'Color',[1 1 1])
    end
end
