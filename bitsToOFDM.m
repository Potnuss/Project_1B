function [zz] = bitsToOFDM(knownBits, sentBits1, N, cycP)

    E = 1;

    % Allocate memory
    Svector1 = zeros(1, N);
%    Svector2 = zeros(1, N);
    SknownVector = zeros(1, N);

    % Handel to generate QPSK
    b = @(re,im) sqrt(E/2)*(re + 1i*im);

    % Encode Seq into QPSK
    for h = 1:N
        Svector1(h) = b(sentBits1(2*h - 1), sentBits1(2*h));
%        Svector2(h) = b(sentBits2(2*h - 1), sentBits2(2*h));
        SknownVector(h) = b(knownBits(2*h - 1), knownBits(2*h));
    end

    % OFDM - Generate z(n) and known
    z1 = ifft(Svector1);
%    z2 = ifft(Svector1);
    knownZ = ifft(SknownVector);

    % Add cyclic_prefix to signal and known signal
    cyclic_prefix1 = z1(end - cycP + 1:end);
%    cyclic_prefix2 = z2(end - cycP + 1:end);
    cyclic_prefixk = knownZ(end - cycP + 1:end);
%    zz = [cyclic_prefixk knownZ cyclic_prefix1 z1 cyclic_prefix2 z2].';
    zz = [cyclic_prefixk knownZ cyclic_prefix1 z1].';
    
end