%example me 3 fwnes (Egw, Maria, Mpikos)

clear all;
clc;
load('filters.mat');

 traindir = 'train-friends/'; 
 nFiles = 3;
 s = [];
 for i=1:nFiles
    filename = sprintf('s%d.wav',i);
    [y,fs] = audioread(strcat(traindir,filename));
     %s(1,:) = filter(Hd,y);
     s(i,:)= y(round(fs/2):round(5*fs/2));
 end
 
 % akoume tis 2 fwnes
 sound(s(1,:),fs);
 sound(s(2,:),fs);
 sound(s(3,:),fs);
 
 
 %παρουσιάζουμε τα σήματα των πηγών
figure;
subplot(3,1,1); plot(s(1,:)),grid on, title('Anastasia'), xlabel('t (msec)'); % plot s1
subplot(3,1,2); plot(s(2,:), 'r'),grid on, title('Maria'), xlabel('t (msec)'); % plot s2
subplot(3,1,3); plot(s(1,:),'g'),grid on, title('Mpikos'), xlabel('t (msec)'); % plot s3

 
 A=[0.5 0.3 0.7; 0.8 0.9 0.7; 0.7 0.8 0.9];  %δημιουργούμε τον πίνακα μίξης
 x=[];
for i=1:nFiles
    % x(i,:)=A(:,i)*s(i,:);       giati den douleuei???
    x=A*s;
end

%ακούμε τη μίξη των δύο σημάτων
sound(x(1,:),fs);
sound(x(2,:),fs);
sound(x(3,:),fs);

% sxediazoume ti miksi
figure;
plot(x(1,:),'r');
hold on
plot(x(2,:),'b');
hold on
plot(x(3,:),'g');

c=fastica([x(1,:);x(2,:);x(3,:)]); % εφαρμογή αλγορίθμου fastICA

%ακούμε τις ανεξάρτητες συνιστώσες που επιστρέφει ο αλγόριθμος fastICA
sound(c(1,:),fs);
sound(c(2,:),fs);
sound(c(3,:),fs);

%παρουσιάζουμε τις ανεξάρτητες συνιστώσες που επιστρέφει ο αλγόριθμος fastICA
figure;
subplot(3,1,1); plot(c(1,:)), grid on,title('Mpikos'), xlabel('t (msec)');
subplot(3,1,2); plot(c(2,:),'r'), grid on, title('Anastasia'), xlabel('t (msec)');
subplot(3,1,3); plot(c(2,:),'g'), grid on, title('Maria'), xlabel('t (msec)');
