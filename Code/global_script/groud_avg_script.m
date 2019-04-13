% Global Script for all subjects data togheter --> Ground Average
% Enable use of toolboxe biosig
addpath(genpath('./../toolboxes/biosig'));
%addpath(genpath('./../toolboxes/eeglab14_1_2b'));

oldpath = path;
path('/Applications/MATLAB_R2018b.app/toolbox/signal',oldpath)

channel_loc_path = './../data/channel_location_16_10-20_mi.mat';

% access functions
addpath('./../1_load_data');
addpath('./../2_preprocessing');
addpath('./../3_epoching');
addpath('./../4_correlate_analysis');
addpath('./../5_feature_extraction');

%% Recover saved Epoching arrays (epoch_MI_start & epoch_MI_stop & epoch_baseline) for all subjects
% MI_start epochs
m1 = load('./../outputs/output_antoine/epoch_MI_Start.mat');
m2 = load('./../outputs/output_JB/epoch_MI_Start.mat');
m3 = load('./../outputs/output_sacha/epoch_MI_Start.mat');

MI_start = m1.epoch_MI_Start;
MI_start.trial = epochs_for_all_subjects({m1.epoch_MI_Start.trial, m2.epoch_MI_Start.trial, m3.epoch_MI_Start.trial});

% MI_stop epochs
m1 = load('./../outputs/output_antoine/epoch_MI_Stop.mat');
m2 = load('./../outputs/output_JB/epoch_MI_Stop.mat');
m3 = load('./../outputs/output_sacha/epoch_MI_Stop.mat');

MI_stop = m1.epoch_MI_Stop;
MI_stop.trial = epochs_for_all_subjects({m1.epoch_MI_Stop.trial, m2.epoch_MI_Stop.trial, m3.epoch_MI_Stop.trial});

% baseline epochs
m1 = load('./../outputs/output_antoine/epoch_baseline.mat');
m2 = load('./../outputs/output_JB/epoch_baseline.mat');
m3 = load('./../outputs/output_sacha/epoch_baseline.mat');

baseline = m1.epoch_baseline;
baseline.trial = epochs_for_all_subjects({m1.epoch_baseline.trial, m2.epoch_baseline.trial, m3.epoch_baseline.trial});

% in the end --> Structures with, as trial, a 4D array for the 4 subjects

% save output
save('../outputs/output_ground_avg/epoch_MI_Start.mat','MI_start')
save('../outputs/output_ground_avg/epoch_MI_Stop.mat','MI_stop')
save('../outputs/output_ground_avg/epoch_baseline.mat','baseline')

%% Mean epochs over subjects without considering padding NaN

MI_start.trial = mean(MI_start.trial, 4, 'omitnan');
MI_stop.trial = mean(MI_stop.trial, 4, 'omitnan');
baseline.trial = mean(baseline.trial, 4, 'omitnan');

%% Correlate Analysis : Periodogram
load(channel_loc_path)
channel_lab = {chanlocs16.labels};

% Periodogram for ONE channel
figure(1)
channel_num = 16;
periodogram_plot_oneChannel(baseline, MI_start, channel_num, channel_lab)

% Periodogram for ALL 16 channels in one plot
figure(2)
periodogram_allChannels(baseline, MI_start, channel_lab)

% Periodogram for average over channels and trials
figure(3)
periodogram_averageChannels(baseline, MI_start)

%% Correlate Analysis : Spectrogram 



%% Correlate Analysis : Topoplot


%% Feature Extraction 


%% Model Building


