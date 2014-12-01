function [estmessageBits, H_est, estpilotBits] = iOFDMToBits(y, pilotBits, cycP, N, synchError, E)
%ONLY USE BITS -1 and 1 as parameters
%E = 1; added as parameter

% Generate known s(k)
    SknownpilotVector = zeros(1, N);
    
    % Handel to generate QPSK
    b = @(re,im) sqrt(E/2)*(re + 1i*im);

    % Encode Seq into QPSK
    for h = 1:N
        SknownpilotVector(h) = b(pilotBits(2*h - 1), pilotBits(2*h));
    end

    % OFDM^1
    % FFT the last 128 of the signal


    pilot_r = fft( y((cycP + 1 + synchError):128 + cycP + synchError) );
    r = fft( y((2*cycP + 128 + 1 + synchError):cycP + 128 + 128 + cycP + synchError) );


    % Estimate filter/channel with the SknownpilotVector
    s = SknownpilotVector.';
    H_est = pilot_r./s;
   
    %Create the conjugate of the estimated Filter
    conjH = conj(H_est);
    
    % Use the conjugate of the estimated Filter to get the estpilotBits
    estKnown = conjH.*pilot_r;
    r_estKnown = sign(real(estKnown));
    i_estKnown = sign(imag(estKnown));
    estpilotBits = [];
    for i = 1:128
        estpilotBits = [estpilotBits, r_estKnown(i), i_estKnown(i)];
    end
   
    
    
    % Use the conjugate of the estimated Filter to get the estmessageBits
    estS = conjH .* r;
    r_estS = sign(real(estS));
    i_estS = sign(imag(estS));
    estmessageBits = [];
    for k = 1:128
        estmessageBits = [estmessageBits, r_estS(k), i_estS(k)];
    end
    
end