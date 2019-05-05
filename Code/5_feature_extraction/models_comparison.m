function [train_mean_acc, test_mean_acc, models_label] = models_comparison(kfold,features_matrix,nFeatKept, do_plot)
% Perform a kfold CrossValidation to have an unbiased accuracy estimation
% of a LDA, Quadratic, SVM, Random Forest and Logistic classifiers.
% Trying to discriminate MI task and offset (class 0
% and 1), based on features being the power densitiy of given channels and
% frequences.
%
% The random forest classifier has been optimized in the RF_optimization
% function
%
% To construcut the classifiers, nFeatKept first best features are kept
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
acc_train = zeros(kfold,5);
acc_test = zeros(kfold,5);

%Store the indice of sorted best feature of each fold
ord_features = zeros(kfold,size(features_matrix,2));

%Store the fischer score of sorted best feature of each fold 
fisher_scores = zeros(kfold,size(features_matrix,2));

%Store ROC CURVE data
% nb_samples=size(features_matrix,1)*size(features_matrix,3);
% frac_test=1/kfold;
% frac_train=1 - 1/kfold;


xroc_train = cell(1,5);% zeros(1+nb_samples*frac_train, kfold, 5);
yroc_train =cell(1,5); %zeros(1+nb_samples*frac_train, kfold, 5);
xroc_test = cell(1,5);%zeros(1+nb_samples*frac_test, kfold, 5);
yroc_test = cell(1,5);%zeros(1+nb_samples*frac_test, kfold, 5);

%models
models_label={'LDA', 'Quadratic', 'SVM', 'Random Forest', 'Logistic'};

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
        
    predic_proba_train=zeros(length(labels_mat_train), 5);
    predic_proba_test=zeros(length(labels_mat_test), 5);
    
    % ---- LDA Classifier ----
    model = fitcdiscr(TrainData_f, labels_mat_train, 'discrimtype', 'linear');   
    [yhat_train,score_train] = predict(model, TrainData_f);
    [yhat_test,score_test] = predict(model, TestData_f);
    
    predic_proba_train(:,1)=score_train(:,2);
    predic_proba_test(:,1)=score_test(:,2);
    
    acc_train(iFold,1) = 100 - (getClassError(yhat_train,labels_mat_train)*100);
    acc_test(iFold,1) = 100 - (getClassError(yhat_test,labels_mat_test)*100);
    
    % ---- Quadratic ---
    model_quad = fitcdiscr(TrainData_f, labels_mat_train, 'discrimtype', 'quadratic');
    [yhat_train,score_train] = predict(model_quad, TrainData_f);
    [yhat_test,score_test] = predict(model_quad, TestData_f);
    
    predic_proba_train(:,2)=score_train(:,2);
    predic_proba_test(:,2)=score_test(:,2);

    acc_train(iFold,2) = 100 - (getClassError(yhat_train,labels_mat_train)*100);
    acc_test(iFold,2) = 100 - (getClassError(yhat_test,labels_mat_test)*100);
    
    % ---- SVM ----
    SVMModel = fitcsvm(TrainData_f,labels_mat_train);
    [yhat_train,score_train] = predict(SVMModel, TrainData_f);
    [yhat_test,score_test] = predict(SVMModel, TestData_f);
    
    predic_proba_train(:,3)=score_train(:,2);
    predic_proba_test(:,3)=score_test(:,2);

    acc_train(iFold,3) = 100 - (getClassError(yhat_train,labels_mat_train)*100);
    acc_test(iFold,3) = 100 - (getClassError(yhat_test,labels_mat_test)*100);
    
    % ---- Random Forest ----
    NumTrees=10;
    MaxNumSplits=2;
    t = templateTree('MaxNumSplits', MaxNumSplits );
    rf=fitcensemble(TrainData_f,labels_mat_train, 'Method', 'LogitBoost', ...
        'Learners', t, 'NumLearningCycles',NumTrees);
    [yhat_train,score_train] = predict(rf, TrainData_f);
    [yhat_test,score_test] = predict(rf, TestData_f);
    
    predic_proba_train(:,4)=score_train(:,2);
    predic_proba_test(:,4)=score_test(:,2);
    
    acc_train(iFold,4) = 100 - (getClassError(yhat_train,labels_mat_train)*100);
    acc_test(iFold,4) = 100 - (getClassError(yhat_test,labels_mat_test)*100);
    
    % ---- Logistic  ----
    logist = fitglm(TrainData_f,labels_mat_train,'Distribution','binomial');
    [yhat_train,score_train] = predict(logist, TrainData_f);
    [yhat_test,score_test] = predict(logist, TestData_f);
    
    %0.5 'classic' threshold
    yhat_train=round(yhat_train);
    yhat_test=round(yhat_test);
    
    predic_proba_train(:,5)=score_train(:,2);
    predic_proba_test(:,5)=score_test(:,2);
    
    acc_train(iFold,5) = 100 - (getClassError(yhat_train,labels_mat_train)*100);
    acc_test(iFold,5) = 100 - (getClassError(yhat_test,labels_mat_test)*100);
    
    %ROC CURVE FOR Offset TASK (CLASS 1)
    for m=1:5
        [x_train,y_train] = perfcurve(labels_mat_train, predic_proba_train(:,m),1);
        [x_test,y_test] = perfcurve(labels_mat_test, predic_proba_test(:,m),1);

        xroc_train{m} = padd_concat(xroc_train{m},x_train);
        yroc_train{m} = padd_concat(yroc_train{m}, y_train);
        xroc_test{m} = padd_concat(xroc_test{m}, x_test);
        yroc_test{m} = padd_concat(yroc_test{m}, y_test);

    end
end

%Get the mean of the roc curves points
for m = 1:5
    xroc_train{m} = mean(xroc_train{m},2,'omitnan' );
    yroc_train{m} = mean(yroc_train{m},2, 'omitnan');
    xroc_test{m} = mean(xroc_test{m},2, 'omitnan');
    yroc_test{m} = mean(yroc_test{m},2,'omitnan');
end

train_mean_acc=zeros(1,5);
test_mean_acc=zeros(1,5);

for m=1:5
        % ---- Plot BOXPLOT of cross-validation accuracies ---- 
        subplot(2,5,m)
        train_mean_acc(1,m) = mean(acc_train(:,m),1);
        test_mean_acc(1,m) = mean(acc_test(:,m),1);
end

if (do_plot)    
    for m=1:5
        % ---- Plot BOXPLOT of cross-validation accuracies ---- 
        subplot(2,5,m)
        

        x = [acc_train(:,m),acc_test(:,m)];
        boxplot(x,'Labels',{'train accuracy','test accuracy'})
        ylim([50, 110])
        title(models_label(m))
        
        % ---- ROC curves ---- 
        subplot(2,5,m+5)
        plot(xroc_train{m},yroc_train{m},'b')
        hold on;
        plot(xroc_test{m},yroc_test{m},'r')
        xlabel('False positive rate') 
        ylabel('True positive rate')
        legend('train','test')
        title(models_label(m))
    end
end
end



