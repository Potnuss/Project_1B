function [startSample] = sigStart(signalVector, varargin)
% First argument is signalVector. Passing 'plot' as second argument will
% cause the function to plot the signalVector as well as where the
% startSample found is located

plotBool = false;
if ~isempty(varargin) && strcmp(varargin{1},'plot') 
   plotBool = true; 
end

mvngAvgL = 25;%250; % Length of moving average filter
checkBack = 15;%200; % Comparison to previous Average
switchFactor = 15; % Rate of Change between averages neccessary in order to consider signal as begun
% --- 
previousAverages = [];
currentAverage = 0;
previousVariances = [];
currentVariance = 0;
sampelStamps = []; % Potential start samples of signal

for k = 1:length(signalVector)-mvngAvgL
   currentAverage = sum((signalVector(k:(k+mvngAvgL-1))))/mvngAvgL; 
   previousAverages = [previousAverages currentAverage]; %#ok<AGROW>
   
   currentVariance = var(signalVector(k:(k+mvngAvgL-1)));
   previousVariances = [previousVariances currentVariance];
   
   if k > 200
    if (abs(currentAverage/previousAverages(k-checkBack)) > switchFactor  && currentVariance/previousVariances(k-checkBack) > 2*switchFactor)
           sampelStamps = [sampelStamps k+mvngAvgL-checkBack]; %#ok<AGROW>
    end
   end
   
end

filteredStamps = [];

for k = 1:length(sampelStamps)-1 % Only keep those whose value is increasing between samples
    if true%totalCh(sampelStamps(k)) < totalCh(sampelStamps(k+1))
       filteredStamps = [filteredStamps sampelStamps(k)]; 
    end
    
end

% 
% Get most likely sampel, considering transient
if max(diff(filteredStamps)) > 500;
    calcDiff = diff(filteredStamps);
    elem = find(calcDiff > max(calcDiff)-1) + 1;

    initSampel = filteredStamps(elem);
else
    initSampel = filteredStamps(1);
end

if plotBool
    figure 
    hold on
    plot(signalVector)
    stem(filteredStamps,ones(1,length(filteredStamps)),'g'); title('Found initsamples of Signal')
    stem(initSampel,1,'r')
    text(60000,0.5, strcat('Sample index:','   ', num2str(initSampel)));
    legend('Channel','Possible start samples','Most likely start sample')
end


startSample = initSampel;
end 