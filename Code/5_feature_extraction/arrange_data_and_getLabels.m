function [data_arranged,labels_mat] = arrange_data_and_getLabels(reference_matrix)
% Rearrange a 3d feature matrix window x feature x trials
% to 2d matrix samples x features by keeping data in coherent order divided
% by classes
%
% Return :
%   - data_arranged : 2d Matrix rearranged
%   - labels_mat : Column vector containing labels of samples contained in
%                   each rows of data_arranged

data_arranged = zeros(size(reference_matrix,1)*size(reference_matrix,3),size(reference_matrix,2)); %34*60 x 304
for iSample = 1:size(reference_matrix,1) %each samples (window)
    for iTrial = 1:size(reference_matrix,3) %each trial
        newRow = size(reference_matrix,3)*(iSample-1) + iTrial;
        data_arranged(newRow,:) = reference_matrix(iSample,:,iTrial);
    end
end

%Create label matrix - one element per sample
%Half first column are class 0 (MOTOR IMAGERY), half other are class 1
%(STOP)
class1 = zeros( size(data_arranged,1) / 2 , 1);
class2 = ones( size(data_arranged,1) / 2 , 1);
labels_mat = cat(1,class1,class2); 

end

