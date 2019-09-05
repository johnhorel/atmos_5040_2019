close all
clear all
display('rolling a six on a single die simulation')
display('john horel 2/2/2019')
% determining as the sample size of rolling a die increases from 1 to 20000
% times how many sixes are rolled in that sample
% rand returns equally distributed random values between 0 and 1
% a six on a six sided die would be those values greater than or equal to 1 -1/6
expected =  1 - 1/6;

for i=1:20000
    %get random numbers between 0 and 1
    %when i = 1, then r will just be a single number
    %when i=20,000, then r will be 20000 values
    r = rand(i,1);
    %find when it is a six within the 20000 rolls
    six = find(r >= expected);
    % now based on how many rolls have been made, what is the empirical
    % probability for each of the 20000 rolls 
    %initially those probabilities can vary quite a bit but as the number
    %of rolls increases, then the probability should converge to 1/6
    %the following statement is just so there is a probability for the first one
    %if a six isn't rolled
    prob(i,1)=0;
    if (six)
        no = length(six);
        prob(i,1)=no/i;
    end
end
% define the tolerance in order to be close to the expected probability 1/6
tol = .01;
%find all the cases when the empirical probability is outside the tolerance
large_diff = find (abs (prob - 1/6) > tol);
%find the last one that is outside the tolerance
%after this roll, then all of the additional rolls are really close to the
%expected probability, so we are converging to an infinite number of rolls
last = large_diff(length(large_diff))

plot(100*prob)
    