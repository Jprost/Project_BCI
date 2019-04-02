%Feature_extraction_script

% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));

%Load Epochs
load('./../outputs/epoch_MI_Stop.mat')

trials = epoch_MI_Stop.trial;
time = epoch_MI_Stop.time;
win = 1;
shift = 0.0625;
start_ERD = -2;
stop_ERD = 0;
start_ERS = 0.5;
stop_ERS = 2.5;

features_mat = feat_extraction(trials, time, win, shift, start_ERD, stop_ERD, start_ERS, stop_ERS);


%% Feature Selection and LDA Classification, with Cross Validation

%features_mat is 32 x 304 x 80   =  samples x Features x nTrials
% 304 features for 19 freq x 16 channel.  Ordered   Channel 1 all freq |
% Channel 2 all freq | ...

%Question --> Are all the trials different samples, or should we take the
%mean ?

%Mean over trials 
%dataInput = squeeze(mean(features_mat,3)); %32 samples x 304 features
%or all trials for all window are different sample
dataInput = zeros(size(features_mat,1)*size(features_mat,3),size(features_mat,2)); %32*60 x 304
for iSample = 1:size(features_mat,1) %each samples
    for iTrial = 1:size(features_mat,3) %each trial
        newRow = size(features_mat,1)*(iSample-1) + iTrial;
        dataInput(newRow,:) = features_mat(iSample,:,iTrial);
    end
end
%dataInput is 32*60 x 304 and half first row are class 0 and the rest 1

%Create label matrix - one element per sample
class1 = zeros( (size(features_mat,1)*size(features_mat,3)) / 2 , 1);
class2 = ones( (size(features_mat,1)*size(features_mat,3)) / 2 , 1);
labels_mat = cat(1,class1,class2);

%% Model selection throughout cross validation.

kfold = 10;

acc_train = zeros(kfold,1);
acc_test = zeros(kfold,1);
kept_features = zeros(kfold,6); %Keep 6 feature in the end

cp = cvpartition(labels_mat,'kfold',kfold);

for iFold = 1:cp.NumTestSets
    trainIdx = cp.training(iFold);
    testIdx = cp.test(iFold);
    
    %Feature selected only on trainset (to not biased the error)
    [orderedInd, orderedPower] = rankfeat(dataInput(trainIdx,:), labels_mat(trainIdx), 'fisher');
    kept_features(iFold,:) = orderedInd(1:6);
    
    %Take 6 first best features
    dataTrain = dataInput(trainIdx,orderedInd(1:6));
    dataTest = dataInput(testIdx,orderedInd(1:6));
    
    %LDA Classifier
    model = fitcdiscr(dataTrain, labels_mat(trainIdx), 'discrimtype', 'linear');
    
    yhat_train = predict(model, dataTrain);
    yhat_test = predict(model, dataTest);
    
    acc_train(iFold,1) = 100 - (getClassError(yhat_train,labels_mat(trainIdx))*100);
    acc_test(iFold,1) = 100 - (getClassError(yhat_test,labels_mat(testIdx))*100);
    
end

%Unbiased errors compute    QUESTION: But data already preprocessed... thus
%cv_error is in fact biased...
train_cv_acc = mean(acc_train,1);
test_cv_acc = mean(acc_test,1);

figure
x = [acc_train,acc_test];
boxplot(x,'Labels',{'train accuracy','test accuracy'})
title('Model accuracy - CV 10 Fold - 6 Features Kept')

%% Final Model Build on WHOLE data
[orderedInd, orderedPower] = rankfeat(dataInput, labels_mat, 'fisher');
final_model = fitcdiscr(dataInput, labels_mat, 'discrimtype', 'linear');
final_features = orderedInd(1:6);

%Warning matlab count from top to bottom before left to right
%Thus map to Channel x freq  -> 16 x 19
siz = [16,19];
[rows,cols] = ind2sub(siz,final_features);
map_feat = zeros(16,19);
for i = 1:size(final_features,2)
    map_feat(rows(i),cols(i)) = 1;
end
figure
imagesc(map_feat);
title('6 Selected Features, Channel vs Freq');
xlabel('frequence [Hz]');
ylabel('channel');
xticks([1:19]);
xticklabels([4:2:40]);
yticks([1:16]);
yticklabels([{'FZ';'FC3';'FC1';'FCz';'FC2';'FC4';'C3';'C1';'Cz';'C2';'C4';'CP3';'CP1';'CPZ';'CP2';'CP4'}]);



