function melceps=mfcc(y,fs,N,M,verbose)


% Frame Blocking
%N=256 samples each frame
%M= samples overlap
nbFrames=ceil((length(y)-N)/M);                      %%128 Frames
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
nbFrames= nbFrames+1;                         % 129
nbSamples= N;                                   % 256
% Hamming Window
W=hamming(nbSamples);                                  %256 hamming parameters-tis pername se kathe frame
windows=zeros(nbFrames,nbSamples);             % windows: 129 x 256
for i=1:nbFrames
    temp=Frames(i , 1:nbSamples);
    windows(i, 1:nbSamples)=W'.* temp ; 
end

% Check the effect of hamming windows
if verbose
    figure 
    hold on
    plot(W,'b')                         % hamming window
    plot(windows(50,:),'g')      % the 50th Frame after hamming windowing (stis akres meiwnetai to platos)
    plot(Frames(50,:),'r')         % the 50th Frame before hamming windowing
end

% Fourier Transform
NFFT = 2^nextpow2(nbSamples);
ffts = fft(windows',NFFT)/nbSamples;                        % FFT on arrays works per column.                     
f = fs/2*linspace(0,1,NFFT/2+1);                            % map [0,256] -> [0,fs/2]
powspecs=abs(ffts).^2;                                                                                  
powspecs=powspecs(1:floor(NFFT/2)+1,:)';                       % 129 (frames) x 129 (samples) Because fft is symmetrical arounf fs/2

% Mel Frequency Wrapping
K = 20;                                                     % number of mfcc's
n = NFFT;                                                   % length of fft =N

m = melfb(K, n, fs);                                        % 20 (filter) x 129 (values)
%plot the filters
if verbose
    figure
    plot(linspace(0, (fs/2), floor(n/2)+1), m'),
    title('Mel-spaced filterbank'), xlabel('Frequency (Hz)');
end

for i=1:nbFrames  %For each frame
    melpowspecs(i,:) = m * powspecs(i,:)'; 
end

if verbose
    figure
    subplot(2,1,1);
    plot(f,powspecs);
    title( 'spectrum of the signal before mel frequency wrapping (after FFT)');


    subplot(2,1,2);
    plot(fs/2*linspace(0,1,20),melpowspecs);      % grammika mexri ta 1000Hz
    title('spectrum of the speech signal after mel frequency wrapping');
end

% DCT - MFCC
melceps=dct(log(melpowspecs));
melceps(1,:)=[];                                                 

if verbose
    figure
    plot(melceps);
    title('MFCC back in time');
end
