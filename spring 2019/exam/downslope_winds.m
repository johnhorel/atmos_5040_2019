clear all
close all
%originally retrieved via synoptic api
%https://api.synopticdata.com/v2/stations/timeseries?&token=tk2019mar0114yCNtyR1mXnO0Zu8BBFN&start=201902210700&end=201902220700&stid=wbb&output=csv&obtimezone=local&vars=air_temp,relative_humidity,wind_speed,wind_direction,wind_gust,pressure
%load the data from the csv file
file = fopen('../data/wbb_02_21_19.csv');

%wbb data
%textscan is a function to read files that are a mix of character (%s), integers (%d)and
%float (%f) values 

wbb_in = textscan(file,'%s%s%f%f%f%f%f%f%f','Delimiter',',','HeaderLines',8);
fclose(file);
%the curly bracket is syntax to denote a cell
%pressure in hPa (or mb)
wb(:,1) = wbb_in{1,3}/100.;
%temp (C)
wb(:,2) = wbb_in{1,4};
%relative humidity (%)
wb(:,3) = wbb_in{1,5};
%wind speed (m/s)
wb(:,4) = wbb_in{1,6};
%wind direction
wb(:,5) = wbb_in{1,7};
%wind gust (m/s)
wb(:,6) = wbb_in{1,8};
%pressure altimeter (in mmb)
wb(:,7) = wbb_in{1,9}/100.;
%
%convert spd,dir to u,v (zonal/meridional wind)
%matlab- 0 angle is relative to x axis and counterclockwise
wb(:,8) = wb(:,4) .* sind(wb(:,5) - 180);
wb(:,9) = wb(:,4) .* cosd(wb(:,5) - 180);
%easterly gusts
wb(:,10) = wb(:,6) .* sind(wb(:,5) - 180);
%compute potential temperature (K)
%conserved if adiabatic process
wb(:,11) = (wb(:,2)+273.16).*(1000./wb(:,1)).^(.286);

% the 2nd column of input has a cell array of times which is the beginning
% time
% times have the format '2017-08-24T00:00:00Z' so we have to define that as
% follows
tim = datenum(wbb_in{1,2},'yyyy-mm-ddTHH:MM:SS-0700');
timv = datevec(wbb_in{1,2},'yyyy-mm-ddTHH:MM:SS-0700');


%remove nans of wind direction
dir_i = find(~isnan(wb(:,5)));
wbb = wb(dir_i,:);
time = tim(dir_i,:);
timev = timv(dir_i,:);
n = length(timev);

%compute mean and sample standard deviation for all variables during Feb 21
wbbm = mean(wbb);
wbbs = std(wbb,1);

% compute anomalies
wbbp = wbb - ones(n,1) * wbbm ;

% compute standardized anomalies

wbbstar = wbbp ./ (ones(n,1) * wbbs);

%open a figure window
figure(1)
%create a plot of temperature vs. relative humidity std anomalies vs time
plot(time,wbbstar(:,2),'c')
hold on
plot(time,wbbstar(:,3),'r')
%datetick labels in this case the x axis labeling in hours
datetick('x','hh');
title('Temperature vs. Relative Humidity Standardized Anomalies. John Horel')
xlabel('Hour')
ylabel('Std Anomalies')

%Question 1. 
% a) There are 1440 values at 1 minute intervals. But, what would be a conservative estimate of the number of degrees
%of freedom and explain why for a)temperature and b) relative humidity?


%b) how would you describe the relationship between temperature (or
%potential temperature) and relative humidity? When viewed over the entire day, 
% does it seem to be due to what is happening overall during the day or more by what is 
% happening during the strong downslope wind period?


%plot all of the histograms and scatter diagrams
figure(2)
plotmatrix(wbb);
xlabel('Variables 1-11');
ylabel('Variables 1-11');

title('Relationships During a Downslope Wind Storm: John Horel 2/22/2019');

