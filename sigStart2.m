function startSample = sigStart2(rec, trueLength, varargin)
% SIGSTART2 The function receives a recoring of a signal and returns an estimated
% start sample of where the signal starts. Requires at least two variables,
% the signal recoring "rec" and the length of the message 'trueLength'. Two
% additional variables can be supplied, 'plot' which will result in the
% function showing a plot of estimated samples. The other variable is a
% float between 0 and 1 to specify the normalized cutoff amplitude for the 
% signal. If no value is passed, then this value is set to 0.7. 
    cutOffAmpl = 0.7;

    if isArgNum(varargin)
        cutOffAmpl = isArgNum(varargin);
    end
    recN = abs(rec./(max(abs(rec)))); % Normalize vector
    recN(recN <= cutOffAmpl) = 0; % Zero out everything bellow threshold
 
    sampleLarg = find(recN > 0);
    sampleStart = sampleLarg(1);
    sampleStop = sampleLarg(end);
    sampleMiddle = sampleStart + (sampleStop - sampleStart)/2;
    
    startSample = sampleMiddle - trueLength/2;
    
    if isArgPlot(varargin)
        figure 
        hold on 
        plot(rec,'k');title('Signal Analysis of when Signal is Initiated')
        plot([startSample*0.5 sampleStop*1.5],[cutOffAmpl*max(abs(rec)) cutOffAmpl*max(abs(rec))],'--m')
        xlabel('samples');ylabel('Normalized Value');
        stem([sampleStart sampleStop], [1 1], 'g');
        stem(sampleMiddle, 1, 'r');
        stem(startSample, 1, 'b');
        legend('Signal','Real Cutoff Amplitude', 'Start & Stop Samples', 'Middle Sample', 'Estimated Start Sample');
        hold off
        axis([startSample*0.5 sampleStop*1.5 -1 1] )
    end
end

%% Suppport Functions 
function bool = isArgPlot(varCell)
    bool = 0;
    if ~isempty(varCell)
        for k = 1:length(varCell)
            if strcmp(varCell{k},'plot') 
                bool = 1;
            end
        end
    end
end

function value = isArgNum(varCell)
    value = 0;
    if ~isempty(varCell)
        for k = 1:length(varCell)
            if isfloat(varCell{k}) && (varCell{k} > 0) && (varCell{k} < 1)
                value = varCell{k};
            end 
        end
    end
end
