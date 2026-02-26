clear; close all; clc;
rng(1);

% Load data
filename = 'EEG_FeatureMatrix.xlsx';
T = readtable(filename);

T.Group = categorical(T.Group);

featureNames = { ...
    'front_delta','front_theta','front_alpha','front_beta', ...
    'post_delta','post_theta','post_alpha','post_beta', ...
    'front_rel_theta','front_rel_beta', ...
    'post_rel_alpha','post_rel_theta', ...
    'theta_alpha_ratio','slow_fast_ratio', ...
    'frontTheta_postAlpha','PAF'};

X = T{:, featureNames};
Y = T.Group;

% 80-20 Stratified Holdout Split
cv_holdout = cvpartition(Y, 'HoldOut', 0.20);

X_train = X(training(cv_holdout), :);
Y_train = Y(training(cv_holdout));

% Stratified 5-Fold Cross-Validation (on training set)
cv5 = cvpartition(Y_train, 'KFold', 5);

fold_accuracy = zeros(5,1);

all_true = [];
all_pred = [];

for k = 1:5
    
    % Split fold
    X_tr = X_train(training(cv5,k), :);
    Y_tr = Y_train(training(cv5,k));
    
    X_val = X_train(test(cv5,k), :);
    Y_val = Y_train(test(cv5,k));
    
    % Standardise training data
    mu = mean(X_tr);
    sigma = std(X_tr);
    
    X_tr = (X_tr - mu) ./ sigma;
    X_val = (X_val - mu) ./ sigma;
    
    % PCA on training data
    [coeff, score_tr, latent, ~, explained] = pca(X_tr);
    
    cumulativeVariance = cumsum(explained);
    
    % Keep components explaining >= 80% variance
    numPCs = find(cumulativeVariance >= 90, 1);
    
    % Project validation data
    score_val = X_val * coeff(:,1:numPCs);
    score_tr = score_tr(:,1:numPCs);
    
    % QDA
    model = fitcdiscr(score_tr, Y_tr, ...
        'DiscrimType','quadratic');
    
    Y_pred = predict(model, score_val);
    
    fold_accuracy(k) = mean(Y_pred == Y_val);
    
    all_true = [all_true; Y_val];
    all_pred = [all_pred; Y_pred];
    
    fprintf('Fold %d: %d PCs retained (%.2f%% variance)\n', ...
        k, numPCs, cumulativeVariance(numPCs));
end

% Results
mean_accuracy = mean(fold_accuracy);

fprintf('\nQDA + PCA Fold Accuracies:\n');
disp(fold_accuracy * 100);

fprintf('Mean CV Accuracy: %.2f%%\n', mean_accuracy*100);

% Concentrated Confusion Matrix
confMat = confusionmat(all_true, all_pred);

disp('QDA + PCA Confusion Matrix (Aggregated)');
disp(array2table(confMat, ...
    'VariableNames', categories(Y), ...
    'RowNames', categories(Y)));

writematrix(confMat, 'QDA_PCA_ConfusionMatrix.xlsx');
