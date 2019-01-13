%clear all the variables
clear all
%close all the figure windows
close all
% jan16 2019 inclass assignment
disp(' ')
disp(' ')
disp(' John Horel')
disp(' ATMOS 5040/ Spring 2019')
disp(' January 16 inclass assignment')
disp(' Requires alta_snow.csv')


%for info on the data
%http://utahavalanchecenter.org/alta-monthly-snowfall
%download the data from the class github repository
data = csvread('../data/alta_snow.csv');
%column 1 is the year and column 8 is the seasonal total
%create a vector of the years 
yr = data(:,1);
%find out how many years
ny = length(yr);
%convert the seasonal totals from inches to cm
tot = data(:,8)*2.54;
%compute the means of each column
mmn = mean(data);
% determine max value and index value of max for the winter season
[maxs,mxi] = max(tot);
% write to screen the year when max occurred
fprintf('year of max seasonal snowfall and amount %d %.1f cm\n', yr(mxi),maxs)
%repeat for min 
[mins,mni] = min(tot);
fprintf('year of min seasonal snowfall and amount %d %.1f cm\n', yr(mni),mins)

%plot time series of snow totals as bar chart
figure(1)
bar(yr,tot)
axis('tight')
title('Alta water year snow total (cm) John Horel 12/30/2018')
xlabel('Year')
ylabel('Snow total (cm)')
grid

%then be sure to publish as a pdf and upload to canvas