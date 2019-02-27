clear all
close all
%originally retrieved via synoptic api
%https://api.synopticdata.com/v2/stations/precip?stid=cln&start=201810010000&end=201902192359&pmode=intervals&interval=day&token=tk2019feb2320yPjcqIn1aoC7wJTAhXX
%https://api.synopticdata.com/v2/stations/timeseries?&token=tk2019feb2320yPjcqIn1aoC7wJTAhXX&start=201810010100&end=201902200000&stid=51101&output=csv
%load the data from the csv files
file_1 = fopen('../data/cln_daily_precip.csv');
file_2 = fopen('../data/buoy_51101_wave_height_2019.csv');

%cln precip
%2018-10-01T00:00:00Z	2018-10-01T23:00:00Z	0
%textscan is a function to read files that are a mix of character (%s), integers (%d)and
%float (%f) values 

%buoy
%8 header lines
% 51101	2018-10-01T01:00:00Z	

cln = textscan(file_1,'%s%s%f','Delimiter',',');
buoy = textscan(file_2,'%s%s%f','Delimiter',',','headerLines',8);

%the curly bracket is syntax to denote a cell
%convert from mm to cm
prec = cln{1,3}/10.;
% the 2nd column of input has a cell array of times which is the beginning
% time
% times have the format '2017-08-24T00:00:00Z' so we have to define that as
% follows
tprec = datenum(cln{1,2},'yyyy-mm-ddTHH:MM:SSZ');
tvprec = datevec(cln{1,2},'yyyy-mm-ddTHH:MM:SSZ');
no_day = length(tprec);

%get the swell height from the third cell
ht = buoy{1,3};
tht = datenum(buoy{1,2},'yyyy-mm-ddTHH:MM:SSZ');
tvht = datevec(buoy{1,2},'yyyy-mm-ddTHH:MM:SSZ');
no_ht = length(tht);
%simplify dates
datc = datenum(tvprec(:,1),tvprec(:,2),tvprec(:,3));
datb = datenum(tvht(:,1),tvht(:,2),tvht(:,3));
%remove nans
ht_i = find(~isnan(ht));
hts = ht(ht_i);
tvhts = tvht(ht_i,:);
thts = tht(ht_i);
datbs = datb(ht_i);

%QUESTION 1. Why is it important to remove the nans?


%loop over all the prec days
for i = 1:no_day
    %find all the values of ht in that day and then find the max swell
    %height for that day
    ht_di = find(datbs==datc(i));
    ht_max(i) = max(hts(ht_di));
    
end

%open a figure window
figure(1)
%create a plot of cln prec vs time
plot(datc,prec,'c')
%datetick labels in this case the x axis labeling the days
datetick('x','mmdd');
hold on
title('CLN Precipitation (m) & Buoy Swell Height (m). John Horel')
xlabel('Day')
ylabel('')
%add buoy height vs time
plot(datc,ht_max,'r')
grid on


%compute the linear correlation between time series a and b
rho = corrcoef(ht_max,prec);


%QUESTION 2. Discuss in a sentence the reason for the linear correlation
%value between the buoy and prec time series. Subjectively, does there
%appear to be a relationship between the buoy and prec time series?



%compute standardized anomalies of the original data
pa = (prec-mean(prec))/std(prec,1);
ha = (ht_max-mean(ht_max))/std(ht_max,1);

%plot the standardized anomalies
figure(2)
plot(datc,pa,'c')
datetick('x','mmdd');

hold on
title('CLN Precipitation & Buoy Swell Height Std Anomalies. John Horel')
xlabel('Day')
ylabel('')
%add buoy height vs time
plot(datc,ha,'r')
grid on

%QUESTION 3.  Subjectively, does there
%appear to be a relationship between the buoy and prec standardized anomaly time series?




%compute the autocorrelation of the collins precipitation for +- 30 day
%lags
[ap,lags] = xcorr(pa,30,'coeff');
%compute the autocorrelation of the swell height for +- 30 day lags
[ah,lags] = xcorr(ha,30,'coeff');
%compute the correlation between prec and swell height for +- 30 day lags
[rc,lags] = xcorr(ha,pa,30,'coeff'); 

