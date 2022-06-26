% This file is used to Plot the figure 2
% Author: Lei Zhang
% Last modified: 01-10-2021
clearvars;
close all;
clc;
%% read the table
tableSD = readtable('State-Data-wave1.csv');
location = tableSD.location;
population = tableSD.population;
medianAge  = tableSD.medianAge;
bed = tableSD.bed;
maxQuarantined = tableSD.maxQuarantined_wave;
S0  = tableSD.s0;
tau = tableSD.tau;

bed_occupancy = maxQuarantined./(bed.* population./1000);

%% Class the location into three pattern.
num_cluster1 = 0;
num_cluster2 = 0;
num_cluster3 = 0;
S0_mean = mean(S0);

for i=1:length(S0)
    if S0(i) >= S0_mean
        num_cluster3 = num_cluster3 + 1;
        index_3(num_cluster3) = i;
        num_cluster(i) = 3;
    elseif medianAge(i) <38
        num_cluster1 = num_cluster1 + 1;
        index_1(num_cluster1) = i;
        num_cluster(i) = 1;
    else
        num_cluster2 = num_cluster2 + 1;
        index_2(num_cluster2) = i;
        num_cluster(i) = 2;
    end
end

% countries with median age over 38
flag_38more    = medianAge>38;
S0_38more         = S0(flag_38more);
bed_atPeak_38more = bed_occupancy(flag_38more);
location_38more = location(flag_38more);


medianAge_38less  = medianAge(index_1);
S0_38less  = S0(index_1);
S0_38more_bedpeak15less  = S0(index_2);
S0_38more_bedpeak15more  = S0(index_3);
S0_38more_bedpeak15more_noBelgium = S0_38more_bedpeak15more(S0_38more_bedpeak15more<70);
S0_Belgium = S0_38more_bedpeak15more(S0_38more_bedpeak15more>70);


medianAge_fit = [medianAge_38less;medianAge(index_3)];
S0_fit = [S0_38less;S0_38more_bedpeak15more];

bed_atPeak_38less = bed_occupancy(index_1);
bed_atPeak_38more_15less = bed_occupancy(index_2);
bed_atPeak_38more_15more = bed_occupancy(index_3);
bed_atPeak_38more_15more_noBelgium = bed_atPeak_38more_15more(S0_38more_bedpeak15more<70);
bed_Belgium = bed_atPeak_38more_15more(S0_38more_bedpeak15more>70);


% the quantile value of three patterns
S0_3_25 = quantile(S0_38less,0.25);
S0_3_75 = quantile(S0_38less,0.75);
bed_atPeak_38less_25 = quantile(bed_atPeak_38less,0.25);
bed_atPeak_38less_75 = quantile(bed_atPeak_38less,0.75);

S0_2_25 = quantile(S0_38more_bedpeak15less,0.25);
S0_2_75 = quantile(S0_38more_bedpeak15less,0.75);
bed_atPeak_38more2_25 = quantile(bed_atPeak_38more_15less,0.25);
bed_atPeak_38more2_75 = quantile(bed_atPeak_38more_15less,0.75);

S0_1_25 = quantile(S0_38more_bedpeak15more,0.25);
S0_1_75 = quantile(S0_38more_bedpeak15more,0.75);
bed_atPeak_38more1_25 = quantile(bed_atPeak_38more_15more,0.25);
bed_atPeak_38more1_75 = quantile(bed_atPeak_38more_15more,0.75);


%% Fit the age and S0 
[para_AgeS0_firstwave,RSD_AgeS0_firstwave] = Fit_age(medianAge_fit,S0_fit);
para_AgeS0_firstwave_a  = para_AgeS0_firstwave.a;
para_AgeS0_firstwave_b  = para_AgeS0_firstwave.b;
medianAge_firstwave_pre = 15:0.1:50;
AgeS0_firstwave_pre  = para_AgeS0_firstwave_a .* medianAge_firstwave_pre .^ para_AgeS0_firstwave_b;



