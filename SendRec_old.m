function [b, numOfErrors, H_est, trueChannel, r, estS, Svector1] = testSendRec(sigma, amp, sentBits1, sentBits2, knownBits, n, cycP, channel, known_channel, synchError)

    N = n;
    E = amp;

    % Allocate memory
    Svector1 = zeros(1, N);
    Svector2 = zeros(1, N);
    SknownVector = zeros(1, N);

    % Handel to generate QPSK
    b = @(re,im) sqrt(E/2)*(re + 1i*im);

    % Encode Seq into QPSK
    for h = 1:N
        Svector1(h) = b(sentBits1(2*h - 1), sentBits1(2*h));
        Svector2(h) = b(sentBits2(2*h - 1), sentBits2(2*h));
        SknownVector(h) = b(knownBits(2*h - 1), knownBits(2*h));
    end

    % OFDM - Generate z(n) and known
    z1 = ifft(Svector1);
    z2 = ifft(Svector1);
    knownZ = ifft(SknownVector);

    % Add cyclic_prefix to signal and known signal
    cyclic_prefix1 = z1(end - cycP + 1:end);
    cyclic_prefix2 = z2(end - cycP + 1:end);
    cyclic_prefixk = knownZ(end - cycP + 1:end);
    zz = [cyclic_prefixk knownZ cyclic_prefix1 z1 cyclic_prefix2 z2].';

    % Channel select
    h1 = zeros(1,60);
    for n = 0:59
        h1(n+1) = 0.8^(n);
    end

    h2 = zeros(1,9);
    h2(1) = 0.5;
    h2(9) = 0.5;

    if strcmp(channel, 'h1')
       h = h1';
    elseif strcmp(channel, 'h2')
       h = h2';
    end

    % Generate noise

    % Length of conv signal
    y_len = length(zz) + length(h) - 1;

    % Noise for known and unknown signal
    w = 1/sqrt(2)*sigma*(randn(y_len, 1) + 1i*randn(y_len, 1));

    % Filter through channel when sending
    y = conv(h, zz) + w;

    % OFDM^1
    % FFT the last 128 of the signal
    

        known_r = fft( y((cycP + 1 + synchError):128 + cycP + synchError) );
        r = fft( y((2*cycP + 128 + 1 + synchError):cycP + 128 + 128 + cycP + synchError) );


    % Estimate filter
    s = SknownVector.';
    H_est = known_r./s;

    % FFT filter and inverse
    H = fft(h,128);
    trueChannel = H;

    % Is the channel know to us?
    %   If not: use estimation of channel for decoding
    if known_channel == 1
        % Real channel
        conjH = conj(trueChannel);
    else
        % Estimation of channel
        conjH = conj(H_est);
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

    % Diff between true and recieved bits
    bb = b - sentBits1;

    % Number of errors after decoding
    numOfErrors = sum(bb(:) ~= 0);
end