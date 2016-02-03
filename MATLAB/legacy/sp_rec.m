function melceps=mfcc(y,fs)

fs=12500;
nbits=16;
[y,fs,nbits]=wavread('s1.wav');
sound(y);
% Total xroniki diarkeia
time=length(y)/fs;
% Xroniki diarkeia 256 samples
% a tropos
time1=256/fs;
% b tropos
time2=(1:length(y))/fs;
time3=time2(256);

% plot signal
plot(y);

% Frame Blocking
N=256;                                                                % 256 samples each frame
M=100;                                                               % 100 samples overlap
nbFrames=ceil((length(y)-N)/M);                       %128 Frames
Frames=zeros(nbFrames+1, N);                         % arxikopoihsh tou pinaka Frames me midenika
for i=0:nbFrames-1
    temp=y(i*M +1 : i*M + N);
    Frames(i+1, 1:N) = temp;
end
% Last Frame
temp=zeros(1,N);                                                % arxikopoihsh 
LastLength=length(y)-nbFrames*M;
temp(1:LastLength)=y(nbFrames*M +1 : (nbFrames*M+1 + LastLength-1));
Frames(nbFrames+1, 1:N) = temp;

% Windowing
framesize=size(Frames);                                    % 129 x 256
nbFrames=framesize(1);                                    % 129
nbSamples=framesize(2);                                   % 256
% Hamming Window
W=hamming(nbSamples);                                  %256 hamming parameters-tis pername se kathe frame
windows=zeros(nbFrames,nbSamples);             % windows: 129 x 256
for i=1:nbFrames
    temp=Frames(i , 1:nbSamples);
    windows(i, 1:nbSamples)=W'.* temp ; 
end

% Fourier Transform
ffts = fft(windows');                                           % 256 x 129
powspecs=abs(ffts).^2;                                     % 256 x 129
n2=floor(N/2) +1;                                               %129
powspecs=powspecs(1:n2-1,:);                          % 128 x 129  Den tha eprepe na einai tetragwnikos?

% Mel Frequency Wrapping
p=20;                                                                  % number of filters
n=256;                                                                % length of fft =N

m=melfb(p, n, fs);
melpowspecs=m*powspecs';                            % 20 x 128  According to theory sould be 20 x 129(=n2)

figure
subplot(2,1,1);
plot(melpowspecs);
title('spectrum of the speech signal after mel frequency wrapping');

subplot(2,1,2);
plot(powspecs);
title( 'spectrum of the signal before mel frequency wrapping (after FFT)');

% DCT - MFCC
melceps=dct(log(melpowspecs));
melceps(1,:)=[];                                                  % 19 x 128 exclude 0th order cepstral coefficient
%plot the filters
plot(linspace(0, (12500/2), 129), melfb(20, 256, 12500)'),
title('Mel-spaced filterbank'), xlabel('Frequency (Hz)');