%Question 2. 
%a. By visual inspection of the histograms on the diagonal or by
%explicitly computing the skewness, which two parameters have the highest
%positive skewness? 



%b. Which variable exhibits the greatest bimodal behavior and why? 



%c. When the pressure is around 840 mb, would you be able to estimate what
%temperature might be expected? Why or why not?

%

% compute linear correlations between every time series
rho = corrcoef(wbb);

%Question 3. From the scatter diagrams and linear correlations, discuss the
%following
%a) Which parameter is most closely strongly linearly correlated with
%temperature?



%b) is there a strong linear relationship between temperature and relative
%humidity? Why or why not?


%c) does it really matter which one of the following time series is used, they all vary similarly:
% wind speed, wind gust, zonal wind, zonal wind gust


%d) is wind direction related to any of the variables in a useful way? Could
% you use it to linearly estimate one of the other variables well? Why or
% why not?


%We could be most interested in the fluctuations that occur during the peak
%of the downslope winds in order to understand physical relationships
%between the variables at the time the specific conditions are taking
%place.

%Much of the relationship shown so far is not due to the downslope wind
%perturbations, so let's do a really crude low-pass filter and remove the
%hourly mean values for the period from 8 AM 0- 4PM when winds are out of east
for hr = 8:15
    h_i = find(timev(:,4)==hr);
    val_h = wbb(h_i,:);
    hm = mean(val_h);
    nh = length(val_h);
    wbbh(h_i,:) = wbb(h_i,:) - ones(nh,1)*hm;
end

%Question 4. Why do I refer to this as a crude low pass filter. What might
%be a better way to do it?


% now limit to standardized anomalies over the period from 8 AM to 4 PM
timeh_i = find((timev(:,4))>=8&timev(:,4)<16);
wbbha = wbbh(timeh_i,:);
timeha = tim(timeh_i,:);
timevha = timev(timeh_i,:);
nh = length(timeha);
wbbham = mean(wbbha);
wbbhas = std(wbbha,1);

% anomalies within the 8 AM to 4 PM period
wbbhap = wbbha - ones(nh,1) * wbbham ;

% standardized anomalies

wbbhsa = wbbhap ./ (ones(nh,1) * wbbhas);

%open a figure window
figure(3)
plot(timeha,wbbhsa(:,2),'c')
hold on
plot(timeha,wbbhsa(:,3),'r') 
datetick('x','hh/MM');
title('Temperature vs. Relative Humidity. John Horel')
xlabel('Hour')
ylabel('Std Anomalies')

%Question 5. There are now only 480 values at 1 minute intervals. Has the number
% of degrees of freedom increased or decreased for temperature and relative humidity?
% You don't need to guestimate the number of degrees of freedom


figure(4)
plotmatrix(wbbhsa);
xlabel('Variables 1-11');
ylabel('Variables 1-11');
title('Relationships During Downslope Wind Storm: John Horel 2/22/2019');

%Question 6.
%a) Has the complexity of the scatter diagrams been reduced (that
%is, is it easier or harder to see linear relationships)? Why or why not?


%b)Have the histograms become more Gaussian? Why or why not?



% compute linear correlations between every time series
rhoh = corrcoef(wbbhsa);

%which linear correlations strengthened or weakened?

rdiff = abs(rhoh)- abs(rho);

%Question 7. 
%a) Focusing on the relationship between temperature (or potential
%temperature) and relative humidity, does the linear relationship between
%those two variable make more sense physically as due to the turbulence 
% associated with the downslope winds than the relationship
%between the original time series? Explain why or why not.



%b) Do you have higher or lower confidence in the nearly identical linear
%correlations between temperature and relative humidity when they are
%computed during the easterly wind period relative to the linear correlations computed from 
%the data during the entire day?



%b) Are the apparent relationships between wind speed variables and relative humidity determined from using the data during the entire
% day relevant for studying the conditions during the downslope wind storm?



%Question 8. How could you improve on this analysis to examine how weather
%parameters are related during downslope wind storms?



