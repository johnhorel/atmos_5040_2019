clear all
close all

disp(' John Horel')
disp(' ATMOS 5040/ Spring 2019')
disp(' Chapter 3')
disp(' Reproducing results in notes')
disp('requires alta_stns.dat')
disp('requires cdfnorm.m')
disp('requires gaussfit')
disp('requires histnorm.m')
disp('requires gsl_monthly.csv')
disp('requires klamath_river_streamflow.csv')
disp('requires utah_precip.csv')
disp('requires weibullparam.m')

%Notes Section 3
%figure 3.1
%vennX: A,A and B,B,B and C, C,A and C,A and B and C
vennX([142 0 83 25 104 79 0],.1)
%figure 3.3
vennX([142 79 104],.1)
%Notes Section 3b
% figure 3.5
% requires stat toolbox
 normspec([.5,1],0,1)

% figure 3.6
% requires stat toolbox
figure(6)
x=-3:.01:3;
f=cdf('norm',x,0,1);
plot(x,f)

%read arrays of monthly lake level
gsl_mon=csvread('../data/gsl_monthly.csv');
lev = gsl_mon(:,3)*.3048;
% lint- histogram interval
lint = 0.2;
xl = 1276:lint:1284;
hl=histnorm(lev,xl);
% fit gaussian to histogram of lake lev
levm = mean(lev);
stdl = std(lev,0);
[sigmal,mul] = gaussfit(xl,hl);
% compute gaussian parametric distribution
pdfg_lev = 1/(sigmal * sqrt(2*pi))*exp(-(xl-mul).^2/(2*sigmal^2));
figure(7)
subplot(2,1,1)
bar(xl,hl);
axis([xl(1) xl(length(xl)) 0 0.6]);
hold on
plot(xl,pdfg_lev,'r')
xlabel('Level (m)');
ylabel('Fractional Contribution');
title('Lake Level Histogram & Gaussian Fit: John Horel 1/20/19');

% plot cumulative distribution
subplot(2,1,2)
[cl yl] =cdfnorm(lev,xl);
plot(yl,cl)
hold on
axis([yl(1) yl(length(yl)) 0 1])
xlabel('Level (m)');
ylabel('Cumulative Distribution');
title('Lake Level Cumulative Distribution & Gaussian Fit: John Horel 1/20/19');
nx = length(xl);
cdfg_lev(1)=0;
for i = 2:nx
    cdfg_lev(i) = cdfg_lev(i-1) + pdfg_lev(i)*lint;
end
plot(yl,cdfg_lev,'r')

% load collins air temperature data (as well as other stations)
  [year,mo,dy,hr,atb,agd,cln,amb,alt] = textread('../data/alta_stns.dat','%f %f %f %f %f %f %f %f %f');
tint = 0.5;
xt = -23:tint:18;
ht=histnorm(cln,xt);
% since original data to nearest whole def F, histogram has some holes (no
% possible values)
% fit gaussian to histogram of collins temp
tm = mean(cln);
stdt = std(cln,0);
[sigmat,mut] = gaussfit(xt,ht);
% compute gaussian parametric distribution
pdfg_cln = exp(-(xt-mut).^2/(2*sigmat^2))/(sigmat * sqrt(2*pi));
figure(8)
subplot(2,1,1)
bar(xt,ht)
axis([xt(1) xt(length(xt)) 0 0.1])
hold on
plot(xt,pdfg_cln,'r')
xlabel('Temperature (C)');
ylabel('Fractional Contribution');
title('Temperature Histogram & Gaussian Fit: John Horel 1/20/19');

% plot cumulative distribution
subplot(2,1,2)
[ct yt] =cdfnorm(cln,xt);
plot(yt,ct)
hold on
axis([yt(1) yt(length(yt)) 0 1])
xlabel('Temperature (C)');
ylabel('Cumulative Distribution');
title('Temperature Cumulative Distribution & Gaussian Fit: John Horel 1/20/19');
nt = length(xt);
cdfg_cln(1)=0;
for i = 2:nt
    cdfg_cln(i) = cdfg_cln(i-1) + pdfg_cln(i)*tint;
end
cdfg_cln(i+1)= cdfg_cln(i);
plot(yt,cdfg_cln,'r')


% for figure 3.9

%p = normspec([-1,1],0,1);

%p = normspec([-2,2],0,1);

%p= normspec ([2,Inf],0,1);

%xq = norminv([0.05 0.95],0,1)

%geometric distribution- see geocdf in statistics toolbox
%xg- max number of years
%pg- probability of an event occurring- .01- one in a hundred years
xg = 300;
pg = 0.01;
sump = 0;
    for i=1:xg
      cg(i) = sump + pg * (1-pg).^(i-1);
      sump = cg(i);
    end
figure(10)
xgg = 1:1:300;
stairs(xgg,cg);
xlabel('Years from present');
ylabel('Cumulative probability that an event will recur');
title('Geometric Distribution for 1 in 100 year event: John Horel 12/29/18');

