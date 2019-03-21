% Building a periodogram based on multiple epochs centered on MI_start
% event 

% % Enable use of toolbox functions
% addpath(genpath('./../toolboxes/biosig'));
% addpath(genpath('./../toolboxes/eeglab14_1_2b'));

% load epoching data
load('./../outputs/epoch_MI_Baseline.mat');

% periodogram for all channels
fs = epochs_MI_Baseline.sampling_frequency;
overlap_time = 0.0625;
window_time = 1;

% ERD_ERS_mat : 4D array -> time x freq x trial x channel 
ERD_ERS_mat = [];

for c=1:1:size(epochs_MI_Baseline.trial, 2)
    ERD_ERS_mat = cat(4, ERD_ERS_mat, spectrogram_from_many_epochs(squeeze(epochs_MI_Baseline.trial(:,11,:)), fs, window_time, overlap_time));
end
    
imagesc(mean(squeeze(ERD_ERS_mat(:,:,:,11)), 3))


%%

noverlap = overlap_time * fs;
window = window_time * fs ; 

tmp=squeeze(epochs_MI_Baseline.trial(1,11,:));
[~,f,t,power] = spectrogram(tmp, window, noverlap, [], fs, 'power');

% get mean base line in -3 to -1 seconds
B1 = mean(power(:,round(size(power,2)/3)), 2);
%B=repmat(B1,1,round(size(power,2)));
% compute ERD/ERS [dB]
ERD_ERS = 10*log10(power./B1);

imagesc(ERD_ERS)