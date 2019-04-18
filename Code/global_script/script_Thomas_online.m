% Global Script for Antoine's data
% Enable use of toolboxe biosig
addpath(genpath('./../toolboxes/biosig'));
%addpath(genpath('./../toolboxes/eeglab14_1_2b'));

% access functions
addpath('./../1_load_data');
addpath('./../2_preprocessing');
addpath('./../3_epoching');
addpath('./../4_correlate_analysis');
addpath('./../5_feature_extraction');

%% Load data

% data localisation
datafolder_path = './../data_online/data_Thomas/data_train/';
channel_loc_path = './../data/channel_location_16_10-20_mi.mat';

% load the data
RunsData = load_data_from_runs(datafolder_path, channel_loc_path);
save('../outputs/output_thomas_online/runsData.mat','RunsData')

% online data 
RunsDataOnline = load_data_from_runs('./../data_online/data_Thomas/data_test/', channel_loc_path);

%% Preprocess : Spatial Filtering

% load the data from the outputs folder
load('./../data_online/laplacian_16_10-20_mi.mat');
    %load('./../outputs/output_antoine/runsData.mat') % <- uncomment to load directly from output folder

% Spatial filtering 
FilteredData = preprocess_all_run(RunsData, lap, true);
FilteredDataOnline = preprocess_all_run(RunsDataOnline, lap, true);

% save the data in .mat 
save('../outputs/output_thomas_online/FilteredRunsData.mat','FilteredData')
save('../outputs/output_thomas_online/FilteredRunsDataOnline.mat','FilteredDataOnline')
    

%% Epoching

% load the data from the outputs folder
    %load('./../outputs/output_antoine/FilteredRunsData.mat'); % <- uncomment to load directly from output folder

% epochs for the baseline: 2 second before MI-start
epoch_baseline = epoching_from_event(FilteredData, 300, 2, 0);
save('../outputs/output_thomas_online/epoch_baseline.mat','epoch_baseline')

% epochs centered on MI-start
epoch_MI_Start = epoching_from_event(FilteredData, 300, 3, 3);
save('../outputs/output_thomas_online/epoch_MI_Start.mat','epoch_MI_Start')

% epochs centered on MI stop
epoch_MI_Stop = epoching_from_event(FilteredData, 555, 3, 3);
save('../outputs/output_thomas_online/epoch_MI_Stop.mat','epoch_MI_Stop')


%% Feature Extraction

%Load Epochs
load('./../outputs/output_thomas_online/epoch_MI_Stop.mat')

%Fixed parameters
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


%% Model building

% LDA classifier keaping 'nFeatKept' firt best features (based on fisher score)
nFeatKept = 6;
[model, mu, sigma,orderedInd] = model_train_for_online(features_mat,nFeatKept);


%% Testing

fs = RunsDataOnline.sampling_rate;
n = length(RunsDataOnline.signal(1,:));
i=1;
y_list = [];
prob_list = [];
prob_list_filtered = [];

Mi_start_times = floor(RunsDataOnline.event.action_pos(RunsDataOnline.event.action_type == 300)/32);
Mi_stop_times = floor(RunsDataOnline.event.action_pos(RunsDataOnline.event.action_type == 555)/32);


alpha = 0.96;
beta = 0.04;

t = []

while i<(n-fs)
    tic;
    start = i;
    stop = i+fs-1;
    test = RunsDataOnline.signal(:,start:stop);
    test = reshape(test,[1,16,512]);

    feat_online = windowing_online(test);
    
    feat_online_norm = (feat_online-mu)./sigma;
    
    feat_online_kept = feat_online_norm(:,orderedInd(1:nFeatKept));
    
    [y,score] = predict(model, feat_online_kept);
    i = i+32;
    y_list = [y_list [y]];
    prob_list = [prob_list score(1)];
    
    if length(prob_list)<2
        prob_list_filtered(end+1) = 0.5;
    elseif ((i/32)>Mi_start_times(1) && length(Mi_start_times)>1) % To set the prob to 0.5 at MI_Start
        prob_list_filtered(end+1) = 0.5;
        Mi_start_times = Mi_start_times(2:end);
    else
        prob_list_filtered(end+1) = alpha*prob_list_filtered(end)+(1-alpha)*prob_list(end);
    end   
    t(end+1)=1000*toc;
    
end   

windows = 1:1:length(y_list);
Mi_start_times = floor(RunsDataOnline.event.action_pos(RunsDataOnline.event.action_type == 300)/32);
ystart = zeros(length(Mi_start_times),1);
ystop = ones(length(Mi_start_times),1);
hold all
plot(windows,prob_list_filtered)
%plot(windows,prob_list)
plot([Mi_start_times.';Mi_start_times.'],[ystart.';ystop.'],'r')
plot([Mi_stop_times.';Mi_stop_times.'],[ystart.';ystop.'],'k')
plot([1 windows(end)],[0.5 0.5],'linestyle','--','color','b')



