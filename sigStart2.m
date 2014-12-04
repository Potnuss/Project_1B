function startSample = sigStart2(rec, trueLength, cycPr ,varargin)
% SIGSTART2 The function receives a recoring of a signal and returns an estimated
% start sample of where the signal starts. Requires at least two variables,
% the signal recoring "rec" and the length of the message 'trueLength'. Two
% additional variables can be supplied, 'plot' which will result in the
% function showing a plot of estimated samples. The other variable is a
% float between 0 and 1 to specify the normalized cutoff amplitude for the 
% signal. If no value is passed, then this value is set to 0.7. 
    cutOffAmpl = 0.75;

    if isArgNum(varargin)
        cutOffAmpl = isArgNum(varargin);
    end
    recN = abs(rec./(max(abs(rec)))); % Normalize vector
    recN(recN <= cutOffAmpl) = 0; % Zero out everything bellow threshold
 
    sampleLarg = find(recN > 0);
    sampleStart = sampleLarg(1);
    sampleStop = sampleLarg(end);
    sampleMiddle = sampleStart + (sampleStop - sampleStart)/2;
    
    if cycPr == 80
        startSample = sampleMiddle - trueLength/2 - 170;  %(CycPreLength - ChannelLength) / 2 --> jumpback; if ChannlLength > Cycprefix --> 0 jumpback
    else
        startSample = sampleMiddle - trueLength/2; 
    end
    if isArgPlot(varargin)
        figure 
        hold on 
        plot(rec,'k');title('Signal Analysis of when Signal is Initiated','FontSize',14,'FontWeight','bold')
        plot([startSample*0.5 sampleStop*1.5],[cutOffAmpl*max(abs(rec)) cutOffAmpl*max(abs(rec))],'--m')
        plot([startSample*0.5 sampleStop*1.5],[-cutOffAmpl*max(abs(rec)) -cutOffAmpl*max(abs(rec))],'--m')
        xlabel('Samples','FontSize',12,'FontWeight','bold');ylabel('Recorded Signal Value','FontSize',12,'FontWeight','bold');
        plot([sampleStart sampleStart], [1 -1], '--g');
        plot([sampleStop sampleStop],[1 -1 ],'--g');
        plot([sampleMiddle sampleMiddle], [1 -1], '--r');
        plot([startSample startSample], [1 -1], '--b');
        legend('Signal','Real Upper Cutoff Amplitude','Real Lower Cutoff Amplitude', 'Start Sample','Stop Sample', 'Middle Sample', 'Estimated Start Sample');
        hold off
        axis([startSample*0.5 sampleStop*1.5 -.05 .05] )
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
