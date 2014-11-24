function zi = interpolate(zu, R)
B = firpm(32,2*[0 0.5/R*0.9 0.5/R*1.6 1/2],[1 1 0 0]);
zi = conv(zu,B);
end