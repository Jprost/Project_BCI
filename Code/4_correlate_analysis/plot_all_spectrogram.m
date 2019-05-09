function plot_all_spectrogram(mean_ERD_ERS_mat, t, f)
    %   UNTITLED7 Summary of this function goes here
    %   Detailed explanation goes here
    
    channel_names = {'FZ';'FC3';'FC1';'FCz';'FC2';'FC4';'C3';'C1';'Cz';'C2';'C4';'CP3';'CP1';'CPZ';'CP2';'CP4'};

    for c = 1:1:size(mean_ERD_ERS_mat, 4)
        if(c == 1)
           subplot(4,5,3)
           spectrogram_plot(mean_ERD_ERS_mat(:,:,c), t-3, f, channel_names{c}, true)
        else
           subplot(4,5,c+4)
           spectrogram_plot(mean_ERD_ERS_mat(:,:,c), t-3, f, channel_names{c}, false)
        end
    end
    
end

