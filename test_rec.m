%% Test code, receiver side
fs = 22050;
T = 3;
N = fs*T;
y = wavrecord(N,fs,2);
plot(y);