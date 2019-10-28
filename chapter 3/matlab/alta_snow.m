clear all
close all
%http://utahavalanchecenter.org/alta-monthly-snowfall
a = csvread('../data/alta_snow.csv');
yr = a(:,1);
b = a(:,2:7) * 2.54;
tot = a(:,8)*2.54;
ny = length(tot);
%bp has the rows and columns flipped
% rows are now all the years
% columns are the months and year total
bp = b';
%create accumulations for each month of each year
%handle the november totals
bc(1,:)=bp(1,:);
bc_max(1) = max(bc(1,1:ny-1));
bc_min(1) = min(bc(1,1:ny-1));
bc_med(1) = median(bc(1,1:ny-1));

%loop over all the other months in a season
for i=1:5
  %compute the cumulative totals each month
  bc(i+1,:)=bc(i,:)+bp(i+1,:);
  bc_max(i+1) = max(bc(i+1,1:ny-1));
  bc_min(i+1) = min(bc(i+1,1:ny-1));
  bc_med(i+1) = median(bc(i+1,1:ny-1));
  %compute the increments for each month
  d_max(i+1) = max(bc(i+1,1:ny-1)-bc(i,1:ny-1));
  d_med(i+1) = median(bc(i+1,1:ny-1)-bc(i,1:ny-1));
  d_min(i+1) = min(bc(i+1,1:ny-1)-bc(i,1:ny-1));
end
figure(1)
bar(yr,tot)
axis([yr(1) yr(length(yr)) 400 2000])
xlabel('year')
ylabel('Alta seasonal snowfall total (cm)')

%plot the monthly totals separately for each season
figure2 = figure
axes1 = axes('Parent',figure2,...
    'XTickLabel',{'Dec1','Jan1','Feb1','Mar1','Apr1','May1'},...
    'XTick',[1 2 3 4 5 6],'FontSize',14);
box(axes1,'on');
hold(axes1,'all');
ylabel('Alta snowfall Accumulation (cm)','FontSize',14);
plot(bc,'Parent',axes1)
hold on
plot(bc(:,length(yr)),'k','LineWidth',4,'Parent',axes1);

%plot what might happen if highest, typical, and lowest snowfall took place
figure3 = figure
axes3 = axes('Parent',figure3,...
    'XTickLabel',{'Dec1','Jan1','Feb1','Mar1','Apr1','May1'},...
    'XTick',[1 2 3 4 5 6],'FontSize',14);
box(axes3,'on');
hold(axes3,'all');
ylabel('Alta snowfall Accumulation (cm)','FontSize',14);
%max  each month
plot(bc_max,'r','Linewidth',2,'Parent',axes3)
hold on
%median  each month
plot(bc_med,'g','LineWidth',2,'Parent',axes3);
%smallest each month
plot(bc_min,'b','LineWidth',2,'Parent',axes3);
%2018-19 season
plot(bc(:,length(yr)),'k','LineWidth',4,'Parent',axes3);

%what might happen
yr_med = median(tot)
%start from feb1 values
feb1 = bc(3,:);
feb1_med = feb1;
%get the difference observed between the end of the season and feb1
mymfb = tot - feb1';

%find the years that have  similar total up to feb 1 compared to this one within 50 cm
syr = find(abs(feb1(ny)-feb1(1:ny-1))<50);
%get their median values
syr_feb1_med = median(feb1(syr));
%get the median values of the differences til the end of the season
syr_mymfb = median(mymfb(syr));
syr_yr = yr(syr);

syr1 = ones(1,length(syr));
sc(1:3,:) = bc(1:3,ny)*syr1;
e_max(1:3,1)=bc(1:3,ny);
e_med(1:3,1)=bc(1:3,ny);
e_min(1:3,1)=bc(1:3,ny);
for i=3:5
    %forecast how similar years have evolved that had similar amounts on
    %feb1
  sc(i+1,:)=sc(i,:)+bp(i+1,syr);
  %forecast how the rest of the year would go if the max, med, and min
  %happened each month
  e_max(i+1)=e_max(i)+d_max(i+1);
  e_med(i+1)=e_med(i)+d_med(i+1);
  e_min(i+1)=e_min(i)+d_min(i+1);
