function [] = periodogram_plot_oneChannel(data_Basline,data_MI,channel,channel_lab)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here

    %Compute PSD for both baseline and MI onset
    [BL_power, BL_freq] = power_compute(data_Basline);
    [MI_power, MI_freq] = power_compute(data_MI);
    %Power is of dimension : Channel x Power x trials
    
    %Select the right channels, and mean over all trial (epcohs)
    BL_mean = mean(BL_power,3);
    MI_mean = mean(MI_power,3);
    BL_mean = BL_mean(channel,:);
    MI_mean = MI_mean(channel,:);
    BL_SD = std(BL_power,0,3); %STD over Trials
    MI_SD = std(MI_power,0,3); %STD over Trials
    BL_SD = BL_SD(channel,:);
    MI_SD = MI_SD(channel,:);
    
    figure
    hold on;
    title(strcat('Periodogram for channel ',channel_lab(channel),', mean over trials'))
    xlabel('Frequency [Hz]')
    ylabel('[dB/Hz]')
    plot(BL_freq,10*log10(BL_mean),'r','LineWidth',1)
    plot(MI_freq,10*log10(MI_mean),'b','LineWidth',1)
    xlim([0,40])
    
    freqBoth = [BL_freq' fliplr(BL_freq')];
    
    BL_shade = [(10*log10(BL_mean+BL_SD)) (fliplr( 10*log10(BL_mean) - ((10*log10(BL_mean+BL_SD))-10*log10(BL_mean)) ))];
    MI_shade = [(10*log10(MI_mean+MI_SD)) (fliplr( 10*log10(MI_mean) - ((10*log10(MI_mean+MI_SD))-10*log10(MI_mean)) ))];
    patch(freqBoth,BL_shade,'r','FaceAlpha',.3,'LineWidth',0.01)
    patch(freqBoth,MI_shade,'b','FaceAlpha',.3,'LineWidth',0.01)
    legend('Baseline','Motor Imagery Start','Std over trials','Std over trials')
    
end

