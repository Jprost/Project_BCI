%Periodogram_script

% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));

%Load Epochs
load('./../outputs/epoch_baseline.mat')
load('./../outputs/epoch_MI_start.mat')
runData = load('./../outputs/runsData.mat');
channel_lab = {runData.RunsData(1).channel_loc.labels};

%% compute power 
[BL_power, BL_freq] = power_compute(data_Basline);
[MI_power, MI_freq] = power_compute(data_MI);

%% Periodogram (PSD) for ONE channel
channel_num = 16;
periodogram_plot_oneChannel(BL_power, BL_freq, MI_power, MI_freq, channel_num,channel_lab)%epochs_baseline,epochs_MI_start,channel_num,channel_lab)

%% Periodogram for ALL 16 channels in one plot
periodogram_allChannels(BL_power, BL_freq, MI_power, MI_freq, channel_lab)%epoch_baseline,epochs_MI_start,channel_lab)

%% Periodogram, average over channels and trials
periodogram_averageChannels(BL_power, BL_freq, MI_power, MI_freq)%epochs_baseline,epochs_MI_start)