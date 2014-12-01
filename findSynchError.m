function [bitErrorpilotBits,bitErrormessageBits] = findSynchError(start, stop, y, pilotBits, cheatknownmessageBits, lengthCycP, N, E)
%ONLY USE BITS -1 and 1 as parameters
iterator = start:stop;
bitErrorpilotBits = zeros(size(start:stop));
bitErrormessageBits = zeros(size(start:stop));
    pilotBits01 = (pilotBits+1)/2; %Converts to 0,1 from -1,1
    cheatknownmessageBits01 = (cheatknownmessageBits+1)/2; %Converts to 0,1 from -1,1
    
for i = iterator
    
    synchError = i;
    [estmessageBits, H_est, estpilotBits] = iOFDMToBits(y, pilotBits, lengthCycP, N, synchError, E);
    
    estpilotBits01 = (estpilotBits + 1)./2; %Converts to 0,1 from -1,1
    estmessageBits01 = (estmessageBits + 1)./2; %Converts to 0,1 from -1,1
    
    bitErrorpilotBits(i-start+1) = sum(abs(estpilotBits01 - pilotBits01));
    bitErrormessageBits(i-start+1) = sum(abs(estmessageBits01 - cheatknownmessageBits01));
end


end