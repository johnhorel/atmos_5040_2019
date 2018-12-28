function smooth = median_smooth(input,n,ns,p);
%input array of length n
%ns is the number of elements in smoother. must be odd
%p is the number of passes of the smoother
%better to smooth with small ns and more p's than large ns and 1-2 p's
%smooth is the output array
%first and last elements are set to the original values on each pass
tmp = input;
for j=1:p
half = (ns - 1)/2;
smooth(1:half)=tmp(1:half);
smooth(n-half+1:n)=tmp(n-half+1:n);
for i=half+1:n-half
values=tmp(i-half:i+half);
smooth(i)=median(values);
end
tmp=smooth;
end
return;
