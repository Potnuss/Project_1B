%% 1 Load p025c80r4212.mat
close all
load('pontusdaniel141202/p025c80r4212.mat')
plot(yrec)
Data = '1';
rngpilots = 42; %#ok<*NASGU>
rngmessage = 12;
lengthCycP = 80; % Length of cyclic prefix
startsample = 1.3013e4;
startsample = startsample-290
startsample2 = sigStart2(yrec, tlength(lengthCycP,128,10),lengthCycP,'plot')
diff = startsample-startsample2
hold on
stem(startsample,0.1,'y')
hold off
startsample = startsample2;
%% 2 Load p025c40r4313.mat
close all
load('pontusdaniel141202/p025c40r4313.mat')
plot(yrec)
Data = '2';
rngpilots = 43;
rngmessage = 13;
lengthCycP = 40; % Length of cyclic prefix
startsample = 1.6644e4;
startsample = startsample-120 
startsample2 = sigStart2(yrec, tlength(lengthCycP,128,10),lengthCycP,'plot')
diff = startsample-startsample2
hold on
stem(startsample,0.1,'y')
hold off
startsample = startsample2;
%% 3 Load p015c80r4414.mat
close all
load('pontusdaniel141202/p015c80r4414.mat')
plot(yrec)
Data = '3';
rngpilots = 44;
rngmessage = 14;
lengthCycP = 80; % Length of cyclic prefix
startsample = 1.5109e4;
startsample = startsample-250 
startsample2 = sigStart2(yrec, tlength(lengthCycP,128,10),lengthCycP,'plot')
diff = startsample-startsample2
hold on
stem(startsample,0.1,'y')
hold off
startsample = startsample2;
%% 4 Load p015c40r4515.mat
close all
load('pontusdaniel141202/p015c40r4515.mat')
plot(yrec)
Data = '4';
rngpilots = 45;
rngmessage = 15;
lengthCycP = 40; % Length of cyclic prefix
startsample = 1.8722e4;
startsample = startsample-270
startsample2 = sigStart2(yrec, tlength(lengthCycP,128,10),lengthCycP,'plot')
diff = startsample-startsample2
hold on
stem(startsample,0.1,'y')
hold off
startsample = startsample2;
%% 5 Load p005c80r4616.mat
close all
load('pontusdaniel141202/p005c80r4616.mat')
plot(yrec)
Data = '5';
rngpilots = 46;
rngmessage = 16;
lengthCycP = 80; % Length of cyclic prefix
startsample = 1.6105e4;
startsample = startsample -330
startsample2 = sigStart2(yrec, tlength(lengthCycP,128,10),lengthCycP,'plot')
diff = startsample-startsample2
hold on
stem(startsample,0.1,'y')
hold off
startsample = startsample2;

noiseAmp = var(yrec(21940:48880))
sigAmp = var(yrec(16120:19840))
SNR = sigAmp/noiseAmp
%% 6 Load p005c40r4717.mat
close all
load('pontusdaniel141202/p005c40r4717.mat')
plot(yrec)
Data = '6';
rngpilots = 47;
rngmessage = 17;
lengthCycP = 40; % Length of cyclic prefix
startsample = 9140;
startsample = startsample -210
startsample2 = sigStart2(yrec, tlength(lengthCycP,128,10),lengthCycP,'plot')
diff = startsample-startsample2
hold on
stem(startsample,0.1,'y')
hold off
startsample = startsample2;
%% 7 Load p002c80r4818.mat
close all
load('pontusdaniel141202/p002c80r4818.mat')
plot(yrec)
Data = '7';
rngpilots = 48;
rngmessage = 18;
lengthCycP = 80; % Length of cyclic prefix
startsample = 1.0795e4;
startsample = startsample -650
startsample2 = sigStart2(yrec, tlength(lengthCycP,128,10),lengthCycP,'plot')
diff = startsample-startsample2
hold on
stem(startsample,0.1,'y')
hold off
startsample = startsample2;
%% General Parameters & Start plot
fs = 22050;      % Sampling frequency
fc = 4000;       % Center frequency
R = 10;           % Upsampling nymber
N = 128;         % Number of bits to send
NN = 2^14;       % Number of frequency grid points
%lengthCycP = 80; % Length of cyclic prefix
E = 100;           % Gain

