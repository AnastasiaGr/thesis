%peirama pou apetyxe, 2 fwnes(vour kai egw), 2 mikrofwna
%to ena M exei fs=44Khz kai to allo fs=8Khz

clear all;
clc;

traindir = 'train-friends/'; 

% Load first file and downsample to 8Khz
 
filename = sprintf('s%d.wav',8);
[y1,fs1] = audioread(strcat(traindir,filename));
y1 = y1(1:24*44100);  %keep 24 first seconds

filename = sprintf('s%d.wav',9);
[y2,fs2] = audioread(strcat(traindir,filename));
y2 = y2(1:24*8000);   %keep 24 first seconds
aud1 = audioplayer(y1,fs1);
aud2 = audioplayer(y2,fs2);

save('anast_vour_data');

load('anast_vour_data');
load('filters.mat');
%downsample first file
Fs = min([fs1 fs2]);
%y3 = decimate(y1,6,10);
y4 = resample(y1,8000,44100);


s = [y2 , y4];
s=s';

 % akoume tis 2 hxografiseis
 sound(s(1,:),Fs);
 sound(s(2,:),Fs);
 
 %παρουσιάζουμε τα σήματα των πηγών
figure;
subplot(2,1,1); plot(s(1,:)),grid on, title('M1'), xlabel('t (msec)'); % plot s1
subplot(2,1,2); plot(s(2,:), 'r'),grid on, title('M2'), xlabel('t (msec)'); % plot s2
 
A=[1.2 1.34164; 1.662077 1.55];  %δημιουργούμε τον πίνακα μίξης
 x=[];
for i=1:2
    % x(i,:)=A(:,i)*s(i,:);       giati den douleuei???
    x=A*s;
end

% sxediazoume ti miksi
figure;
plot(x(1,:),'r');
hold on
plot(x(2,:),'b');
hold off;

c=fastica([s(1,:);s(2,:)]); % εφαρμογή αλγορίθμου fastICA

%ακούμε τις ανεξάρτητες συνιστώσες που επιστρέφει ο αλγόριθμος fastICA
sound(s(1,:),Fs);
sound(s(2,:),Fs);

%παρουσιάζουμε τις ανεξάρτητες συνιστώσες που επιστρέφει ο αλγόριθμος fastICA
figure;
subplot(2,1,1); plot(c(1,:)), grid on,title('Anastasia'), xlabel('t (msec)');
subplot(2,1,2); plot(c(2,:),'r'), grid on, title('Maria'), xlabel('t (msec)');