% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));
addpath(genpath('./../toolboxes/eeglab14_1_2b'));

% load the data from the outputs folder
load('./../outputs/FilteredRunsData.mat')

% baseline --> 200
epochs_baseline = epoching_from_event(FilteredData, 300, 3, 0);
save('../outputs/epoch_baseline.mat','epochs_baseline')

% strat MI --> 300
epochs_MI_start = epoching_from_event(FilteredData, 300, 0, 3);
save('../outputs/epoch_MI_start.mat','epochs_MI_start')

% baseline + MI centered in MI 
epochs_MI_Baseline = epoching_from_event(FilteredData, 300, 3, 3);
save('../outputs/epoch_MI_Baseline.mat','epochs_MI_Baseline')