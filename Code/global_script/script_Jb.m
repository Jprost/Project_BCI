% Global Script for Antoine's data
% Enable use of toolboxes
addpath(genpath('./../toolboxes/biosig'));
%addpath(genpath('./../toolboxes/eeglab14_1_2b'));

oldpath = path;
path('/Applications/MATLAB_R2018b.app/toolbox/signal',oldpath)

% access functions
addpath('./../1_load_data');
addpath('./../2_preprocessing');
addpath('./../3_epoching');
addpath('./../4_correlate_analysis');
addpath('./../5_feature_extraction');

figure_path='../../Figures/Jb/';

%% Load data

% data localisation
datafolder_path = './../data/JB/';
channel_loc_path = './../data/channel_location_16_10-20_mi.mat';

% load the data
RunsData = load_data_from_runs(datafolder_path, channel_loc_path);
%save('../outputs/output_Jb/runsData.mat','RunsData')

%% Preprocess : Spatial Filtering

% load the data from the outputs folder
load('./../data/laplacian_16_10-20_mi.mat');

% Spatial filtering 
FilteredData = preprocess_all_run(RunsData, lap, true, false);

% save the data in .mat 
%save('../outputs/output_Jb/FilteredRunsData.mat','FilteredData')
    

%% Epoching

% load the data from the outputs folder
    %load('./../outputs/output_antoine/FilteredRunsData.mat'); % <- uncomment to load directly from output folder

% epochs for the baseline: 2 second before MI-start
epoch_baseline = epoching_from_event(FilteredData, 300, 2, 0);
%save('../outputs/output_Jb/epoch_baseline.mat','epoch_baseline')

% epochs centered on MI-start
epoch_MI_Start = epoching_from_event(FilteredData, 300, 3, 3);
%save('../outputs/output_Jb/epoch_MI_Start.mat','epoch_MI_Start')

% epochs centered on MI stop
epoch_MI_Stop = epoching_from_event(FilteredData, 555, 3, 3);
%save('../outputs/output_Jb/epoch_MI_Stop.mat','epoch_MI_Stop')

%% Correlate Analysis : Periodogram

oldpath = path;
path('/Applications/MATLAB_R2018b.app/toolbox/signal',oldpath)

channel_lab = {RunsData(1).channel_loc.labels};

[BL_power, BL_freq] = power_compute(epoch_baseline);
[MI_power, MI_freq] = power_compute(epoch_MI_Stop);

% Periodogram for ONE channel
figure(1)
channel_num = 16;
periodogram_plot_oneChannel(BL_power, BL_freq, MI_power, MI_freq, channel_num,channel_lab)%epoch_baseline, epoch_MI_Start, channel_num,channel_lab)
%savefig('periodogram.fig')

% Periodogram for ALL 16 channels in one plot
figure(2)
periodogram_allChannels(BL_power, BL_freq, MI_power, MI_freq, channel_lab)%epoch_baseline, epoch_MI_Start, channel_lab)
%savefig('../../Figures/Jb/all_periodogram_jb.fig')

% Periodogram for average over channels and trials
figure(3)
periodogram_averageChannels(BL_power, BL_freq, MI_power, MI_freq)%epoch_baseline, epoch_MI_Start)
%savefig('../../Figures/Jb/avg_periodogram_jb.fig')

%% Correlate Analysis : Spectrogram
% load epoching data
load('./../outputs/output_Jb/epoch_MI_Stop.mat');
load('./../outputs/output_Jb/epoch_MI_Start.mat');
load('./../outputs/output_Jb/epoch_Baseline.mat');

% spectrogram parameters
fs = epoch_MI_Start.sampling_frequency;
non_overlap_time = 0.0625;
window_time = 1;

% compute ERD_ERS_mat centered on MI-start and MI-stop
[ERD_ERS_mat_start, t_start, f_start] = compute_spectrogram(epoch_MI_Start, epoch_baseline, fs, window_time, non_overlap_time);
[ERD_ERS_mat_stop, t_stop, f_stop] = compute_spectrogram(epoch_MI_Stop, epoch_baseline, fs, window_time, non_overlap_time);

%save('./../outputs/output_jb/ERD_ERS_mat_start.mat','ERD_ERS_mat_start')
%save('./../outputs/output_jb/ERD_ERS_mat_stop.mat','ERD_ERS_mat_stop')

figure(4)
%sgtitle('Spectrogram Centered on MI-Start')
mean_ERD_ERS_mat_start= mean(squeeze(ERD_ERS_mat_start(:,:,:,:)),3);
plot_all_spectrogram(mean_ERD_ERS_mat_start, t_start, f_start)
%savefig('../../Figures/Jb/MIstart_spectrogram_jb.fig')

figure(5)
%sgtitle('Spectrogram Centered on MI-Stop')
mean_ERD_ERS_mat_stop= mean(squeeze(ERD_ERS_mat_stop(:,:,:,:)),3);
plot_all_spectrogram(mean_ERD_ERS_mat_stop, t_stop, f_stop)
%savefig('../../Figures/Jb/MIstop_spectrogram_jb.fig')



