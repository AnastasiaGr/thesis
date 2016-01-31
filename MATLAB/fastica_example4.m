%example me ena arxeio mousikis kai ti fwni mou
%fs=44Khz kai ta dyo

clear all;
clc;
load('filters.mat');

 traindir = 'train-friends/'; 
 s=[];

 
    filename = sprintf('s%d.wav',7);
    [y,fs] = audioread(strcat(traindir,filename));
    %s(1,:) = filter(Hd,y);
   s(1,:)= y(round(fs/2):round(5*fs/2));


     
    filename = sprintf('s%d.wav',1);
    [y,fs] = audioread(strcat(traindir,filename));
    %s(1,:) = filter(Hd,y);
    s(2,:)= y(round(fs/2):round(5*fs/2));

 % akoume tis 2 fwnes
 sound(s(1,:),fs);
 sound(s(2,:),fs);
 
 %παρουσιάζουμε τα σήματα των πηγών
figure;
subplot(2,1,1); plot(s(1,:)),grid on, title('Piano'), xlabel('t (msec)'); % plot s1
subplot(2,1,2); plot(s(2,:), 'r'),grid on, title('Anastasia'), xlabel('t (msec)'); % plot s2
 
 A=[0.5 0.3; 0.8 0.9];  %δημιουργούμε τον πίνακα μίξης
 x=[];
%for i=1:nFiles
    % x(i,:)=A(:,i)*s(i,:);       giati den douleuei???
    x=A*s;
%end

%ακούμε τη μίξη των δύο σημάτων
sound(x(1,:),fs);
sound(x(2,:),fs);

% sxediazoume ti miksi
figure;
plot(x(1,:),'r');
hold on
plot(x(2,:),'b');
hold off;

c=fastica([x(1,:);x(2,:)]); % εφαρμογή αλγορίθμου fastICA

%ακούμε τις ανεξάρτητες συνιστώσες που επιστρέφει ο αλγόριθμος fastICA
sound(c(1,:),fs);
sound(c(2,:),fs);

%παρουσιάζουμε τις ανεξάρτητες συνιστώσες που επιστρέφει ο αλγόριθμος fastICA
figure;
subplot(2,1,1); plot(c(1,:)), grid on,title('Anastasia'), xlabel('t (msec)');
subplot(2,1,2); plot(c(2,:),'r'), grid on, title('Maria'), xlabel('t (msec)');