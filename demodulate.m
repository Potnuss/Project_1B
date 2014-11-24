function yib = demodulate(yrec,fs,fc,NN,zi)
%Remove zi? why is it there, the reciever dont know this?
fs = 22050;
fc = 4000;
F = (0:NN-1)/NN*fs;
n = (0:length(zi)-1)';
yib = yrec.*exp(-i*2*pi*fc/fs*n);
end