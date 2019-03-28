% Building a periodogram based on multiple epochs centered on MI_start
% event 

% % Enable use of toolbox functions
% addpath(genpath('./../toolboxes/biosig'));
% addpath(genpath('./../toolboxes/eeglab14_1_2b'));

% load epoching data
load('./../outputs/epoch_MI_Stop.mat');
load('./../outputs/epoch_MI_Start.mat');
load('./../outputs/epoch_Baseline.mat');

% periodogram for all channels
fs = epoch_MI_Start.sampling_frequency;
non_overlap_time = 0.0625;
window_time = 1;

%% Compute ERD/ERS
[ERD_ERS_mat, t, f] = compute_spectrogram(epoch_MI_Start, epoch_baseline, fs, window_time, non_overlap_time);

%% Plot the spectrogram averaged over all trials
figure(1)
plot_all_spectrogram(ERD_ERS_mat, t, f)