function [ERD_ERS, t, f] = spectrogram_from_epoch(epoch, fs, window_time, non_overlap_time)
    % INPUT : epoch -> temporal signal for one epoch for one channel --> 1D vector
    %         fs -> sampling rate [Hz]
    %         window_time -> time width of the window for the spectrogram function
    %         overlap_time -> time of overlap between the window
    % OUTPUT : 2D array containing the ERG/ERS power signal 
    %          dim1 : time ; dim2 : freq
    
    window = window_time * fs; 
    noverlap = window - non_overlap_time * fs;
    
    [~,f,t,power] = spectrogram(epoch, window, noverlap, [], fs, 'power');
    
    f=f(1:41);
    power = power(1:41,:);
    
    % get mean base line in -3 to -1 seconds
    B = repmat(mean(power(:,1:find(t==2)),2), 1, size(power,2));
    
    % compute ERD/ERS [dB]
    ERD_ERS = 10*log10(power./B);
end