% Confidence and Prediction Bounds (95%)
para_AgeS0_firstwave_cb = confint(para_AgeS0_firstwave);
para_AgeS0_firstwave_a_lb = para_AgeS0_firstwave_cb(1,1);
para_AgeS0_firstwave_a_ub = para_AgeS0_firstwave_cb(2,1);
para_AgeS0_firstwave_b_lb = para_AgeS0_firstwave_cb(1,2);
para_AgeS0_firstwave_b_ub = para_AgeS0_firstwave_cb(2,2);

AgeS0_firstwave_cb = predint(para_AgeS0_firstwave,medianAge_firstwave_pre,0.95);
AgeS0_firstwave_cb(1:236,1) = 0.001;
AA_AgeS0_firstwave = [medianAge_firstwave_pre(1:end),medianAge_firstwave_pre(length(medianAge_firstwave_pre):-1:1)];
BB_AgeS0_firstwave = [AgeS0_firstwave_cb(1:end,2);AgeS0_firstwave_cb(length(AgeS0_firstwave_cb):-1:1,1)];


% caculate the R2
S0_AgeS0_pre = para_AgeS0_firstwave_a .* medianAge_fit .^ para_AgeS0_firstwave_b;

SSR1 = sum((S0_AgeS0_pre - mean(S0_fit)).^2);
SST1 = sum((S0_fit - mean(S0_fit)).^2);
SSE1 = sum((S0_fit - S0_AgeS0_pre).^2);

R2_fitage1 = SSR1/SST1;

% caculate the pearson correlation coefficient
r_age = corr(medianAge_fit,S0_fit,'type','pearson');




%% Fit the bed_occupancy and S0 (median age > 38)
% fit ( no Belgium)
iflag_noBelgium = S0_38more<70;



bed_atPeak_38more2 = bed_atPeak_38more(iflag_noBelgium);
S0_38more2 = S0_38more(iflag_noBelgium);
location_38more2 = location_38more(iflag_noBelgium);
% location_NoRecoverData ={'United Kingdom','Norway','Italy','Netherlands'};
location_NoRecoverData ={''};
iflag_NoRecoverData = ismember(location_38more2,location_NoRecoverData);

bed_atPeak_38more3 = bed_atPeak_38more2(~iflag_NoRecoverData);
S0_38more3 = S0_38more2(~iflag_NoRecoverData);
location_38more3 = location_38more2(~iflag_NoRecoverData);

[para_BedS0_38more,RSD_atPeak_38more] = Fit_bed(bed_atPeak_38more3,S0_38more3);
para_BedS0_38more_a   = para_BedS0_38more.a;
para_BedS0_38more_b   = para_BedS0_38more.b;
bed_atPeak_38more_pre = 0.005:0.01:10;
S0_BedS0_38more_pre   = para_BedS0_38more_a .* bed_atPeak_38more_pre .^ para_BedS0_38more_b;


r_bed = corr(bed_atPeak_38more3,S0_38more3,'type','pearson');


% Confidence and Prediction Bounds (95%)
para_BedS0_38more_cb   = confint(para_BedS0_38more);
para_BedS0_38more_a_lb = para_BedS0_38more_cb(1,1);
para_BedS0_38more_a_ub = para_BedS0_38more_cb(2,1);
para_BedS0_38more_b_lb = para_BedS0_38more_cb(1,2);
para_BedS0_38more_b_ub = para_BedS0_38more_cb(2,2);

S0_BedS0_38more_cb = predint(para_BedS0_38more,bed_atPeak_38more_pre,0.95);
S0_BedS0_38more_cb(1:36,1)= 0.0001;
AA_BedS0_38more = [bed_atPeak_38more_pre(1:end),bed_atPeak_38more_pre(length(bed_atPeak_38more_pre):-1:1)];
BB_BedS0_38more = [S0_BedS0_38more_cb(1:end,2);S0_BedS0_38more_cb(length(S0_BedS0_38more_cb):-1:1,1)];




% caculate the R2
S0_BedS0_38more_pre3 = para_BedS0_38more_a .* bed_atPeak_38more3 .^ para_BedS0_38more_b;

SSR2 = sum((S0_BedS0_38more_pre3 - mean(S0_38more3)).^2);
SST2 = sum((S0_38more3 - mean(S0_38more3)).^2);
SSE2 = sum((S0_38more3 - S0_BedS0_38more_pre3).^2);

