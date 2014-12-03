%% Load p025c80r4212.mat
close all
load('pontusdaniel141202/p025c80r4212.mat')
plot(yrec)

rngpilots = 42; %#ok<*NASGU>
rngmessage = 12;
lengthCycP = 80; % Length of cyclic prefix
startsample = 1.3013e4;
startsample = startsample-290 ;
%% Load p025c40r4313.mat
close all
load('pontusdaniel141202/p025c40r4313.mat')
plot(yrec)

rngpilots = 43;
rngmessage = 13;
lengthCycP = 40; % Length of cyclic prefix
startsample = 1.6644e4;
startsample = startsample-120 ;
%% Load p015c80r4414.mat
close all
load('pontusdaniel141202/p015c80r4414.mat')
plot(yrec)

rngpilots = 44;
rngmessage = 14;
lengthCycP = 80; % Length of cyclic prefix
startsample = 1.5109e4;
startsample = startsample-250 ;
%% Load p015c40r4515.mat
close all
load('pontusdaniel141202/p015c40r4515.mat')
plot(yrec)

rngpilots = 45;
rngmessage = 15;
lengthCycP = 40; % Length of cyclic prefix
startsample = 1.8722e4;
startsample = startsample-270 ;
%% Load p005c80r4616.mat
close all
load('pontusdaniel141202/p005c80r4616.mat')
plot(yrec)

rngpilots = 46;
rngmessage = 16;
lengthCycP = 80; % Length of cyclic prefix
startsample = 1.6105e4;
startsample = startsample -330 ;
%% Load p005c40r4717.mat
close all
load('pontusdaniel141202/p005c40r4717.mat')
plot(yrec)

rngpilots = 47;
rngmessage = 17;
lengthCycP = 40; % Length of cyclic prefix
startsample = 9140;
startsample = startsample -210 ;
%% Load p002c80r4818.mat
close all
load('pontusdaniel141202/p002c80r4818.mat')
plot(yrec)

rngpilots = 48;
rngmessage = 18;
lengthCycP = 80; % Length of cyclic prefix
startsample = 1.0795e4;
startsample = startsample -650 ; %factor 5 : 100samples here is 20samples for synkerror
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
lengthB = 33; %length of filter B
lengthzmr = (lengthCycP+N+lengthCycP+N)*R + lengthB - 1;
lengthzmr =  lengthzmr + 800; %OBS +800!to be able to go +80 shifts
zmr = yrec(startsample:startsample+lengthzmr-1);
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
title('Bit errors for bit message')
xlabel('Shifted samples in baseband')
ylabel('Nr of bit error')

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
