function zm = modulate(zi,fs,fc,NN)
fs = 22050;
fc = 4000;
F = (0:NN-1)/NN*fs;
n = (0:length(zi)-1)';
zm = zi.*exp(1i*2*pi*fc/fs*n);
end
