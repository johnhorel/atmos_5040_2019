close all
clear all
% compute wins and losses from superbowl bets
%possible wagers
poss(1,:)=[145,125,0];
poss(2,:)=[105,115,0];
poss(3,:)=[105,105,0];
poss(4,:)=[105,140,0];
poss(5,:)=[155,220,0];
poss(6,:)=[200,105,0];
poss(7,:)=[130,110,0];
poss(8,:)=[150,170,0];
poss(9,:)=[150,130,0];
poss(10,:)=[120,110,0];
%winning bets 100, losing bets -100; 0- no bet
% ne wins
win(1,:)= [100,-100,0];
%pts under
win(2,:)= [-100,100,0];
%tails
win(3,:)= [-100,100,0];
%roof closed
win(4,:)= [-100,100,0];
%levine no hat
win(5,:)= [-100,100,0];
%bud light
win(6,:)= [-100,100,0];
%first score. ne 
win(7,:)= [100,-100,0];
%brady inter yes
win(8,:)= [100,-100,0];
%fg both
win(9,:)= [100,-100,0];
%dump fluid
win(10,:)= [100,-100,0];

bid = fopen('../data/superbowl_bets_2019.csv');
bets_in = textscan(bid,...
    '%s %d %d %d %d %d %d %d %d %d %d','Delimiter',',');
names = char(bets_in{1});
no_bets = size(names,1);

%cycle over the 10 bets
pay = zeros(10,no_bets);
loss = zeros(10,no_bets);
fees = zeros(no_bets);
for w = 1:10
    bets(w,:) = bets_in{w+1};
    wagers(w,:)= sign(win(w,bets(w,:))).*poss(w,bets(w,:));
    %cycle thru everyone
    for n=1:no_bets
        %if you have a winning bet, you get your money back
        if(win(w,bets(w,n))>=100)
            %winning bet
            pay(w,n)=win(w,bets(w,n));
            fees(n)=fees(n)+5;
        elseif(win(w,bets(w,n))<=-100)
            %losing bet
            loss(w,n)=poss(w,bets(w,n));
            fees(n)=fees(n)+5;
        end
    end
end
for n = 1:no_bets
    %total wagers
    total_bets(n)= sum(abs(wagers(:,n)));
    % limit to max of 500
    if(total_bets(n)>500)
        net(n) = 450;
        prof(n) = 50;
    else
    %money left for bettors 
    net(n) = 500 - fees(n) - sum(loss(:,n)) + sum(pay(:,n));
    %net for bookie
    prof(n) = 500 - net(n);
    end
end

figure(1)
x = 0:50:600;
hist(total_bets,x)
title('Total Amount Wagered')
xlabel('$');
ylabel('Count')
axis('tight')
figure(2)
x = -500:100:1500;
hist(net,x)
title('Bettors Money Left')
xlabel('$');
ylabel('Count')
axis('tight')
figure(3)
x = -1000:100:3000;
hist(prof,x)
title('Bookies Profit')
xlabel('$');
ylabel('Count')
axis('tight')
figure(4)
bar(net)
set(gca,'Xtick',1:1:no_bets);
set(gca,'XTickLabel',names(1:1:no_bets,:))

titles=['WIN ';'PTS ';'COIN';'ROOF';'HAT ';...
    'BEER';'FSCO';'INT ';'FGS ';'DUMP']
%loop over bets
for w=1:10
    %loop over type of bets
    for cat=1:3
         no_win(cat)=0;
        if(isempty(find(bets(w,:)==cat)))
            no_cat(cat) = 0;
        else
            val = find(bets(w,:)==cat);
            no_cat(cat) = length(val);
            if(win(w,cat)>=100)
                no_win(cat)=no_cat(cat);
            end
        end
    end
    figure(w+10)
    x=1:3;
    %red are losing bets
    bar(x,no_cat,'r')
    hold on
    %blue are winning bets
    bar(x,no_win,'b')
    title(titles(w,:))
    xlabel('Bet Type');
    ylabel('Count')
    axis([1 3 0 no_bets]);
end
%summary stats
class_med = median(net)
class_mean = mean(net)
class_prof = sum(prof)
valn=find(net>500);
%number of bets with net winning
total_net_pos=length(valn);


% now repeat for 10,000 random bettors
no_bets_r = 10000;
%cycle over the 10 bets
payr = zeros(10,no_bets_r);
lossr = zeros(10,no_bets_r);
feesr = zeros(no_bets_r);

for w = 1:10
    r = randi([1 3],1,no_bets_r);
    betsr(w,:) = r;
    wagersr(w,:)= sign(win(w,betsr(w,:))).*poss(w,betsr(w,:));
    for n=1:no_bets_r
        if(win(w,betsr(w,n))>=100)
            %winning bet
            payr(w,n)=win(w,betsr(w,n));
            feesr(n)=feesr(n)+5;
        elseif(win(w,betsr(w,n))<=-100)
            %losing bet
            lossr(w,n)=poss(w,betsr(w,n));
            feesr(n)=feesr(n)+5;
        end
    
    end
end

for n = 1:no_bets_r
    total_betsr(n)= sum(abs(wagersr(:,n)));
        netr(n) = 500 - feesr(n) - sum(lossr(:,n)) + sum(payr(:,n));
        profr(n) = 500 - netr(n);
end


figure(101)
x = 0:100:2500;
hist(total_betsr,x)
title('Total Amount Wagered')
xlabel('$');
ylabel('Count')
axis('tight')
figure(102)
x = -1000:100:3000;
hist(netr,x)
title('Bettors Final')
xlabel('$');
ylabel('Count')
axis('tight')
figure(103)
x = -2000:100:3000;
hist(profr,x)
title('Profit')
xlabel('$');
ylabel('Count')
axis('tight')

for w=1:10
    for cat=1:3
        no_winr(cat)=0;
        if(isempty(find(betsr(w,:)==cat)))
            no_cat(cat) = 0;
        else
            val = find(betsr(w,:)==cat);
            no_cat(cat) = length(val);
            if(win(w,cat)>=100)
                no_winr(cat)=no_cat(cat);
            end
        end
    end
    figure(w+110)
    x=1:3;
    bar(x,no_cat,'r')
    hold on
    bar(x,no_winr,'b')

    title(titles(w,:));
    xlabel('Bet Type');
    ylabel('Count')
    axis([1 3 0 no_bets_r]);
    
end
ran_mean= mean(netr)
ran_med= median(netr)
ran_prof = sum(profr)/no_bets_r
valnr=find(netr>500);
%fraction of bets with net winning
total_net_pos_r=length(valnr)/no_bets_r;

