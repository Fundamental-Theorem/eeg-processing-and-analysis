function features = extractFeatures(EEG)

    % Parameters
    fs = EEG.srate;
    posterior_ch = {'O1','O2','P3','P4'};
    frontal_ch   = {'F3','F4','Fp1','Fp2'};

    win_length = 4;
    nwin = win_length * fs;
    noverlap = nwin/2;

    % Frequency bands
    bands.delta = [0.5 4];
    bands.theta = [4 8];
    bands.alpha = [8 13];
    bands.beta  = [13 30];

    % Find channel indices
    labels = {EEG.chanlocs.labels};

    post_idx = find(ismember(labels, posterior_ch));
    front_idx = find(ismember(labels, frontal_ch));

    data = EEG.data;   % channels x samples
    if ndims(data) == 3
        data = data(:,:,1); % use first epoch if epoched
    end


    % Compute PSD per channel
    for ch = 1:length(post_idx)
        x = data(post_idx(ch),:);
        [Pxx,f] = pwelch(x, hann(nwin), noverlap, [], fs);
        post_psd(:,:,ch) = Pxx;
    end

    for ch = 1:length(front_idx)
        x = data(front_idx(ch),:);
        [Pxx,~] = pwelch(x, hann(nwin), noverlap, [], fs);
        front_psd(:,:,ch) = Pxx;
    end

    % Average PSD across channels
    post_psd = mean(post_psd,3);
    front_psd = mean(front_psd,3);

    % Band power function
    bandpower_calc = @(Pxx,f,band) ...
      bandpower(Pxx,f,band,'psd');

    % Posterior absolute powers
    post_delta = bandpower_calc(post_psd,f,bands.delta);
    post_theta = bandpower_calc(post_psd,f,bands.theta);
    post_alpha = bandpower_calc(post_psd,f,bands.alpha);
    post_beta  = bandpower_calc(post_psd,f,bands.beta);

    % Frontal absolute powers
    front_delta = bandpower_calc(front_psd,f,bands.delta);
    front_theta = bandpower_calc(front_psd,f,bands.theta);
    front_alpha = bandpower_calc(front_psd,f,bands.alpha);
    front_beta  = bandpower_calc(front_psd,f,bands.beta);

    % Total power (1–40 Hz)
    post_total = bandpower(post_psd,f,[1 40],'psd');
    front_total = bandpower(front_psd,f,[1 40],'psd');

    % Relative powers
    post_rel_delta = post_delta / post_total;
    post_rel_theta = post_theta / post_total;
    post_rel_alpha = post_alpha / post_total;
    post_rel_beta  = post_beta  / post_total;

    front_rel_delta = front_delta / front_total;
    front_rel_theta = front_theta / front_total;
    front_rel_alpha = front_alpha / front_total;
    front_rel_beta  = front_beta  / front_total;

    % Band Ratios
    theta_alpha_ratio = post_theta / post_alpha;
    slow_fast_ratio = (post_delta + post_theta) / (post_alpha + post_beta);
    frontTheta_postAlpha = front_theta / post_alpha;

    % Peak alpha frequency (Posterior)
    alpha_idx = f >= 8 & f <= 13;
    [~,max_idx] = max(post_psd(alpha_idx));
    alpha_freqs = f(alpha_idx);
    PAF = alpha_freqs(max_idx);

    % Store features
    features = struct;

    % Absolute
    features.post_delta = post_delta;
    features.post_theta = post_theta;
    features.post_alpha = post_alpha;
    features.post_beta  = post_beta;

    features.front_delta = front_delta;
    features.front_theta = front_theta;
    features.front_alpha = front_alpha;
    features.front_beta  = front_beta;

    % Relative
    features.post_rel_alpha = post_rel_alpha;
    features.post_rel_theta = post_rel_theta;
    features.front_rel_theta = front_rel_theta;
    features.front_rel_beta  = front_rel_beta;

    % Ratios
    features.theta_alpha_ratio = theta_alpha_ratio;
    features.slow_fast_ratio = slow_fast_ratio;
    features.frontTheta_postAlpha = frontTheta_postAlpha;

    % Peak
    features.PAF = PAF;

end
