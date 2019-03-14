function p_list = periodogram(epoch, channel, sampling_rate)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here

    %epoch = trial x 16 x time
    
    avg_signal = squeeze(mean(epoch.data, 1));
    
    p_list = [];
    for i=1:1:size(channel)
        [pxx, f] = pwelch(avg_signal(channel(i)), sampling_rate, 0.5*sampling_rate, [], sampling_rate);
        p_temp = plot(f,10*log10(pxx));
        title(strcat('Channel n°',str(channel(i)))
        xlabel('frequence [Hz]')
        ylabel('PSD [dB/Hz]')
        p_list.cat(p_temp,1) 
    end
end

