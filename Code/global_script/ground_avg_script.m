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
% m1 = load('./../outputs/output_antoine/epoch_MI_Start.mat');
% m2 = load('./../outputs/output_JB/epoch_MI_Start.mat');
% m3 = load('./../outputs/output_sacha/epoch_MI_Start.mat');
% m4 = load('./../outputs/output_Thomas/epoch_MI_Start.mat');
% 
% MI_start = m1.epoch_MI_Start;
% MI_start.trial = epochs_for_all_subjects({m1.epoch_MI_Start.trial, m2.epoch_MI_Start.trial, m3.epoch_MI_Start.trial, m4.epoch_MI_Start.trial});
% 
% % MI_stop epochs
% m1 = load('./../outputs/output_antoine/epoch_MI_Stop.mat');
% m2 = load('./../outputs/output_JB/epoch_MI_Stop.mat');
% m3 = load('./../outputs/output_sacha/epoch_MI_Stop.mat');
% m4 = load('./../outputs/output_Thomas/epoch_MI_Stop.mat');
% 
% MI_stop = m1.epoch_MI_Stop;
% MI_stop.trial = epochs_for_all_subjects({m1.epoch_MI_Stop.trial, m2.epoch_MI_Stop.trial, m3.epoch_MI_Stop.trial, m4.epoch_MI_Stop.trial});
% 
% % baseline epochs
% m1 = load('./../outputs/output_antoine/epoch_baseline.mat');
% m2 = load('./../outputs/output_JB/epoch_baseline.mat');
% m3 = load('./../outputs/output_sacha/epoch_baseline.mat');
% m4 = load('./../outputs/output_Thomas/epoch_baseline.mat');
% 
% baseline = m1.epoch_baseline;
% baseline.trial = epochs_for_all_subjects({m1.epoch_baseline.trial, m2.epoch_baseline.trial, m3.epoch_baseline.trial, m4.epoch_baseline.trial});
% 
% % in the end --> Structures with, as trial, a 4D array for the 4 subjects
% 
% % save output
% save('../outputs/output_ground_avg/epoch_MI_Start.mat','MI_start')
% save('../outputs/output_ground_avg/epoch_MI_Stop.mat','MI_stop')
% save('../outputs/output_ground_avg/epoch_baseline.mat','baseline')
% 
% %% Mean epochs over subjects without considering padding NaN
% 
% MI_start.trial = mean(MI_start.trial, 4, 'omitnan');
% MI_stop.trial = mean(MI_stop.trial, 4, 'omitnan');
% baseline.trial = mean(baseline.trial, 4, 'omitnan');
% 
% %% Correlate Analysis : Periodogram
% load(channel_loc_path)
% channel_lab = {chanlocs16.labels};
% 
% % Periodogram for ONE channel
% figure(1)
% channel_num = 16;
% periodogram_plot_oneChannel(baseline, MI_start, channel_num, channel_lab)
% 
% % Periodogram for ALL 16 channels in one plot
% figure(2)
% periodogram_allChannels(baseline, MI_start, channel_lab)
% 
% % Periodogram for average over channels and trials
% figure(3)
% periodogram_averageChannels(baseline, MI_start)

%% Correlate Analysis : Spectrogram 

% FOR MI_START
% load ERD_ERS_mat of each subject
m1 = load('./../outputs/output_antoine/ERD_ERS_mat_start.mat');
m2 = load('./../outputs/output_JB/ERD_ERS_mat_start.mat');
%m3 = load('./../outputs/output_sacha/ERD_ERS_mat_start.mat');
m4 = load('./../outputs/output_Thomas/ERD_ERS_mat_start.mat');

all_ERD_ERS_start = padcat_ERDERS({m1.ERD_ERS_mat_start, m2.ERD_ERS_mat_start, m4.ERD_ERS_mat_start}, 5); 
ground_ERD_ERS_start = mean(all_ERD_ERS_start, 5, 'omitnan');
t_start = 0.5:0.0625:5.5;
f_start = [0:1:40]';

figure()
sgtitle('Spectrogram Centered on MI-Start')
plot_all_spectrogram(ground_ERD_ERS_start, t_start, f_start)

% FOR MI_STOP
m1 = load('./../outputs/output_antoine/ERD_ERS_mat_stop.mat');
m2 = load('./../outputs/output_JB/ERD_ERS_mat_stop.mat');
%m3 = load('./../outputs/output_sacha/ERD_ERS_mat_stop.mat');
m4 = load('./../outputs/output_Thomas/ERD_ERS_mat_stop.mat');

