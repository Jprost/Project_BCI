%Feature_extraction_script

% Enable use of toolbox functions
addpath(genpath('./../toolboxes/biosig'));

%Load Epochs
load('./../outputs/output_sacha/epoch_MI_Stop.mat')

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

%features_mat is 34 x 304 x 80   =  samples x Features x nTrials
% 304 features for 19 freq x 16 channel.  Ordered   Channel 1 all freq |
% Channel 2 all freq | ...

%or all trials for all window are different sample
dataInput = zeros(size(features_mat,1)*size(features_mat,3),size(features_mat,2)); %34*60 x 304
for iSample = 1:size(features_mat,1) %each samples
    for iTrial = 1:size(features_mat,3) %each trial
        newRow = size(features_mat,3)*(iSample-1) + iTrial;
        dataInput(newRow,:) = features_mat(iSample,:,iTrial);
    end
end
%dataInput is 34*60 x 304 and half first row are class 0 and the remaining rows are 1

%Create label matrix - one element per sample
class1 = zeros( (size(features_mat,1)*size(features_mat,3)) / 2 , 1);
class2 = ones( (size(features_mat,1)*size(features_mat,3)) / 2 , 1);
labels_mat = cat(1,class1,class2); %2040 x 1. frist 1020 are 0

%% Model selection throughout cross validation.

kfold = 10;

acc_train = zeros(kfold,1);
acc_test = zeros(kfold,1);
ord_features = zeros(kfold,size(features_mat,2)); 
fisher_scores = zeros(kfold,size(features_mat,2));
%ROC CURVE data
x_train_avg = [];
y_train_avg = [];
x_test_avg = [];
y_test_avg = [];

%CV Kfold by hand, only on TRIALS and not window, otherwise model is biased
%(a test window can overlap a train window)
all_index = 1:size(features_mat,3); % 1 : nTrials
cv_index = [1:round(size(features_mat,3)/kfold):size(features_mat,3)]; % 1 : fold_size : nTrials

for iFold = 1:kfold 
    
    % ---- Indexing the trials use for train or test set ----
    if iFold == kfold %fold 1 to 9
        test_index = cv_index(iFold):size(features_mat,3);
    else % last fold
        test_index = cv_index(iFold):(cv_index(iFold+1)-1);
    end
    %Train index are all index except test index ones
    train_index = all_index;
    train_index(test_index) = [];
    
    % ---- Build the corresponding train/test input matrix ----
    kept_trials_mat_train = features_mat(:,:,train_index);
    dataInput_train = zeros(size(kept_trials_mat_train,1)*size(kept_trials_mat_train,3),size(kept_trials_mat_train,2)); 
    for iSample = 1:size(kept_trials_mat_train,1) %each samples
        for iTrial = 1:size(kept_trials_mat_train,3) %each trial
            newRow = size(kept_trials_mat_train,3)*(iSample-1) + iTrial;
            dataInput_train(newRow,:) = kept_trials_mat_train(iSample,:,iTrial);
        end
    end %dataInput_train is (34*nTrials_train) x 304 and half first row are class 0 and the rest 1   
    kept_trials_mat_test = features_mat(:,:,test_index);
    dataInput_test = zeros(size(kept_trials_mat_test,1)*size(kept_trials_mat_test,3),size(kept_trials_mat_test,2)); 
    for iSample = 1:size(kept_trials_mat_test,1) %each samples 1:34
        for iTrial = 1:size(kept_trials_mat_test,3) %each trial 1:6
            newRow = size(kept_trials_mat_test,3)*(iSample-1) + iTrial;
            dataInput_test(newRow,:) = kept_trials_mat_test(iSample,:,iTrial);
        end
    end %dataInput_test is (34*nTrials_test) x 304 and half first row are class 0 and the rest 1 
    
    %Create corresponding label train/test matrix
    class1 = zeros( (size(dataInput_train,1)*size(dataInput_train,3)) / 2 , 1);
    class2 = ones( (size(dataInput_train,1)*size(dataInput_train,3)) / 2 , 1);
    labels_mat_train = cat(1,class1,class2);
    
    class1 = zeros( (size(dataInput_test,1)*size(dataInput_test,3)) / 2 , 1);
    class2 = ones( (size(dataInput_test,1)*size(dataInput_test,3)) / 2 , 1);
    labels_mat_test = cat(1,class1,class2);
    
    % ---- NORMALIZE ----
    [TrainData_norm, mu, sigma] = zscore(dataInput_train);
    TestData_norm = (dataInput_test - mu)./sigma;
      
    
    % ---- Feature selection ---- (only on trainset to not biased the error)
    [orderedInd, orderedPower] = rankfeat(TrainData_norm, labels_mat_train, 'fisher');
    fisher_scores(iFold,:) = orderedPower;
    ord_features(iFold,:) = orderedInd; 
    %Take 6 first best features
    TrainData_f = TrainData_norm(:,orderedInd(1:6));
    TestData_f = TestData_norm(:,orderedInd(1:6));
    
    %LDA Classifier
    model = fitcdiscr(TrainData_f, labels_mat_train, 'discrimtype', 'linear');
    
    [yhat_train,score_train] = predict(model, TrainData_f);
    [yhat_test,score_test] = predict(model, TestData_f);
    
    %ROC CURVE FOR MI TASK (CLASS 0)
    [x_train,y_train] = perfcurve(labels_mat_train,score_train(:,1),0);
    [x_test,y_test] = perfcurve(labels_mat_test,score_test(:,1),0);
    x_train_avg = [x_train_avg x_train];
    y_train_avg = [y_train_avg y_train];
    x_test_avg = [x_test_avg x_test];
    y_test_avg = [y_test_avg y_test];
    
    acc_train(iFold,1) = 100 - (getClassError(yhat_train,labels_mat_train)*100);
    acc_test(iFold,1) = 100 - (getClassError(yhat_test,labels_mat_test)*100);
    
