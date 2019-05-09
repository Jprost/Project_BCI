% Global Script for Antoine's data
% Enable use of toolboxe biosig
addpath(genpath('./../toolboxes/biosig'));
%addpath(genpath('./../toolboxes/eeglab14_1_2b'));

oldpath = path;
path('/Applications/MATLAB_R2017b.app/toolbox/signal',oldpath)

% access functions
addpath('./../1_load_data');
addpath('./../2_preprocessing');
addpath('./../3_epoching');
addpath('./../4_correlate_analysis');
addpath('./../5_feature_extraction');

%% Load data

% data localisation
datafolder_path = './../data/data_Sacha/';
channel_loc_path = './../data/channel_location_16_10-20_mi.mat';

% load the data
RunsData = load_data_from_runs(datafolder_path, channel_loc_path);

% clean Run n°3 (missing data)
% take only the event represented on the signal available and make sur the last event is a end of trial event (event_id = 700)
len_corrupted_run = size(RunsData(3).signal, 2);
upper_idx_to_keep = find((RunsData(3).event.action_pos < len_corrupted_run) & (RunsData(3).event.action_type == 700), 1, 'last');
RunsData(3).event.action_pos = RunsData(3).event.action_pos(1:upper_idx_to_keep, :);
RunsData(3).event.action_type = RunsData(3).event.action_type(1:upper_idx_to_keep, :);

save('../outputs/output_sacha/runsData.mat','RunsData')

%% Preprocess : Spatial Filtering

% load the data from the outputs folder
load('./../data/laplacian_16_10-20_mi.mat');
    %load('./../outputs/output_antoine/runsData.mat') % <- uncomment to load directly from output folder

% Spatial filtering 
FilteredData = preprocess_all_run(RunsData, lap, true, false);

% save the data in .mat 
save('../outputs/output_sacha/FilteredRunsData.mat','FilteredData')
    

%% Epoching

% load the data from the outputs folder
    %load('./../outputs/output_antoine/FilteredRunsData.mat'); % <- uncomment to load directly from output folder

% epochs for the baseline: 2 second before MI-start
epoch_baseline = epoching_from_event(FilteredData, 300, 2, 0);
save('../outputs/output_sacha/epoch_baseline.mat','epoch_baseline')

% epochs centered on MI-start
epoch_MI_Start = epoching_from_event(FilteredData, 300, 3, 3);
save('../outputs/output_sacha/epoch_MI_Start.mat','epoch_MI_Start')

% epochs centered on MI stop
epoch_MI_Stop = epoching_from_event(FilteredData, 555, 3, 3);
save('../outputs/output_sacha/epoch_MI_Stop.mat','epoch_MI_Stop')

%% Correlate Analysis : Periodogram

%Load Epochs
load('./../outputs/output_sacha/epoch_baseline.mat') % <- uncomment to load directly from output folder
load('./../outputs/output_sacha/epoch_MI_Start.mat') % <- uncomment to load directly from output folder
runData = load('./../outputs/output_sacha/runsData.mat'); % <- uncomment to load directly from output folder
channel_lab = {RunsData(1).channel_loc.labels};

[BL_power, BL_freq] = power_compute(epoch_baseline);
[MI_power, MI_freq] = power_compute(epoch_MI_Start);

% Periodogram for ONE channel
figure(1)
channel_num = 16;
periodogram_plot_oneChannel(BL_power, BL_freq, MI_power, MI_freq, channel_num,channel_lab)%epoch_baseline, epoch_MI_Start, channel_num,channel_lab)
%savefig('periodogram.fig')

% Periodogram for ALL 16 channels in one plot
figure(2)
periodogram_allChannels(BL_power, BL_freq, MI_power, MI_freq, channel_lab)%epoch_baseline, epoch_MI_Start, channel_lab)
savefig('../../Figures/sacha/all_periodogram_sacha.fig')

% Periodogram for average over channels and trials
figure(3)
periodogram_averageChannels(BL_power, BL_freq, MI_power, MI_freq)%epoch_baseline, epoch_MI_Start)
savefig('../../Figures/sacha/avg_periodogram_sacha.fig')

%% Correlate Analysis : Spectrogram
% load epoching data
load('./../outputs/output_sacha/epoch_MI_Stop.mat'); % <- uncomment to load directly from output folder
load('./../outputs/output_sacha/epoch_MI_Start.mat'); % <- uncomment to load directly from output folder
load('./../outputs/output_sacha/epoch_baseline.mat'); % <- uncomment to load directly from output folder

% spectrogram parameters
fs = epoch_MI_Start.sampling_frequency;
non_overlap_time = 0.0625;
window_time = 1;

% compute ERD_ERS_mat centered on MI-start and MI-stop
[ERD_ERS_mat_start, t_start, f_start] = compute_spectrogram(epoch_MI_Start, epoch_baseline, fs, window_time, non_overlap_time);
[ERD_ERS_mat_stop, t_stop, f_stop] = compute_spectrogram(epoch_MI_Stop, epoch_baseline, fs, window_time, non_overlap_time);

figure(4)
%sgtitle('Spectrogram Centered on MI-Start')
plot_all_spectrogram(mean(ERD_ERS_mat_start,3), t_start, f_start)
savefig('../../Figures/sacha/MIstart_spectrogram_sacha.fig')

figure(5)
%sgtitle('Spectrogram Centered on MI-Stop')
plot_all_spectrogram(mean(ERD_ERS_mat_stop,3), t_stop, f_stop)
savefig('../../Figures/sacha/MIstop_spectrogram_sacha.fig')

% save outputs
save('../outputs/output_sacha/ERD_ERS_mat_start.mat','ERD_ERS_mat_start')
save('../outputs/output_sacha/ERD_ERS_mat_stop.mat','ERD_ERS_mat_stop')

%% Correlate Analysis : Topoplots

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
savefig('../../Figures/sacha/MIstart_topoplot_sacha.fig')

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
savefig('../../Figures/sacha/MIstop_topoplot_sacha.fig')



%% Feature Extraction

% avoid conflict with pwelch function of eeglab toolbox
oldpath = path;
path('/Applications/MATLAB_R2017b.app/toolbox/signal',oldpath)

%load trials data
load('./../outputs/output_sacha/epoch_MI_Stop.mat') % <- uncomment to load directly from output folder

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
save('../outputs/output_sacha/features.mat','features_mat')


%% Model building
kfold = 10;
nFeatKept = 6;
% Plot (1) boxplot of CV accuracies and  (2) average ROC curves
% LDA classifier keaping 'nFeatKept' firt best features (based on fisher score)
[~,~,~,~,fisher_scores,ord_features,~,~] = CV_avg_performance_and_featScore(kfold,features_mat(:,:,1:60),nFeatKept, true);

%Plot a heatmap channel vs freq, with avg fisher score
[fisherScore_map] = avg_fisherScore(fisher_scores,ord_features,kfold);
