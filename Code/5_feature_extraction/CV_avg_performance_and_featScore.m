function [xroc_train_avg,yroc_train_avg,xroc_test_avg,yroc_test_avg,fisher_scores,ord_features, acc_train, acc_test] = CV_avg_performance_and_featScore(kfold,features_matrix,nFeatKept, do_plot)
% Perform a kfold CrossValidation to have an unbiased accuracy estimation
% of a LDA classifier, trying to discriminate MI task and offset (class 0
% and 1), based on features being the power densitiy of given channels and
% frequences.
%
% To construcut the classifier, nFeatKept first best features are kept
% (based on their fisher score)
%
% Output :
%       - Two PLOTS :
%           - Boxplot of cross validation accuracies
%           - average ROC curves for predicting class 1
%       - [xroc_train_avg,yroc_train_avg,xroc_test_avg,yroc_test_avg]
%       - fisher_scores, ord_features
%           indice of sorted best feature of each fold
%          & fischer score of sorted best feature of each fold


%------ STORE VARIABLE ------
acc_train = zeros(kfold,1);
acc_test = zeros(kfold,1);
%Store the indice of sorted best feature of each fold
ord_features = zeros(kfold,size(features_matrix,2));
%Store the fischer score of sorted best feature of each fold 
fisher_scores = zeros(kfold,size(features_matrix,2));
%Store ROC CURVE data
xroc_train_avg = [];
yroc_train_avg = [];
xroc_test_avg = [];
yroc_test_avg = [];

%CV Kfold by hand, only on TRIALS and not window, otherwise model is biased
%(a test window can overlap a train window)
all_index = 1:size(features_matrix,3); % 1 : nTrials
cv_index = 1:round(size(features_matrix,3)/kfold):size(features_matrix,3); % 1 : fold_size : nTrials

for iFold = 1:kfold 
    
    % ---- Indexing the trials use for train or test set ----
    if iFold == kfold %fold 1 to 9
        test_index = cv_index(iFold):size(features_matrix,3);
    else % last fold
        test_index = cv_index(iFold):(cv_index(iFold+1)-1);
    end
    %Train index are all index except test index ones
    train_index = all_index;
    train_index(test_index) = [];
    
    % ---- Build the corresponding train/test input matrix ----
    kept_trials_mat_train = features_matrix(:,:,train_index);
    [dataInput_train, labels_mat_train] = arrange_data_and_getLabels(kept_trials_mat_train);
    kept_trials_mat_test = features_matrix(:,:,test_index);
    [dataInput_test, labels_mat_test] = arrange_data_and_getLabels(kept_trials_mat_test);
    
    % ---- NORMALIZE ----
    [TrainData_norm, mu, sigma] = zscore(dataInput_train);
    TestData_norm = (dataInput_test - mu)./sigma;
          
    % ---- Feature selection ---- (only on trainset to not biased the error)
    [orderedInd, orderedPower] = rankfeat(TrainData_norm, labels_mat_train, 'fisher');
    fisher_scores(iFold,:) = orderedPower;
    ord_features(iFold,:) = orderedInd; 
    %Take nFeatKept first best features
    TrainData_f = TrainData_norm(:,orderedInd(1:nFeatKept));
    TestData_f = TestData_norm(:,orderedInd(1:nFeatKept));
    
    % ---- LDA Classifier ----
    model = fitcdiscr(TrainData_f, labels_mat_train, 'discrimtype', 'linear');   
    [yhat_train,score_train] = predict(model, TrainData_f);
    [yhat_test,score_test] = predict(model, TestData_f);
    
    %ROC CURVE FOR Offset TASK (CLASS 1)
    [x_train,y_train] = perfcurve(labels_mat_train,score_train(:,2),1);
    [x_test,y_test] = perfcurve(labels_mat_test,score_test(:,2),1);
    xroc_train_avg = [xroc_train_avg x_train];
    yroc_train_avg = [yroc_train_avg y_train];
    xroc_test_avg = [xroc_test_avg x_test];
    yroc_test_avg = [yroc_test_avg y_test];
    
    acc_train(iFold,1) = 100 - (getClassError(yhat_train,labels_mat_train)*100);
    acc_test(iFold,1) = 100 - (getClassError(yhat_test,labels_mat_test)*100);
    
end

xroc_train_avg = mean(xroc_train_avg,2);
yroc_train_avg = mean(yroc_train_avg,2);
xroc_test_avg = mean(xroc_test_avg,2);
yroc_test_avg = mean(yroc_test_avg,2);

if(do_plot)
    % ---- Plot BOXPLOT of cross-validation accuracies ----   
    train_cv_acc = mean(acc_train,1);
    test_cv_acc = mean(acc_test,1);
    figure
    x = [acc_train,acc_test];
    boxplot(x,'Labels',{'train accuracy','test accuracy'})
    title(join(['Model accuracy - CV 10 Fold - ',num2str(nFeatKept),' Features Kept']))

    % ---- Plot average ROC CURVES for predicting class 1 (
    figure
    plot(xroc_train_avg,yroc_train_avg,'b')
    hold on;
    plot(xroc_test_avg,yroc_test_avg,'r')
    xlabel('False positive rate') 
    ylabel('True positive rate')
    legend('train','test')
    title('ROC for Classification, Class 1 (Offset)')
end
end