R2_fitbed2 = SSR2/SST2;

%% Change the bed numbers
% Wuhan
[tau_Wuhan,S0_Wuhan,bed_Wuhan,population_Wuhan,maxQuarantined_Wuhan]...
    = para_location(tableSD,'Wuhan');
S0_BedS0_Wuhan = S0_Bedchange(bed_Wuhan,maxQuarantined_Wuhan,population_Wuhan,para_BedS0_38more_a,para_BedS0_38more_b);
% Canada
[tau_CAN,S0_CAN,bed_CAN,population_CAN,maxQuarantined_CAN,death_CAN]...
    = para_location(tableSD,'Canada');
S0_BedS0_CAN = S0_Bedchange(bed_CAN,maxQuarantined_CAN,population_CAN,para_BedS0_38more_a,para_BedS0_38more_b);
% Italy
[tau_Italy,S0_Italy,bed_Italy,population_Italy,maxQuarantined_Italy,death_Italy]...
    = para_location(tableSD,'Italy');
S0_BedS0_Italy = S0_Bedchange(bed_Italy,maxQuarantined_Italy,population_Italy,para_BedS0_38more_a,para_BedS0_38more_b);


% Deaths can be avoided by increasing 1 time of beds
S0_BedS0_Wuhan0  = S0_BedS0_Wuhan(1);
S0_BedS0_Wuhan1  = S0_BedS0_Wuhan(11);
ratio_AddBed_onetime  = (1-S0_BedS0_Wuhan1/S0_BedS0_Wuhan0);

% Deaths can be avoided in Canada
death_avoid_CAN = death_CAN * roundn(ratio_AddBed_onetime,-1);

% Deaths can be avoided in Italy
death_avoid_Italy = death_Italy * roundn(ratio_AddBed_onetime,-1);


%% Deaths can be avoided by increasing beds in Wuhan

bed_Wuhan_BeforeOutbreak = bed_Wuhan * population_Wuhan/1000;
bedOcuupancy_Wuhan_BeforeOutbreak = maxQuarantined_Wuhan/bed_Wuhan_BeforeOutbreak;
S0_Wuhan_bedBeforeOutbreak = para_BedS0_38more_a*(bedOcuupancy_Wuhan_BeforeOutbreak)^para_BedS0_38more_b;

bedOcuupancy_Wuhan_AfterOutbreak = (S0_Wuhan/para_BedS0_38more_a)^(1/para_BedS0_38more_b);
bed_Wuhan_AfterOutbreak = maxQuarantined_Wuhan/bedOcuupancy_Wuhan_AfterOutbreak;

bed_add_Wuhan  = bed_Wuhan_AfterOutbreak - bed_Wuhan_BeforeOutbreak;
ratio_AddBed_Wuhan = bed_add_Wuhan/bed_Wuhan_BeforeOutbreak;

% Decrease in mortality explained by actual increased beds 15000

bed_Wuhan_actualAdd = bed_Wuhan_BeforeOutbreak + 15000;
bedOcuupancy_Wuhan_actualAdd = maxQuarantined_Wuhan/bed_Wuhan_actualAdd;
S0_Wuhan_bedactualAdd = para_BedS0_38more_a*(bedOcuupancy_Wuhan_actualAdd)^para_BedS0_38more_b;


% Deaths can be avoided by actual increased bed capacity
death_Wuhan_bedBeforeOutbreak = S0_Wuhan_bedBeforeOutbreak* population_Wuhan./100000;
death_Wuhan_actual = S0_Wuhan * population_Wuhan./100000;
death_Wuhan_bedactualAdd = S0_Wuhan_bedactualAdd * population_Wuhan./100000;
death_avoid_actual = death_Wuhan_bedBeforeOutbreak-death_Wuhan_actual;
death_avoid_bedactualAdd = death_Wuhan_bedBeforeOutbreak-death_Wuhan_bedactualAdd;
ratio_avoid_bedactualAdd = death_avoid_bedactualAdd/death_avoid_actual;


