% v1 = mfcc(y1,fs,256,100,0);
% d=v1;   %128 (nbFrames) x 20(Filters-MFCC)
% k=16;

function r = vqlbg(d,k)
% VQLBG Vector quantization using the Linde-Buzo-Gray algorithm
%
% Inputs:
%       d contains training data vectors (one per column)
%       k is number of centroids required
%
% Outputs:
%       c contains the result VQ codebook (k columns, one for each centroids)

e = .0003;
r = mean(d, 2);    %128(nbFrames) x 1
dpr = 10000;
for i = 1:log2(k)
    r = [r*(1+e), r*(1-e)];
    
    while(1 == 1)
        z = disteu(d, r);         % 20 (MFCC each frame) x 16 (k)
        [m,ind] = min(z, [], 2);    % ind = 20 x 1 
        t = 0;
        for j = 1:2^i
            r(:, j) = mean(d(:, find(ind == j)), 2);
            x = disteu(d(:, find(ind == j)), r(:, j));
            for q = 1:length(x)
                t = t + x(q);
            end
        end
        if (((dpr - t)/t) < e)
            break ;
        else
            dpr = t;
        end
    end
end

% r = nbFrames(128) x k (16)