all_ERD_ERS_stop = padcat_ERDERS({m1.ERD_ERS_mat_stop, m2.ERD_ERS_mat_stop, m4.ERD_ERS_mat_stop}, 5); 
ground_ERD_ERS_stop = mean(all_ERD_ERS_stop, 5, 'omitnan');
t_stop = 0.5:0.0625:5.5;
f_stop = [0:1:40]';

figure()
sgtitle('Spectrogram Centered on MI-Stop')
plot_all_spectrogram(ground_ERD_ERS_stop, t_stop, f_stop)

%% Correlate Analysis : Topoplot

figure()

j=1;
for time=1:5
    xwx=mean(ground_ERD_ERS_start(20, find(t_start==time),:,:), 3);
    
    subplot(2,3,j)
    topo_plot(squeeze(xwx),true);
    title(['Time ',int2str(time-3)])
    
    j=j+1;
end  

%% Model Building

% load feature_mat 
f1 = load('./../outputs/output_antoine/features.mat');
f2 = load('./../outputs/output_sacha/features.mat');

fisher_scores_all = [];
ord_features_all = [];
xroc_train = {};
yroc_train = {};
xroc_test = {};
yroc_test = {};

% build model for each feature_mat & concatenate output on single matrices
kfold = 10;
nFeatKept = 6;

% Plot (1) boxplot of CV accuracies and  (2) average ROC curves
% LDA classifier keaping 'nFeatKept' firt best features (based on fisher score)
[xroc_train_avg,yroc_train_avg,xroc_test_avg,yroc_test_avg,fisher_scores,ord_features] = CV_avg_performance_and_featScore(kfold,f1.features_mat(:,:,1:70),nFeatKept);

fisher_scores_all = cat(3, fisher_scores_all, fisher_scores);
ord_features_all = cat(3, ord_features_all, ord_features);
xroc_train{end+1} = xroc_train_avg;
yroc_train{end+1} = yroc_train_avg;
xroc_test{end+1} = xroc_test_avg;
yroc_test{end+1} = yroc_test_avg;

[xroc_train_avg,yroc_train_avg,xroc_test_avg,yroc_test_avg,fisher_scores,ord_features] = CV_avg_performance_and_featScore(kfold,f2.features_mat,nFeatKept);

fisher_scores_all = cat(3, fisher_scores_all, fisher_scores);
ord_features_all = cat(3, ord_features_all, ord_features);
xroc_train{end+1} = xroc_train_avg;
yroc_train{end+1} = yroc_train_avg;
xroc_test{end+1} = xroc_test_avg;
yroc_test{end+1} = yroc_test_avg;

% average in dimension of subject 
fisher_scores_all = mean(fisher_scores_all, 3);
ord_features_all = mean(ord_features_all, 3);
xroc_train_ground = mean(padcat1D(xroc_train,2), 2, 'omitnan');
yroc_train_ground = mean(padcat1D(yroc_train,2), 2, 'omitnan');
xroc_test_ground = mean(padcat1D(xroc_test,2), 2, 'omitnan');
yroc_test_ground = mean(padcat1D(yroc_test,2), 2, 'omitnan');

% do plots
figure
hold on;
plot(xroc_train_ground,yroc_train_ground,'Color',[1,0.5,0.3,1], 'Linewidth',3)
plot(xroc_test_ground,yroc_test_ground,'Color',[0.3,0.5,1,1], 'Linewidth', 3)

for i=1:1:(size(xroc_train,2))
    plot(cell2mat(xroc_train(i)),cell2mat(yroc_train(i)),'Color',[1,0.5,0.3,0.2], 'Linewidth',3)
end

for i=1:1:(size(xroc_test,2))
    plot(cell2mat(xroc_test(i)),cell2mat(yroc_test(i)),'Color',[0.3,0.5,1,0.2], 'Linewidth',3)
end

xlabel('False positive rate') 
ylabel('True positive rate')
legend('train','test', 'Location','SouthEast')
title('ROC for Classification, Class 1 (Offset) averaged over subjects')

%% Plot a heatmap channel vs freq, with avg fisher score
[fisherScore_map] = avg_fisherScore(fisher_scores_all,ord_features_all,kfold);
