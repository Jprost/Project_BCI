%Feature_extraction_script

% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));

%Load Epochs
load('./../outputs/epoch_MI_Stop.mat')

trials = epoch_MI_Stop.trial;
time = epoch_MI_Stop.time;
win = 1;
shift = 0.0625;
start_ERD = -2;
stop_ERD = 0;
start_ERS = 0.5;
stop_ERS = 2.5;

features_mat = feat_extraction(trials, time, win, shift, start_ERD, stop_ERD, start_ERS, stop_ERS);