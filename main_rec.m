
%% Record received data
close all
yrec = wavrecord(5*fs,fs);
%%
plot(yrec)
%plot(abs(fft(yrec)))

%% Modify samples 
start = 6564;
% slut = 1.621e4;
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



