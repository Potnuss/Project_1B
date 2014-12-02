%% Test code for transmitter
fs = 22050;    % Sampling frequency
t = 0:1/fs:10; % A time reference
f0 = 1000;     % A transmitted signal frequency
x = sin(2*pi*f0*t');
wavplay([x x*0], fs);