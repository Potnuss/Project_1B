%% Detect signal among noise

%% Data for testing function
close all
nc = 15000; % Number of samples recorded 

ns = 2000; % Number of samples of signal sent 

% Channel noise
chStd = 0.2;
ch = chStd.*rand(1,nc);

% True signal 
sigStd = 1;
sig = sigStd.*rand(1,ns);

sigPadded = [zeros(1,floor((nc-ns)/2)) sig zeros(1,ceil((nc-ns)/2))];

% Sound Card Transient
nt = 200;
sndStd = 0.8;
snd = sndStd.*rand(1,nt);
sndPadded = [zeros(1,floor((nc-nt)/2)-3000) snd zeros(1,ceil((nc-nt)/2)+3000)];

letsPlot = false;
if letsPlot 
    figure 
    plot(ch); title('Channel')
    figure
    plot(sigPadded); title('Padded Signal')
    figure
    plot(sndPadded); title('Sound Card Transient')
end

totalCh = ch + sigPadded + sndPadded;
hold on
plot(totalCh)
%% 
%------------------------
% Script for function 
%------------------------
mvngAvgL = 40; % Length of moving average filter
checkBack = 4; % Comparison to previous Average
switchFactor = 1.3; % Rate of Change between averages neccessary in order to consider signal as begun
% --- 
previousAverages = [];
currentAverage = 0;
sampelStamps = []; % Potential start samples of signal

for k = 1:length(totalCh)-mvngAvgL
   currentAverage = sum((totalCh(k:(k+mvngAvgL-1))))/mvngAvgL; 
   previousAverages = [previousAverages currentAverage]; %#ok<AGROW>
   
   if k > 10
    if (currentAverage/previousAverages(k-checkBack) > switchFactor)
           sampelStamps = [sampelStamps k+mvngAvgL-checkBack]; %#ok<AGROW>
    end
   end
   
   debug = false; 
   if debug
       if k > 6475 && k < 6505 %#ok<UNRCH>
           fprintf('k:%d\n',k);
           fprintf('CurrentAverage:%d\n',currentAverage);
           fprintf('PreviousAverages(k-5):%d\n',previousAverages(k-5));
           fprintf('CurrentAverage/PreviousAverages(k-5):%d\n\n',currentAverage/previousAverages(k-5))
       end
   end
   
end

filteredStamps = [];

for k = 1:length(sampelStamps)-1 % Only keep those whose value is increasing between samples
    if totalCh(sampelStamps(k)) < totalCh(sampelStamps(k+1))
       filteredStamps = [filteredStamps sampelStamps(k)]; 
    end
    
end

stem(filteredStamps,ones(1,length(filteredStamps)),'g'); title('Found initsamples of Signal')

% Get most likely sampel, considering transient
if max(diff(filteredStamps)) > 500;
    calcDiff = diff(filteredStamps);
    elem = find(calcDiff > max(calcDiff)-1) + 1;

    initSampel = filteredStamps(elem);
else
    initSampel = filteredStamps(1);
end

stem(initSampel,1,'r')
legend('Channel','Possible start samples','Most likely start sample')





