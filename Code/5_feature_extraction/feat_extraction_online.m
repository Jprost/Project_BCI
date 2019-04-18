function [feat_online] = feat_extraction_online(trial)

%   Input :
%       - trial : a trial window of length 1sec (512 samples)
%                   Dim (trial x Channel x time) (1 x 16 x [time window of
%                   1 s])
%
%
%   Output :
%       feat_online : 1 x 304 --> 304 features values containing 19 power values (for freq 4:2:40) for
%       all 16 channels
%

    sampling_rate = 512;
    data = squeeze(trial); % 16 x time 

    %pwelch compute PSD on each column
    [pxx, f] = pwelch(transpose(data), sampling_rate, 0.5*sampling_rate, [4:2:40], sampling_rate);
    pxx = reshape(pxx, [1,304]); %1 x 304 

    feat_online = pxx;
end

