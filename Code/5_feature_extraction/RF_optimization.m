function [acc_test] = RF_optimization(kfold,features_matrix,nFeatKept, do_plot)
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
acc_train = zeros(kfold,5);
acc_test = zeros(kfold,5);

%Store the indice of sorted best feature of each fold
ord_features = zeros(kfold,size(features_matrix,2));

%Store the fischer score of sorted best feature of each fold 
fisher_scores = zeros(kfold,size(features_matrix,2));

%Store ROC CURVE data
nb_samples=size(features_matrix,1)*size(features_matrix,3);
frac_test=1/kfold;
frac_train=1 - 1/kfold;


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

NumTrees_=10:50:310;
MaxNumSplits_=2:2:20;

acc_test=zeros(length(NumTrees_), length(MaxNumSplits_));


for tree=1:length(NumTrees_)
    tree
    for depth=1:length(MaxNumSplits_)
        acc_test_folds=zeros(1,kfold);
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




        % ---- Random Forest ----
        MaxNumSplits=MaxNumSplits_(depth);
        NumTrees=NumTrees_(tree);
        t = templateTree('MaxNumSplits', MaxNumSplits );
        rf=fitcensemble(TrainData_f,labels_mat_train, 'Method', 'LogitBoost', ...
            'Learners', t, 'NumLearningCycles',NumTrees);
%         [yhat_train,score_train] = predict(rf, TrainData_f);
         [yhat_test,] = predict(rf, TestData_f);
% 
%         predictions_train(:,4)=yhat_train; %cell2mat(yhat_train);
%         predic_proba_train(:,4)=score_train(:,2);
%         predictions_test(:,4)=yhat_test;
%         predic_proba_test(:,4)=score_test(:,2);

        %acc_train(iFold,4) = 100 - (getClassError(yhat_train,labels_mat_train)*100);
        acc_test_folds(iFold)=100 - (getClassError(yhat_test,labels_mat_test)*100);

        end
        acc_test(tree,depth)=mean(acc_test_folds);
        
    end
    
end


