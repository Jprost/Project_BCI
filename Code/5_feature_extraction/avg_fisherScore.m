function [fisherScore_map] = avg_fisherScore(fisher_scores,ord_features,kfold)
% Plot on a  16 Channels x 19 freq grid the average fisherscore accross 10
% fold CV.
%
%   Input : 
%       -fisher_score : indice of sorted best feature of each fold
%       -ord_features : fischer score of sorted best feature of each fold
%
%   Output:
%       -Plot the map of avg features fisher score
%       -fisherScore_map : The plotted map, needed for ground average
%

avg_fisher_score = zeros(kfold,size(fisher_scores,2));
for iFeatures = 1:size(fisher_scores,2)
    for ifo = 1:kfold
        avg_fisher_score(ifo,ord_features(ifo,iFeatures)) = fisher_scores(ifo,iFeatures);
    end
end
avg_fisher_score = mean(avg_fisher_score,1); %Avg power off each features ORDERED as  | Channel 1 all freq | Channel 2 all freq | Channel 3 all freq | ....

avg_fisher_score_map = reshape(avg_fisher_score,[19,16]); % 19 X 16 each columns is a channel

figure
imagesc(avg_fisher_score_map');
title('Avg power of each feature over 10-fold CV, Channel vs Freq');
xlabel('frequence [Hz]');
ylabel('channel');
xticks([1:19]);
xticklabels([4:2:40]);
yticks([1:16]);
yticklabels([{'FZ';'FC3';'FC1';'FCz';'FC2';'FC4';'C3';'C1';'Cz';'C2';'C4';'CP3';'CP1';'CPZ';'CP2';'CP4'}]);
c = colorbar;
c.Label.String = 'Fisher Score';
c.Label.FontSize = 13;

fisherScore_map = avg_fisher_score_map'; 

end

