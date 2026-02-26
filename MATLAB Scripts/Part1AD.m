clear; close all; clc;

channel = 'Cz';
tStart = 10;
tEnd = 20;

% Load the EEG signal
[t, x] = extractEEG('sub-010.set', fullfile('AD'), channel, tStart, tEnd);

% Splitting into 3 evenly spaced overlapping windows of 4 seconds
i1 = 1:1:round(0.4*length(t));
i2 = round(0.3*length(t)):1:round(0.7*length(t));
i3 = round(0.6*length(t)):1:length(t);
t1 = t(i1); t2 = t(i2); t3 = t(i3);
x1 = x(i1); x2 = x(i2); x3 = x(i3);

% FFT 
N = length(t);
Nfft = 4096;                % use zero-padding
fs = 1 / mean(diff(t));     % sampling frequency
f = (0:Nfft-1)*fs/Nfft;     % frequency vector

% FFT - Rectangular Window
x1Rect = x1; x2Rect = x2; x3Rect = x3;
X1Rect = fft(x1Rect, Nfft);
X2Rect = fft(x2Rect, Nfft);
X3Rect = fft(x3Rect, Nfft);

% FFT - Hanning Window
x1Hann = x1'.*hann(length(x1)); x2Hann = x2'.*hann(length(x2)); x3Hann = x3'.*hann(length(x3));
X1Hann = fft(x1Hann, Nfft);
X2Hann = fft(x2Hann, Nfft);
X3Hann = fft(x3Hann, Nfft);

% FFT - Hamming Window
x1Hamm = x1'.*hamming(length(x1)); x2Hamm = x2'.*hamming(length(x2)); x3Hamm = x3'.*hamming(length(x3));
X1Hamm = fft(x1Hamm, Nfft);
X2Hamm = fft(x2Hamm, Nfft);
X3Hamm = fft(x3Hamm, Nfft);

% Resizing for up to 60Hz 
idx = 20:1:500;
f = f(idx);
X1Rect = X1Rect(idx); X1Hann = X1Hann(idx); X1Hamm = X1Hamm(idx);
X2Rect = X2Rect(idx); X2Hann = X2Hann(idx); X2Hamm = X2Hamm(idx);
X3Rect = X3Rect(idx); X3Hann = X3Hann(idx); X3Hamm = X3Hamm(idx);

% Plotting
figure(1);
subplot(3, 1, 1); hold on;
plot(f, abs(X1Rect)); plot(f, abs(X1Hann)); plot(f, abs(X1Hamm));
title("AD - Sub 10 - Time Window: 10s-14s");
legend("Orthogonal", "Hanning", "Hamming");
subplot(3, 1, 2); hold on;
plot(f, abs(X2Rect)); plot(f, abs(X2Hann)); plot(f, abs(X2Hamm));
title("AD - Sub 10 - Time Window: 13s-17s");
legend("Orthogonal", "Hanning", "Hamming");
subplot(3, 1, 3); hold on;
plot(f, abs(X3Rect)); plot(f, abs(X3Hann)); plot(f, abs(X3Hamm));
title("AD - Sub 10 - Time Window: 16s-20s");
legend("Orthogonal", "Hanning", "Hamming");