end

%Unbiased errors compute    QUESTION: But data already preprocessed... thus
%cv_error is in fact biased...
train_cv_acc = mean(acc_train,1);
test_cv_acc = mean(acc_test,1);

figure
x = [acc_train,acc_test];
boxplot(x,'Labels',{'train accuracy','test accuracy'})
title('Model accuracy - CV 10 Fold - 6 Features Kept')

%ROC CURVE
x_train_avg = mean(x_train_avg,2);
y_train_avg = mean(y_train_avg,2);
x_test_avg = mean(x_test_avg,2);
y_test_avg = mean(y_test_avg,2);
figure
plot(x_train_avg,y_train_avg,'b')
hold on;
plot(x_test_avg,y_test_avg,'r')
xlabel('False positive rate') 
ylabel('True positive rate')
legend('train','test')
title('ROC for Classification, Class 0 (MI)')

%% Average fisher score of fisher over 10-fold CV
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



%% Final Model Build on WHOLE data


% [orderedInd, orderedPower] = rankfeat(dataInput, labels_mat, 'fisher');
% final_model = fitcdiscr(dataInput, labels_mat, 'discrimtype', 'linear');
% final_features = orderedInd(1:6);
% 
% %Warning matlab count from top to bottom before left to right
% %Thus map to freq x channel  -> 19 x 16
% siz = [19,16];
% [rows,cols] = ind2sub(siz,final_features);
% map_feat = zeros(19,16);
% for i = 1:size(final_features,2)
%     map_feat(rows(i),cols(i)) = 1;
% end
% figure
% imagesc(map_feat');
% title('6 Selected Features, Freq vs Channel');
% xlabel('frequence [Hz]');
% ylabel('channel');
% xticks([1:19]);
% xticklabels([4:2:40]);
% yticks([1:16]);
% yticklabels([{'FZ';'FC3';'FC1';'FCz';'FC2';'FC4';'C3';'C1';'Cz';'C2';'C4';'CP3';'CP1';'CPZ';'CP2';'CP4'}]);
% 
% 
% all_feat_score = zeros(19,16);
% [rows_pow,cols_pow] = ind2sub(siz,orderedInd);
% for i = 1:size(orderedPower,2)
%     all_feat_score(rows_pow(i),cols_pow(i)) = orderedPower(i);
% end
% 
% figure
% imagesc(all_feat_score');
% title('Power of all features, Channel vs Freq');
% xlabel('frequence [Hz]');
% ylabel('channel');
% xticks([1:19]);
% xticklabels([4:2:40]);
% yticks([1:16]);
% yticklabels([{'FZ';'FC3';'FC1';'FCz';'FC2';'FC4';'C3';'C1';'Cz';'C2';'C4';'CP3';'CP1';'CPZ';'CP2';'CP4'}]);
% c = colorbar
% c.Label.String = 'Fisher Score';
% c.Label.FontSize = 13;


% all_feat_score = zeros(19,16);
% [rows_pow,cols_pow] = ind2sub(siz,1:size(fisher_scores,2));
% for i = 1:size(avg_fisher_score,2)
%     all_feat_score(rows_pow(i),cols_pow(i)) = avg_fisher_score(i);
% end

