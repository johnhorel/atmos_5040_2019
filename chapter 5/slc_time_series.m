clear all
close all
% create time series for slc area (40.5-41.5,-113-111)
%from https://www.esrl.noaa.gov/psd/cgi-bin/data/timeseries/timeseries1.pl
slc = csvread('../data/slc_time_series.csv');
yrs = slc(:,1);
jan = slc(:,2);
nyr = length(yrs);
mjan = mean(jan);
sjan = std(jan,1);
jan_sanom = (jan - mjan)/sjan;
figure(1)
subplot(2,1,1)
plot(yrs,jan);
subplot(2,1,2)
plot(yrs,jan_sanom);
%dont include 1948
csvwrite('../data/slc_timeseries.dat',jan_sanom(2:nyr));

%now let's composite 500 mb hPa height
% during positive MEI Jan's vs. negative MEI Jan's
%positive MEI in Jan
yrp = [1973,1983,1992,1998,2010,2016];
%negative MEI in Jsn
yrn = [1956;1972;1974;1976;1989;2011];
nop = length(yrp);
non = length(yrn);
for i=1:nop
in_yrp(i) = find(yrs==yrp(i));
end
for i=1:non
in_yrn(i) = find(yrs==yrn(i));
end

%get samples for pos and neg Jan's
sam_yrp = jan_sanom(in_yrp);
sam_yrn = jan_sanom(in_yrn);
yrp_mn = mean(sam_yrp);
yrn_mn = mean(sam_yrn);
yrp_v = var(sam_yrp,1);
yrn_v = var(sam_yrn,1);
df = nop+non - 2;
%compute t statistic
sig = (yrp_mn - yrn_mn)*sqrt(df);
noise = sqrt(((nop-1)*yrp_v+(non-1)*yrn_v)*(1/nop + 1/non));
t = sig/noise;

%hypothesis that heights abnormally high during
%one tail t test that positive MEI higher than negative MEI

%value of t statistic corresponding to 5% confidence to reject
% the null hypothesis
t_null = tinv(0.95,df);

%in this instance t < t_null which means not enough signal
%so can't reject the null hypothesis