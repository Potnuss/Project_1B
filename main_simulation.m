%% Transmitter
clc, clear variables

% Variables used
fs = 22050;      % Sampling frequency
fc = 4000;       % Center frequency
R = 10;           % Upsampling nymber
N = 128;         % Number of bits to send
NN = 2^14;       % Number of frequency grid points
lengthCycP = 80; % Length of cyclic prefix
E = 1;           % Gain

rng(1);          % Seed for int generation
pilotBits = 2*round(rand(1, 2*N)) - 1;

rng(5);
messageBits = 2*round(rand(1, 2*N)) - 1;

% Make z(n) length(z)=cyc+N+cyc+N = 128*2+80*2=416
z = bitsToOFDM(pilotBits, messageBits, N, lengthCycP, E);

% Upsample length(zu)=length(z)*R=416*5=2080
zu = upsample(z, length(z), R);

% Interpolate
B = firpm(32, 2*[0 0.5/R*0.9 0.5/R*1.6 1/2], [1 1 0 0]);
zi = conv(zu, B);%length(zi)=length(zu)+length(B)-1=2080*33-1=2112

% Modulate
zm = modulate(zi, fs, fc, NN);%length(zm)=length(zi)

% Make reallength(zmr)=length(zm)
zmr = real(zm);

yrec = simulate_audio_channel(zmr, 0.1);


%% Use sigstart on yrec to get startsample
% startsample = sigStart(yrec, 'plot');

startsample = 64010; %factor 5 : 100samples here is 20samples for synkerror
%% Parameters

fs = 22050;      % Sampling frequency
fc = 4000;       % Center frequency
R = 10;           % Upsampling nymber
N = 128;         % Number of bits to send
NN = 2^14;       % Number of frequency grid points
lengthCycP = 80; % Length of cyclic prefix
E = 1;           % Gain

%Pilots
rng(1);
pilotBits = 2*round(rand(1,2*N))-1;
%Message
rng(5);
cheatmessageBits = 2*round(rand(1, 2*N)) - 1;
% cheatmessageBits = text2bit('raman potnus daniel marko ramana');%right message for yreec.mat

%% Modify samples - Cut yrec to right length

lengthB = 33; %length of filter B
lengthzmr = (lengthCycP+N+lengthCycP+N)*R + lengthB - 1;
zmr = yrec(startsample:startsample+lengthzmr-1);

%% RECIEVER first part

%Demodulation
yib = demodulate(zmr,fs,fc,NN,zmr);

%Decimation
B = firpm(32,2*[0 0.5/R*0.9 0.5/R*1.6 1/2],[1 1 0 0]);
yi = conv(yib,B);


%Down sampling
y = yi(1:R:end);
%% Check BER for different syncerrors between start and stop
start = -80;
stop = 0;

[BERpilot,BERmessage] = findSynchError(start, stop, y, pilotBits,cheatmessageBits, lengthCycP, N, E);

figure(1)
clf
hold on
plot(start:stop,BERpilot);
plot(start:stop,BERmessage,'r');
legend('BERpilot','BERmessage')

figure(2)
plot(yrec)

%% Decode at one specific syncerror
clc
synchError = -40; %Choose a synchError (check with findSynchError)
[estmessageBits, H_est, estpilotBits] = iOFDMToBits(y, pilotBits, lengthCycP, N, synchError, E);

%Plot the recieved estmessagebits
figure(3)
clf
stem(abs(H_est))
title('stem(abs(Hest))')

figure(4)
stem(angle(H_est))
title('stem(angle(Hest))')

%Check biterror
estmessageBits01 = (estmessageBits + 1)./2;%convert to 1,0
cheatmessageBits01 = (cheatmessageBits + 1)./2;%convert to 1,0
biterrors = sum(abs(estmessageBits01 - cheatmessageBits01));
disp('Bit errors for recieved message');
disp(biterrors);
disp('with syncherror');
disp(synchError);

