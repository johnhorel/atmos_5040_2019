%This function makes a normalized histogram, i.e. the area of the histogram is
%equal to one.
%
%INPUT:
%data - empirical data
%x - centers of bins

%OUTPUTs:
%h - the normalized "height" of the histogram bars

function h =histnorm(data, x)
    
    h = hist(data,x);
    step = abs(x(2) - x(1));
    area = sum(step*h);
    h = h/area;
  
     