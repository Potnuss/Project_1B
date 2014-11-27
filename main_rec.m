
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





