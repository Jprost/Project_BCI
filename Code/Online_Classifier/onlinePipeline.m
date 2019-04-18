function [prob_list,prob_list_filtered,mean_t] = onlinePipeline(RunsDataOnline,model,mu,sigma,orderedInd,nFeatKept,window_size)
% This function computes features and classes probabilities on a moving window (like an online run)
% INPUT
%     - RunsDataOnline : The data used as an "online" run
%     - window_size : Size of the sliding window (32 by default)
%     - mu / sigma : normalization factors from z-score on train
%     
% OUTPUT
%     - Plot of the Class 1 propability, with the corresponding timing of MI Start/Stop events
%     - Prob_list and Prob_list_filtered
%     - mean_t : The mean time taken for the full filtering/feature extraction/classification on 1 window

fs = RunsDataOnline.sampling_rate;
n = length(RunsDataOnline.signal(1,:));
i=1;
y_list = [];
prob_list = [];
prob_list_filtered = [];

Mi_start_times = floor(RunsDataOnline.event.action_pos(RunsDataOnline.event.action_type == 300)/window_size);
Mi_stop_times = floor(RunsDataOnline.event.action_pos(RunsDataOnline.event.action_type == 555)/window_size);


alpha = 0.96;

t = [];

while i<(n-fs)
    tic;
    start = i;
    stop = i+fs-1;
    test = RunsDataOnline.signal(:,start:stop);
    test = reshape(test,[1,16,512]);

    feat_online = feat_extraction_online(test);
    
    feat_online_norm = (feat_online-mu)./sigma;
    
    feat_online_kept = feat_online_norm(:,orderedInd(1:nFeatKept));
    
    [y,score] = predict(model, feat_online_kept);
    i = i+window_size;
    y_list = [y_list [y]];
    prob_list = [prob_list score(1)];
    
    if length(prob_list)<2
        prob_list_filtered(end+1) = 0.5;
    elseif ((i/window_size)>Mi_start_times(1) && length(Mi_start_times)>1) % To set the prob to 0.5 at MI_Start
        prob_list_filtered(end+1) = 0.5;
        Mi_start_times = Mi_start_times(2:end);
    else
        prob_list_filtered(end+1) = alpha*prob_list_filtered(end)+(1-alpha)*prob_list(end);
    end   
    t(end+1)=1000*toc;
    
end   

mean_t = mean(t);
windows = 1:1:length(y_list);

Mi_start_times = floor(RunsDataOnline.event.action_pos(RunsDataOnline.event.action_type == 300)/window_size);
ystart = zeros(length(Mi_start_times),1);
ystop = ones(length(Mi_start_times),1);
hold all
plot(windows,prob_list_filtered)
MIstart = plot([Mi_start_times.';Mi_start_times.'],[ystart.';ystop.'],'r');
MIstop = plot([Mi_stop_times.';Mi_stop_times.'],[ystart.';ystop.'],'k');
plot([1 windows(end)],[0.5 0.5],'linestyle','--','color','b')
xlabel('Window index')
ylabel('Probability to belong to MI class')
legend("Filtered probability")
legend([MIstart(1), MIstop(1)], 'MI Start', 'MI Stop')
title("Online run using a 1s long window")
end

