% Calculate optimal cuttoff level
clear all

sumMatrix = [];
sumOfBer = 0;

for cutOff = 0.1:0.05:0.9
    sumOfBer = 0;
    %% Load p025c80r4212.mat
    data1 = load('pontusdaniel141202/p025c80r4212.mat');

    rngpilots1 = 42; %#ok<*NASGU>
    rngmessage1 = 12;
    lengthCycP1 = 80; % Length of cyclic prefix
    startsample1 = 1.3013e4;
    startsample1 = startsample1-290;
    startsampleSig1 = sigStart2(data1.yrec, tlength(lengthCycP1,128,10),cutOff);
    sumOfBer = sumOfBer + abs(startsample1-startsampleSig1);
    % startsample = startsamplesig2;
    %% Load p025c40r4313.mat
    data2 = load('pontusdaniel141202/p025c40r4313.mat');
    % plot(yrec)

    rngpilots2 = 43;
    rngmessage2 = 13;
    lengthCycP2 = 40; % Length of cyclic prefix
    startsample2 = 1.6644e4;
    startsample2 = startsample2-120 ;
    startsampleSig2 = sigStart2(data2.yrec, tlength(lengthCycP2,128,10),cutOff);
    sumOfBer = sumOfBer + abs(startsample2-startsampleSig2);
    %% Load p015c80r4414.mat
    data3 = load('pontusdaniel141202/p015c80r4414.mat');

    rngpilots3 = 44;
    rngmessage3 = 14;
    lengthCycP3 = 80; % Length of cyclic prefix
    startsample3 = 1.5109e4;
    startsample3 = startsample3-250 ;
    startsampleSig3 = sigStart2(data3.yrec, tlength(lengthCycP3,128,10),cutOff);
    sumOfBer = sumOfBer + abs(startsample3-startsampleSig3);
    %% Load p015c40r4515.mat
    data4 = load('pontusdaniel141202/p015c40r4515.mat');

    rngpilots4 = 45;
    rngmessage4 = 15;
    lengthCycP4 = 40; % Length of cyclic prefix
    startsample4 = 1.8722e4;
    startsample4 = startsample4-270 ;
    startsampleSig4 = sigStart2(data4.yrec, tlength(lengthCycP4,128,10),cutOff);
    sumOfBer = sumOfBer + abs(startsample4-startsampleSig4);
    %% Load p005c80r4616.mat
%     data5 = load('pontusdaniel141202/p005c80r4616.mat');
% 
%     rngpilots5 = 46;
%     rngmessage5 = 16;
%     lengthCycP5 = 80; % Length of cyclic prefix
%     startsample5 = 1.6105e4;
%     startsample5 = startsample5 -330 ;
%     startsampleSig5 = sigStart2(data5.yrec, tlength(lengthCycP5,128,10),cutOff);
%     sumOfBer = sumOfBer + abs(startsample5-startsampleSig5);
    %% Load p005c40r4717.mat
    data6 = load('pontusdaniel141202/p005c40r4717.mat');

    rngpilots6 = 47;
    rngmessage6 = 17;
    lengthCycP6 = 40; % Length of cyclic prefix
    startsample6 = 9140;
    startsample6 = startsample6 -210 ;
    startsampleSig6 = sigStart2(data6.yrec, tlength(lengthCycP6,128,10),cutOff);
    sumOfBer = sumOfBer + abs(startsample6-startsampleSig6);
    sumMatrix = [sumMatrix sumOfBer];
    %% Load p002c80r4818.mat
%     data7 = load('pontusdaniel141202/p002c80r4818.mat');
% 
%     rngpilots7 = 48;
%     rngmessage7 = 18;
%     lengthCycP7 = 80; % Length of cyclic prefix
%     startsample7 = 1.0795e4;
%     startsample7 = startsample7 -650 ; %factor 5 : 100samples here is 20samples for synkerror
%     startsampleSig7 = sigStart2(data7.yrec, tlength(lengthCycP7,128,10),cutOff);
%     sumOfBer = sumOfBer + abs(startsample7-startsampleSig7);
%     
end
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
