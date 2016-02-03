    
file='train-friends\s3.wav';
%fs=44100;
[s, fs] = audioread(file,[1 fs*5]);
sound(s,fs);