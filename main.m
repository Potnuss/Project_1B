clc, clear variables

N = 128;
z = bitsToOFDM(estimationBits, messageBits, N, lengthCycP);
z = 0.8.^(0:N-1)';                   % original signal
NN = 2^14;                           % Number of frequency grid points
f = (0:NN-1)/NN;
semilogy(f,abs(fft(z,NN)))           % Check transform
xlabel('Relative frequency [f/fs]', 'Interpreter', 'latex', 'FontSize', 20);

%% Now upsampling
R = 5;
zu = upsample(z, R)

semilogy(f,abs(fft(zu,NN)))          % Check transform
xlabel('Normalized frequency [f/fs]', 'Interpreter', 'latex', 'FontSize', 20);


%% Design a LP interpolation filter
B = firpm(32,2*[0 0.5/R*0.9 0.5/R*1.6 1/2],[1 1 0 0]);
zi = conv(zu,B);

% zi is now the interpolated signal
figure(1)
plot(zi)
figure(2)
semilogy(f,abs([fft(zu,NN) fft(zi,NN) fft(B.',NN)]) ) % Check transforms
legend('Up-sampled z_u','Interpolated after LP filtering','LP-filter')
xlabel('relative frequency [f/fs]', 'Interpreter', 'latex', 'FontSize', 20);

%% Modulation
fs = 22050;
fc = 4000;
F = (0:NN-1)/NN*fs;
n = (0:length(zi)-1)';
zm = zi.*exp(i*2*pi*fc/fs*n);

semilogy(F,abs([fft(zi,NN) fft(zm,NN) ]) ) % Check transforms
legend('Interpolated','Modulated')
xlabel('Frequency [Hz]', 'Interpreter', 'latex', 'FontSize', 20);

%% Make signal real
zmr = real(zm);
semilogy(F,abs([fft(zi,NN) fft(zm,NN) fft(zmr,NN) ]) ) % Check transforms
legend('Interpolated','Modulated','Real and modulated')
xlabel('Frequency [Hz]', 'Interpreter', 'latex', 'FontSize', 20);


%% Demodulation
fs = 22050;
fc = 4000;
F = (0:NN-1)/NN*fs;
n = (0:length(zi)-1)';
yrec = zmr;
yib = yrec.*exp(-i*2*pi*fc/fs*n);

semilogy(F,abs([fft(y,NN) fft(yib,NN) ]) ) % Check transforms
legend('Modulated','Demodulated')
xlabel('Frequency (Hz)');




