function [t, signal] = extractEEG(filename, filepath, channel, tStart, tEnd)
    eeglab;
    EEG = pop_loadset('filename', filename, 'filepath', filepath);
    data = EEG.data;                    % [channels x samples x epochs]
    fs   = EEG.srate;                   % sampling rate
    chan = {EEG.chanlocs.labels};       % channel names
    t = (0:size(data,2)-1) / fs;        % time vector

    % Choose channel 
    ch = find(strcmpi({EEG.chanlocs.labels}, channel));

    % Choose time window
    idx = round(tStart*fs) : round(tEnd*fs);

    % Extract signal
    signal = squeeze(data(ch,:,1));
    t = t(idx);
    signal = signal(idx); 

end