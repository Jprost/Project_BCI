function [] = periodogram_averageChannels(data_Basline,data_MI)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here

    %Channel x Power x trials
    [BL_power, BL_freq] = power_compute(data_Basline);
    [MI_power, MI_freq] = power_compute(data_MI);

    %MEAN OVER ALL 16 channels, and ALL trials (epochs)
    BL_mean = mean(mean(BL_power,1),3);
    MI_mean = mean(mean(MI_power,1),3);
    BL_SD = std(mean(BL_power,3),0,1); %STD over CHANNEL
    MI_SD = std(mean(MI_power,3),0,1); %STD over CHANNEL
    
    figure
    hold on;
    title('Average PSD over all trials (epochs) and all channels')
    plot(BL_freq,10*log10(BL_mean),'r')
    plot(MI_freq,10*log10(MI_mean),'b')

    freqBoth = [BL_freq' fliplr(BL_freq')];
    BL_shade = [(10*log10(BL_mean+BL_SD)) (fliplr( 10*log10(BL_mean) - ((10*log10(BL_mean+BL_SD))-10*log10(BL_mean)) ))];
    MI_shade = [(10*log10(MI_mean+MI_SD)) (fliplr( 10*log10(MI_mean) - ((10*log10(MI_mean+MI_SD))-10*log10(MI_mean)) ))];
    patch(freqBoth,BL_shade,'r','FaceAlpha',.3)
    patch(freqBoth,MI_shade,'b','FaceAlpha',.3)
    legend('Baseline','Motor Imagery Start','Std over channels','Std over channels')
    xlim([0,40])
    
    
end

