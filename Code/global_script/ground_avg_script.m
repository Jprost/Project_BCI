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

%% Correlate Analysis : Periodogram
oldpath = path;
path('/Applications/MATLAB_R2018b.app/toolbox/signal',oldpath)

m1 = load('./../outputs/output_antoine/epoch_MI_Start.mat');
m2 = load('./../outputs/output_JB/epoch_MI_Start.mat');
m3 = load('./../outputs/output_sacha/epoch_MI_Start.mat');
m4 = load('./../outputs/output_Thomas/epoch_MI_Start.mat');

b1 = load('./../outputs/output_antoine/epoch_baseline.mat');
b2 = load('./../outputs/output_JB/epoch_baseline.mat');
b3 = load('./../outputs/output_sacha/epoch_baseline.mat');
b4 = load('./../outputs/output_Thomas/epoch_baseline.mat');

[BL_power1, BL_freq1] = power_compute(b1.epoch_baseline);
[MI_power1, MI_freq1] = power_compute(m1.epoch_MI_Start);

[BL_power2, BL_freq2] = power_compute(b2.epoch_baseline);
[MI_power2, MI_freq2] = power_compute(m2.epoch_MI_Start);

[BL_power3, BL_freq3] = power_compute(b3.epoch_baseline);
[MI_power3, MI_freq3] = power_compute(m3.epoch_MI_Start);

[BL_power4, BL_freq4] = power_compute(b4.epoch_baseline);
[MI_power4, MI_freq4] = power_compute(m4.epoch_MI_Start);
%Power is of dimension : Channel x Power x trials
%%
% concat all power in the 4th dimension and fill 'holes' with nan
all_BL_power = padcat_power({BL_power1, BL_power2, BL_power3, BL_power4}, 4);
all_MI_power = padcat_power({MI_power1, MI_power2, MI_power3, MI_power4}, 4);

% mean on the 4th dimension by omitting nan
mean_BL_power = mean(all_BL_power, 4, 'omitnan');
mean_MI_power = mean(all_MI_power, 4, 'omitnan');

% plot
load(channel_loc_path)
channel_lab = {chanlocs16.labels};

figure(1)
channel_num = 16;
periodogram_plot_oneChannel(mean_BL_power, BL_freq1, mean_MI_power, MI_freq1, channel_num,channel_lab)

% Periodogram for ALL 16 channels in one plot
figure(2)
periodogram_allChannels(mean_BL_power, BL_freq1, mean_MI_power, MI_freq1, channel_lab)
savefig('../../Figures/Grand_avg/all_periodogram_GrandAvg.fig')

% Periodogram for average over channels and trials
figure(3)
periodogram_averageChannels(mean_BL_power, BL_freq1, mean_MI_power, MI_freq1)
savefig('../../Figures/Grand_avg/avg_periodogram_GrandAvg.fig')

%% Correlate Analysis : Spectrogram 

% FOR MI_START
% load ERD_ERS_mat of each subject
m1 = load('./../outputs/output_antoine/ERD_ERS_mat_start.mat');
m2 = load('./../outputs/output_JB/ERD_ERS_mat_start.mat');
m3 = load('./../outputs/output_sacha/ERD_ERS_mat_start.mat');
m4 = load('./../outputs/output_Thomas/ERD_ERS_mat_start.mat');

all_ERD_ERS_start = padcat_ERDERS({m1.ERD_ERS_mat_start, m2.ERD_ERS_mat_start, m4.ERD_ERS_mat_start}, 5); 
ground_ERD_ERS_start = mean(all_ERD_ERS_start, 5, 'omitnan');
t_start = 0.5:0.0625:5.5;
f_start = [0:1:40]';

figure()
sgtitle('Spectrogram Centered on MI-Start')
plot_all_spectrogram(ground_ERD_ERS_start, t_start, f_start)
savefig('../../Figures/Grand_avg/MIstart_spectrogram_GrandAvg.fig')

% FOR MI_STOP
m1 = load('./../outputs/output_antoine/ERD_ERS_mat_stop.mat');
m2 = load('./../outputs/output_JB/ERD_ERS_mat_stop.mat');
m3 = load('./../outputs/output_sacha/ERD_ERS_mat_stop.mat');
m4 = load('./../outputs/output_Thomas/ERD_ERS_mat_stop.mat');

all_ERD_ERS_stop = padcat_ERDERS({m1.ERD_ERS_mat_stop, m2.ERD_ERS_mat_stop, m3.ERD_ERS_mat_stop m4.ERD_ERS_mat_stop}, 5); 
ground_ERD_ERS_stop = mean(all_ERD_ERS_stop, 5, 'omitnan');
t_stop = 0.5:0.0625:5.5;
f_stop = [0:1:40]';

figure()
sgtitle('Spectrogram Centered on MI-Stop')
plot_all_spectrogram(ground_ERD_ERS_stop, t_stop, f_stop)
savefig('../../Figures/Grand_avg/MIstop_spectrogram_GrandAvg.fig')