klamath=csvread('../data/klamath_river_streamflow.csv');
figure(11)
yr = klamath(:,1);
flow = klamath(:,2);
bar(yr,flow)
axis([1910 2018 0 600000])
xlabel('Water Year');
ylabel('Peak streamflow ft^3/s');
title('Klamath River Peak Streamflow: John Horel 1/20/19');
hold on
%going to add some lines to this figure in a bit

fint = 25000;
xf = 1000:25000:585000;
hf=histnorm(flow,xf);
hf = hf * fint;
% fit gaussian to histogram of klamath flow
% don't need to, but put in as first guess
% the sample mean and estimate of pop std dev
flowm = mean(flow);
stdf = std(flow,0);
[sigmaf,muf] = gaussfit(xf,hf,stdf,flowm);
% compute gaussian parametric distribution
pdfg_flow = fint * exp(-(xf-muf).^2/(2*sigmaf^2))/(sigmaf * sqrt(2*pi));
%get weibull parameters
[alpha beta] = weibullparam(flow);
% compute weibull parametric distribution
pdfw_flow = fint * (alpha/beta)*((xf/beta).^(alpha-1)).*exp(-(xf/beta).^alpha);

figure(12)
subplot(1,2,1)
bar(xf,hf)
axis([xf(1) xf(length(xf)) 0 0.25])
hold on
plot(xf,pdfg_flow,'r')
plot(xf,pdfw_flow,'g')
xlabel('Peak Flow (ft^3/s)');
ylabel('Fractional Contribution');
title('Klamath Peak Flow, Gaussian & Weibull Fits: John Horel 1/20/19');

% plot cumulative distribution
subplot(1,2,2)
[cf yf] =cdfnorm(flow,xf);
plot(yf,cf)
hold on
axis([yf(1) yf(length(yf)) 0 1])
xlabel('Peak flow (ft^3/s)');
ylabel('Cumulative Distribution');
title('Klamath CDF & Gaussian  and Weibull Fits: John Horel 1/20/19');
nf = length(xf);
cdfg_flow(nf)=1;
cdfw_flow(nf)= 1;
for i = 2:nf
    %do it in reverse since for gaussian some below 0 flow
    ii = nf - i + 1;
    cdfg_flow(ii) = cdfg_flow(ii+1) - pdfg_flow(ii);
    cdfw_flow(ii) = cdfw_flow(ii+1) - pdfw_flow(ii);
end
cdfg_flow(nf+1)=1;
cdfw_flow(nf+1) = 1;
plot(yf,cdfg_flow,'r');
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
hold on
% plot the empirical estimates vs those observed
loglog(qe,flows,'x')
axis([10000 600000 10000 600000]);
xlabel('Weibull Estimate of Peak flow');
ylabel('Observed Peak Flow (ft^3/s)');
title('Klamath Quantile-Quantile Plot with Weibull Fit: John Horel 1/20/19');


%create probability-probability plot for weibull for klamath flow
%see wilks
subplot(1,2,2)
% plotting a straight line which would be where the points 
% should line up if a weibull fit is really appropriate

loglog(cdfw,cdfw,'g')
hold on
%need to interpolate the empirical cdf to the values observed
opc = interp1q(yf',cf',flows);

loglog(rm,opc,'x')
axis([.001 1 .001 1])
xlabel('Weibull Probability Estimate');
ylabel('Observed Probability');
title('Klamath Probability-Probability Plot with Weibull Fit: John Horel 1/20/19');

figure(11)
% add some guestimates for one in a hundred year floods 
%  weibull fit value for the one in hundred event
qw99 = beta * (-log(1-0.99)).^(1/alpha);
line([1910 2018],[qw99 qw99],'Color',[0,1,0]);
%to get the empirical 1 in 100 event
% need to interpolate  from the empirical cdf
emp99 = interp1q(cf',yf',.99);
line([1910 2018],[emp99 emp99],'Color',[0,0,1]);

%figure 3.14

mu=-5.2;
sig=5.7;
%normspec([mu-1.96*sig, mu+1.96*sig], mu, sig);


%figure 3.15

[nd,nn] = size(year);
for i=1:nd
    if(year(i)<50)
        year(i)=year(i)+2000;
    else
        year(i)=year(i)+1900;
    end
end
dates = datenum(year,mo,dy,hr,0,0);
figure(15)
hold on
x1 = [dates(1), dates(nd)];
y1 = [ 6, 6];
y2 = [-16,-16];
plot(x1,y1,'r');
plot(x1,y2,'g')
datetick('x',25)
bar(dates,cln)

% annual total utah precip (cm)
ut_ppt=csvread('../data/utah_precip.csv');
ppt = ut_ppt(:,2)*2.54;
p_yr = ut_ppt(:,1);
no_p = length(ppt);
meanp = mean(ppt);
%sample std dev
sdp = std(ppt,1);
anomp = ppt - meanp;

%for Fig. 3.17
p_1yr_5percent = normspec([-1.96*sdp,1.96*sdp],0,sdp);
xpq = norminv([0.025 0.975],0,sdp);
%for Fig 3.17
sd3 = sdp/sqrt(3);
p_3yr_5percent = normspec([-1.96*sd3,1.96*sd3],0,sd3);
xpq3 = norminv([0.025 0.975],0,sd3);

