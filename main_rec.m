%% clc, clear variables
% 
% N = 128;
% lengthCycP = 60;
% %z = bitsToOFDM(estimationBits, messageBits, N, lengthCycP);
% z = 0.8.^(0:N-1)';                   % original signal
% NN = 2^14;                           % Number of frequency grid points
% f = (0:NN-1)/NN;
% semilogy(f,abs(fft(z,NN)))           % Check transform
% xlabel('Relative frequency [f/fs]', 'Interpreter', 'latex', 'FontSize', 20);
% %% SENDER test of hole chain
% clc, clear variables
% 
% N = 128;
NN = 2^14;   
% lengthCycP = 60;
% % Generate random bit sequence
% messageBits = 2*round(rand(1,2*N))-1;
% estimationBits = 2*round(rand(1,2*N))-1;
% 
% % Make z(n)
% z = bitsToOFDM(estimationBits, messageBits, N, lengthCycP);
% 
% % Upsample
% R = 5;
% zu = upsample(z, length(z), R);
% 
% %Interpolate
% %zi = interpolate(zu, R);
% B = firpm(32,2*[0 0.5/R*0.9 0.5/R*1.6 1/2],[1 1 0 0]);
% zi = conv(zu,B);
% 
% %Modulate
% fs = 22050;
% fc = 4000;
% zm = modulate(zi,fs,fc,NN);
% 
% %Make real
% zmr = real(zm);
% 
% %Send through audio channel
% sigma = 0.1;
% yrec = simulate_audio_channel( zmr, sigma );
%% Record input signal
%% Record received data
close all
yrec = wavrecord(5*fs,fs);
%%
plot(yrec)



%plot(abs(fft(yrec)))

%% Modify samples 
start = 6575;
% slut = 1.621e4;
zmr = yrec(start:start+2112);
figure
plot(zmr)


%% RECIEVER test of hole chain (need to add some synchronization)
close all
rng(4);
estimationBits = 2*round(rand(1,2*N))-1;
lengthCycP = 80;
%Demodulation
%m = demodulate(yrec,fs,fc,NN,zi)
zi = ones(1,length(zmr));
yib = demodulate(zmr,fs,fc,NN,zi);

%Decimation
B = firpm(32,2*[0 0.5/R*0.9 0.5/R*1.6 1/2],[1 1 0 0]);
yi = conv(yib,B);

%Down sampling
D = 5;
y = yi(1:D:end);

% from y(n) to bits (need to add some synchronization)
[b H_est]= iOFDMToBits(y, estimationBits, lengthCycP, N);
figure
stem(abs(H_est))
figure 
stem(angle(H_est))
bb = (b + 1)./2;
message = bit2text(bb);
disp(message);
recm = text2bit(message); 
sendm = text2bit('raman potnus daniel marko ramana');
biterrorrate = sum(abs(recm - sendm));
disp(biterrorrate);

%% Test of bitsToOFDM and back like in Project1A
N = 128;
lengthCycP = 60;
% Generate random bit sequence
messageBits = 2*round(rand(1,2*N))-1;
% Generate random bit for the 'known' messege
estimationBits = 2*round(rand(1,2*N))-1;

z = bitsToOFDM(estimationBits, messageBits, N, lengthCycP);
[y, H] = testchannelLab1A(z);
b = iOFDMToBits(y, estimationBits, lengthCycP, N);

%% Now upsampling
R = 5;
zu = upsample(z, R)

semilogy(f,abs(fft(zu,NN)))          % Check transform
xlabel('Normalized frequency [f/fs]', 'Interpreter', 'latex', 'FontSize', 20);


%% Design a LP interpolation filter
B = firpm(32,2*[0 0.5/R*0.9 0.5/R*1.6 1/2],[1 1 0 0]);
zi = conv(zu,B);
zi = interpolate(zu, R);
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
zm = modulation(zi,fs,fc,NN);
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




