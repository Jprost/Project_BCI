function [] = periodogram_allChannels(data_Basline,data_MI,channel_lab)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here

    %Compute PSD for both baseline and MI onset
    [BL_power, BL_freq] = power_compute(data_Basline);
    [MI_power, MI_freq] = power_compute(data_MI);
    %Power is of dimension : Channel x Power x trials
    
    %mean over all trial (epcohs)
    BL_mean = mean(BL_power,3);
    MI_mean = mean(MI_power,3);
    BL_SD = std(BL_power,0,3); %STD over Trials
    MI_SD = std(MI_power,0,3); %STD over Trials
    
    
    figure()
    iChannel = 1;
    hold on;
    annotation('textbox', [0 0.9 1 0.1], ...
    'String', 'Periodogram for all channels, average over trials', ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center','FontSize',14,'FontWeight','bold')
    subplot(4,5,3)
    
    
    
    plot(BL_freq,10*log10(BL_mean(iChannel,:)),'r','LineWidth',1)
    plot(MI_freq,10*log10(MI_mean(iChannel,:)),'b','LineWidth',1)
    xlim([0,40])
    title(channel_lab(1))
    freqBoth = [BL_freq' fliplr(BL_freq')];
    
    BL_shade = [(10*log10(BL_mean(iChannel,:)+BL_SD(iChannel,:))) (fliplr( 10*log10(BL_mean(iChannel,:)) - ((10*log10(BL_mean(iChannel,:)+BL_SD(iChannel,:))) - (10*log10(BL_mean(iChannel,:)))) ))];
    MI_shade = [(10*log10(MI_mean(iChannel,:)+MI_SD(iChannel,:))) (fliplr( 10*log10(MI_mean(iChannel,:)) - ((10*log10(MI_mean(iChannel,:)+MI_SD(iChannel,:))) - (10*log10(MI_mean(iChannel,:)))) ))];
    patch(freqBoth,BL_shade,'r','FaceAlpha',.3,'LineWidth',0.01)
    patch(freqBoth,MI_shade,'b','FaceAlpha',.3,'LineWidth',0.01)
    
    subplot(4,5,5)
    plot(0,0,  0,0)
    patch(0,0,'r','FaceAlpha',.3,'LineWidth',0.01)
    patch(0,0,'b','FaceAlpha',.3,'LineWidth',0.01)
    axis off
    legend('Baseline','Motor Imagery Start','Std over trials','Std over trials')

    for iChannel=2:16
        subplot(4,5,iChannel+4)
        title(channel_lab(iChannel))
        hold on;
        plot(BL_freq,10*log10(BL_mean(iChannel,:)),'r','LineWidth',1)
        plot(MI_freq,10*log10(MI_mean(iChannel,:)),'b','LineWidth',1)
        xlim([0,40])
    
        freqBoth = [BL_freq' fliplr(BL_freq')];

        BL_shade = [(10*log10(BL_mean(iChannel,:)+BL_SD(iChannel,:))) (fliplr( 10*log10(BL_mean(iChannel,:)) - ((10*log10(BL_mean(iChannel,:)+BL_SD(iChannel,:))) - (10*log10(BL_mean(iChannel,:)))) ))];
        MI_shade = [(10*log10(MI_mean(iChannel,:)+MI_SD(iChannel,:))) (fliplr( 10*log10(MI_mean(iChannel,:)) - ((10*log10(MI_mean(iChannel,:)+MI_SD(iChannel,:))) - (10*log10(MI_mean(iChannel,:)))) ))];
        patch(freqBoth,BL_shade,'r','FaceAlpha',.3,'LineWidth',0.01)
        patch(freqBoth,MI_shade,'b','FaceAlpha',.3,'LineWidth',0.01)
        hold off;
    end
    
end

