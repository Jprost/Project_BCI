function plot_all_spectrogram(ERD_ERS_mat, t, f)
    %   UNTITLED7 Summary of this function goes here
    %   Detailed explanation goes here
    
    channel_names = {'FZ';'FC3';'FC1';'FCz';'FC2';'FC4';'C3';'C1';'Cz';'C2';'C4';'CP3';'CP1';'CPZ';'CP2';'CP4'};

    for c = 1:1:size(ERD_ERS_mat, 4)
        if(c == 1)
           subplot(4,5,3)
           spectrogram_plot(mean(squeeze(ERD_ERS_mat(:,:,:,c)), 3), t-3, f, channel_names{c})
        else
           subplot(4,5,c+4)
           spectrogram_plot(mean(squeeze(ERD_ERS_mat(:,:,:,c)), 3), t-3, f, channel_names{c})
        end
    end
    
end

