clear all;
clc;
load('filters.mat');

%% without extra noise
%load the input signals
traindir = 'matlab_examples/'; 
nFiles = 2;
s = [];
 
[y1,fs] = read_NIST_file('matlab_examples/SI1024.WAV');
size_1 = length(y1);
 
[y2,fs] = read_NIST_file('matlab_examples/SX223.WAV');
size_2 = length(y2);
s=zeros(2,max(size_1,size_2));
s(1,1:size_1) = y1;
s(2,1:size_2) = y2;
 
%  for i=1:nFiles
%     filename = sprintf('SA%d.WAV',i);
%     [y,fs] = read_NIST_file(strcat(traindir,filename));
%      %s(i,:) = y;
%      %s(1,:) = filter(Hd,y);
%      s(i,:)= y(round(fs/2):round(5*fs/2));
%  end
 
% hear the input signals
sound(s(1,:),fs);
sound(s(2,:),fs);
 
%plot the input signals
figure;
subplot(2,1,1); plot(s(1,:)),grid on, title('signal_1'), xlabel('t (msec)'); % plot s1
subplot(2,1,2); plot(s(2,:), 'r'),grid on, title('signal_2'), xlabel('t (msec)'); % plot s2
 
%create the mixing table and mix the signals
 A=[0.5 0.3; 0.8 0.9];  
 x=[];
for i=1:nFiles
   x=A*s;
end

%hear the mixed signals
sound(x(1,:),fs);
sound(x(2,:),fs);

% plot the mixed signals
figure;
plot(x(1,:),'r');
hold on
plot(x(2,:),'b');
hold off;

%implementation of the fastica algorithm
c=fastica([x(1,:);x(2,:)]); 

%hear the independent components of the fastica algorithm
sound(c(1,:),fs);
sound(c(2,:),fs);

%plot the independent components of the fastica algorithm
figure;
subplot(2,1,1); plot(c(1,:)), grid on,title('signal_1'), xlabel('t (msec)');
subplot(2,1,2); plot(c(2,:),'r'), grid on, title('signal_2'), xlabel('t (msec)');

wav1=c(1,:)
wav2=c(2,:)


audiowrite('fir.wav',wav1,fs);
wavwrite(wav1,fs,'audio.wav');
wavwrite(wav2,fs,'audio1.wav');

Reference https://www.physicsforums.com/threads/matlab-using-wavwrite-to-create-a-single-audio-file.189093/
%% adding extra noise awgn 

clear all;
clc;
load('filters.mat');

%load the input signals
traindir = 'matlab_paradeigmata/'; 
nFiles = 2;
s = [];
 
[y1,fs] = read_NIST_file('matlab_paradeigmata/SA1.WAV');
size_1 = length(y1);
 
[y2,fs] = read_NIST_file('matlab_paradeigmata/SA2.WAV');
size_2 = length(y2);
s=zeros(2,max(size_1,size_2));
z1 = awgn(y1,10,'measured');
z2 = awgn(y2,10,'measured');
%z1=y1+2*(rand(length(y1),1)-.5))
s(1,1:size_1) = z1;
s(2,1:size_2) = z2;

% hear the input signals
sound(s(1,:),fs);
sound(s(2,:),fs);

%plot the input signals
figure;
subplot(2,1,1); plot(s(1,:)),grid on, title('signal_1'), xlabel('t (msec)'); % plot s1
subplot(2,1,2); plot(s(2,:), 'r'),grid on, title('signal_2'), xlabel('t (msec)'); % plot s2
 
%create the mixing table and mix the signals
 A=[0.5 0.3; 0.8 0.9];  
 x=[];
for i=1:nFiles
   x=A*s;
end

%hear the mixed signals
sound(x(1,:),fs);
sound(x(2,:),fs);

% plot the mixed signals
figure;
plot(x(1,:),'r');
hold on
plot(x(2,:),'b');
hold off;

%implementation of the fastica algorithm
c=fastica([x(1,:);x(2,:)]); 

%hear the independent components of the fastica algorithm
sound(c(1,:),fs);
sound(c(2,:),fs);

%plot the independent components of the fastica algorithm
figure;
subplot(2,1,1); plot(c(1,:)), grid on,title('signal_1'), xlabel('t (msec)');
subplot(2,1,2); plot(c(2,:),'r'), grid on, title('signal_2'), xlabel('t (msec)');





