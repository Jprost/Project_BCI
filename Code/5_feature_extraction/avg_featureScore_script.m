%Feature_extraction_script

% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));

%Load Epochs
load('./../outputs/output_sacha/epoch_MI_Stop.mat')

%Fixed parameters
trials = epoch_MI_Stop.trial;
time = epoch_MI_Stop.time;
win = 1;
shift = 0.0625;
start_ERD = -2;
stop_ERD = 0;
start_ERS = 0.5;
stop_ERS = 2.5;

%Get power densitiy for all 304 features (16channels x 19freq) for 17
%windows on MI event and 17 windows on STOP event
%304 feature a  Ordered    Channel 1 all freq | Channel 2 all freq | ...
features_mat = feat_extraction(trials, time, win, shift, start_ERD, stop_ERD, start_ERS, stop_ERS);


%% Feature selection throughout Cross Validation

kfold = 10;
nFeatKept = 6;
% Perform a kfold CrossValidation, with LDA classifier keaping 'nFeatKept'
% firt best features (based on fisher score)
% Plot (1) boxplot of CV accuracies and  (2) average ROC curves
[~,~,~,~,fisher_scores,ord_features] = CV_avg_performance_and_featScore(kfold,features_mat,nFeatKept);

%% Average fisher score of fisher over 10-fold CV

%Plot a heatmap channel vs freq, with avg fisher score
[fisherScore_map] = avg_fisherScore(fisher_scores,ord_features,kfold);


