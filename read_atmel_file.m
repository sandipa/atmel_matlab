function [ outvals ] = read_atmel_file( filename, format )
%UNTITLED2 read a hex atmel studio output file
outvals = [];
if nargin == 1
    format = 1;
end
%format = 1 for 8 bit signed ints
%format = 2 for 16 bit signed ints
%format = 3 for 16-bit complex ints
%format = 4 for 32-bit signed ints
%format = 5 for 32-bit complex ints
%format = 6 for 32-bit floats
switch format
    case 1
        bytesperint = 1;
        complexints = 0;
    case 2
        bytesperint = 2;
        complexints = 0;
    case 3
        bytesperint = 2;
        complexints = 1;
    case 4
        bytesperint = 4;
        complexints = 0;
    case 5
        bytesperint = 4;
        complexints = 1;
    case 6
         bytesperint = 4;
        complexints = 0;
    otherwise
        bytesperint = 1;
        complexints = 0;
end

fd = fopen(filename);
if (fd == -1)
    error('', 'Could not open file');
    return;
end
%dump the first line
line  = fgetl(fd);

while(1)
    line  = fgetl(fd);
    if ~isstr(line), break;end
    dline = line(10:length(line)-2);
    hexvec = reshape(dline,bytesperint*2,length(dline)./(bytesperint*2));
    %swap bytes
    if (bytesperint == 2)
        hexvec = [hexvec(3:4,:); hexvec(1:2,:)];
    end
    if (bytesperint == 4)
        hexvec = [hexvec(7:8,:); hexvec(5:6,:); hexvec(3:4,:); hexvec(1:2,:)];
    end
    dat = hex2dec(hexvec.');
    
    outvals = [outvals;dat];
end
if format == 6
    outvals = typecast(uint32(outvals), 'single');
else
    maxint = 2^(bytesperint*8-1)-1;
    index = find(outvals > maxint);
    outvals(index) = outvals(index)-2^(bytesperint*8);
    if (complexints) %if complex
        outvals  = outvals(1:2:end) + outvals(2:2:end).*sqrt(-1);
    end
end