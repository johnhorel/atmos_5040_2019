%This function makes a cumulative distribution
%
%INPUT:
%data - empirical data
%x - centers of bins

%OUTPUTs:
%hy - the accumulated fraction below the beginning of each bin 
% y - values from the beginning of the lowest bin to the end of the highest bin 

function [hy y] =cdfnorm(data, x)
    
    h = hist(data,x);
    step = abs(x(2) - x(1));
    y = x(1)-step/2:step:x(length(x))+step/2;
    area = sum(step*h);
    h = h/area;
    hy(1) = 0;
    for i=2:length(y)
        hy(i)=hy(i-1)+step*h(i-1);
    end
    
     