end
%forecasts based on similar years
plot(sc,'m--','LineWidth',2,'Parent',axes3)
%forecasts based on max, median, and min accumulations
plot(e_max,'r--','LineWidth',2,'Parent',axes3)
plot(e_med,'g--','LineWidth',2,'Parent',axes3)
plot(e_min,'b--','LineWidth',2,'Parent',axes3)

%keep track of when the snowfall amount is below, near, and above normal
nym = ny-1;
bct(:,:) = bc(:,1:nym)';
%define thresholds of 33 and 66% for each month
pc = prctile(bct,[33.333,66.666]);

ct = zeros(4,4,6);
%count how many times specific amounts happen relative to threshold
for i=1:5
    %this first is the joint prob that a month is below normal and the
    %season total is below normal, etc. for the rest
   ct(1,1,i) = length(find(bct(:,i)<pc(1,i)...
       &bct(:,6)<pc(1,6)));
   ct(1,2,i) = length(find(bct(:,i)>=pc(1,i)&bct(:,i)<pc(2,i)...
       &bct(:,6)<pc(1,6)));
   ct(1,3,i) = length(find(bct(:,i)>=pc(2,i)...
       &bct(:,6)<pc(1,6)));
   ct(2,1,i) = length(find(bct(:,i)<pc(1,i)...
       &bct(:,6)>=pc(1,6)&bct(:,6)<pc(2,6)));
   ct(2,2,i) = length(find(bct(:,i)>=pc(1,i)&bct(:,i)<pc(2,i)...
       &bct(:,6)>=pc(1,6)&bct(:,6)<pc(2,6)));
   ct(2,3,i) = length(find(bct(:,i)>=pc(2,i)...
       &bct(:,6)>=pc(1,6)&bct(:,6)<pc(2,6)));
   ct(3,1,i) = length(find(bct(:,i)<pc(1,i)...
       &bct(:,6)>=pc(2,6)));
   ct(3,2,i) = length(find(bct(:,i)>=pc(1,i)&bct(:,i)<pc(2,i)...
       &bct(:,6)>=pc(2,6)));
   ct(3,3,i) = length(find(bct(:,i)>=pc(2,i)...
       &bct(:,6)>=pc(2,6)));
   for j=1:3
       ct(j,4,i)= sum(ct(j,1:3,i));
       ct(4,j,i)= sum(ct(1:3,j,i));
   end
   ct(4,4,i)=sum(ct(4,1:3,i));
end

%find the years when the snow totals are in the three categories
   cb = find(bct(1:nym-1,6)<pc(1,6));
   cn = find(bct(1:nym-1,6)>=pc(1,6)&bct(1:nym-1,6)<pc(2,6));
   ca = find(bct(1:nym-1,6)>=pc(2,6));
   ct(1,1,6) = length(find(bct(cb+1,6)<pc(1,6)));   
   ct(1,2,6) = length(find(bct(cn+1,6)<pc(1,6)));
   ct(1,3,6) = length(find(bct(ca+1,6)<pc(1,6)));
   ct(2,1,6) = length(find(bct(cb+1,6)>=pc(1,6)&bct(cb+1,6)<pc(2,6)));
   ct(2,2,6) = length(find(bct(cn+1,6)>=pc(1,6)&bct(cn+1,6)<pc(2,6)));
   ct(2,3,6) = length(find(bct(ca+1,6)>=pc(1,6)&bct(ca+1,6)<pc(2,6)));
   ct(3,1,6) = length(find(bct(cb+1,6)>=pc(2,6)));   
   ct(3,2,6) = length(find(bct(cn+1,6)>=pc(2,6)));
   ct(3,3,6) = length(find(bct(ca+1,6)>=pc(2,6)));
   %accumulate them into separate tables for each case
   for j=1:3
       ct(j,4,6)= sum(ct(j,1:3,6));
       ct(4,j,6)= sum(ct(1:3,j,6));
   end
   %sum of the marginal totals over all the years
   ct(4,4,6)=sum(ct(4,1:3,6));