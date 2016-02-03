function [data,sampRate,header] = read_NIST_file(filename,endianness)
% [data,sampRate,header] = read_NIST_file(filename)
% - reads a NIST audio file
% - returns the samples in a 1 x D matrix
if nargin < 2  
    endianness = 'l';
end

file = fopen(filename,'r',endianness);
header = fread(file,1024,'char');
fseek(file,0,'bof');

line = fgetl(file);
if ~strcmp(line(1:4),'NIST')
    fprintf('read_NIST_file: not a valid nist file, "%s"\n',filename);
    data = [];
    sampRate = [];
    return
end
line = fgetl(file);
while ~strncmp(line,'end_head',8)
    if strncmp(line,'sample_count',12)
        [a, b, nSamples] = strread(line,'%s %s %f');
    elseif strncmp(line,'sample_rate',11)
        [a, b, sampRate] = strread(line,'%s %s %f');
    end
    line = fgetl(file);
end
fseek(file,1024,'bof');
data = fread(file,[1,nSamples],'int16');
fclose(file);