%[h,p,ci,stat]= ttest(valy,0,.05,'left');
%Which first indicates that you need the statistics tool box to use
%where on input valy is the vector of values in each 3-year sample
%0 is the mean value for the null hypothesis
%.05 is the significance level chosen (5%) 
%and �left� indicates that we are assuming that we have ruled out that large positive anomalies are relevant (the other options are �both� a two-tailed test and �right� where we rule out large negative anomalies, i.e., look for wet periods)
%where on output h is a flag, 0 means the null hypothesis can not be rejected, 1 means it can be rejected
%p is the significance level corresponding to the t value, the smaller the number the better.
%ci is the confidence interval
%p is the chance (risk) that the null hypothesis is incorrectly rejected

h03_one = zeros(1,no_p);
p03_one = zeros(1,no_p);
h03_two = zeros(1,no_p);
p03_two = zeros(1,no_p);
%one sided test. only asking about droughts
for iyr=p_yr(2):p_yr(no_p-1)
    ii = iyr-1894;
    %load valy with each 3 yr sample
    valy = anomp(ii-1:ii+1);
[h,p,ci,stat]= ttest(valy,0,.05,'left');
h03_one(ii) = h;
p03_one(ii) = 100*p;
end

figure(18)
subplot(4,1,1)
bar(p_yr,anomp,'g')
xlabel('Year');
title('Utah precipitation anomalies (cm)')
axis('tight')
subplot(4,1,2)
x1 = [p_yr(2), p_yr(no_p-1)];
y1 = [ 5, 5];
bar(p_yr,p03_one,'r');
hold on
plot(x1,y1,'k');
axis('tight')
axis([p_yr(1) p_yr(no_p) 0 25])
set(gca, 'YDir','reverse')
xlabel('Year');
title('Signifance Level- 1 sided test');

%plot the 3yr periods for which the null hypothesis
%can be rejected with a risk of 5% 
subplot(4,1,3)
bar(p_yr,h03_one,'b');
axis('tight')
xlabel('Year');
title('Reject Null Hypothesis- 1 sided test');

%now repeat but do a two-sided t test
for iyr=p_yr(2):p_yr(no_p-1)
    ii = iyr-1894;
    valy = anomp(ii-1:ii+1);
[h,p,ci,stat]= ttest(valy,0,.05,'both');
h03_two(ii) = h;
p03_two(ii) = 100*p;
end
subplot(4,1,4)
bar(p_yr,h03_two,'k');
axis('tight')
xlabel('Year');
title('Reject Null Hypothesis- 2 sided test, Wet or Dry periods');

%repeat doing 9 year periods
%one sided test. only asking about droughts
h09_one = zeros(1,no_p);
p09_one = zeros(1,no_p);
h09_two = zeros(1,no_p);
p09_two = zeros(1,no_p);
for iyr=p_yr(5):p_yr(no_p-4)
    ii = iyr-1894;
    %load valy with each 9 yr sample
    valy = anomp(ii-4:ii+4);
[h,p,ci,stat]= ttest(valy,0,.05,'left');
h09_one(ii) = h;
p09_one(ii) = 100*p;
end

figure(19)
subplot(4,1,1)
bar(p_yr,anomp,'g')
xlabel('Year');
title('Utah precipitation anomalies (cm)')
axis('tight')
subplot(4,1,2)
x9 = [p_yr(5), p_yr(no_p-4)];
y1 = [ 5, 5];
bar(p_yr,p09_one,'r');
hold on
plot(x9,y1,'k');
axis('tight')
axis([p_yr(1) p_yr(no_p) 0 25])
set(gca, 'YDir','reverse')
xlabel('Year');
title('Signifance Level- 1 sided test');

%plot the 9yr periods for which the null hypothesis
%can be rejected with a risk of 5% 
subplot(4,1,3)
bar(p_yr,h09_one,'b');
axis('tight')
xlabel('Year');
title('Reject Null Hypothesis- 1 sided test');

%now repeat but do a two-sided t test
for iyr=p_yr(5):p_yr(no_p-4)
    ii = iyr-1894;
    valy = anomp(ii-4:ii+4);
[h,p,ci,stat]= ttest(valy,0,.05,'both');
h09_two(ii) = h;
% store the values so that the cases where the null hypothesis can be
% rejected appear near 1
p09_two(ii) = 100*p;
end
subplot(4,1,4)
bar(p_yr,h09_two,'k');
axis('tight')
xlabel('Year');
title('Reject Null Hypothesis- 2 sided test, Wet or Dry periods');

% a simple little comparison of how the t test values
% are distributed for a sample of 3 vs. a sample of 30 years
% which is almost the same as a gaussian
% i.e. if your sample size is greater than 30
% the t test values are distributed like a gaussian
figure(20);
x = -5:.1:5;
sample_3yr = tpdf(x,3);
gaussian = normpdf(x,0,1);
sample_30yr = tpdf(x,30);
plot(x,gaussian,'r',x,sample_3yr,'g',x,sample_30yr,'b');



