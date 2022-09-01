# Bayesian_Strategy_Analysis_MATLAB
MATLAB toolbox for Bayesian analysis of behavioural strategies on choice tasks

Pre-print: https://biorxiv.org/cgi/content/short/2022.08.30.505807v1

Tested with: MATLAB R2017a onwards
Requires: Statistics and Machine Learning Toolbox

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

# How do I use the toolbox with my data?
1. Put your data into a format that can be read into a Table using "readtable" - see any of the top-level scripts for examples. For example, a CSV file. Ensure to include the command to write the Table entries as strings: readtable(<name of your data file>,'TextType','string'). 
2. Use Replicate_Figure1 as a template. Make a copy (e.g. My_Strategy_Analysis.m). Edit that copy to load your data (in the format of Step 1) and select the strategies you want to apply (in the string "strategues = ["go_left",...,]); then run it and see the results
3. Write your own strategy models: see the Strategy_models/ folder for examples, and a template. All strategy model functions have the same input (rows of the data Table up to the current trial) and output (the trial type as a string). Then simply add the name of the new function to your list of strategies in your script. And run it!
