%% Transmitter
clc, clear variables

% Variables used
fs = 22050;      % Sampling frequency
fc = 4000;       % Center frequency
R = 5;           % Upsampling nymber
N = 128;         % Number of bits to send
NN = 2^14;       % Number of frequency grid points
lengthCycP = 80; % Length of cyclic prefix
E = 1;           % Gain

rng(1);          % Seed for int generation
pilotBits = 2*round(rand(1, 2*N)) - 1;

rng(5);
messageBits = 2*round(rand(1, 2*N)) - 1;

% Make z(n)
z = bitsToOFDM(pilotBits, messageBits, N, lengthCycP, E);

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
% wavplay([zmr zmr*0], fs);