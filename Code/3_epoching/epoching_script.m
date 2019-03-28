% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));
addpath(genpath('./../toolboxes/eeglab14_1_2b'));

% load the data from the outputs folder
load('./../outputs/FilteredRunsData.mat');

%% baseline centered on MI-start
epoch_baseline = epoching_from_event(FilteredData, 300, 2, 0);
save('../outputs/epoch_baseline.mat','epoch_baseline')

% epochs centered on MI-start
epoch_MI_Start = epoching_from_event(FilteredData, 300, 3, 3);
save('../outputs/epoch_MI_Start.mat','epoch_MI_Start')

% epochs centered on MI stop
epoch_MI_Stop = epoching_from_event(FilteredData, 555, 3, 3);
save('../outputs/epoch_MI_Stop.mat','epoch_MI_Stop')