figure(3)
plot(lags,ap,'c')
hold on
plot(lags,ah,'r')
plot(lags,rc,'k')
title('Autocorrelation and Cross Correlations  John Horel')
xlabel('Lag')
ylabel('Correlations')
grid on

%which lag has the largest positive cross correlation with swell leading precip?
[~,I] = max(rc(1:30));
lagDiff = lags(I);


%QUESTION 4. Explain in a couple of sentences the key characteristics of
%the autocorrelation of the buoy time series with itself at lags from -30
%to +30



%QUESTION 5. Explain in a couple of sentences the key characteristics of
%the autocorrelation of the prec time series with itself at lags from -30
%to +30



%QUESTION 6. Explain in a couple of sentences the key characteristics of
%the correlation of the buoy time series with the prec time series at lags from -30 to +30




%QUESTION 7. What fraction of total variance of the prec time series  is explained
%by the buoy time series at LagDiff?



%shift the precip time series to then align as best as possible with
%precip
figure(4)
lgp = pa(-lagDiff+1:end);
tlgp = (0:length(lgp)-1);

plot(datc,ha,'r')


datetick('x','mmdd');
hold on
plot(datc(-lagDiff+1:end),lgp,'c');
title('CLN Precipitation, Buoy Swell Height shifted to Max Corr Lag. John Horel')

polytool(ha(-lagDiff+1:end),lgp)

%QUESTION 8. Discuss really briefly whether the "buoy" time series is a good predictor of prec time series at
%lag LagDiff. Would you be able to reject the null hypothesis?



%smooth the precipitation and height fields as a means to be less
%stringent on the relationship
ps = mean_smooth(prec,no_day,3,3);
hts = mean_smooth(ht_max,no_day,3,3);
psa = (ps-mean(ps))/std(ps,1);
hsa = (hts-mean(hts))/std(hts,1);

%compute standardized anomalies of the smoothed data
psa = (ps-mean(ps))/std(ps,1);
hsa = (hts-mean(hts))/std(hts,1);



%plot the standardized anomalies
figure(5)
plot(datc,psa,'c')
datetick('x','mmdd');
hold on
title('CLN Precipitation & Buoy Swell Height Smoothed Std Anomalies. John Horel')
xlabel('Day')
ylabel('')
%add buoy height vs time
plot(datc,hsa,'r')
grid on

%QUESTION 9. Are the smoothed time series likely to be more or less Gaussian than the original time series?
% Why or why not? Hint, feel free to look at histograms of the different
% time series




%compute the autocorrelation of the collins precipitation for +- 21 day
%lags
[aps,lags] = xcorr(psa,30,'coeff');
%compute the autocorrelation of the swell height for +- 21 day lags
[ahs,lags] = xcorr(hsa,30,'coeff');
%compute the correlation between prec and swell height for +- 21 day lags
[rcs,lags] = xcorr(hsa,psa,30,'coeff'); 

figure(6)
plot(lags,aps,'c')
hold on
plot(lags,ahs,'r')
plot(lags,rcs,'k')
title('Autocorrelation and Cross Correlations Smoothed Data  John Horel')
xlabel('Lag')
ylabel('Correlations')
grid on

%which lag has the largest positive cross correlation with swell leading precip?
[~,I] = max(rcs(1:30));
lagDiffs = lags(I);

% Question 10. Describe the differences between the autocorrelations and
% cross correlations of the smoothed time series compared to those from the
% original time series



%QUESTION 11. What fraction of total variance of the smoothed prec time series is explained
%by the smoothed buoy time series at LagDiffs?




%shift the precip time series to then align as best as possible with
%precip
figure(7)
lgps = psa(-lagDiff+1:end);
tlgps = (0:length(lgps)-1);

plot(datc,hsa,'r')


datetick('x','mmdd');
hold on
plot(datc(-lagDiff+1:end),lgps,'c');
title('CLN Precipitation, Buoy Swell Height shifted to Max Corr Lag. John Horel')

polytool(hsa(-lagDiff+1:end),lgps)

%QUESTION 12. Discuss really briefly whether the smoothed "buoy" time series is a good predictor of prec time series at
%lag LagDiffs. Would you be able to reject the null hypothesis?

 

%QUESTION 13. So, explain briefly what would you tell someone about the relationship
%between buoy wave heights and precipitation in the Wasatch Mountains?



%save as a pdf and upload the resulting pdf file to canvas
    