%% Fit the mortality of Wuhan
[CDR_wh,CDR_pre_wh,CDR_cb_wh,s0_CDR_wh,tau_CDR_wh,tc_CDR_wh,time_pre_wh,t_pre_wh] = ...
    FitMortality('Wuhan');

% The simulation of Wuhan's mortality.
y0    = CDR_pre_wh(1);
tspan = t_pre_wh;

% no fang-cang hospital
[~,S_pre_Wuhan_nofangcang] = ode45(@(t,y) St_evolution(y,tau_Wuhan,S0_BedS0_Wuhan0), tspan, y0);

% with fang-cang hospital
[~,S_pre_Wuhan_fangcang] = ode45(@(t,y) St_evolution(y,tau_Wuhan,S0_Wuhan_bedactualAdd), tspan, y0);

disp(['The average S0 is   ',num2str(mean(S0))]);

disp(['S0 of low-pattern-1:   ',num2str(median(S0_38less)),'(' num2str(S0_3_25),',',num2str(S0_3_75),')']);
disp(['S0 of low-pattern-2:   ',num2str(median(S0_38more_bedpeak15less)),'(' num2str(bed_atPeak_38more2_25),',',num2str(bed_atPeak_38more2_75),')']);
disp(['S0 of high-pattern:   ',num2str(median(S0_38more_bedpeak15more)),'(' num2str(S0_1_25),',',num2str(S0_1_75),')']);

disp(['bed-occupancy of low-pattern-1:   ',num2str(median(bed_atPeak_38less,'omitnan')),'(' num2str(bed_atPeak_38less_25),',',num2str(bed_atPeak_38less_75),')']);
disp(['bed-occupancy of low-pattern-2:   ',num2str(median(bed_atPeak_38more_15less,'omitnan')),'(' num2str(S0_2_25),',',num2str(S0_2_75),')']);
disp(['bed-occupancy of high-pattern:   ',num2str(median(bed_atPeak_38more_15more,'omitnan')),'(' num2str(bed_atPeak_38more1_25),',',num2str(bed_atPeak_38more1_75),')']);

disp(['The parameter a of S0-Age is ',num2str(para_AgeS0_firstwave_a),...
    '(IQR, ',num2str(para_AgeS0_firstwave_a_lb),'，',num2str(para_AgeS0_firstwave_a_ub),')'])
disp(['The parameter b of S0-Age is ',num2str(para_AgeS0_firstwave_b),...
    '(IQR, ',num2str(para_AgeS0_firstwave_b_lb),'，',num2str(para_AgeS0_firstwave_b_ub),')'])

disp(['The parameter a of S0-bed occupancy is ',num2str(para_BedS0_38more_a),...
    '(IQR, ',num2str(para_BedS0_38more_a_lb),'，',num2str(para_BedS0_38more_a_ub),')'])
disp(['The parameter b of S0-bed occupancy  is ',num2str(para_BedS0_38more_b),...
    '(IQR, ',num2str(para_BedS0_38more_b_lb),'，',num2str(para_BedS0_38more_b_ub),')'])

rsquare_AgeS0_firstwave  = RSD_AgeS0_firstwave.rsquare;
rsquare_atPeak_firstwave = RSD_atPeak_38more.rsquare;



%%
disp(['The R^2 of "median age-S0"    is ',num2str(rsquare_AgeS0_firstwave)])
% disp(['The R^2 of "bed occupancy-S0" is ',num2str(rsquare_atPeak_firstwave)])
disp(['The R^2 of "bed occupancy-S0" is ',num2str(R2_fitbed2)])

disp(['Country: ',num2str(ratio_AddBed_onetime*100),...
    ' % deaths can be avoided by increasing 1 time of beds'])

disp(['Canada: ',num2str(death_avoid_CAN),...
    '  deaths can be avoided by increasing 1 time of beds'])
disp(['Italy: ',num2str(death_avoid_Italy),...
    '  deaths can be avoided by increasing 1 time of beds'])
disp(['Wuhan: ','The bed-ocuupancy of Wuhan with the bed number before outbreak is ',...
    num2str(bedOcuupancy_Wuhan_BeforeOutbreak)])
disp(['Wuhan: ','The bed-ocuupancy of Wuhan with the bed number after outbreak is ',...
    num2str(bedOcuupancy_Wuhan_AfterOutbreak)])
