function message = bit2text(bitStream)
    % Takes a bit sequence array with 0 padded ansi encoding and returns a
    % character string. 
    bitStreamMatrix = zeros(length(bitStream)/8, 8);
    
    for k = 1:length(bitStream) %Bitstream is a 1x(mxn) matrix
       myCol = rem(k,8); % myCol will go from 1 to 8
       if myCol == 0;
           myCol = 8;
       end;
       myRow = 1 + idivide(int32(k-1),int32(8),'floor'); % myRow will go ++1 for each multiple of 8
       bitStreamMatrix(myRow, myCol) = bitStream(k);
    end
    
    noPad = bitStreamMatrix(:,2:end); % Remove 0 padding 
    
    charCell = cell(size(noPad,1),1); % Cell for conversion of numbers to characters
    for rows = 1:size(noPad,1)
        for cols = 1:size(noPad,2)
        charCell{rows} = [charCell{rows} num2str(noPad(rows,cols))]; % bitstring generation
        end
    end

    bits = cell2mat(charCell); % A matrix consiting of bitstrings
    charNums = bin2dec(bits); % Get character encoding 
    message = char(charNums)'; % Return Message
    
    
end