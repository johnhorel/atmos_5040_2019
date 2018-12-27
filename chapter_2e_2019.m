close all;
clear all;
disp(' ')
disp(' ')
disp(' John Horel')
disp(' ATMOS 5040/ Spring 2019')
disp(' Chapter 2e')

%get time series of wind speed and direction from WBB for June 2018 in csv
%format
%documentation on how that was done from Synoptic api services
%http://synopticdata.com
%http://api.synopticlabs.org/v2/stations/timeseries?stid=wbb&output=csv&obtimezone=local&start=201806010600&end=201807010559&vars=wind_speed,wind_direction,wind_gust&obtimezone=local&timeformat=%y%m%d%H%M&token=tk2019jan0216yZVw1gWKP6oIdgvChuT
%requires an active token to run the above
%returns a csv file with a header and text line that have been removed
%4 columns: date(YYMMDDHHMM), wind speed (m/s) direction, wind gust(m/s)
data_wind = csvread('data/wbb_wind_0618.csv');
tv=datevec(num2str(data_wind(:,1)),'yymmddHHMM');
td=datenum(num2str(data_wind(:,1)),'yymmddHHMM');

% get the speed and direction data
%set_1 refers to that a site could have more 
%than one sensor reporting the same variable
spd = data_wind(:,2);
gst = data_wind(:,4);
dir = data_wind(:,3);

%convert spd,dir to u,v. matlab- 0 angle is relative to x axis
% and counterclockwise
u = spd .* sind(dir - 180);
v = spd .* cosd(dir - 180);

figure(12)
subplot(2,2,1)
sp1= 0:0.5:15;
hist(spd,sp1);
axis([0,15,0,5000]);
hold on;
xlabel('Wind Speed (m/s)');
ylabel('Count');
title('Histogram: John Horel 12/26/2018');

subplot(2,2,2)
cdfplot(spd)
xlabel('Wind Speed (m/s)');
ylabel('Cumulative Distributions');
title('Cumulative Distributions: John Horel 12/26/2018');

subplot(2,2,3)
dir1= 0:5:360;
hist(dir,dir1);
axis([0,360,0,1250]);
xlabel('Wind Direction');
ylabel('Count');


subplot(2,2,4)
cdfplot(dir)
axis([0,360,0,1])
xlabel('Horizontal Wind Direction');
ylabel('Cumulative Distribution');

%plot a 2 panel plot of
%top- histogram of wind gust from 0-15 at intervals of 0.5 m/s
%bottom- cdf of wind gust

figure(1) 

subplot(2,1,1)
gs1= 0:0.5:15;
hist(gst,gs1);
axis([0,15,0,5000]);
hold on;
xlabel('Gust (m/s)');
ylabel('Count');
title('Histogram: John Horel 12/026/2018');

subplot(2,1,2)
cdfplot(gst)
xlabel('Gust (m/s)');
ylabel('Cumulative Distributions');
title('Cumulative Distributions: John Horel 12/26/2018');


%compute mean, median, mode, sample std, unbiased estimate of the population std dev,
%and skewness of wind speed, gust, and direction

spd_mean = mean(spd)
spd_median = median(spd)
spd_mode = mode(spd)
spd_std = std(spd,1)
spd_stdp = std(spd,0)
spd_skew = skewness(spd)

gst_mean = mean(gst)
gst_median = median(gst)
gst_mode = mode(gst)
gst_std = std(gst,1)
gst_stdp = std(gst,0)
gst_skew = skewness(gst)

dir_mean = mean(dir)
dir_median = median(dir)
dir_mode = mode(dir)
dir_std = std(dir,1)
dir_stdp = std(dir,0)
dir_skew = skewness(dir)

figure(13)
u1= -5:0.25:5;
subplot(2,2,1)
hist(u);
hold on;
xlabel('Zonal Wind Speed (m/s)');
ylabel('Count');
title('Histograms: John Horel 12/26/2018');

