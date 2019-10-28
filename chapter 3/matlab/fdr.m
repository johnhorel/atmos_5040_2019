clear all
close all
%false discovery rate as discussed by Wilks (2016, BAMS)

%alpha = input('enter p value to reject null hypothesis:')
%n = input('enter the fake sample size of times used to compute the map: ')

%hardwire to the following
alpha = .05;
n = 30;

x = -50:1:50;
y = -50:1:50;
[locX,locY] = meshgrid(x,y);
%compute a hypothetical teleconnection map
sigma = 30;
amp = exp(-(locX.^2 + locY.^2)./(2*sigma^2));
r = amp.*cosd(180*locX/30).*cosd(180*locY/30);
%plot the correlations
figure(1)
contourf(locX,locY,r,-.9:.1:.9)
colorbar;
title('correlations')

%compute the f test for the correlations
r2 = r.^2;
inl = find(r2<.001);
r2(inl) = .001;
inh = find(r2>.999);
r2(inh) = .999;
%plot the f values for the anova test
figure(2)
f = ((n-2)*r2)./(1-r2);
contourf(locX,locY,f,1:10)
colorbar;
title('f values for correlations')
%define the threshold for the f distribution for alpha level
f_null = finv(1-alpha,1,n);
%determine the p values for each correlation's f value
p = 1-fcdf(f,1,n);
figure(3)
contourf(locX,locY,p,.01:.01:.15);
colorbar;
title('p values for rejecting the null hypothesis')

%find the locations where the null hypothesis 
%could be rejected locally
rej_null = find(p<alpha);
no_rej_null = length(rej_null);
%sort from smallest to largest the p values that
%would suggest the null hypothesis could be rejected
%locally
[rej_null_sort, rej_null_ind] = sort(p(rej_null));
[rn_x,rn_y] = ind2sub([101,101],rej_null(rej_null_ind)); 
p_local_rej = ones(101,101);
p_fdr_rej = ones(101,101);
no_grid_points = 101*101;
n_fdr = 0;
%loop over all the cases where it the null hypothesis
%is assumed could be rejected locally
for i = 1:no_rej_null
    pi = p(rej_null(rej_null_ind(i)));
    p_local_rej(rn_x(i),rn_y(i))= pi;
    % compute fdr threshold
    fdr_thres = 2*alpha*i/no_grid_points;
    %find local p values that are less than fdr threshold
    if(pi<fdr_thres)
        p_fdr_rej(rn_x(i),rn_y(i)) = pi;
        n_fdr = n_fdr+1;
    end 
end
%plot locations where the null hypothesis would be rejected locally
figure(4)
contourf(locX,locY,p_local_rej,.01:.01:.05);
colorbar;
title('non-yellow area where null hypothesis rejected locally')

%plot locations where the null hypothesis would be rejected on the basis of
%the fdr

figure(5)
contourf(locX,locY,p_fdr_rej,.005:.005:.05);
colorbar;
title('non-yellow area where null hypothesis rejected by fdr')


