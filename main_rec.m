
%% Record received data
close all
yrec = wavrecord(5*fs,fs);
%%
plot(yrec)
%plot(abs(fft(yrec)))

%% Modify samples 
start = 6564;
% slut = 1.621e4;
yreec = load('yreec.mat');
yrec = yreec.yrec;
zmr = yrec(start:start+2112-1);
figure
plot(zmr)


%% RECIEVER test of hole chain (need to add some synchronization)

close all
rng(4);
N = 128;
estimationBits = 2*round(rand(1,2*N))-1;
lengthCycP = 80;
fs = 22050;
fc = 4000;
NN = 2^14;  
%Demodulation
yib = demodulate(zmr,fs,fc,NN,zmr);

%Decimation
R = 5;
B = firpm(32,2*[0 0.5/R*0.9 0.5/R*1.6 1/2],[1 1 0 0]);
yi = conv(yib,B);

%Down sampling
D = 5;
y = yi(1:D:end);
start = -80;
stop = 10;
clc
BER = findSynchError(start, stop, y, estimationBits, lengthCycP, N);
plot(start:stop,BER);

%%

% from y(n) to bits (need to add some synchronization)
[b H_est]= iOFDMToBits(y, estimationBits, lengthCycP, N);

%Plot the recieved
figure
stem(abs(H_est))
figure 
stem(angle(H_est))
bb = (b + 1)./2;
message = bit2text(bb);
disp(message);
recm = text2bit(message); 
sendm = text2bit('raman potnus daniel marko ramana');
% sendm = text2bit('abcdefghabcdefghabcdefghabcdefhg');
% sendm = text2bit('FreedomfromWantisthethirdoftheFo');
% sendm = text2bit('paintingsbyAmericanartistNormanR');
% sendm = text2bit('commonlyunderstoodoraccepteduniv');
biterrorrate = sum(abs(recm - sendm));
disp(biterrorrate);



%%

% from y(n) to bits (need to add some synchronization)
iterator = start:10;
start = -80;
errors = zeros(size(start:130));
sendm = text2bit('raman potnus daniel marko ramana');

for i = iterator
    
    synchError = i;
    b = iOFDMToBits(y, estimationBits, lengthCycP, N, synchError);
    
    bb = (b + 1)./2;
%     message = bit2text(bb);

%     recm = text2bit(message); 
    
    errors(i-start+1) = sum(abs(bb - sendm));

end
disp(message);
figure
plot(errors)
title('Different bit error rates')