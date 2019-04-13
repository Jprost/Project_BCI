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

%% Load data

% data localisation
datafolder_path = './../data/data_Sacha/';
channel_loc_path = './../data/channel_location_16_10-20_mi.mat';

% load the data
RunsData = load_data_from_runs(datafolder_path, channel_loc_path);
save('../outputs/output_sacha/runsData.mat','RunsData')

%% Preprocess : Spatial Filtering

% load the data from the outputs folder
load('./../data/laplacian_16_10-20_mi.mat');
    %load('./../outputs/output_antoine/runsData.mat') % <- uncomment to load directly from output folder

% Spatial filtering 
FilteredData = preprocess_all_run(RunsData, lap, true);

% save the data in .mat 
save('../outputs/output_sacha/FilteredRunsData.mat','FilteredData')
    

%% Epoching

% load the data from the outputs folder
    %load('./../outputs/output_antoine/FilteredRunsData.mat'); % <- uncomment to load directly from output folder

% epochs for the baseline: 2 second before MI-start
epoch_baseline = epoching_from_event(FilteredData, 300, 2, 0);
save('../outputs/output_sacha/epoch_baseline.mat','epoch_baseline')

% epochs centered on MI-start
epoch_MI_Start = epoching_from_event(FilteredData, 300, 3, 3);
save('../outputs/output_sacha/epoch_MI_Start.mat','epoch_MI_Start')

% epochs centered on MI stop
epoch_MI_Stop = epoching_from_event(FilteredData, 555, 3, 3);
save('../outputs/output_sacha/epoch_MI_Stop.mat','epoch_MI_Stop')

%% Correlate Analysis : Periodogram

%Load Epochs
    %load('./../outputs/output_sacha/epoch_baseline.mat')
    %load('./../outputs/output_sacha/epoch_MI_Start.mat')
runData = load('./../outputs/output_sacha/FilteredRunsData.mat');
channel_lab = {runData.FilteredData(1).channel_loc.labels};

% Periodogram for ONE channel
figure(1)
channel_num = 16;
periodogram_plot_oneChannel(epoch_baseline, epoch_MI_Start, channel_num,channel_lab)

% Periodogram for ALL 16 channels in one plot
figure(2)
periodogram_allChannels(epoch_baseline, epoch_MI_Start, channel_lab)

% Periodogram for average over channels and trials
figure(3)
periodogram_averageChannels(epoch_baseline, epoch_MI_Start)

%% Correlate Analysis : Spectrogram
% load epoching data
load('./../outputs/output_sacha/epoch_MI_Stop.mat');
load('./../outputs/output_sacha/epoch_MI_Start.mat');
load('./../outputs/output_sacha/epoch_baseline.mat');

% spectrogram parameters
fs = epoch_MI_Start.sampling_frequency;
non_overlap_time = 0.0625;
window_time = 1;

% compute ERD_ERS_mat centered on MI-start and MI-stop
[ERD_ERS_mat_start, t_start, f_start] = compute_spectrogram(epoch_MI_Start, epoch_baseline, fs, window_time, non_overlap_time);
[ERD_ERS_mat_stop, t_stop, f_stop] = compute_spectrogram(epoch_MI_Stop, epoch_baseline, fs, window_time, non_overlap_time);

figure(4)
%sgtitle('Spectrogram Centered on MI-Start')
plot_all_spectrogram(ERD_ERS_mat_start, t_start, f_start)

figure(5)
%sgtitle('Spectrogram Centered on MI-Stop')
plot_all_spectrogram(ERD_ERS_mat_stop, t_stop, f_stop)

%% Correlate Analysis : Topoplots



%% Feature Extraction - Average perf and fisher score across CV

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

% Get features matrix (power densitiy for all 304 features (16channels x 19freq) for 17
%windows on MI event and 17 windows on STOP event
features_mat = feat_extraction(trials, time, win, shift, start_ERD, stop_ERD, start_ERS, stop_ERS);

kfold = 10;
nFeatKept = 6;
% Plot (1) boxplot of CV accuracies and  (2) average ROC curves
% LDA classifier keaping 'nFeatKept' firt best features (based on fisher score)
[~,~,~,~,fisher_scores,ord_features] = CV_avg_performance_and_featScore(kfold,features_mat,nFeatKept);

%Plot a heatmap channel vs freq, with avg fisher score
[fisherScore_map] = avg_fisherScore(fisher_scores,ord_features,kfold);


%% Model building
