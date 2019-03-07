% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));
addpath(genpath('./../toolboxes/eeglab14_1_2b'));

% load the data from the outputs folder
load('./../outputs/runsData.mat')



% baseline --> 200
epochs_baseline = epoching_from_event(RunsData, 300, 3, 0);
save('../outputs/epoch_baseline.mat','epochs_baseline')

% strat MI --> 300
epochs_MI_start = epoching_from_event(RunsData, 300, 0, 3);
save('../outputs/epoch_MI_start.mat','epochs_MI_start')

% stop MI --> 555
epochs_MI_stop = epoching_from_event(RunsData, 555, 0, 3);
save('../outputs/epoch_MI_stop.mat','epochs_MI_stop')