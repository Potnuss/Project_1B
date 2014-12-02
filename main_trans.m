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

% Make z(n) length(z)=cyc+N+cyc+N = 128*2+80*2=416
z = bitsToOFDM(pilotBits, messageBits, N, lengthCycP, E);

% Upsample length(zu)=length(z)*R=416*5=2080
zu = upsample(z, length(z), R);

% Interpolate
B = firpm(32, 2*[0 0.5/R*0.9 0.5/R*1.6 1/2], [1 1 0 0]);
zi = conv(zu, B);%length(zi)=length(zu)+length(B)-1=2080*33-1=2112

% Modulate
zm = modulate(zi, fs, fc, NN);%length(zm)=length(zi)

% Make reallength(zmr)=length(zm)
zmr = real(zm);

% Send signal
% wavplay([zmr zmr*0], fs);
