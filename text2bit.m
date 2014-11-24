function bitStream = text2bit(message)
% Takes a message as a string and decodes it into an ansi bit sequence 
% array. This array is padded with an additional zero as to keep the
% number of bits a multiple of 2. The returned bit sequence array is as 
% according to the sequence of letters, 
% i.e. 'abc' ---> [0|a_bits 0|b_bits 0|c_bits]. 
    bitStreamNoPad = dec2bin(message);
    rows = size(bitStreamNoPad,1);
    bitStreamPad = cell(rows,1);

    
    for n = 1:rows
        bitStreamPad{n} = [dec2bin(0) bitStreamNoPad(n,:)];
    end
    
    bitStreamMat = cell2mat(bitStreamPad);
    [rows, cols] = size(bitStreamMat);
    
    bitStream = ones(1, rows*cols);
    
    
    for k = 1:rows*cols
       a = rem(k,8);
       if a == 0;
           a = 8;
       end;
        
       bitStream(k) = bitStreamMat(1 + idivide(int32(k-1),int32(8),'floor'), a);
       if bitStream(k) == 48
           bitStream(k) = 0;
       else
           bitStream(k) = 1;
       end
    end

end
