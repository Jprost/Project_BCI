% Building a periodogram based on multiple epochs centered on MI_start
% event 

% % Enable use of toolbox functions
% addpath(genpath('./../toolboxes/biosig'));
% addpath(genpath('./../toolboxes/eeglab14_1_2b'));

% load epoching data
load('./../outputs/epoch_MI_Stop.mat');
load('./../outputs/epoch_Baseline.mat');

% periodogram for all channels
fs = epoch_MI_Stop.sampling_frequency;
non_overlap_time = 0.0625;
window_time = 1;

%% Compute ERD/ERS
[ERD_ERS_mat, t, f] = compute_spectrogram(epoch_MI_Stop, epoch_baseline, fs, window_time, non_overlap_time);

%% Plot the spectrogram averaged over all trials
% single plot : Channel C3
figure(1)
spectrogram_plot(mean(squeeze(ERD_ERS_mat(:,:,:,11)), 3), t-3, f, 'C3')

% all channels
channel_names = {'FZ';'FC3';'FC1';'FCz';'FC2';'FC4';'C3';'C1';'Cz';'C2';'C4';'CP3';'CP1';'CPZ';'CP2';'CP4'};

figure(2)
for c = 1:1:size(ERD_ERS_mat, 4)
   subplot(4,4,c)
   spectrogram_plot(mean(squeeze(ERD_ERS_mat(:,:,:,c)), 3), t-3, f, channel_names{c})
end
