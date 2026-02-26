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

X = T{:, featureNames};
group = T.Group;

% Run MANOVA
[~, p] = manova1(X, group);

% Create results table (ONLY scalar values)
Results_MANOVA = table(p, ...
    'VariableNames', {'Wilks_p_value'});

disp('MANOVA Results:')
disp(Results_MANOVA)

% Export to Excel
writetable(Results_MANOVA, 'MANOVA.xlsx');
