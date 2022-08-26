# Bayesian_Strategy_Analysis_MATLAB
MATLAB toolbox for Bayesian analysis of behavioural strategies on choice tasks

Tested with: MATLAB R2017a onwards
Requires: Statistics and Machine Learning Toolbox

[reference to pre-print to go here]

## Top-level scripts
Four scripts demonstrate the main use of the Toolbox:
1. Demonstrate_Bayesian_strategy_analysis.m: shows how to run the algorithm for a single strategy model  
2. Demonstrate_Multiple_Bayesian_strategy_analysis.m: demonstrates the functions that allow the algorithm to be run on an arbitrary set of strategy models, and how to store the outputs
3. Demonstrate_interpolation_of_null_trials: the functions executing the strategy models return Null trials as NaNs, to allow users to test their own models of how to handle this trial type. This script demonstrates the approach we use in the pre-print: it replaces those NaNs by interpolating the preceding values of the Beta distribution's parameters.
4. Replicate_Figure1: replicates panels c, d, and e of Figure 1 in the paper, to demonstrate the full workflow: choosing strategies, computing p(strategy) for each, interpolating probabilities for Null trials, and then plotting the appropriate time-series of probabilities


## Folders
- Strategy_models/: each function in this folder executes a single strategy model; the range of strategy models can be easily expanded by adding functions to this folder - a template has been provided
- Functions/: the set of functions that implement the Bayesian algorithm, handle multiple strategies, and summarise the Beta distribution (MAP estimate, precision etc)
- Processed_data/: the Y-maze rat data used to demonstrate the code in the top-level scripts
- Development/: scripts used in testing code for bugs, including unit-tests of strategy models [toolbox functionality does not need this folder]



