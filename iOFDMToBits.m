function [b, H_est, estKnownBits] = iOFDMToBits(y, knownBits, cycP, N, se)
E = 1;
synchError = se;
% Generate known s(k)
    SknownVector = zeros(1, N);
    
    % Handel to generate QPSK
    b = @(re,im) sqrt(E/2)*(re + 1i*im);

    % Encode Seq into QPSK
    for h = 1:N
        SknownVector(h) = b(knownBits(2*h - 1), knownBits(2*h));
    end

    % OFDM^1
    % FFT the last 128 of the signal


    known_r = fft( y((cycP + 1 + synchError):128 + cycP + synchError) );
    r = fft( y((2*cycP + 128 + 1 + synchError):cycP + 128 + 128 + cycP + synchError) );


    % Estimate filter
    s = SknownVector.';
    H_est = known_r./s;
   
    
    % Estimation of channel
    conjH = conj(H_est);
    
    estKnown = conjH.*known_r;
    r_estKnown = sign(real(estKnown));
    i_estKnown = sign(imag(estKnown));
    
    estKnownBits = [];
    
    for i = 1:128
        estKnownBits = [estKnownBits, r_estKnown(i), i_estKnown(i)];
    end
    
    
    
    % Estimation of S for known and unknown signal
    estS = conjH .* r;
    r_estS = sign(real(estS));
    i_estS = sign(imag(estS));

    % Decode QPSK to bits
    b = [];
    for k = 1:128
        b = [b, r_estS(k), i_estS(k)];
    end
end