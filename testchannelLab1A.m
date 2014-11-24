function [y, H] = testchannelLab1A(z)

    sigma = 0;

    % Channel select
    h = zeros(1,60);
    for n = 0:59
        h(n+1) = 0.8^(n);
    end

    % Generate noise
    % Length of conv signal
    y_len = length(z) + length(h) - 1;

    % Noise for known and unknown signal
    w = 1/sqrt(2)*sigma*(randn(y_len, 1) + 1i*randn(y_len, 1));

    % Filter through channel when sending
    y = conv(h, z) + w;

    % FFT filter and inverse
    H = fft(h,128);

end