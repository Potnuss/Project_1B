%% Transmitter
clc, clear variables

% Variables used
fs = 22050;      % Sampling frequency
fc = 4000;       % Center frequency
R = 5;           % Upsampling nymber
N = 128;         % Number of bits to send
NN = 2^14;       % Number of frequency grid points
lengthCycP = 80; % Length of cyclic prefix
rng(1);          % Seed for int generation

% Create data to send
% messageBits = text2bit('raman potnus daniel marko ramana');
% messageBits = text2bit('abcdefghabcdefghabcdefghabcdefhg');
% messageBits = text2bit('FreedomfromWantisthethirdoftheFo');
% messageBits = text2bit('paintingsbyAmericanartistNormanR');
% messageBits = text2bit('commonlyunderstoodoraccepteduniv');
estimationBits = 2*round(rand(1, 2*N)) - 1;
rng(5);
messageBits = 2*round(rand(1, 2*N)) - 1;

% Make z(n)
z = bitsToOFDM(estimationBits, messageBits, N, lengthCycP);

% Upsample
zu = upsample(z, length(z), R);

% Interpolate
B = firpm(32, 2*[0 0.5/R*0.9 0.5/R*1.6 1/2], [1 1 0 0]);
zi = conv(zu, B);

% Modulate
zm = modulate(zi, fs, fc, NN);

% Make real
zmr = real(zm);

% Send signal
wavplay([zmr zmr*0], fs);