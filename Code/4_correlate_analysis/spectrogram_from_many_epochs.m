function ERD_ERS_mat = spectrogram_from_many_epochs(trials, fs, window_time, overlap_time)
    % INPUT : trials -> 2D array of trials for all epochs : trial x time
    %         fs -> sampling rate [Hz]
    %         window_time -> time width of the window for the spectrogram function
    %         overlap_time -> time of overlap between the window
    % OUTPUT : 3D array of the spectrogram of all epochs : time x freq x trials
    
    ERD_ERS_mat = [];
    
    for ep=1:1:size(trials, 1)
        % add the spectrogram of the given epoch at a given channel to the output array 
        ERD_ERS_mat = cat(3, ERD_ERS_mat, spectrogram_from_epoch(squeeze(trials(ep,:)), fs, window_time, overlap_time));
    end
end

