
% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));
%addpath(genpath('./../toolboxes/eeglab14_1_2b'));

%Load Epochs
load('./../outputs/epoch_baseline.mat')
load('./../outputs/epoch_MI_start.mat')


%Channel x Power x trials

%[BL_power, BL_freq] = power_compute(epochs_baseline);
%[MI_power, MI_freq] = power_compute(epochs_MI_start);

%MEAN OVER ALL 16 channels, and ALL trials (epochs)
BL_mean = mean(mean(BL_power,1),3);
MI_mean = mean(mean(MI_power,1),3);
BL_SD = std(mean(BL_power,3),0,1); %STD over CHANNEL
MI_SD = std(mean(MI_power,3),0,1); %STD over CHANNEL


figure
hold on;
title('Average PSD over all trials (epochs) and all channels')
plot(freq,10*log10(BL_mean),'r')
plot(freq,10*log10(MI_mean),'b')

freqBoth = [freq' fliplr(freq')];
BL_shade = [(10*log10(BL_mean)+10*log10(BL_SD)) (fliplr(10*log10(BL_mean)-10*log10(BL_SD)))];
size(freqBoth)
size(BL_shade)
%patch(freqBoth,BL_shade,'r','FaceAlpha',.3)
legend('Baseline','Motor Imagery Start')
xlim([0,40])