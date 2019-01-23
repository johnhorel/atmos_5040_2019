clear all;
close all;

disp(' John Horel')
disp(' ATMOS 5040/ Spring 2019')
disp(' Chapter 4')
disp('requires ../data/snotel_wtr_yr_2018.csv')

input = csvread('../data/snotel_wtr_yr_2018.csv');
% first column: year
yr = input(:,1);
tot(:,1:7) = input(:,2:8)*2.54;
  %tot(:,1)=tony grove lake
  %tot(:,2)=ben lomond peak
  %tot(:,3)=ben lomond trail
  %tot(:,4)= farmington
  %tot(:,5)= parleys
  %tot(:,6)= timpanogos
  %tot(:,7)=payson
label = ['TGL';'BLP';'BLT';'FRM';'PAR';'TIM';'PAY'];
  
n = length(yr);

% plot blt and blp totals 
figure(2)
subplot(2,1,1)
plot(yr,tot(:,2),'r',yr,tot(:,3),'b')
ylabel('Total (cm)')
labelp = [label(2,:);label(3,:)];
h=legend(labelp);
 
  %for convenience and to match notes, define blt as x and blp as y
  
x = tot(:,3);
y = tot(:,2);

xm = mean(x);
ym = mean(y);
xs = std(x,1);
ys = std(y,1);

% anomalies
xprime = x - xm;
yprime = y - ym;

% standardized anomalies

xstar = xprime/xs;
ystar = yprime/ys;

 % plot blt and blp standardized anomalies 
subplot(2,1,2)
plot(yr,ystar,'r',yr,xstar,'b')
ylabel('STD ANOM')
h=legend(labelp);

% brute force way to compute regression
% method 1

covar_1 = 0;
varx_1 = 0;
vary_1 = 0;

for i=1:n
covar_1 = covar_1 + xprime(i)*yprime(i);
varx_1 = varx_1 + xprime(i)*xprime(i);
vary_1 = vary_1 + yprime(i)*yprime(i);
end

covar_1 = covar_1/n;
varx_1 = varx_1/n;
vary_1 = vary_1/n;

b_1 = covar_1/varx_1;
r_1 = covar_1/sqrt(varx_1*vary_1);
sdx_1 = sqrt(varx_1);
sdy_1 = sqrt(vary_1);

% linear algebra way to compute

covar_2 = transpose(xprime)*yprime;
varx_2 = transpose(xprime)*xprime;
vary_2 = transpose(yprime)*yprime;
covar_2 = covar_2/n;
varx_2 = varx_2/n;
vary_2 = vary_2/n;

b_2 = covar_2/varx_2;
r_2 = covar_2/sqrt(varx_2*vary_2);
sdx_2 = sqrt(varx_2);
sdy_2 = sqrt(vary_2);

% compute estimate of y over range of x's 
%(we can choose whatever range of x's we want)
xhat = [-50:5:75];
yhat = b_2 * xhat;

% add mean back in 
XH = xm + xhat;
YH = ym + yhat;

% plot estimate of y as line and plot original data as points
figure(3)
subplot(2,1,1)
plot(XH,YH,'r-',x,y,'+','MarkerSize',10);
xlabel('Ben Lomond Trail','FontSize',16)
ylabel('Ben Lomond Peak','FontSize',16)

% scatter plot in terms of standardized anomalies
subplot(2,1,2)
plot(xhat/xs,yhat/ys,'-',xstar,ystar,'+','MarkerSize',10);
xlabel('Ben Lomond Trail','FontSize',16)
ylabel('Ben Lomond Peak','FontSize',16)

% polytool
polytool(x,y)

% use matlab correlation function
rhop = corr(x,y,'type','Pearson');
rhos = corr(x,y,'type','Spearman');

%now let's deal with all 7 time series at once
xt = tot;
figure(5)
plotmatrix(xt);
xlabel('Precipitation (cm)');

title('SNOTEL Total Precipitation: John Horel 1/21/2019');
 
xtm = mean(xt);
xts = std(xt,1);
no = 7;

% anomalies
xtp = xt - ones(n,1) * xtm ;

% standardized anomalies

xstar = xtp ./ (ones(n,1) * xts);

% plot hovmuller diagram of standardized temporal anomalies
figure(6)
hold on
xa = 1:1:no;
[C,hc]=contour(xa,yr,xstar);
clabel(C,hc);
set(gca,'YDir','reverse')
xlabel('SNOTEL Stn #');
ylabel('Year');
title('Hovmuller of Station Std Anom: John Horel 1/21/2019');
 
% linear algebra way to compute cross correlations

rho_1 = transpose(xstar)*xstar / no;

% matlab direct calculation
rho_2 = corrcoef(xt);

figure(7)
hold on
[C,hc]=contour(rho_2,[0.99;0.95;0.90;0.85;0.80;0.75;0.70;0.65]);
clabel(C,hc);
xlabel('SNOTEL Stn #');
ylabel('SNOTEL Stn #');
title('Correlations of Time Series: John Horel 1/21/2019');


