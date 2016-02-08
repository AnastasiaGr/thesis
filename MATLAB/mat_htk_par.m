%% Speech separation and recognition from an HMM Trained on TIMIT copurs by HTK
% 
% University of Patras - Anastasia Grigoropoulou 2016

clear;
clc;
load('legacy/filters.mat');
addpath('FastICA');
% Set up directories
HOME = '../';
WORKDIR = strcat(HOME,'HTK_TIMIT_WRD/');
TIMIT = strcat(HOME, 'TIMIT/TIMIT/');

%% Loading files
%load the input signals
fid = fopen('coreTEST.SCP');
files = textscan(fid,'%s\n');
files = files{1};
fclose(fid);

% traindir = 'matlab_examples/'; 
nFiles = 2;
inputs = cell(2,1);
fs = 16000;
for i=1:nFiles
    [inputs{i}, Fs] = read_NIST_file(strcat(TIMIT,files{i}));
    assert(Fs==fs);
end

s = zeros(nFiles,max(cellfun('length',inputs)));

for i=1:nFiles
    s(i,1:size(inputs{i},2)) = zscore(inputs{i});
end
t = 1/fs:1/fs:size(s,2)/fs;
%plot the input signals
figure('color','white');
subplot(2,1,1); plot(t,s(1,:)),grid on, title('Signal 1'), xlabel('t (sec)'); % plot s1
subplot(2,1,2); plot(t,s(2,:), 'r'),grid on, title('Signal 2'), xlabel('t (sec)'); % plot s2

%% Mixing without extra noise

% create the mixing table and mix the signals
A=[0.5 0.3; 0.8 0.9];  
x=[];
for i=1:nFiles
   x=A*s;
end

% %hear the mixed signals
% sound(x(1,:),fs);
% sound(x(2,:),fs);

% plot the mixed signals
figure('color','white');
subplot(4,1,1); plot(t,s(1,:)),grid on, title('Signal 1'), xlabel('t (sec)'); % plot s1
subplot(4,1,2); plot(t,x(1,:)),grid on, title('Mixed Signal 1'), xlabel('t (sec)'); % plot x1
subplot(4,1,3); plot(t,s(2,:), 'r'),grid on, title('Signal 2'), xlabel('t (sec)'); % plot s2
subplot(4,1,4); plot(t,x(2,:), 'r'),grid on, title('Mixed Signal 2'), xlabel('t (sec)'); % plot x2

%implementation of the fastica algorithm
c=fastica([x(1,:);x(2,:)]); 

% %hear the independent components of the fastica algorithm
% sound(c(1,:),fs);
% sound(c(2,:),fs);

%plot the independent components of the fastica algorithm
figure('color','white');
subplot(4,1,1); plot(t,s(1,:)),grid on, title('Signal 1'), xlabel('t (sec)'); % plot s1
subplot(4,1,2); plot(t,c(1,:)),grid on, title('ICA Signal 1'), xlabel('t (sec)'); % plot x1
subplot(4,1,3); plot(t,s(2,:), 'r'),grid on, title('Signal 2'), xlabel('t (sec)'); % plot s2
subplot(4,1,4); plot(t,c(2,:), 'r'),grid on, title('ICA Signal 2'), xlabel('t (sec)'); % plot x2

for i=1:size(c,1)
    audiowrite(sprintf('Outputs/%d.wav',i),c(i,:),fs);
end

%% Mixing adding white gaussian noise with specified SNR.

SNR = [1,5,10];

for k=1:size(SNR,2)
    z(1,:) = awgn(s(1,:),SNR(k),'measured');
    z(2,:) = awgn(s(2,:),SNR(k),'measured');

    % % hear the input signals
    % sound(z1,fs);
    % sound(z2,fs);

    %plot the input signals
    figure('color','white');
    subplot(4,1,1); plot(t(fs:2*fs),s(1,fs:2*fs)),grid on, title('Signal 1'), xlabel('t (sec)'); % plot s1
    subplot(4,1,2); plot(t(fs:2*fs),z(1,fs:2*fs)),grid on, title(sprintf('Noisy Signal 1 - SNR: %d ',k)), xlabel('t (sec)'); % plot x1
    subplot(4,1,3); plot(t(fs:2*fs),s(2,fs:2*fs)),grid on, title('Signal 2'), xlabel('t (sec)'); % plot s2
    subplot(4,1,4); plot(t(fs:2*fs),z(2,fs:2*fs)),grid on, title(sprintf('Noisy Signal 1 - SNR: %d ',k)), xlabel('t (sec)'); % plot x2

    %create the mixing table and mix the signals
     A=[0.5 0.3; 0.8 0.9];  
     x=[];
    for i=1:nFiles
       x=A*z;
    end

    %implementation of the fastica algorithm
    c=fastica([x(1,:);x(2,:)]); 

    % %hear the independent components of the fastica algorithm
    % sound(c(1,:),fs);
    % sound(c(2,:),fs);

    %plot the independent components of the fastica algorithm
    figure('color','white');
    subplot(4,1,1); plot(t,s(1,:)),grid on, title('Signal 1'), xlabel('t (sec)'); % plot s1
    subplot(4,1,2); plot(t,c(1,:)),grid on, title(sprintf('ICA Signal 1 - SNR: %d ',k)), xlabel('t (sec)'); % plot x1
    subplot(4,1,3); plot(t,s(2,:), 'r'),grid on, title('Signal 2'), xlabel('t (sec)'); % plot s2
    subplot(4,1,4); plot(t,c(2,:), 'r'),grid on, title(sprintf('ICA Signal 1 - SNR: %d ',k)), xlabel('t (sec)'); % plot x2

    for i=1:size(c,1)
        audiowrite(sprintf('Outputs/%d_SNR_%d.wav',i,SNR(k)),c(i,:),fs);
    end

end
