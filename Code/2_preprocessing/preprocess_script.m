% Enable use of toolbox functions
% addpath(genpath('./../toolboxes/biosig'));
% addpath(genpath('./../toolboxes/eeglab14_1_2b'));

% load the data from the outputs folder
load('./../outputs/runsData.mat')
load('./../data/laplacian_16_10-20_mi.mat');

% Spatial filtering 
FilteredData = preprocess_all_run(RunsData, lap, true);

% save the data in .mat 
save('../outputs/FilteredRunsData.mat','FilteredData')


