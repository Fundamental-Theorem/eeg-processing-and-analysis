clear; close all; clc;

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

alpha = 0.05;

nFeatures = length(featureNames);
p_values = zeros(nFeatures,1);
F_values = zeros(nFeatures,1);

% ANOVA
for i = 1:nFeatures
    
    data = T.(featureNames{i});
    groups = T.Group;
    
    [p, tbl] = anova1(data, groups, 'off');
    
    p_values(i) = p;
    F_values(i) = tbl{2,5};
end

bonf_alpha = alpha / nFeatures;

% Display Results
Results_ANOVA = table( ...
    featureNames', ...
    F_values, ...
    p_values, ...
    p_values < alpha, ...
    p_values < bonf_alpha, ...
    'VariableNames', ...
    {'Feature','F_statistic','p_value','Significant_0_05','Significant_Bonferroni'});

disp(Results_ANOVA)

% Export results
writetable(Results_ANOVA, 'ANOVA.xlsx');

