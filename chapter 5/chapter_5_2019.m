clear all
close all
disp(' ')
disp(' ')
disp(' John Horel')
disp(' ATMOS 5040/ Spring 2019')
disp(' Chapter 5')
disp(' Reproducing results in notes')
disp('Requires MEI_1951_2018.txt')
disp('Requires PNA_1951_2018.txt')

% read MEI index
load ../data/MEI_1951_2018.txt;

% read PNA index
load ../data/PNA_1951_2018.txt;

% read through data and create time and array with both indices
% but only use the january values
time = MEI_1951_2018(:,1);
val(:,1) = MEI_1951_2018(:,2);
val(:,2) = PNA_1951_2018(:,2);

% create std anom of indices
val(:,1)= (val(:,1)-mean(val(:,1)))/std(val(:,1),1);
val(:,2)= (val(:,2)-mean(val(:,2)))/std(val(:,2),1);
figure(1)
plot(time,val(:,1),'r')
hold on;
axis([1950 2021 -3 3]);
xlabel('Time');
ylabel('MEI-r PNA-b');
title('MEI and PNA Indices: John Horel 2/9/19');
hold on
plot(time,val(:,2),'b')

%compute anova table
r = corrcoef(val);
r2 = r(1,2)^2;
n = length(val(:,1));
SST = n;
SSR = n * r2;
SSE = n * (1-r2);
MST = n/(n-1);
MSR = n *r2;
MSE = n * (1-r2)/(n-2);
F = (n-2)*r2/(1-r2);

f01 = finv(.99,1,n)
f05 = finv(.95,1,n)
f01_50 = finv(.99,1,34)

%bootstrapping requires statistics toolbox
figure(2)
rhos10000 = bootstrp(10000,'corrcoef',val(:,1),val(:,2));
hist(rhos10000(:,2),30)
xlabel('Correlations');
ylabel('# of Occurences');
title('Bootstrapping MEI and PNA Correlation : John Horel 2/9/2019');
mean_rhos = mean(rhos10000(:,2));
std_rhos = std(rhos10000(:,2),1);

figure(3)

%cross validation
for i=1:n
    %define temporary vectors
    soit = val(:,1);
    pnat = val(:,2);
    %eliminate ith data point
    soit(i) = [];
    pnat(i) = [];
    %compute regression line from the n-1 data points
    regress(i,:) = polyfit(soit,pnat,1);
    %store the regression value that would be estimated at the ith
    %point from the other ic-1 points
    reg(i) = polyval(regress(i,:),val(i,1));
end
% variance explained by the regression
regvar = var(reg,1);
% compute our estimate for each time by adding some
% random numbers with a certain amount of unexplained variance
est = reg + (1-regvar)*randn(1,n);
scatter(val(:,2),est','b+')
xlabel('Observed PNA');
ylabel('Estimated PNA from MEI');
title('Cross Validation of MEI/PNA: John Horel 2/8/2019');
% compute errors of the estimate
err = val(:,2) - est';
bias = mean(err);
rmse = std(err,1);


    

