function [features_mat] = feat_extraction(trials, time, win, shift, start_ERD, stop_ERD, start_ERS, stop_ERS)
%Perform sequential Pwelch over 1s on ERD and ERS subpart of all trials, for
%Feature Extraction
%  
%   Input :
%       - trials : all trials output from epoching. 
%                   Dim (trials x Channel x time)
%                   WARNING : Need an epoching -3 +3 aroung MI_STOP event
%       - time : time value associated with the epoch
%       - win : time window in s on wich pwelch is compute
%       - shift : time overlap in s to shift windwo and compute next Pwelch
%       - start : Time in second from EVENT, where to start feature extr.
%       - stop : Time in second from EVENT, where to stop feature extr.
%                If MI-STOP event:
%                   ERD (Class 0) : start = -2   stop = 0
%                   ERS (Class 1) : start = 0.5 stop = 2.5
%
%
%   Output :
%       features_mat : 34 x 304 x 80   =  samples x Features x nTrials
%       All Features (channels & freq) for all trials and all 1s window
%       shifted (samples)
%       feat_oneTrial : 34 x 304   concatenate both output of windowing()
%       on ERD and ERS subpart of trial
%       34 samples (34 pwelch power) on 19freq and 16channel = 304 features
%       17 first samples are ERD (CLASS 0) and 17 last ERS (CLASS 1)

%Loop over trial
nTrials = size(trials,1);

features_mat = [];

for itrial = 1:nTrials
    thisTrial = trials(itrial,:,:);
    feat_oneTrial_ERD = windowing(thisTrial, time, win, shift, start_ERD, stop_ERD);
    %17 x 304
    feat_oneTrial_ERS = windowing(thisTrial, time, win, shift, start_ERS, stop_ERS);

    feat_oneTrial = cat(1,feat_oneTrial_ERD,feat_oneTrial_ERS); %32 x 304
    
    features_mat = cat(3,features_mat,feat_oneTrial);
    % 34 x 304 x 80   =  samples x Features x nTrials

end

end