disp(['Wuhan: ','The predicted S0 of Wuhan with the bed number before outbreak is ',...
    num2str(S0_Wuhan_bedBeforeOutbreak)])
disp(['Wuhan: ','The S0 of Wuhan with the bed number after outbreak is ' num2str(S0_Wuhan)])
disp(['Wuhan: ','The added bed number is ' num2str(bed_add_Wuhan)])
disp(['Wuhan: ','The S0 of Wuhan with the actual added bed   is ' num2str(S0_Wuhan_bedactualAdd)])
disp(['Wuhan: deaths avoided in actual is ',num2str(death_avoid_actual)])
disp(['Wuhan: deaths avoided by adding 15000 bed is ',num2str(death_avoid_bedactualAdd),'(',num2str(ratio_avoid_bedactualAdd),')'])



%% Plot the result.
% subplot 1

gcf = figure('position',[591,42,955,953]);
t = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
nexttile([1,1])
hold on
plot(medianAge(index_1),S0(index_1),'o',...
    'markerfacecolor',[0.93333	0.41569	0.31373],...
    'markeredgecolor',[0.93333	0.41569	0.31373],...
    'MarkerSize',7,'LineWidth',1);
plot(medianAge(index_2),S0(index_2),'o',...
    'markerfacecolor',[0.55294	0.71373	0.80392],...
    'markeredgecolor',[0.55294	0.71373	0.80392],...
    'MarkerSize',7,'LineWidth',1);
plot(medianAge(index_3),S0(index_3),'o',...
    'markerfacecolor',[0.85882	0.43922	0.57647],...
    'markeredgecolor',[0.85882	0.43922	0.57647],...
    'MarkerSize',7,'LineWidth',1);
plot(medianAge_firstwave_pre,AgeS0_firstwave_pre,'k-','LineWidth',2);

p1  = fill(AA_AgeS0_firstwave,BB_AgeS0_firstwave,'blue');
p1.FaceColor = [0.81176	0.81176	0.81176];
p1.EdgeColor = 'none';
p1.FaceAlpha = 0.8;


plot(medianAge(index_1),S0(index_1),'o',...
    'markerfacecolor',[0.93333	0.41569	0.31373],...
    'markeredgecolor',[0.93333	0.41569	0.31373],...
    'MarkerSize',7,'LineWidth',1);
plot(medianAge(index_2),S0(index_2),'o',...
    'markerfacecolor',[0.55294	0.71373	0.80392],...
    'markeredgecolor',[0.55294	0.71373	0.80392],...
    'MarkerSize',7,'LineWidth',1);
plot(medianAge(index_3),S0(index_3),'o',...
    'markerfacecolor',[0.85882	0.43922	0.57647],...
    'markeredgecolor',[0.85882	0.43922	0.57647],...
    'MarkerSize',7,'LineWidth',1);
plot(medianAge_firstwave_pre,AgeS0_firstwave_pre,'k-','LineWidth',2);


legend({'low pattern-1','low pattern-2','high pattern',...
    ['y = ',sprintf('%0.1ex^{%0.1f}',roundn(para_AgeS0_firstwave_a,-6),...
    para_AgeS0_firstwave_b)],'95% CI'},'location','northwest','FontSize',14,...
    'NumColumns',1)

legend('boxoff')
ylim([0.1,1000])
xlim([15,50])
set(gca,'xscale','log')
set(gca,'yscale','log')
set(gca,'Layer','top');
set(gca,'FontSize',14)

xlabel('Median age','interpreter','latex','FontSize',16)
ylabel('Saturation mortality ($S_0$)','interpreter','latex','FontSize',16)
box on
title(['Countries not in low pattern-2 (N=' num2str(length(S0_fit)) ')'],...
    'interpreter','latex','FontSize',16);


annotation(gcf,'textbox',...
    [0.365 0.895 0.085 0.05],...
    'String',['$R^2$' '=' num2str(roundn(rsquare_AgeS0_firstwave,-2))],...
    'FontSize',14,'interpreter','latex',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.365 0.865 0.095 0.05],...
    'String',['$r$' ' = ' num2str(roundn(r_age,-2))],...
    'FontSize',14,'interpreter','latex',...
    'FitBoxToText','off',...
    'EdgeColor','none');



