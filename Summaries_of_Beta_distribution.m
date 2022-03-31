function estimator = Summaries_of_Beta_distribution(alpha,beta,type,varargin)

% SUMMARIES_OF_BETA_DISTRIBUTION compute the requested summary statistic from the Beta PDF
% E = SUMMARIES_OF_BETA_DISTRIBUTION(a,b,T) given the Beta(a,b) parameters, computes the
% requested summary statistic T, returned as a scalar E
%   T:
%       'MAP': maximum a posteriori
%       'Mean': mean of beta distribution
%       'Var': variance
%       'Precision': 1/variance
%       'Percentile': Xth percentile of distribution, giving the Xth credible interval 
%       [define X as 4th argument: 0.95 = 95th percentile etc]; E will be 2-element array
%       [lower upper].
%
% 12/10/16: Initial version
% 31/03/22: update to MAP explicit calculation
% Mark Humphries 

switch type
    case 'MAP'
        if alpha > 1 && beta > 1
            estimator = (alpha - 1) ./ (alpha + beta + 2);  % maximum a posteriori estimate
        elseif alpha <= 1 && beta > 1
            estimator = 0;
        elseif alpha > 1 && beta <= 1
            estimator = 1;
        else 
            % if alpha < 1 && beta < 1 distribution is bimodal, so no MAP
            % alpha = beta = 1, distribution is uniform, so no MAP
            estimator = NaN;  
        end

    case 'Mean'
        estimator = alpha ./ (alpha + beta);
    case {'Var','Precision'}
        estimator = (alpha*beta) / ((alpha+beta).^2 .* (alpha+beta+1));
        if strcmp(type,'Precision')
            estimator = 1./estimator;
        end
    case 'Percentile'
        Prct = varargin{1};
        delta = 1-Prct;
        P = [delta/2 Prct + delta/2];
        estimator = betainv(P,alpha,beta);
    otherwise
        error([type ' is unknown estimator type'])
end