subplot(2,2,2)
cdfplot(u);
xlabel('Zonal Wind (m/s)');
ylabel('Cumulative Distribution');
title('Cumulative Distribution: John Horel 12/26/2018');

subplot(2,2,3)
v1= -10:0.5:10;
hist(v,v1);
hold on;
xlabel('Meridional Wind (m/s)');
ylabel('Count');

subplot(2,2,4)
cdfplot(v);
xlabel('Meridional Wind(m/s)');
ylabel('Cumulative Distribution');

%compute mean, median, mode, unbiased estimate of the population
%std,skewness for zonal and meridional wind


figure(14)
% wind rose
n=length(dir);
ctrl = 0;
ctrm = 0;
%loop over all elements
for i=1:n
 %convert direction to radians  
 dirr(i,1) = dir(i) * pi/180;
 %count light winds first
    if (spd(i) < 2)
        ctrl=ctrl+1;
    dirl(ctrl,1) = dirr(i,1);
    end
    %count medium winds next
if (spd(i)<4)
    ctrm=ctrm+1;
    dirm(ctrm,1) = dirr(i,1);
end
end
%30 degree increments
x = [pi/12:pi/6:2*pi-pi/12];
%plot all winds first to set axes
h=rose(dirr,x);
set(h,'LineWidth',4,'Color','k');
hold on;
%plot medium winds
hm=rose(dirm,x);
set(hm,'LineWidth',2,'Color','r');
%plot light winds
hl=rose(dirl,x);
set(hl,'LineWidth',3,'Color','b');
title('WBB Hodograph: John Horel 12/26/18');
%by default the rose is reversed relative to 
%convention used in the atmospheric sciences
set(gca,'View',[-90 90],'YDir','reverse');

ctr = zeros(1,24);
%loop over all elements of time series
for i=1:n
 %load up arrays for each hour of the day
 h = tv(i,4)+1;
 ctr(1,h)=ctr(1,h)+1;
 sph(ctr(1,h),h)=spd(i);
 dh(ctr(1,h),h)=dir(i);
 uh(ctr(1,h),h)=u(i);
 vh(ctr(1,h),h)=v(i);
end
%compute mean wind speed for each hour
spm = sum(sph)./ctr;
% compute mean components each hour
um = sum(uh)./ctr;
vm = sum(vh)./ctr;
% compute resultant wind speed for each hour
ressp = sqrt(um.*um+vm.*vm);
hrlbl = 0:1:23;
figure(15)
hold on
plot(hrlbl,spm,'r')
plot(hrlbl,ressp,'g')
axis([0 23 0 5])
xlabel('Hour of day');
ylabel('Wind Speed (m/s)');
title('WBB Mean and Resultant Wind Speed: John Horel 12/26/2018');

figure(3)
% wind gust rose
n=length(dir);
ctrl = 0;
ctrm = 0;
%loop over all elements
for i=1:n
 %convert direction to radians  
 dirr(i,1) = dir(i) * pi/180;
 %count light winds first
    if (gst(i) < 3)
        ctrl=ctrl+1;
    dirl(ctrl,1) = dirr(i,1);
    end
    %count medium winds next
if (gst(i)<6)
    ctrm=ctrm+1;
    dirm(ctrm,1) = dirr(i,1);
end
end
%30 degree increments
x = [pi/12:pi/6:2*pi-pi/12];
%plot all winds first to set axes
h=rose(dirr,x);
set(h,'LineWidth',4,'Color','k');
hold on;
%plot medium winds
hm=rose(dirm,x);
set(hm,'LineWidth',2,'Color','r');
%plot light winds
hl=rose(dirl,x);
set(hl,'LineWidth',3,'Color','b');
title('WBB Wind Gust Hodograph: John Horel 12/26/2018');
%by default the rose is reversed relative to 
%convention used in the atmospheric sciences
set(gca,'View',[-90 90],'YDir','reverse');