%% Correlate Analysis : Topoplots
%figure()
lower_range= 20;
upper_range= 30;
%topoplot_gif(ERD_ERS_mat_start,lower_range, upper_range,t_start, './../outputs/output_jb/')

figure(6)

j=1;
for time=1:5
    xwx=mean(mean(ERD_ERS_mat_start(20:30, find(t_start==time),:,:),3), 1);
    add_cbar = false;
    if time==5
        add_cbar = true;
    end
    
    subplot(1,5,j)
    originalSize = get(gca, 'Position');
    topo_plot(squeeze(xwx),add_cbar);
    set(gca, 'Position', originalSize);
    title(['Time ',num2str(time-3.5), ' : ', num2str(time-2.5)])
    
    j=j+1;
end
%sgtitle('Topoplot Centered on MI-Start')
%savefig('../../Figures/Jb/MIstart_topoplot_jb.fig')

figure(7)

j=1;
for time=1:5
    xwx=mean(mean(ERD_ERS_mat_stop(20:30, find(t_start==time),:,:),3), 1);
    
    add_cbar = false;
    if time==5
        add_cbar = true;
    end
    
    
    
    subplot(1,5,j)
    originalSize = get(gca, 'Position');
    topo_plot(squeeze(xwx),add_cbar);
    set(gca, 'Position', originalSize);
    title(['Time ',num2str(time-3.5), ' : ', num2str(time-2.5)])

    j=j+1;
end
%sgtitle('Topoplot Centered on MI-Stop')
%savefig('../../Figures/Jb/MIstop_topoplot_jb.fig')

%% Feature Extraction
% avoid conflict with pwelch function of eeglab toolbox

% avoid conflict with pwelch function of eeglab toolbox
oldpath = path;
path('/Applications/MATLAB_R2018b.app/toolbox/signal',oldpath)

%load trials data
    %load('./../outputs/output_antoine/epoch_MI_Stop.mat') % <- uncomment to load directly from output folder

trials = epoch_MI_Stop.trial;
time = epoch_MI_Stop.time;
win = 1;
shift = 0.0625;
start_ERD = -2;
stop_ERD = 0;
start_ERS = 0.5;
stop_ERS = 2.5;

% Get features matrix (power densitiy for all 304 features (16channels x 19freq) for 17
%windows on MI event and 17 windows on STOP event
features_mat = feat_extraction(trials, time, win, shift, start_ERD, stop_ERD, start_ERS, stop_ERS);

% save outputs feature matrix
%save('./../outputs/output_jb/features.mat','features_mat')

%% Model building
kfold = 10;
nFeatKept = 6;
% Plot (1) boxplot of CV accuracies and  (2) average ROC curves
% LDA classifier keaping 'nFeatKept' firt best features (based on fisher score)
%[~,~,~,~,fisher_scores,ord_features,~,~] = CV_avg_performance_and_featScore(kfold,features_mat(:,:,:),nFeatKept, true);

[~,~,~,~,fisher_scores,ord_features,~,~] = CV_diaglin(kfold,features_mat(:,:,:),nFeatKept, true);

%savefig('../../Figures/Jb/ROC_LDA.fig')
%savefig('../../Figures/Jb/accuracies_LDA.fig')


%Plot a heatmap channel vs freq, with avg fisher score
%[fisherScore_map] = avg_fisherScore(fisher_scores,ord_features,kfold);

%savefig('../../Figures/Jb/FeatureSelectionMap_LDA.fig')

%% Model Comparison - Accuracies & ROC
figure()
[train_mean_acc, test_mean_acc, models_labels] = models_comparison(kfold, ...
        features_mat,nFeatKept, true);


savefig('../../Figures/Jb/Models_Comparison.fig')
%% Model Comparison - nFeats

nFeats=5:20:105;
mean_tr=zeros(length(nFeats),5);
mean_te=zeros(length(nFeats),5);

i=1;
for nFeatKept=nFeats
    [train_mean_acc, test_mean_acc, models_labels] = models_comparison(kfold, ...
        features_mat,nFeatKept, false);
    
    mean_tr(i,:)=train_mean_acc;
    mean_te(i,:)=test_mean_acc;
    i=i+1;
end

%% ---- Plotting ---
figure()
for m=1:5
    subplot(1,2,1)
    title('Train accuracy')
    plot(nFeats, mean_tr(:,m),'LineWidth', 1.5 );
    ylim([65, 105]);
    hold on;
    grid on;
end 
legend(models_labels)


for m=1:5
    subplot(1,2,2)
    title('Test accuracy')
    plot(nFeats, mean_te(:,m), 'LineWidth', 1.5);
    ylim([65, 105]);
    hold on;
    grid on;
end
legend(models_labels)

savefig('../../Figures/JB/Nb_Features.fig')