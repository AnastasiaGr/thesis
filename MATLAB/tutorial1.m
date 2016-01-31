%% Anastasia AM modulation
clear all;
clc;
% Generate an input signal
si=random('Normal',rand()*8+2, 1.5,[2000 1]);
si2=random('beta',rand()*8+2, 1.5,[2000 1]);

figure
hold on 
plot(si,'r')
plot(si2*mean(si))

% Obtain signal parameters
    % mean
        m1= mean(si);
        m2= mean(si2);
        v1=var(si);
        v2=var(si2);
        
  %fourier analysis
       si_f=fft(si)
       
       Fs = 5000;                    % Sampling frequency
       L = 2000;                     % Length of signal
       NFFT = 2^nextpow2(L);   % Next power of 2 from length of y
       Y = fft(si,NFFT)/L;
       f = Fs/2*linspace(0,1,NFFT/2+1);
       
       % Plot single-sided amplitude spectrum.
       figure 
       
        plot(f,2*abs(Y(1:NFFT/2+1)) )
        axis([0 200 0 2])
        xlabel('Frequency (Hz)')
        ylabel('|Y(f)|')
