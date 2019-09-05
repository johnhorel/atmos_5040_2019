close all
clear all
% Chapter 2a

%read 3 column vectors of years, number of observations, and yearly lake level for 1895-2012 period
%lake level (in ft)
data_lev = csvread('../data/gsl_yr.csv');
year = data_lev(:,1);
%convert level to meters
lev = data_lev(:,3)*.3048;

%read 2 column vectors of years and precipitation (in inches)
data_ppt = csvread('../data/utah_precip.csv');
yearp = data_ppt(:,1);
%convert precip to cm
ppt = 2.54*data_ppt(:,2);

%read 2 column vectors of years and annual mean temperature (in F) 
data_t = csvread('../data/utah_temp.csv');
yeart = data_t(:,1);
%convert to C
temp = 5*(data_t(:,2) - 32)/9;

% figure 2.1
figure(1);
subplot(3,1,1);
bar(year,lev,'g');
axis([1895 2018 1277 1284])
decade_ticks = 1900:10:2010;
decade_labels = cellstr(num2str(decade_ticks'));
set(gca,'XTick',decade_ticks);
set(gca,'XTickLabel',decade_labels);
grid on
xlabel('Time');
ylabel('Level (m)');

subplot(3,1,2);
bar(yearp,ppt,'c');
axis([1895 2018 20 55])
set(gca,'XTick',decade_ticks);
set(gca,'XTickLabel',decade_labels);
grid on;
xlabel('Time');
ylabel('Precipitation (cm)');

subplot(3,1,3)
bar(yeart,temp,'r');
axis([1895 2018 6.0 11.5])
set(gca,'XTick',decade_ticks);
set(gca,'XTickLabel',decade_labels);
grid on
xlabel('Time');
ylabel('Temperature (C)');

% section 2.b

levsort = sort(lev,'ascend');
range_lev = max(lev) - min(lev);

%figure 2.2
figure(2)
subplot(2,2,1)
x1 = 1277:1:1284;
histogram(lev,x1);
xlabel('Level (m)');
ylabel('Number of Years');

subplot(2,2,2)
x2 = 1277:.5:1284;
histogram(lev,x2);
xlabel('Level (m)');
ylabel('Number of Years');

subplot(2,2,3)
histogram(lev,x1,'Normalization','probability');
xlabel('Level (m)');
ylabel('Probability');

subplot(2,2,4)
histogram(lev,x2,'Normalization','probability');
xlabel('Level (m)');
ylabel('Probability');

% data range
range_lev = max(lev) - min(lev);

%figure 2.3 
figure(3)
cdfplot(lev)
xlabel('Level')
ylabel('Cumulative Probability')
title('Great Salt Lake Level Cumulative Probability')

% section 2.c

%median values
med_lev = median(lev);
med_temp = median(temp);
med_ppt = median(ppt);

%prctile in stattool package
perc_lev = prctile(lev,[10,25,50,75,90]);
perc_temp = prctile(temp,[10,25,50,75,90]);
perc_ppt = prctile(ppt,[10,25,50,75,90]);

%boxplot in stattool package
%figure 2.4
figure(4)
subplot(1,3,1)
boxplot(lev,'notch','on')
set(gca,'XTickLabel',{' '})
ylabel('Level (m)');
subplot(1,3,2)
boxplot(ppt,'notch','on')
ylabel('Precipitation (cm)');
set(gca,'XTickLabel',{' '})
subplot(1,3,3)
boxplot(temp,'notch','on')
set(gca,'XTickLabel',{' '})
ylabel('Temperature (C)');

%load all variables into a 3 column array to streamline processing
array(:,1) = lev;
array(:,2) = ppt;
array(:,3) = temp;

iq_var = iqr(array);
xbar = mean(array);
xmed = median(array);
xmod = mode(array);
xbar_trim = trimmean(array,10);

%put in a bad value
array_wbad = array;
array_wbad(1,:) = 100;
xbar_wbad = mean(array_wbad);
xmed_wbad = median(array_wbad);
xbar_trim_wbad = trimmean(array_wbad,10);

%median absolute deviation
ma = mad(array);

% unbiased estimate of population standard deviation and variance
var0 = var(array,0);
std0 = std(array,0);

% sample standard deviation and variance
var1 = var(array,1);
std1 = std(array,1);

skew = skewness(array);

%section 2d

% compute departures from mean
% need to use some matlab matrix algebra for the array
ny = length(array(:,1));

%sample means
xbar_array = ones(ny,1)*xbar;
%sample standard deviations
sx_array = ones(ny,1)*std(array,1);

array_a = array - xbar_array;

% figure 2.5
figure(5);
%define the plot axes
axis_val = [1895 2018 -4 4; 1895 2018 -20 20; 1895 2018 -2 2];
%define the labels
xlabels = cellstr(['Time';'Time'; 'Time']);
ylabels = cellstr(['Level(m)          ';'Precipitation (cm)';'Temperature (C)   ']);
%define the colors
colors = ['g' 'c' 'r'];
for i=1:3
subplot(3,1,i);
bar(year,array_a(:,i), colors(i));
axis([axis_val(i,:)])
set(gca,'XTick',decade_ticks);
set(gca,'XTickLabel',decade_labels);
grid on
xlabel(xlabels(i));
ylabel(ylabels(i));
end


% define climate normal for 1981-2010 period. find those years
cyr_beg = find(year == 1981);
cyr_end = find(year == 2010);

cnorm = mean(array(cyr_beg:cyr_end,:));
cnorm_array = ones(ny,1)*cnorm;
array_cna = array - cnorm_array;

figure(6);
for i=1:3
subplot(3,1,i);
bar(year,array_cna(:,i), colors(i));
axis([axis_val(i,:)])
set(gca,'XTick',decade_ticks);
set(gca,'XTickLabel',decade_labels);
grid on
xlabel(xlabels(i));
ylabel(ylabels(i));
end

% section 2.d beginning with using monthly data where earlier in chapter using
% yearly data

%read array of data with year,month,level
data_levm = csvread('../data/gsl_monthly.csv');

% salt lake level begins in 1903 through 2018
%create 2d array levm for processing
% rows are years and columns are months
% also create 2d array of dates where
% the date is the midpoint of the month

%determine the number of years
nym = max(data_levm(:,1))-min(data_levm(:,1))+1;
nm = 12
for i=1:nym
for j=1:nm
ic = (i-1)*nm+j;
levm(i,j)= data_levm(ic,3)*.3048;
datem(i,j)= data_levm(ic,1)+(data_levm(ic,2)-0.5)/12.;
end
end

%compute sample mean and standard deviation for each month
mean_m = mean(levm);
sx_m = std(levm,1);

%plot monthly mean;

figure(8);
bar(mean_m,'g');
axis([0.5 12.5 1279.5 1280.2])
month_ticks = 0.5:1:11.5;
month_labels = cellstr(['JAN';'FEB';'MAR';'APR';'MAY';'JUN';'JUL';'AUG';'SEP';'OCT';'NOV';'DEC'])';
set(gca,'XTick',month_ticks);
set(gca,'XTickLabel',month_labels);
grid on
xlabel('Time');
ylabel('Level (m)');

%in order to plot monthly values, need to reorder back into 
% 1d vectors. use transpose and then make 1d
dm = datem';
datem_1d = dm(:);
lm = levm';
levm_1d = lm(:);
figure(7);
subplot(3,1,1);
bar(datem_1d,levm_1d,'g');
axis([1900 2019 1277 1284])
decade_ticks = 1900:10:2010;
decade_labels = cellstr(num2str(decade_ticks'));
set(gca,'XTick',decade_ticks);
set(gca,'XTickLabel',decade_labels);
grid on
xlabel('Time');
ylabel('Level (m)');

%plot anomalies
%first create array of monthly means which are different for each month of the year
mean_levm = ones(nym,1)*mean_m;
levm_a = levm - mean_levm;
lma = levm_a';
levm_a_1d = lma(:);
%to plot
subplot(3,1,2);
bar(datem_1d,levm_a_1d,'g');
axis([1900 2019 -2.5 4 ])
decade_ticks = 1900:10:2010;
decade_labels = cellstr(num2str(decade_ticks'));
set(gca,'XTick',decade_ticks);
set(gca,'XTickLabel',decade_labels);
grid on
xlabel('Time');
ylabel('Level Anomalies (m)');

%transform GSL level further by normalizing by monthly standard deviation
% use matlab matrix algebra- ./ is element divide

sx_array = ones(nym,1)*sx_m;
z = levm_a./sx_array;
zt = z';
z_1d = zt(:);

subplot(3,1,3);
bar(datem_1d,z_1d,'c');
axis([1900 2019 -2.5 4])
decade_ticks = 1900:10:2010;
decade_labels = cellstr(num2str(decade_ticks'));
set(gca,'XTick',decade_ticks);
set(gca,'XTickLabel',decade_labels);
grid on
xlabel('Time');
ylabel('Standardized Anomalies');

%plot cdf of transformed data
figure(9);
cdfplot(z_1d(:));
xlabel('Standardized Anomalies');
ylabel('Cumulative Probability Distribution');

% compute median smoothed values with 5 passes of a 3 point smoother
ppt_ms = median_smooth(array_a(:,2),ny,3,5);

ppt_mns = mean_smooth(array_a(:,2),ny,3,5)

%plot anomalies and overlay mean and median smoothed lines
figure(10)
bar(year,array_a(:,2), 'c');
axis([axis_val(2,:)])
set(gca,'XTick',decade_ticks);
set(gca,'XTickLabel',decade_labels);
grid on
xlabel('Time');
ylabel('Precipitation (cm)');
hold on
% note that ppt_ms is a row vector not a column vector
plot(year,ppt_ms','r','LineWidth',2);
plot(year,ppt_mns','g','LineWidth',2);
