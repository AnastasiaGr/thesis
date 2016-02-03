%% Anastasia Grigoropoulou
% Speaker Recognition with MFC coefficients
% clear all;
% clc;

% Loading Files 
[y1,fs]=audioread('s1.wav');

[y2,fs]=audioread('s2.wav');
%sound(y2);

% mfcc(signal,sampling frequence,window size, overlap, verbose)
v1 = mfcc(y1,fs,256,100,0);

v2 = mfcc(y2,fs,256,100,0);

% 
% [coeff,score,latent,tsquared,explained,mu] = pca(v1');
% 
% v1coeff = coeff;
% [coeff,score,latent,tsquared,explained,mu] = pca(v2');
% 
% v2coeff = coeff;


figure
hold on
scatter(v1(:,1),v1(:,2),'g');
scatter(v2(:,1),v2(:,2),'r');
xlabel('1st dimension'); ylabel('2nd dimension');
title('MFCCS n1,n2 for all frames')

r1 = vqlbg(v1,16);
r2 = vqlbg(v2,16);

figure
hold on
scatter(r1(:,1),r1(:,2),'g');
scatter(r2(:,1),r2(:,2),'r');
xlabel('1st dimension'); ylabel('2nd dimension');
title('Cendroids n1,n2 for all frames');

n=8;
code = train('C:\Users\Anastasia\Documents\MATLAB\train\', n)

test('C:\Users\Anastasia\Documents\MATLAB\train\', n, code)




