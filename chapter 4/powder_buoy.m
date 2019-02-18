
clear all
close all

%load the data from the csv files
file_1 = fopen('../data/cln_daily_precip.csv');
file_2 = fopen('../data/buoy_51101_wave_height.csv');

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
prec = cln{1,3}/10.;
% the 2nd column of input has a cell array of times which is the beginning
% time
% times have the format '2017-08-24T00:00:00Z' so we have to define that as
% follows
tprec = datenum(cln{1,2},'yyyy-mm-ddTHH:MM:SSZ');
tvprec = datevec(cln{1,2},'yyyy-mm-ddTHH:MM:SSZ');
no_day = length(tprec);

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

%loop over all the prec days
for i = 1:no_day
    %find all the values of ht in that day and then find the max swell
    %height for that day
    ht_di = find(datbs==datc(i));
    ht_max(i) = max(hts(ht_di));
    if(ht_max(i)>5)
        ht_max(i)=5;
    end
end
%open a figure window
figure(1)
%create a plot of cln prec vs time
plot(datc,prec,'c')
%datetick labels in this case the x axis labeling the days
datetick('x','mmdd');
hold on
title('CLN Precipitation (cm) & Buoy Swell Height (m). John Horel')
xlabel('Day')
ylabel('')
%add buoy height vs time
plot(datc,ht_max,'r')


pn = sqrt(prec);
figure(2)
psa = (pn-mean(pn))/std(pn,1);
hsa = (ht_max-mean(ht_max))/std(ht_max,1);
plot(datc,psa,'c')
datetick('x','mmdd');

[ap,lags] = xcorr(psa,21,'coeff');
[ah,lags] = xcorr(hsa,21,'coeff');
[rc,lags] = xcorr(hsa,psa,21,'coeff'); 

%which has the largest cross correlation
[~,I] = max(abs(rc));
lagDiff = lags(I)


hold on
title('CLN Precipitation (cm) & Buoy Swell Height (m). John Horel')
xlabel('Day')
ylabel('')
%add buoy height vs time
plot(datc,hsa,'r')

figure(3)
lgh = hsa(lagDiff+1:end);
tlgh = (0:length(lgh)-1);

plot(tlgh,lgh)

plot(datc,psa)
datetick('x','mmdd');
hold on
plot(datc(lagDiff+1:end),lgh);



    