% Build feature matrix for all subjects
clear; clc;
eeglab;

% Settings
groups = {'AD','FTD','CN'};
featureNames = { ...
    'front_delta', ...
    'front_theta', ...
    'front_alpha', ...
    'front_beta', ...
    'post_delta', ...
    'post_theta', ...
    'post_alpha', ...
    'post_beta', ...
    'front_rel_theta', ...
    'front_rel_beta', ...
    'post_rel_alpha', ...
    'post_rel_theta', ...
    'theta_alpha_ratio', ...
    'slow_fast_ratio', ...
    'frontTheta_postAlpha', ...
    'PAF'};

% Initial storage
FeatureMatrix = [];
GroupLabels = {};
SubjectNames = {};

% Loop through subjects
for g = 1:length(groups)

    groupName = groups{g};
    folderPath = fullfile(pwd, groupName);

    files = dir(fullfile(folderPath, '*.set'));

    fprintf('\nProcessing group: %s\n', groupName);

    for f = 1:length(files)

        filename = files(f).name;
        fprintf('  Subject: %s\n', filename);

        % Load
        EEG = pop_loadset('filename', filename, ...
                          'filepath', folderPath);

        % FILTER (1–40 Hz, 4th order, SOS)
        fs = EEG.srate;
        Wn = [1 40] / (fs/2);
        [sos,gain] = butter(4, Wn, 'bandpass');

        data = double(EEG.data);
        if ndims(data) == 3
            data = data(:,:,1);
        end

        for ch = 1:size(data,1)
            data(ch,:) = filtfilt(sos, gain, data(ch,:));
        end

        EEG.data = data;

        %% EXTRACT FEATURES
        features = extractFeatures(EEG);

        %% STORE SELECTED FEATURES
        featureVector = [];
        for k = 1:length(featureNames)
            featureVector(k) = features.(featureNames{k});
        end

        FeatureMatrix = [FeatureMatrix; featureVector];
        GroupLabels{end+1,1} = groupName;
        SubjectNames{end+1,1} = filename;

    end
end

% Create and export table
FeatureTable = array2table(FeatureMatrix, ...
    'VariableNames', featureNames);

FeatureTable.Group = GroupLabels;
FeatureTable.Subject = SubjectNames;

disp(' ')
disp('Feature extraction complete.')
disp(FeatureTable(1:5,:))

writetable(FeatureTable, 'EEG_FeatureMatrix.xlsx');
