%modified from Ph MSC César Manuel Díez Chirinos
%nomencalture consistent with wilks which is reversed for matlab
function [alpha beta] = weibullparam(x)

xx = sort(log(x));
lth = length(xx);
id = 1:lth;
%this is called the median estimate of the CDF
rm = (id-0.3)/(lth+0.4);
lnrm = log(log((1)./(1-rm)));
%basically fitting a regression line 
bro = robustfit(xx,lnrm);
alpha = bro(2,:);
beta = exp(-(bro(1,:)/alpha));
