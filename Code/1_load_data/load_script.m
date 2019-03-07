% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));
addpath(genpath('./../toolboxes/eeglab14_1_2b'));

% data localisation
datafolder_path = './../data/test_data/20191902/';
channel_loc_path = './../data/channel_location_16_10-20_mi.mat';

% load the data
RunsData = load_data_from_runs(datafolder_path, channel_loc_path);

% save the data in .mat 
save('../outputs/runsData.mat','RunsData')


