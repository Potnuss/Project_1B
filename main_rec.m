
%% Record received data
close all
yrec = wavrecord(5*fs,fs);
%% Load stored yrec (instead of recording)
clear all
load('yreec.mat');
%% Use sigstart on yrec to get startsample
close all
plot(yrec)
% startsample = sigStart(yrec, 'plot');
%try -300samples below
startsample = 1.0116e4
startsample = startsample -170 ; %factor 5 : 100samples here is 20samples for synkerror
%% Parameters

fs = 22050;      % Sampling frequency
fc = 4000;       % Center frequency
R = 10;           % Upsampling nymber
N = 128;         % Number of bits to send
NN = 2^14;       % Number of frequency grid points
lengthCycP = 80; % Length of cyclic prefix
E = 100;           % Gain

%Pilots
rng(48);
pilotBits = 2*round(rand(1,2*N))-1;
%Message
rng(18);
cheatmessageBits = 2*round(rand(1, 2*N)) - 1;
% cheatmessageBits = text2bit('raman potnus daniel marko ramana');%right message for yreec.mat
%% Modify samples - Cut yrec to right length
close all
% startsample = 6564;
lengthB = 33; %length of filter B
lengthzmr = (lengthCycP+N+lengthCycP+N)*R + lengthB - 1;
zmr = yrec(startsample:startsample+lengthzmr-1);
figure
plot(zmr)
%% RECIEVER first part
close all

%Demodulation
yib = demodulate(zmr,fs,fc,NN,zmr);

%Decimation
B = firpm(32,2*[0 0.5/R*0.9 0.5/R*1.6 1/2],[1 1 0 0]);
yi = conv(yib,B);

%Down sampling
y = yi(1:R:end);
%% Check BER for different syncerrors between start and stop
close all
start = -80;
stop = 5;
clc
[BERpilot,BERmessage] = findSynchError(start, stop, y, pilotBits,cheatmessageBits, lengthCycP, N, E);
plot(start:stop,BERpilot);
hold on
plot(start:stop,BERmessage,'r');
legend('BERpilot','BERmessage')

%% Decode at one specific syncerror
synchError = 0; %Choose a synchError (check with findSynchError)
[estmessageBits, H_est, estpilotBits] = iOFDMToBits(y, pilotBits, lengthCycP, N, synchError, E);

%Plot the recieved estmessagebits
figure
stem(abs(H_est))
title('stem(abs(Hest))')
figure 
stem(angle(H_est))
title('stem(angle(Hest))')

%Check bitterror
estmessageBits01 = (estmessageBits + 1)./2;%convert to 1,0
cheatmessageBits01 = (cheatmessageBits + 1)./2;%convert to 1,0
biterrors = sum(abs(estmessageBits01 - cheatmessageBits01));
disp('Bit errors for recieved message');
disp(biterrors);
disp('with sycherror');
disp(synchError);
