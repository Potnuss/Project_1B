%% Run
%clc, clear variables, close all
clc, close all
iterations = 1000;

acErr = 0; %Acumulated error

E = 1;  %Signal amplitude (Do not change)

N = 128;

% Generate random bit sequence
bitMessage1 = 2*round(rand(1,2*N))-1;
% Generate random bit sequence
bitMessage2 = 2*round(rand(1,2*N))-1;
% Generate random bit for the 'known' messege
knownBits = 2*round(rand(1,2*N))-1;

% Filter for channel and length of cyclic prefix
% %----Filter h1
ch = 'h1';
cyclicPref = 60;
%----Filter h2
% ch = 'h2';
% cyclicPref = 9;

% Is the channel known to the reciever?
known_channel = 1;

%Std dev for noise
s = 0;
%s = 0.01;
% s = 0.05;
% s = 0.1;

% Synchronization error?
%synchError = 0;
 synchError = -8;
% synchError = 8;


for k = 1:iterations
    [receivedBits, errs, H_est, trueH, r, estS, S] = testSendRec(s, E, bitMessage1, bitMessage2, knownBits, N, cyclicPref, ch, known_channel, synchError);
    acErr = acErr + errs;
end

avNumOfErrors = acErr/iterations
avErrorRate = avNumOfErrors/(2*N)

if known_channel == 1
    H = trueH;
else
    H = H_est;
end
%% Plots

% Plot r(k) and s(k)
figure(1)
stem(bitMessage - receivedBits);

title('Difference between $\hat{s}(k)$ and $s(k)$', 'Interpreter', 'latex', 'FontSize', 20);
xlabel('bit [n]', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Defference', 'Interpreter', 'latex', 'FontSize', 16);

%%
% Plot h(n) and est of h(n)
figure(2)
hold on
plot(abs(trueH), 'LineWidth', 1);
plot(abs(H_est), 'ro');

if strcmp(ch, 'h1')
    title('Impulse response of $h_{1}(w)$ and $\hat{h}_{1}(w)$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('$|h_{1}(w)|$', 'Interpreter', 'latex', 'FontSize', 16);
else
    title('Impulse response of $h_{2}(w)$ and $\hat{h}_{2}(w)$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('$|h_{2}(w)|$', 'Interpreter', 'latex', 'FontSize', 16);
end

xlabel('Sample [n]', 'Interpreter', 'latex', 'FontSize', 16);

legend('Actual', 'Estimation');

H_diff = abs(trueH) - abs(H_est);
H_err = rms(H_diff)
hold off

% Plot of phase for h(n) and est of h(n)
figure(3)
hold on
plot(angle(trueH), 'LineWidth', 1)
plot(angle(H_est), 'r')

if strcmp(ch, 'h1')
    title('Phase of $h_{1}(w)$ and $\hat{h}_{1}(w)$', 'Interpreter', 'latex', 'FontSize', 20);
else
    title('Phase of $h_{2}(w)$ and $\hat{h}_{2}(w)$', 'Interpreter', 'latex', 'FontSize', 20);
end
xlabel('Sample [n]', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Angle [rad]', 'Interpreter', 'latex', 'FontSize', 16);

legend('Actual', 'Estimation');
hold off

%%
% Plot of s(k), r(k) and estS(k)
figure(4)

subplot(211)
hold on
title('$|s(k)|$ and $|r(k)|$', 'Interpreter', 'latex', 'FontSize', 20);
stem(abs(S), 'Marker','.','LineWidth',1,'Color',[1 0 0])   % |s(k)|
stem(abs(r))        % |r(k)|

xlabel('Symbol [n]', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Absolute value', 'Interpreter', 'latex', 'FontSize', 16);
legend('s(k)', 'r(k)')
hold off

subplot(212)
hold on
title('Phase of $s(k)$ and $r(k)$', 'Interpreter', 'latex', 'FontSize', 20);
stem(angle(S), 'Marker','.','LineWidth',1,'Color',[1 0 0]) % <s(k)
stem(angle(r))      % <r(k)

xlabel('Symbol [n]', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Phase', 'Interpreter', 'latex', 'FontSize', 16);
legend('s(k)', 'r(k)')
hold off

%%
figure(5)
subplot(211)
hold on
title('$|s(k)|$ and $|\hat{s}(k)|$', 'Interpreter', 'latex', 'FontSize', 20);
stem(abs(S), 'Marker','.','LineWidth',1,'Color',[1 0 0])   % |s(k)|
stem(abs(estS))        % |estS(k)|

xlabel('Symbol [n]', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Absolute value', 'Interpreter', 'latex', 'FontSize', 16);
legend('s(k)', 'est. of s(k)')
hold off

%%
subplot(212)
hold on
title('Phase of $s(k)$ and $\hat{s}(k)$', 'Interpreter', 'latex', 'FontSize', 20);
stem(angle(S), 'Marker','.','LineWidth',1,'Color',[1 0 0]) % <s(k)
stem(angle(estS))      % <estS(k)

xlabel('Symbol [n]', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Phase', 'Interpreter', 'latex', 'FontSize', 16);
legend('s(k)', 'est. of s(k)')
hold off

%% Phase bar
hold on
title('Noise free \& synch error', 'Interpreter', 'latex', 'FontSize', 20);
stem(angle(S), 'MarkerSize',15,'MarkerFaceColor',[1 0 0],...
    'MarkerEdgeColor',[1 0 0],...
    'Marker','.',...
    'LineWidth',1,...
    'Color',[1 0 0])          % <s(k)
stem(angle(estS))                                                % <estS(k)
plot([0 128], [pi/2 pi/2], '-.k')
plot([0 128], [-pi/2 -pi/2], '-.k')

axis([0 128 -4 4])

xlabel('Symbol [n]', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Phase [rad]', 'Interpreter', 'latex', 'FontSize', 16);
legend('s(k)', 'est. of s(k)')
hold off

%%
hold on
title('Noise free \& synch error', 'Interpreter', 'latex', 'FontSize', 20);
stem(angle(S), 'MarkerSize',15,'MarkerFaceColor',[1 0 0],...
    'MarkerEdgeColor',[1 0 0],...
    'Marker','.',...
    'LineWidth',1,...
    'Color',[1 0 0])          % <s(k)
stem(angle(r))                                                      % <r(k)
plot([0 128], [pi/2 pi/2], '-.k')
plot([0 128], [-pi/2 -pi/2], '-.k')

axis([0 128 -4 4])

xlabel('Symbol [n]', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Phase [rad]', 'Interpreter', 'latex', 'FontSize', 16);
legend('s(k)', 'r(k)')
hold off