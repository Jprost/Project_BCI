function [power, freq] = power_compute(epoch)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here

    %epoch = trial x 16 x time
    
    power = []  %nChannel x Trials
    %power = zeros(16,257);
    freq = [];
    sampling_rate = 512;
       
    for iTrial = 1:1:size(epoch.trial,1)
        p_trial = [];
        for iChannel = 1:1:16
            
            iChannel
            thisTrial = squeeze(epoch.trial(iTrial,iChannel,:)); 

            [pxx, f] = pwelch(thisTrial, sampling_rate, 0.5, [], sampling_rate);
            p_trial = cat(1,p_trial,pxx.');
            if length(freq) == 0
                freq = f;
            end
        end 
        size(p_trial);
        power = cat(3,power,p_trial);  %Channel x Power x trials
        

end

