%Periodogram_script

% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));

%Load Epochs
load('./../outputs/epoch_baseline.mat')
load('./../outputs/epoch_MI_start.mat')
runData = load('./../outputs/runsData.mat');
channel_lab = {runData.RunsData(1).channel_loc.labels};

%% Periodogram (PSD) for ONE channel
channel_num = 16;
periodogram_plot_oneChannel(epochs_baseline,epochs_MI_start,channel_num,channel_lab)


%% Periodogram for ALL 16 channels in one plot
periodogram_allChannels(epoch_baseline,epochs_MI_start,channel_lab)


%% Periodogram, average over channels and trials
periodogram_averageChannels(epochs_baseline,epochs_MI_start)