function [model, mu, sigma] = model_train_for_online(features_matrix,nFeatKept)
<<<<<<< Updated upstream
% Train an LDA classifier, trying to discriminate MI task and offset (class 0
=======
% Perform a kfold CrossValidation to have an unbiased accuracy estimation
% of a LDA classifier, trying to discriminate MI task and offset (class 0
>>>>>>> Stashed changes
% and 1), based on features being the power densitiy of given channels and
% frequences.
%
% To construcut the classifier, nFeatKept first best features are kept
% (based on their fisher score)
%
% Output :
<<<<<<< Updated upstream
%       - the trained model
%       - mu and sigma to normalize the online data
=======
%       - Two PLOTS :
%           - Boxplot of cross validation accuracies
%           - average ROC curves for predicting class 1
%       - [xroc_train_avg,yroc_train_avg,xroc_test_avg,yroc_test_avg]
%       - fisher_scores, ord_features
%           indice of sorted best feature of each fold
%          & fischer score of sorted best feature of each fold
>>>>>>> Stashed changes

% ---- Build the corresponding train/test input matrix ----

[dataInput_train, labels_mat_train] = arrange_data_and_getLabels(features_matrix);

% ---- NORMALIZE ----
[TrainData_norm, mu, sigma] = zscore(dataInput_train);
%TestData_norm = (dataInput_test - mu)./sigma;

% ---- Feature selection ---- (only on trainset to not biased the error)
[orderedInd, ~] = rankfeat(TrainData_norm, labels_mat_train, 'fisher');

%Take nFeatKept first best features
TrainData_f = TrainData_norm(:,orderedInd(1:nFeatKept));


% ---- LDA Classifier ----
model = fitcdiscr(TrainData_f, labels_mat_train, 'discrimtype', 'linear');   
%[yhat_train,score_train] = predict(model, TrainData_f);
%[yhat_test,score_test] = predict(model, TestData_f);






end

