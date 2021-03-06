function [feat_oneTrial] = windowing(trial, time, win, shift, start, stop)
%Perform sequential Pwelch over 1s on a given subpart of a given trial, for
%Feature Extraction
%  
%   Input :
%       - trial : a trial output from epoching. 
%                   Dim (trial x Channel x time) (1 x 16 x [time window of
%                   2 s])
%                   WARNING : Need an epoching -3 +3 aroung MI_STOP event
%       - time : time value associated with the epoch
%       - win : time window in s on wich pwelch is compute
%       - shift : time overlap in s to shift windwo and compute next Pwelch
%       - start : Time in second from EVENT, where to start feature extr.
%       - stop : Time in second from EVENT, where to stop feature extr.
%                If MI-STOP event:
%                   ERD (Class 0) : start = -2   stop = 0
%                   ERS (Class 1) : start = 0.5 stop = 2.5
%
%
%   Output :
%       feat_oneTrial : 17 x 304     for each 17 sequential Pwelch (each Pwelch 1s, shifted 0.0625, , 304
%       features values containing 19 power values (for freq 4:2:40) for
%       all 16 channels
%

% Extract the subpart of interest (ERD or ERS) from the whole epoch
%WARNING : Need an epoching -3 +3 aroung MI_STOP event
    sampling_rate = 512;
    time = time;
    start_i = find(time==start);
    data = squeeze(trial); % 16 x time 
   
    power = [];
    %Shift sequentially window
    shift_nsample = shift*sampling_rate; %32
    n_win = 16;%(stop-start)/shift; %16
    for iShift = 0:n_win
        start_ind = start_i + iShift*shift_nsample;
        stop_ind = start_ind + win*sampling_rate;
            
        %pwelch compute PSD on each column
        [pxx, f] = pwelch(transpose(data(:,start_ind:stop_ind)), sampling_rate, 0.5*sampling_rate, [4:2:40], sampling_rate);
        %pxx = 19x16   PSD for (freq x eachChannel)
        pxx = reshape(pxx, [1,304]); %1 x 304 
        power = cat(1,power,pxx);  % 17 x 304    (window_shifted x features) = (samples * features)
    
    end
    
    feat_oneTrial = power;
end

