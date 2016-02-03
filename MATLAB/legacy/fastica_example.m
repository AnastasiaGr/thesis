%example me 2 simata pou kataskeuasa egw
clear all;
clc;


for(i=1:2500)
x1(i)=10*cos(2*pi*10*i/1000);
end
x2=zeros(1,2500);
for(j=800:1550)
x2(j)=4;
end

figure;
subplot(2,1,1); plot(x1); % plot x1
subplot(2,1,2); plot(x2, 'r'); % plot x2

%αρχικές τιμές βαρών
a1=0.2; a2=0.5; a3=0.4; a4=0.1;
%μίξη αρχικών σημάτων x1 και x2
for(n=1:2500)
    y1(n)=a1*x1(n)+a2*x2(n);
    y2(n)=a3*x1(n)+a4*x2(n);
end

%σχεδιάζουμε τη μίξη των σημάτων
figure;
subplot(2,1,1); plot(y1);
subplot(2,1,2); plot(y2, 'r');

figure;
c = fastica([y1;y2]); % εφαρμογή του αλγορίθμου fastICA
subplot(2,1,1); plot(c(1,:));
subplot(2,1,2); plot(c(2,:),'r');