%% subplot 2
nexttile([1,1])
hold on
plot(bed_occupancy(index_2),S0(index_2),'o',...
    'markeredgecolor',[0.55294	0.71373	0.80392],...
    'markerfacecolor',[0.55294	0.71373	0.80392],...
    'MarkerSize',7,'LineWidth',1);

plot(bed_atPeak_38more_15more_noBelgium,S0_38more_bedpeak15more_noBelgium,'o',...
    'markeredgecolor',[0.85882	0.43922	0.57647],...
    'markerfacecolor',[0.85882	0.43922	0.57647],...
    'MarkerSize',7,'LineWidth',1);

plot(bed_atPeak_38more_pre,S0_BedS0_38more_pre,'k-','LineWidth',2);


p3  = fill(AA_BedS0_38more,BB_BedS0_38more,'blue');
p3.FaceColor = [0.81176	0.81176	0.81176];
p3.EdgeColor = 'none';
p3.FaceAlpha = 0.8;

plot(bed_occupancy(index_2),S0(index_2),'o',...
    'markeredgecolor',[0.55294	0.71373	0.80392],...
    'markerfacecolor',[0.55294	0.71373	0.80392],...
    'MarkerSize',7,'LineWidth',1);

plot(bed_atPeak_38more_15more_noBelgium,S0_38more_bedpeak15more_noBelgium,'o',...
    'markeredgecolor',[0.85882	0.43922	0.57647],...
    'markerfacecolor',[0.85882	0.43922	0.57647],...
    'MarkerSize',7,'LineWidth',1);


plot(bed_atPeak_38more_pre,S0_BedS0_38more_pre,'k-','LineWidth',2);

plot(bed_Belgium,S0_Belgium,'o',...
    'markeredgecolor',[0.85882	0.43922	0.57647],...
    'MarkerSize',7,'LineWidth',1);

text(0.22,90,'Belgium','color',[0.4 0.4 0.4],'FontSize',14)

set(gca,'xscale','log')
set(gca,'yscale','log')
set(gca,'Layer','top');
set(gca,'FontSize',14)

xlabel('Bed occupancy','interpreter','latex','FontSize',16)
ylabel('Saturation mortality ($S_0$)','interpreter','latex','FontSize',16)
legend({'low pattern-2','high pattern',...
      ['y = ',sprintf('%0.1fx^{%0.1f}',para_BedS0_38more_a,para_BedS0_38more_b)],'95% CI'},...
      'location','northwest','FontSize',14)
legend('boxoff')
ylim([0.1,1000])
xlim([0.005,5])
xticks([0.01,0.1,1])
xticklabels({'1%','10%','100%'})
box on
title(['Countries with median age above 38 (N=' num2str(length(S0_38more)-1) ')'],...
    'interpreter','latex','FontSize',16);

