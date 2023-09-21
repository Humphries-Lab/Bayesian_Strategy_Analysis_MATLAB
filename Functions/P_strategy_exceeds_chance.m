function P_exceed_chance = P_strategy_exceeds_chance(a,b,p_chance)

% P_STRATEGY_EXCEEDS_CHANCE compute the probability that P(strategy_i) exceeds chance
% P = P_STRATEGY_EXCEEDS_CHANCE(A,B,PCHANCE) takes the Beta distribution
% defined by parameters (A,B), and computes the probability P that the
% resulting distribution includes a defined chance level PCHANCE. Returns
%
% This is used to define learning: if Beta(a,b) is the posterior on
% P(strategy_i), then P[P_strategy_i > p(chance)] can be used to define
% when the posterior estimate of P(strategy_i) is sufficiently greater
% than chance to be deemed "learning". Defining learning thus requires
% applying some threshold to the output P e.g. P > 0.95 would be a 95%
% threshold on not including p(chance)
%
% Mark Humphries 19/9/2023

P_exceed_chance = 1 - betacdf(p_chance,a,b);