%Pilots
rng(rngpilots);
pilotBits = 2*round(rand(1,2*N))-1;
%Message
rng(rngmessage);
cheatmessageBits = 2*round(rand(1, 2*N)) - 1;

% Modify samples - Cut yrec to right length
close all
truelength = tlength(lengthCycP,N,R);
truelength =  truelength + 800;
zmr = yrec(startsample:startsample+truelength-1);
figure
plot(zmr)

% RECIEVER first part
close all

%Demodulation
yib = demodulate(zmr,fs,fc,NN,zmr);

%Decimation
B = firpm(32,2*[0 0.5/R*0.9 0.5/R*1.6 1/2],[1 1 0 0]);
yi = conv(yib,B);

%Down sampling
y = yi(1:R:end);

% Check BER for different syncerrors between start and stop
close all
start = -lengthCycP -0;
stop = lengthCycP-0;
clc
[BERpilot,BERmessage] = findSynchError(start, stop, y, pilotBits,cheatmessageBits, lengthCycP, N, E);

plot(start:stop,BERmessage);
% title('Bit errors for bit message')
xlabel('Shifted samples in baseband')
ylabel('# of bit errors')
%% Decode at one specific syncerror, BE and BER
synchError = 0; %Choose a synchError (check with findSynchError)
[estmessageBits, H_est, estpilotBits] = iOFDMToBits(y, pilotBits, lengthCycP, N, synchError, E);

%Plot the recieved estmessagebits
figure
stem(abs(H_est))
% title('stem(abs(Hest))')
xlabel('Samples');
ylabel('Amplitude');
figure 
stem(angle(H_est))
xlabel('Samples');
ylabel('Phase [rad]');
% title('stem(angle(Hest))')

%Check bitterror
estmessageBits01 = (estmessageBits + 1)./2;%convert to 1,0
cheatmessageBits01 = (cheatmessageBits + 1)./2;%convert to 1,0
biterrors = sum(abs(estmessageBits01 - cheatmessageBits01));
disp('Data #')
disp(Data)
disp('Bit errors for recieved message');
disp(biterrors);
BER = biterrors/256
%% Frequency plotting
close all
C = [115 115 115];
L = [82 82 82];
fs = 22050;
NN = 2^14;
w = (0:NN-1)/NN*fs;

f_yrec = abs(fft(yrec, NN));    % Recorded signal
f_dem = abs(fft(yib, NN));      % Demodulated signal
f_filt = abs(fft(yi, NN));
f_down = abs(fft(y, NN));

close all
figure(1)
plot(w,f_yrec, 'Color', C./255);
title('Recieved signal', 'Interpreter', 'latex', 'FontSize', 20)
xlabel('Frequency [Hz]', 'Interpreter', 'latex', 'FontSize', 16, 'Color', C./255);
ylabel('Amplitude', 'Interpreter', 'latex', 'FontSize', 16, 'Color', C./255);
figure(2)
plot(f_dem, 'Color', C./255);
title('Demodulated signal', 'Interpreter', 'latex', 'FontSize', 20)
xlabel('Frequency [Hz]', 'Interpreter', 'latex', 'FontSize', 16, 'Color', C./255);
ylabel('Amplitude', 'Interpreter', 'latex', 'FontSize', 16, 'Color', C./255);
figure(3)
plot(f_filt, 'Color', C./255);
title('Filtered signal', 'Interpreter', 'latex', 'FontSize', 20)
xlabel('Frequency [Hz]', 'Interpreter', 'latex', 'FontSize', 16, 'Color', C./255);
ylabel('Amplitude', 'Interpreter', 'latex', 'FontSize', 16, 'Color', C./255);
figure(4)
plot(f_down, 'Color', C./255);
title('Downsampled signal', 'Interpreter', 'latex', 'FontSize', 20)
xlabel('Frequency [Hz]', 'Interpreter', 'latex', 'FontSize', 16, 'Color', C./255);
ylabel('Amplitude', 'Interpreter', 'latex', 'FontSize', 16, 'Color', C./255);