%% Correlate Analysis : Topoplot

figure()
j=1;
for time=1:5
    xwx=mean(mean(mean(all_ERD_ERS_start(20:30, find(t_start==time),:,:),3), 1), 5);
    
    add_cbar = false;
    if time==5
        add_cbar = true;
    end
    
    subplot(1,5,j)
    originalSize = get(gca, 'Position');
    topo_plot(squeeze(xwx),add_cbar);
    set(gca, 'Position', originalSize);
    title(['Time : ', num2str(time-3.5), ' : ', num2str(time-2.5)])
    
    j=j+1;
end  
sgtitle('Topoplot Centered on MI-Start')
savefig('../../Figures/Grand_avg/MIstart_topoplot_GrandAvg.fig')

figure()
j=1;
for time=1:5
    xwx=mean(mean(mean(all_ERD_ERS_stop(20:30, find(t_start==time),:,:),3), 1), 5);
    
    add_cbar = false;
    if time==5
        add_cbar = true;
    end
    
    subplot(1,5,j)
    originalSize = get(gca, 'Position');
    topo_plot(squeeze(xwx),add_cbar);
    set(gca, 'Position', originalSize);
    title(['Time : ', num2str(time-3.5), ' : ', num2str(time-2.5)])
    
    j=j+1;
end 
sgtitle('Topoplot Centered on MI-Stop')
savefig('../../Figures/Grand_avg/MIstop_topoplot_GrandAvg.fig')

%% Model Building

% load feature_mat 
f1 = load('./../outputs/output_antoine/features.mat');
f2 = load('./../outputs/output_sacha/features.mat');
f3 = load('./../outputs/output_JB/features.mat');
f4 = load('./../outputs/output_thomas/features.mat');

fmat = {f1.features_mat(:,:,1:70), f2.features_mat, f3.features_mat, f4.features_mat};

fisher_scores_all = [];
ord_features_all = [];
xroc_train = {};
yroc_train = {};
xroc_test = {};
yroc_test = {};
accuracy_train = [];
accuracy_test =[];

% build model for each feature_mat & concatenate output on single matrices
kfold = 10;
nFeatKept = 6;

% Plot (1) boxplot of CV accuracies and  (2) average ROC curves
% LDA classifier keaping 'nFeatKept' firt best features (based on fisher score)
for i = 1:1:size(fmat,2)
    [xroc_train_avg,yroc_train_avg,xroc_test_avg,yroc_test_avg,fisher_scores,ord_features, acc_train, acc_test] = CV_avg_performance_and_featScore(kfold,cell2mat(fmat(i)),nFeatKept, false);

    fisher_scores_all = cat(3, fisher_scores_all, fisher_scores);
    ord_features_all = cat(3, ord_features_all, ord_features);
    xroc_train{end+1} = xroc_train_avg;
    yroc_train{end+1} = yroc_train_avg;
    xroc_test{end+1} = xroc_test_avg;
    yroc_test{end+1} = yroc_test_avg;
    accuracy_train = cat(1, accuracy_train, mean(acc_train));
    accuracy_test = cat(1, accuracy_test, mean(acc_test));
 end

% average in dimension of subject 
xroc_train_ground = mean(padcat1D(xroc_train,2), 2, 'omitnan');
yroc_train_ground = mean(padcat1D(yroc_train,2), 2, 'omitnan');
xroc_test_ground = mean(padcat1D(xroc_test,2), 2, 'omitnan');
yroc_test_ground = mean(padcat1D(yroc_test,2), 2, 'omitnan');
accuracy_train_ground = accuracy_train;%mean(accuracy_train, 2);
accuracy_test_ground = accuracy_test;%mean(accuracy_test, 2);

% do plots
figure
x = [accuracy_train_ground, accuracy_test_ground];
boxplot(x,'Labels',{'train accuracy','test accuracy'})
title('Model train/test accuracies over all subjects')

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
% normalize over subjects the fisher scores to enables comparison
for i=1:1:size(fisher_scores_all, 3)
    max_score = max(fisher_scores_all(:,:,i),[],[1 2]);
    min_score = min(fisher_scores_all(:,:,i),[],[1 2]);
    
    fisher_scores_all(:,:,i) = (fisher_scores_all(:,:,i) - min_score)./(max_score - min_score);
end

% reordonnate features 
fisher_scores_all_avg = zeros(size(fisher_scores_all));

for i=1:1:size(fisher_scores_all, 3)
    for feat=1:1:size(fisher_scores_all, 2) 
       for fold=1:1:size(fisher_scores_all, 1)
            fisher_scores_all_avg(fold,ord_features_all(fold,feat,i),i) = fisher_scores_all(fold,feat,i);
       end
   end 
end

% average score
fisher_scores_all_avg = mean(fisher_scores_all_avg, 3);

% plot
[fisherScore_map] = avg_fisherScore(fisher_scores_all_avg(:,:),repmat(1:304,10,1),kfold);
