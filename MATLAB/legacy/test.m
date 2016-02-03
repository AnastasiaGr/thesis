

%function test(testdir, n, code)
% Speaker Recognition: Testing Stage
%
% Input:
%       testdir : string name of directory contains all test sound files
%       n       : number of test files in testdir
%       code    : codebooks of all trained speakers
%
% Note:
%       Sound files in testdir is supposed to be: 
%               s1.wav, s2.wav, ..., sn.wav
%
% Example:
%       >> test('C:\data\test\', 8, code);

testdir = 'C:\Users\Anastasia\Documents\MATLAB\train\';
n = 8;
code = train('C:\Users\Anastasia\Documents\MATLAB\train\', n);

for k = 1:n                     % read test sound file of each speaker
    file = sprintf('%ss%d.wav', testdir, k);
    [s, fs] = audioread(file);      
        
    v = mfcc(s, fs,256,100,0);            % Compute MFCC's
   
    distmin = inf;
    k1 = 0;
   
    for l = 1:length(code)      % each trained codebook, compute distortion
        d = disteu(v, code{l});  % 128(frames) x 20(mfcc)  VS 128(frames) x 16(cendroids) (for l=1) . kathe mfcc poso apexei apo kathe cendroid gia ola ta fames
        dist = sum(min(d,[],2)) / size(d,1);  % vres to min tis apostasis se kathe row kai athroise ta. nbFrames rows(128)
      
        if dist < distmin
            distmin = dist;
            k1 = l;               % apo 1 ews 8
        end      
    end
   
    msg = sprintf('Speaker %d matches with speaker %d', k, k1);
    disp(msg);
end