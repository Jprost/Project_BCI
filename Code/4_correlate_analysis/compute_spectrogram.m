function [ERD_ERS_mat, t, f] = compute_spectrogram(signals, baselines, fs, window_time, non_overlap_time)
    %   UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    
    ERD_ERS_mat = [];
    
    % for each channel
    for c=1:1:size(signals.trial, 2)
        ERD_ERS_trial = [];
           
        % for each trial
        for ep=1:1:size(signals.trial, 1)
            % add the spectrogram of the given epoch at a given channel to the output array 
            baseline = compute_baseline_spectrogram(squeeze(baselines.trial(ep,c,:)), fs, window_time, non_overlap_time);
            
            [ERD_ERS_ep, t, f] = spectrogram_from_epoch(squeeze(signals.trial(ep,c,:)), baseline, fs, window_time, non_overlap_time);
            
            ERD_ERS_trial = cat(3, ERD_ERS_trial, ERD_ERS_ep);
        end
        
        ERD_ERS_mat = cat(4, ERD_ERS_mat, ERD_ERS_trial);
    end
    
end

