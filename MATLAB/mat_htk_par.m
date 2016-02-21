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
files = textscan(fid,'%s');
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
    s(i,1:size(inputs{i},2)) = inputs{i}/max(abs(inputs{i}));
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

for i=1:nFiles
    c(i,:) = c(i,:)/max(abs(c(i,:)));
end
% %hear the independent components of the fastica algorithm
% sound(c(1,:),fs);
% sound(c(2,:),fs);

if sum(abs(s(1,:))-abs(c(2,:))) < sum(abs(s(1,:))-abs(c(1,:)))
    temp = c(1,:);
    c(1,:) = c(2,:);
    c(2,:) = temp;
end

%plot the independent components of the fastica algorithm
figure('color','white');
subplot(4,1,1); plot(t,s(1,:)),grid on, title('Signal 1'), xlabel('t (sec)'); % plot s1
subplot(4,1,2); plot(t,c(1,:)),grid on, title('ICA Signal 1'), xlabel('t (sec)'); % plot x1
subplot(4,1,3); plot(t,s(2,:), 'r'),grid on, title('Signal 2'), xlabel('t (sec)'); % plot s2
subplot(4,1,4); plot(t,c(2,:), 'r'),grid on, title('ICA Signal 2'), xlabel('t (sec)'); % plot x2

for i=1:nFiles
    audiowrite(sprintf('Outputs/%s.wav',files{i}(16:end-4)),c(i,:),fs);
end

%% Mixing adding white gaussian noise with specified SNR.

SNR = [0, 5, 10, 15, 20, 30, 40];

copyfile(strcat(WORKDIR,'coreTESTMono.mlf'),'Outputs/MATLABMono.mlf');
copyfile(strcat(WORKDIR,'coreTESTWord.mlf'),'Outputs/MATLABWord.mlf');

for k=1:size(SNR,2)
    system(sprintf('sed "s/\\.lab/_SNR_%d\\.lab/" < ../HTK_TIMIT_WRD/coreTESTMono.mlf >> Outputs/MATLABMono.mlf',SNR(k)));
    system(sprintf('sed "s/\\.lab/_SNR_%d\\.lab/" < ../HTK_TIMIT_WRD/coreTESTWord.mlf >> Outputs/MATLABWord.mlf',SNR(k)));
end

SIR = zeros(nFiles,size(SNR,2));
SNRout = zeros(nFiles,size(SNR,2));
for k=1:size(SNR,2)
    z(1,:) = awgn(s(1,:),SNR(k),'measured');
    z(2,:) = awgn(s(2,:),SNR(k),'measured');
    
    % % hear the input signals
    % sound(z1,fs);
    % sound(z2,fs);

    %plot the input signals
    figure('color','white');
    subplot(4,1,1); plot(t(fs:2*fs),s(1,fs:2*fs)),grid on, title('Signal 1'), xlabel('t (sec)'); % plot s1
    subplot(4,1,2); plot(t(fs:2*fs),z(1,fs:2*fs)),grid on, title(sprintf('Noisy Signal 1 - SNR: %d ',SNR(k))), xlabel('t (sec)'); % plot x1
    subplot(4,1,3); plot(t(fs:2*fs),s(2,fs:2*fs)),grid on, title('Signal 2'), xlabel('t (sec)'); % plot s2
    subplot(4,1,4); plot(t(fs:2*fs),z(2,fs:2*fs)),grid on, title(sprintf('Noisy Signal 2 - SNR: %d ',SNR(k))), xlabel('t (sec)'); % plot x2

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

    if sum(abs(z(1,:))-abs(c(2,:))) < sum(abs(z(1,:))-abs(c(1,:)))
        temp = c(1,:);
        c(1,:) = c(2,:);
        c(2,:) = temp;
    end
    
    for i=1:nFiles
        c(i,:) = c(i,:)/max(abs(c(i,:)));
   end   
    
    for i=1:nFiles
    % Calculate the power in the transmitted signal, 'SignalPower'
           SignalPower = norm(s(i,:))^2/length(s(i,:));
    % Estimate the noise power based on the signal-to-noise ratio
           NoisePower = SignalPower/db2pow(SNR(k));
    % Calculate the total power in the received signal    
           TotalPower = norm(c(i,:))^2/length(c(i,:));
    % Calculate the interference power
           InterferePower = TotalPower - NoisePower - SignalPower;
    % Calculate the Carrier-To-Interference Ratio in dB
           CIR =  pow2db(abs(SignalPower/InterferePower));
           
           SIR(i,k) = CIR;
           SNRout(i,k) = pow2db(TotalPower/NoisePower);
           
    end
    
   %for i=1:nFiles
   %     c(i,:) = c(i,:)/max(abs(c(i,:)));
   %end

    %plot the independent components of the fastica algorithm
    figure('color','white');
    subplot(4,1,1); plot(t,s(1,:)),grid on, title('Signal 1'), xlabel('t (sec)'); % plot s1
    subplot(4,1,2); plot(t,c(1,:)),grid on, title(sprintf('ICA Signal 1 - SNR: %d ',SNR(k))), xlabel('t (sec)'); % plot x1
    subplot(4,1,3); plot(t,s(2,:), 'r'),grid on, title('Signal 2'), xlabel('t (sec)'); % plot s2
    subplot(4,1,4); plot(t,c(2,:), 'r'),grid on, title(sprintf('ICA Signal 2 - SNR: %d ',SNR(k))), xlabel('t (sec)'); % plot x2

    for i=1:size(c,1)
       audiowrite(sprintf('Outputs/%s_SNR_%d.wav',files{i}(16:end-4),SNR(k)),c(i,:),fs);
    end

end

figure 
hold on
for i=1:nFiles
    plot(SNR,SIR(i,:)),xlabel('SNR (db)'),ylabel('SIR (db)'); grid on;
    hold on
end


%% Recognize the un-mixed signals with the best HTK recognizer
[~,buffer] = system('source ~/.bashrc ; source eval_matlab.sh');

