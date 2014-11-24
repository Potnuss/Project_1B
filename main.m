clc, clear variables

N = 128;
z = 0.8.^(0:N-1)';                   % original signal
NN = 2^14;                           % Number of frequency grid points
f = (0:NN-1)/NN;

% z = someFunction()

R = 5;                               %
zu = zeros(N*R,1);
% zu(1:R:end) = z;

semilogy(f,abs(fft(zu,NN)))          % Check transform
xlabel('Normalized frequency [f/fs]', 'Interpreter', 'latex', 'FontSize', 20);
