function zu = upsample(z, R)
% zu is the upsampled vector

zu = zeros(N*R,1);
zu(1:R:end) = z;

end