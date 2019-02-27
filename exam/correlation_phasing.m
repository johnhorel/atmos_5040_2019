close all
clear all
%linear correlation when one time series lags another 
%create a time series of 150 days
t = 0:1:150;
% a-buoy: fake sinusoidal time series with first peak at time=14
a = sin(pi*(t)/28);
% b- prec: fake phase shifted (delayed relative to buoy) time series with
% first peak at time=28
b = sin(pi*(t-14)/28);

figure(1)
plot(t,a,'r')
hold on
plot(t,b,'c')
grid on

%compute the linear correlation between time series a and b
rho = corrcoef(a,b);

%QUESTION 1. Discuss in a sentence the reason for the linear correlation
%value between the buoy and prec time series. Subjectively, does there
%appear to be a relationship between the buoy and prec time series?



%compute the autocorrelation of the buoy time series with itself at lags from -30
%to +30
[raa,lagt] = xcorr(a,a,30,'coeff'); 

%compute the linear correlation of time series a with b at lags from -30 to 30
[rab,lagt] = xcorr(a,b,30,'coeff'); 

figure(2)
plot(lagt,raa,'r')
hold on
plot(lagt,rab,'k')
grid on

%find the largest positive cross correlation, meaning a leads b
[~,I] = max(rab);
lagDiff = lagt(I);


%QUESTION 2. Explain in a couple of sentences the key characteristics of
%the autocorrelation of the buoy time series with itself at lags from -30
%to +30



%QUESTION 3. Explain in a couple of sentences the key characteristics of
%the correlation of the buoy time series with the prec time series at lags from -30 to +30


%QUESTION 4. What fraction of total variance of the prec time series  is explained
%by the buoy time series at the lag -14?



%shift the prec time series back in time to align with the buoy time
%series

figure(3)
lgb = b(-lagDiff+1:end);
tlgb = (0:length(lgb)-1);
plot(t,a,'r')
hold on
plot(tlgb,lgb,'c')
grid on
nol = length(lgb)
polytool(a(1:nol),lgb)

%QUESTION 5. Discuss really briefly whether the "buoy" time series is a good predictor of prec time series at
%lag LagDiff. Would you be able to reject the null hypothesis in this
%instance?



%save as a pdf and upload the resulting pdf file to canvas