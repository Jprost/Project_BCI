function [baseline] = compute_baseline_spectrogram(baseline_signal, fs, window_time, non_overlap_time)
    % INPUT : baseline_signal -> temporal signal for one epoch for one channel to be used as baseline --> 1D vector
    %         fs -> sampling rate [Hz]
    %         window_time -> time width of the window for the spectrogram function
    %         overlap_time -> time of overlap between the window
    %
    % OUTPUT : 1D array containing the baseline power for each frequency
    
    window = window_time * fs; 
    noverlap = window - non_overlap_time * fs;
    
    [~,~,~,power] = spectrogram(baseline_signal, window, noverlap, [], fs, 'power');
    
    power = power(1:41,:);
    
    baseline = mean(power,2);
end

