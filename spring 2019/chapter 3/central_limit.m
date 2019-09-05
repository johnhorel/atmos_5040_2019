close all
clear all
display('john horel 2019')
display('demonstrate central limit theorem')
display(' ')
sides = input('enter the number of sides on the die (6 or 10 or...): ')
dice = input('enter the sample size (number of dice to roll at the same time): ')
rolls = input('enter the number of rolls: ')
%get random numbers between 0 and 1 
rd = rand(rolls,dice);
%compute probability that any one number comes up
%convert 0 - 1/sides = 1; 1/sides - 2/sides = 2, etc.
rdd = ceil(sides*rd);
%define the population as all the possible rolls
pop = rdd(:);
%compute the sum and mean of the sample
if(dice>1)
ss = sum(rdd,2);
sm = mean(rdd,2);
else
ss = rdd;
sm = rdd;
end

mean_sum = mean(ss);
mean_mean = mean(sm);

%now plot
figure(1)
%plot population
subplot(3,1,1)
bar(pop)
axis('tight')
title('Population: each die is rolled independently')
subplot(3,1,2)
%plot sample sum
histogram(ss,'BinMethod','integer')
axis('tight')
title('Sample sum')
subplot(3,1,3)
%plot sample mean
vals = 1-.5*1/dice:1/dice:sides+.5*1/dice;
histogram(sm,'BinEdges',vals)
axis('tight')
title('Sample mean')

%compute the std of the sample means 
sstd = std(sm,0);
%compute std of population
pstd = std(pop,0);
%does the central limit theorem work? is the following close to sstd?
check = pstd/sqrt(dice);
