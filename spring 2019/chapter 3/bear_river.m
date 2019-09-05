clear all
close all

disp(' John Horel')
disp(' ATMOS 5040/ Spring 2019')
disp(' Chapter 3')
disp(' hundred year flood on Bear River')

disp('requires bear_river_corinne.csv')
disp('requires weibullparam.m')



bear=csvread('../data/bear_river_corinne.csv');
figure(11)
yr = bear(:,1);
mon = bear(:,2);
date = yr + (mon-.5)/12;
flow = bear(:,3);
bar(date,flow)
axis([1950 2018 0 10000])
xlabel('Date');
ylabel('Streamflow ft^3/s');
title('Bear River  Streamflow: John Horel 2/10/19');
hold on
grid on
%going to add some lines to this figure in a bit

fint = 100;
xf = 0:fint:10000;
hf=histnorm(flow,xf);
hf_sum=sum(hf);
hf = hf * fint;

%get weibull parameters
[alpha beta] = weibullparam(flow);
% compute weibull parametric distribution
pdfw_flow = fint * (alpha/beta)*((xf/beta).^(alpha-1)).*exp(-(xf/beta).^alpha);

figure(12)
subplot(1,2,1)
bar(xf,hf)
axis([xf(1) xf(length(xf)) 0 .1])
hold on
plot(xf,pdfw_flow,'g')
xlabel(' Flow (ft^3/s)');
ylabel('Fractional Contribution');
title('Bear River Flow, Weibull Fit: John Horel 2/10/19');
pdf_sum = sum(pdfw_flow);
% plot cumulative distribution
subplot(1,2,2)
[cf yf] =cdfnorm(flow,xf);
plot(yf,cf)
hold on
axis([yf(1) yf(length(yf)) 0 1])
xlabel('Flow (ft^3/s)');
ylabel('Cumulative Distribution');
title('Bear River CDF &  Weibull Fit: John Horel 2/10/19');
nf = length(xf);
cdfw_flow(nf)= 0;
for i = 2:nf
    cdfw_flow(i) = cdfw_flow(i-1) + pdfw_flow(i)/pdf_sum;
end
cdfw_flow(nf+1) = 1;
grid on

plot(yf,cdfw_flow,'g');

%create quantile-quantile plot for weibull for klamath flow
%see wilks
cdfw = .001:.001:0.999;
% compute quantile values for a weibull fit to the data
qw = beta * (-log(1-cdfw)).^(1/alpha);

% now need to guestimate the empirical CDF
flows = sort(flow);
lth = length(flow);
id = 1:lth;
%this is called the median estimate of the empirical CDF
rm = (id-0.3)/(lth+0.4);
% now compute quantile values for empirical CDF
qe = beta * (-log(1-rm)).^(1/alpha);

figure(13)
subplot(1,2,1)
% plotting a straight line which would be where the points 
% should line up if a weibull fit is really appropriate
loglog(qw,qw,'g')
grid on
hold on
% plot the empirical estimates vs those observed
loglog(qe,flows,'x')
axis([100 10000 100 10000]);
xlabel('Weibull Estimate of Peak flow');
ylabel('Observed Peak Flow (ft^3/s)');
title('Bear River Quantile-Quantile with Weibull Fit: 2/10/19');


%create probability-probability plot for weibull for klamath flow
%see wilks
subplot(1,2,2)
% plotting a straight line which would be where the points 
% should line up if a weibull fit is really appropriate

loglog(cdfw,cdfw,'g')
hold on
grid on
%need to interpolate the empirical cdf to the values observed
opc = interp1q(yf',cf',flows);

loglog(rm,opc,'x')
axis([.001 1 .001 1])
xlabel('Weibull Probability Estimate');
ylabel('Observed Probability');
title('Bear River Prob-Prob Plot with Weibull Fit: 1/20/19');

figure(11)
% add some guestimates for one in a hundred year floods 
%  weibull fit value for the one in hundred event
qw99 = beta * (-log(1-0.99)).^(1/alpha);
line([1910 2018],[qw99 qw99],'Color',[0,1,0]);
%to get the empirical 1 in 100 event
% need to interpolate  from the empirical cdf
emp99 = interp1q(cf',yf',.99);
line([1910 2018],[emp99 emp99],'Color',[0,0,1]);

%find months where greater than a 1 in a hundred chance according to
%empirical fit
g99e = find(flow>=emp99);
g99_em(:,1) = yr(g99e);
g99_em(:,2) = mon(g99e);
g99_em(:,3) = flow(g99e);
%find months where greater than a 1 in a hundred chance according to the
%weibull fit
g99w = find(flow>=emp99);
g99_we(:,1) = yr(g99w);
g99_we(:,2) = mon(g99w);
g99_we(:,3) = flow(g99w);



