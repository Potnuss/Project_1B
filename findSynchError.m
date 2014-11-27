function bitErrorRate = findSynchError(start, stop, y, estimationBits, lengthCycP, N)

iterator = start:stop;
errors = zeros(size(start:stop));

for i = iterator
    
    synchError = i;
    [b, H_est, estKnown] = iOFDMToBits(y, estimationBits, lengthCycP, N, synchError);
    
    bb = (estKnown + 1)./2;
    
    estimationBits = (estimationBits+1)/2;
    
    errors(i-start+1) = sum(abs(bb - estimationBits));

end

bitErrorRate = errors;

end