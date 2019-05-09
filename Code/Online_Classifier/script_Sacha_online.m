% Global Script for Antoine's data
% Enable use of toolboxe biosig
addpath(genpath('./../toolboxes/biosig'));
%addpath(genpath('./../toolboxes/eeglab14_1_2b'));

% access functions
addpath('./../1_load_data');
addpath('./../2_preprocessing');
addpath('./../3_epoching');
addpath('./../4_correlate_analysis');
addpath('./../5_feature_extraction');
addpath('./../Online_Classifier');

%% Load data

% data localisation
datafolder_path = './../data_online/data_Sacha/data_train/';
channel_loc_path = './../data/channel_location_16_10-20_mi.mat';

% load the data
RunsData = load_data_from_runs(datafolder_path, channel_loc_path);
save('../outputs/output_sacha_online/runsData.mat','RunsData')

% online data 
RunsDataOnline = load_data_from_runs('./../data_online/data_Sacha/data_test/', channel_loc_path);

% clean the corrupt test Run (missing data)
% take only the event represented on the signal available and make sur the last event is a end of trial event (event_id = 700)
len_corrupted_run = size(RunsDataOnline(1).signal, 2);
upper_idx_to_keep = find((RunsDataOnline(1).event.action_pos < len_corrupted_run) & (RunsDataOnline(1).event.action_type == 700), 1, 'last');
RunsDataOnline(1).event.action_pos = RunsDataOnline(1).event.action_pos(1:upper_idx_to_keep, :);
RunsDataOnline(1).event.action_type = RunsDataOnline(1).event.action_type(1:upper_idx_to_keep, :);

%% Preprocess : Spatial Filtering

% load the data from the outputs folder
load('./../data_online/laplacian_16_10-20_mi.mat');
    %load('./../outputs/output_antoine/runsData.mat') % <- uncomment to load directly from output folder

% Spatial filtering 
FilteredData = preprocess_all_run(RunsData, lap, true);
FilteredDataOnline = preprocess_all_run(RunsDataOnline, lap, true);

% save the data in .mat 
save('../outputs/output_sacha_online/FilteredRunsData.mat','FilteredData')
save('../outputs/output_sacha_online/FilteredRunsDataOnline.mat','FilteredDataOnline')
    

%% Epoching

% load the data from the outputs folder
    %load('./../outputs/output_antoine/FilteredRunsData.mat'); % <- uncomment to load directly from output folder

% epochs for the baseline: 2 second before MI-start
epoch_baseline = epoching_from_event(FilteredData, 300, 2, 0);
save('../outputs/output_sacha_online/epoch_baseline.mat','epoch_baseline')

% epochs centered on MI-start
epoch_MI_Start = epoching_from_event(FilteredData, 300, 3, 3);
save('../outputs/output_sacha_online/epoch_MI_Start.mat','epoch_MI_Start')

% epochs centered on MI stop
epoch_MI_Stop = epoching_from_event(FilteredData, 555, 3, 3);
save('../outputs/output_sacha_online/epoch_MI_Stop.mat','epoch_MI_Stop')


%% Feature Extraction

%Load Epochs
load('./../outputs/output_sacha_online/epoch_MI_Stop.mat')

%Fixed parameters
trials = epoch_MI_Stop.trial;
time = epoch_MI_Stop.time;
win = 1;
shift = 0.0625;
start_ERD = -2;
stop_ERD = 0;
start_ERS = 0.5;
stop_ERS = 2.5;

% Get features matrix (power densitiy for all 304 features (16channels x 19freq) for 17
%windows on MI event and 17 windows on STOP event
features_mat = feat_extraction(trials, time, win, shift, start_ERD, stop_ERD, start_ERS, stop_ERS);


%% Model building

% LDA classifier keaping 'nFeatKept' firt best features (based on fisher score)
nFeatKept = 6;
[model, mu, sigma,orderedInd] = model_train_for_online(features_mat,nFeatKept);


%% Testing
[prob_list,prob_list_filtered,mean_t] = onlinePipeline(RunsDataOnline,model,mu,sigma,orderedInd,nFeatKept,32);