annotation(gcf,'textbox',...
    [0.855 0.895 0.085 0.05],...
    'String',['$R^2$' '=' num2str(roundn(R2_fitbed2,-2))],...
    'FontSize',14,'interpreter','latex',...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(gcf,'textbox',...
    [0.855 0.865 0.095 0.05],...
    'String',['$r$' ' = ' num2str(roundn(r_bed,-2))],...
    'FontSize',14,'interpreter','latex',...
    'FitBoxToText','off',...
    'EdgeColor','none');

%% subplot 3
nexttile([1,1])
hold on
plot(0:length(S0_BedS0_Italy(:,1))-1,S0_BedS0_Italy(:,1),'-',...
    'color',[0.21176	0.21176	0.21176],'LineWidth',2)
plot(0:length(S0_BedS0_CAN(:,1))-1,S0_BedS0_CAN(:,1),'-',...
    'color',[0.8500 0.3250 0.0980],'LineWidth',2)

% grid on
% set(gca,'yscale','log')
ylim([0,50])
xlim([0,20])
xticks(0:5:20)
xticklabels({'0','50%','100%','150%','200%'})
set(gca,'FontSize',14)
xlabel('Multiples of increasing beds','interpreter','latex','FontSize',16)
ylabel('Saturation mortality ($S_0$)','interpreter','latex','FontSize',16)
title('Italy and Canada','interpreter','latex','FontSize',16)
legend({'Italy','Canada'},'location','northeast','interpreter','latex',...
    'FontSize',14)
legend('boxoff')
box on



%% subplot 4
nexttile([1,1])
hold on
plot(time_pre_wh(1+30:47+30),CDR_wh(1:47),'o',...%     'markerfacecolor',[0.41176	0.41176	0.41176 ],...
    'markeredgecolor',[0.21176	0.21176	0.21176],...
    'MarkerSize',8,'LineWidth',1);
plot(time_pre_wh(1+30:70+30),S_pre_Wuhan_nofangcang(1+30:70+30),...
    '-','color',[0.93333 0.47451 0.62353],'LineWidth',2)
plot(time_pre_wh(1+30:70+30),S_pre_Wuhan_fangcang(1+30:70+30),...
    '-','color',[0.06275 0.30588 0.5451],'LineWidth',2)

ylabel('Deaths per 100k population','interpreter','latex','FontSize',16)
legend({'reported data','no Fang-Cang','with Fang-Cang'},...
    'location','southeast',...
    'interpreter','latex','FontSize',14)
legend('boxoff')
% grid on
box on
ylim([0,28])


set(gca,'FontSize',14)
% xlabel('Date','FontSize',14)
ylabel('Deaths per 100k population','interpreter','latex','FontSize',16)
title('Wuhan City','interpreter','latex','FontSize',16)

annotation(gcf,'textbox',...
    [0.005 0.95 0.025 0.05],...
    'String','a',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.495 0.95 0.025 0.05],...
    'String','b',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.005 0.44 0.025 0.05],...
    'String','c',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.495 0.44 0.025 0.05],...
    'String','d',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');


function [fitresult, gof] = Fit_age(data_x,data_S0)

[xData, yData] = prepareCurveData(data_x,data_S0);

% Set up fittype and options.
ft = fittype( 'power1'  );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
% opts.Robust = 'LAR';
opts.StartPoint = [47.9730194551921 -0.630239075022815];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

end

function [fitresult, gof] = Fit_bed(data_x,data_S0)

[xData, yData] = prepareCurveData(data_x,data_S0);

% Set up fittype and options.
ft = fittype( 'power1'  );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'LAR';
opts.StartPoint = [47.9730194551921 -0.630239075022815];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

end

% Define the differential equation.
function St = St_evolution(y,Tau,S0)

St = 1/Tau * y * (1-y./S0);

end

function [Tau_location,S0_location,bed_location,population_location,...
    maxQuarantined_location,death_location] = para_location(tableSD,location)

Location   = tableSD.location;
population = tableSD.population;
bed        = tableSD.bed;
maxQuarantined = tableSD.maxQuarantined_wave;
S0         = tableSD.s0;
Tau        = tableSD.tau;
death      = tableSD.deaths_wave;

Tau_location = Tau(strcmp(Location,location));
S0_location  = S0(strcmp(Location,location));
bed_location = bed(strcmp(Location,location));
population_location = population(strcmp(Location,location));
maxQuarantined_location = maxQuarantined(strcmp(Location,location));
death_location = death(strcmp(Location,location));
end

function S0_BedS0_i = S0_Bedchange(bed,maxQuarantined,population,para_BedS0_38more_a,para_BedS0_38more_b)

aa = 0;
for i = 0:0.1:10 % change bed numbers
    aa = aa + 1;
    bb = 0;
    for j = 1:-0.1:0.1 % change hospitalized cases
        bb = bb + 1;
        bed_i(aa,bb)  = bed * (1+i);
        maxQuarantined_j(aa,bb) = maxQuarantined * j;
        bed_atPeak_i(aa,bb) = maxQuarantined_j(aa,bb)./(bed_i(aa,bb).* population./1000);
        S0_BedS0_i(aa,bb)   = para_BedS0_38more_a .* bed_atPeak_i(aa,bb) .^ para_BedS0_38more_b;
    end
end
end