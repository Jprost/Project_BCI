function spectrogram_plot(ERD_ERS_mat, t, f, title_plot)
    % INPUT: ERD_ERS_mat -> Spectrogram data to plot for a given channel (or mean over channels) or a given trial (or mean over trials)
    %              >>> 2D array : dim2 (x) = time ; dim1 (y) = frequency
    %        t -> 1D array representing the time vector
    %        f -> 1D array representing the frequency vector
    
    clims = [-5 5];
    imagesc(ERD_ERS_mat, clims)
    colormap jet;
    c = colorbar;
    c.Label.String = 'ERD/ERS [dB]';
    c.Label.FontSize = 15;
    title(title_plot, 'FontSize', 20)
    
    % set the xtick with the input time values
    xticks(9:16:size(t,2))
    xticklabels(t(9:16:size(t,2)))
    xtickangle(90)
    xlabel('time [s]', 'FontSize', 15)
   
    % set the ytick with the input freq values
    yticks(1:5:size(f,1))
    yticklabels(f(1:5:size(f,1)))
    ylabel('Frequency [Hz]', 'FontSize', 15)

    % reverse Y axis
    set(gca,'Ydir','normal')
end

