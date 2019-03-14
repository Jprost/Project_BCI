
% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));
addpath(genpath('./../toolboxes/eeglab14_1_2b'));

%Load Epochs
load('./../outputs/epoch_baseline.mat')
load('./../outputs/epoch_MI_start.mat')

%[power, freq] = power_compute(epochs_baseline);
size(power)
size(freq)

%[BL_power, BL_freq] = power_compute(epochs_baseline);
%[MI_power, MI_freq] = power_compute(epochs_MI_stop);
%BL_mean = mean(mean(BL_power,1),3);
%MI_mean = mean(mean(MI_power,1),3);

figure
hold
plot(freq,10*log10(BL_mean),'r')
plot(freq,10*log10(MI_mean),'b')
xlim([0,40])