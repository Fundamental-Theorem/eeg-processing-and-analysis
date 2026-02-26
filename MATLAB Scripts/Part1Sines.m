clear; close all; clc;


fs = 256; % Sampling frequency
T = 10; % Analog signal duration
N = fs*T; % Number of samples
t = (0:N-1)/fs; % Time vector

f1 = 10; % Frequency of first sine (# of periods within T = integer)
f2 = 10.3; % Frequency of the second sine (# of periods within T != integer)

Nfft = 4096; % Samples with zero-padding to the nearest power of 2
f = (0:Nfft-1)*fs/Nfft; % Frequency vector

% Original Signals
x1 = 0.00001*cos(2*pi*f1*t);
x2 = 0.00001*cos(2*pi*f2*t); 

% Case 1: Orthogonal window
x1Rect = x1;
x2Rect = x2;
X1Rect = fft(x1Rect, Nfft);
X2Rect = fft(x2Rect, Nfft);

% Case 2: Hanning window
x1Hann = x1'.*hann(N);
x2Hann = x2'.*hann(N);
X1Hann = fft(x1Hann, Nfft);
X2Hann = fft(x2Hann, Nfft);

% Case 3: Hamming window
x1Hamm = x1'.*hamming(N);
x2Hamm = x2'.*hamming(N);
X1Hamm = fft(x1Hamm, Nfft);
X2Hamm = fft(x2Hamm, Nfft);

figure(1);

subplot(2,1,1);
plot(f, abs(X1Rect));
xline(f1);
xline(fs-f1);
title('Ideal Sine - Rectangular window');
grid on;

subplot(2,1,2)
plot(f, abs(X2Rect))
xline(f2);
xline(fs-f2);
title('Practical Sine - Rectangular Window')
grid on;


figure(2);
subplot(2,1,1)
plot(f, abs(X1Hann))
title('Ideal Sine - Hanning Window')
grid on;

subplot(2,1,2)
plot(f, abs(X2Hann))
title('Practical Sine - Hanning Window')
grid on;

figure(3);
subplot(2,1,1);
plot(f, abs(X1Hamm));
title('Ideal Sine - Hamming Window');
grid on;

subplot(2,1,2);
plot(f, abs(X2Hamm));
title('Practical Sine - Hamming Window');
grid on;

xlabel('Frequency (Hz)')





