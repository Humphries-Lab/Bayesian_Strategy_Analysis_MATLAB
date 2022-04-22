% script to demonstrate asymptotic behaviour of (alpha, beta) parameters of
% Beta distribution when we use decaying evidence
%
% 22/4/2022
% Mark Humphries

clearvars; close all

% set of decay values to check
gamma = [0.5:0.1:0.9 0.91:0.01:0.99];
T = 1000;  % number of sequential trials of the same outcome

% prior distribution parameters
alpha0 = 1;

t = 1:T;
alpha_iterative = zeros(numel(gamma),numel(t));
alpha_one_step = zeros(numel(gamma),1);
alpha_exact_asymptote = zeros(numel(gamma),1);

for iGamma = 1:numel(gamma)
    for iTimestep = t
        % iteratively sum decayed evidence
        % 1 is the evidence on trial t (x(t) = 1)
        alpha_iterative(iGamma,iTimestep) = alpha0 + sum(gamma(iGamma).^(iTimestep-(1:iTimestep))*1);
    end
    alpha_one_step(iGamma) = alpha0 + sum(gamma(iGamma).^(T-t)*1);  % sum of decayed evidence
    alpha_exact_asymptote(iGamma) = alpha0 + 1/(1-gamma(iGamma));  % asymptotic value of evidence sum
end

figure
plot(t,alpha_iterative); hold on
for iGamma = 1:numel(gamma)
    line([1 T],[alpha_exact_asymptote(iGamma) alpha_exact_asymptote(iGamma)],'Color',[0.7 0.7 0.7]);
end
xlabel('Trial');
ylabel('alpha')

