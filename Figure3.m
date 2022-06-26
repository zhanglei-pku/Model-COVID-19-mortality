% This file is used to Plot the figure 3
% Author: Lei Zhang
% Last modified: 01-10-2021
clearvars;
close all;
clc;

% Read the table.
tableSD   = readtable('State-Data-all-waves.csv');
continent = tableSD.continent;
Location  = tableSD.location;

Tau   = tableSD.tau;
duration = tableSD.duration;
K_CDR = tableSD.K;
flag_wave = tableSD.flag_wave;
flag_type = tableSD.flag_type;

i_flag = flag_type==1;
continent = continent(i_flag);
Location = Location(i_flag);
Tau = Tau(i_flag);
duration = duration(i_flag);
K_CDR = K_CDR(i_flag);
flag_wave = flag_wave(i_flag);


% All countries
K_CDR_mean = mean(K_CDR);
K_CDR_25   = quantile(K_CDR,0.25);
K_CDR_75   = quantile(K_CDR,0.75);

disp(['The K of all countries is ',num2str(K_CDR_mean),...
    '(IQR, ',num2str(K_CDR_25),'，',num2str(K_CDR_75),')'])

% Africa
flag_AF  = ismember(continent,'Africa');
Tau_AF   = Tau(flag_AF);
duration_AF = duration (flag_AF);
K_AF      = K_CDR(flag_AF);
K_AF_mean = mean(K_AF);
K_AF_25   = quantile(K_AF,0.25);
K_AF_75   = quantile(K_AF,0.75);

flag_wave_AF = flag_wave(flag_AF);

disp(['The K of Africa is ',num2str(K_AF_mean),...
    '(IQR, ',num2str(K_AF_25),'，',num2str(K_AF_75),')'])

% Asia
flag_asia  = ismember(continent,'Asia');
Tau_asia   = Tau(flag_asia);
duration_asia = duration (flag_asia);
K_asia      = K_CDR(flag_asia);
K_asia_mean = mean(K_asia);
K_asia_25   = quantile(K_asia,0.25);
K_asia_75   = quantile(K_asia,0.75);

flag_wave_asia = flag_wave(flag_asia);

disp(['The K of Asia is ',num2str(K_asia_mean),...
    '(IQR, ',num2str(K_asia_25),'，',num2str(K_asia_75),')'])

% Europe
flag_europe  = ismember(continent,'Europe');
Tau_europe   = Tau(flag_europe);
duration_europe = duration(flag_europe);
K_europe      = K_CDR(flag_europe);
K_europe_mean = mean(K_europe);
K_europe_25   = quantile(K_europe,0.25);
K_europe_75   = quantile(K_europe,0.75);

flag_wave_europe = flag_wave(flag_europe);

disp(['The K of europe is ',num2str(K_europe_mean),...
    '(IQR, ',num2str(K_europe_25),'，',num2str(K_europe_75),')'])

% North America
flag_america  = ismember(continent,'North America');
Tau_america   = Tau(flag_america);
duration_america = duration(flag_america);
K_america      = K_CDR(flag_america);
K_america_mean = mean(K_america);
K_america_25   = quantile(K_america,0.25);
K_america_75   = quantile(K_america,0.75);

flag_wave_america = flag_wave(flag_america);

disp(['The K of america is ',num2str(K_america_mean),...
    '(IQR, ',num2str(K_america_25),'，',num2str(K_america_75),')'])

%% Fit the data

% All countries
tau_pre   = 0:0.1:50;
[para,RSD] = fit_tau_duration(Tau,duration);
para_a = para.a;
duration_pre = para_a * tau_pre;

% Confidence and Prediction Bounds (95%)
para_a_cb = confint(para);
para_a_lb = para_a_cb(1);
para_a_ub = para_a_cb(2);

tau_pre_cb = predint(para,tau_pre,0.95);
AA_tau_pre = [tau_pre(1:end),tau_pre(length(tau_pre):-1:1)];
BB_tau_pre = [tau_pre_cb(1:end,2);tau_pre_cb(length(tau_pre_cb):-1:1,1)];

r_p = corr(Tau,duration,'type','pearson');

disp(['The fit parameter a of all countries is ',num2str(para_a),...
    '(',num2str(para_a_lb),'，',num2str(para_a_ub),')'])

% Africa
[para_AF,RSD_AF] = fit_tau_duration(Tau_AF,duration_AF);
para_a_AF = para_AF.a;
duration_pre_AF = para_a_AF * tau_pre;

% Confidence and Prediction Bounds (95%)
para_a_AF_cb = confint(para_AF);
para_a_AF_lb = para_a_AF_cb(1);
para_a_AF_ub = para_a_AF_cb(2);

tau_pre_AF_cb = predint(para_AF,tau_pre,0.95);
AA_tau_pre_AF = [tau_pre(1:end),tau_pre(length(tau_pre):-1:1)];
BB_tau_pre_AF = [tau_pre_AF_cb(1:end,2);tau_pre_AF_cb(length(tau_pre_AF_cb):-1:1,1)];

r_p_AF = corr(Tau_AF,duration_AF,'type','pearson');

disp(['The fit parameter a of Africa is ',num2str(para_a_AF),...
    '(',num2str(para_a_AF_lb),'，',num2str(para_a_AF_ub),')'])


% Asia
[para_asia,RSD_asia] = fit_tau_duration(Tau_asia,duration_asia);
para_a_asia = para_asia.a;
duration_pre_asia = para_a_asia * tau_pre;

% Confidence and Prediction Bounds (95%)
para_a_asia_cb = confint(para_asia);
para_a_asia_lb = para_a_asia_cb(1);
para_a_asia_ub = para_a_asia_cb(2);

tau_pre_asia_cb = predint(para_asia,tau_pre,0.95);
AA_tau_pre_asia = [tau_pre(1:end),tau_pre(length(tau_pre):-1:1)];
BB_tau_pre_asia = [tau_pre_asia_cb(1:end,2);tau_pre_asia_cb(length(tau_pre_asia_cb):-1:1,1)];

r_p_asia = corr(Tau_asia,duration_asia,'type','pearson');

disp(['The fit parameter a of Asia is ',num2str(para_a_asia),...
    '(',num2str(para_a_asia_lb),'，',num2str(para_a_asia_ub),')'])


% Europe
[para_europe,RSD_europe] = fit_tau_duration(Tau_europe,duration_europe);
para_a_europe = para_europe.a;
duration_pre_europe = para_a_europe * tau_pre;

% Confidence and Prediction Bounds (95%)
para_a_europe_cb = confint(para_europe);
para_a_europe_lb = para_a_europe_cb(1);
para_a_europe_ub = para_a_europe_cb(2);

tau_pre_europe_cb = predint(para_europe,tau_pre,0.95);
AA_tau_pre_europe = [tau_pre(1:end),tau_pre(length(tau_pre):-1:1)];
BB_tau_pre_europe = [tau_pre_europe_cb(1:end,2);tau_pre_europe_cb(length(tau_pre_europe_cb):-1:1,1)];

r_p_europe = corr(Tau_europe,duration_europe,'type','pearson');

disp(['The fit parameter a of Europe is ',num2str(para_a_europe),...
    '(',num2str(para_a_europe_lb),'，',num2str(para_a_europe_ub),')'])


% America
[para_america,RSD_america] = fit_tau_duration(Tau_america,duration_america);
para_a_america = para_america.a;
duration_pre_america = para_a_america * tau_pre;

% Confidence and Prediction Bounds (95%)
para_a_america_cb = confint(para_america);
para_a_america_lb = para_a_america_cb(1);
para_a_america_ub = para_a_america_cb(2);

tau_pre_america_cb = predint(para_america,tau_pre,0.95);
AA_tau_pre_america = [tau_pre(1:end),tau_pre(length(tau_pre):-1:1)];
BB_tau_pre_america = [tau_pre_america_cb(1:end,2);tau_pre_america_cb(length(tau_pre_america_cb):-1:1,1)];

r_p_america = corr(Tau_america,duration_america,'type','pearson');

disp(['The fit parameter a of America is ',num2str(para_a_america),...
    '(',num2str(para_a_america_lb),'，',num2str(para_a_america_ub),')'])


%% Plot the result

color_k = [...
    0.42353	0.65098	0.80392;...
    0.41176	0.5451	0.41176;...
    0.73725	0.56078	0.56078;...
    0.27843	0.23529	0.5451;];
gcf1 = figure('Position',[195,91,1528,812]);
tiledlayout(2,4,'TileSpacing','loose','Padding','compact');


% All countries
% subplot(2,4,[1,2,5,6])
nexttile(1,[2,2])
hold on

for k = 1:4
    scatter(Tau(flag_wave == k),duration(flag_wave == k),'o',...
        'filled','SizeData',200,...
        'markerfacecolor',color_k(k,:),'markeredgecolor',color_k(k,:),...
        'MarkerFaceAlpha',0.75,'MarkerEdgeAlpha',0.75)
end

plot(tau_pre,duration_pre,'k-','LineWidth',2)

p1  = fill(AA_tau_pre,BB_tau_pre,'blue');
p1.FaceColor = [0.81176 0.81176 0.81176];
p1.EdgeColor = 'none';

for k = 1:4
    scatter(Tau(flag_wave == k),duration(flag_wave == k),'o',...
        'filled','SizeData',200,...
        'markerfacecolor',color_k(k,:),'markeredgecolor',color_k(k,:),...
        'MarkerFaceAlpha',0.75,'MarkerEdgeAlpha',0.75)
end
plot(tau_pre,duration_pre,'k-','LineWidth',2)
box on
title(['54 countires in 4 waves (N=',num2str(length(Tau)),')'],'interpreter','latex')
ylabel('Epidemic  duration in each wave','interpreter','latex','FontSize',20)
xlabel('$\tau$','interpreter','latex','FontSize',16)
set(gca,'Layer','top');
set(gca,'FontSize',20)
ylim([0,400])
xlim([0,50])
xticks([0,10,20,30,40,50])

legend({'1st wave','2nd wave','3rd wave','4th wave',['$y$','=',num2str(roundn(para_a,-2)) '$x$'],'95\% CI'},...
    'location','northwest','FontSize',20,'interpreter','latex')
legend('boxoff')
text(0.73,0.15,['$R^2$','=' num2str(roundn(RSD.rsquare,-2))],...
    'FontSize',20,'Units','normalized','interpreter','latex');
text(0.73,0.10,['   $r$',' = ' num2str(roundn(r_p,-2))],...
    'FontSize',20,'Units','normalized','interpreter','latex');
% Europe
nexttile([1,1])
hold on

plot(tau_pre,duration_pre_europe,'k-','LineWidth',2)

p1  = fill(AA_tau_pre_europe,BB_tau_pre_europe,'blue');
p1.FaceColor = [0.81176 0.81176 0.81176];
p1.EdgeColor = 'none';

for k = 1:4
    scatter(Tau_europe(flag_wave_europe == k),duration_europe(flag_wave_europe == k),'o',...
        'filled','SizeData',100,...
        'markerfacecolor',color_k(k,:),'markeredgecolor',color_k(k,:),...
        'MarkerFaceAlpha',0.75,'MarkerEdgeAlpha',0.75)
end
plot(tau_pre,duration_pre_europe,'k-','LineWidth',2)

box on
title(['Europe (N=',num2str(length(Tau_europe)),')'],'interpreter','latex')
ylabel('epidemic duration','interpreter','latex','FontSize',16)
xlabel('$\tau$','interpreter','latex','FontSize',16)
set(gca,'Layer','top');
set(gca,'FontSize',18)
ylim([0,400])
xlim([0,50])
xticks([0,25,50])

legend({['$y$','=',num2str(roundn(para_a_europe,-2)) '$x$'],'95\% CI'},...
    'location','northwest','FontSize',16,'interpreter','latex')
legend('boxoff')

text(0.60,0.15,['$R^2$','=' num2str(roundn(RSD_europe.rsquare,-2))],...
    'FontSize',14,'Units','normalized','interpreter','latex');
text(0.60,0.07,['   $r$',' = ' num2str(roundn(r_p_europe,-2))],...
    'FontSize',14,'Units','normalized','interpreter','latex');


% Africa
nexttile([1,1])
hold on

plot(tau_pre,duration_pre_AF,'k-','LineWidth',2)

p1  = fill(AA_tau_pre_AF,BB_tau_pre_AF,'blue');
p1.FaceColor = [0.81176 0.81176 0.81176];
p1.EdgeColor = 'none';

for k = 1:4
    scatter(Tau_AF(flag_wave_AF == k),duration_AF(flag_wave_AF == k),'o',...
        'filled','SizeData',100,...
        'markerfacecolor',color_k(k,:),'markeredgecolor',color_k(k,:),...
        'MarkerFaceAlpha',0.75,'MarkerEdgeAlpha',0.75)
end
plot(tau_pre,duration_pre_AF,'k-','LineWidth',2)
box on
title(['Africa (N=',num2str(length(Tau_AF)),')'],'interpreter','latex')
ylabel('epidemic duration','interpreter','latex','FontSize',16)
xlabel('$\tau$','interpreter','latex','FontSize',16)
set(gca,'Layer','top');
set(gca,'FontSize',18)
ylim([0,400])
xlim([0,50])
xticks([0,25,50])

legend({['$y$','=',num2str(roundn(para_a_AF,-2)) '$x$'],'95\% CI'},...
    'location','northwest','FontSize',16,'interpreter','latex')
legend('boxoff')

text(0.60,0.15,['$R^2$','=' num2str(roundn(RSD_AF.rsquare,-2))],...
    'FontSize',14,'Units','normalized','interpreter','latex');
text(0.60,0.07,['   $r$',' = ' num2str(roundn(r_p_AF,-2))],...
    'FontSize',14,'Units','normalized','interpreter','latex');

% Asia
nexttile([1,1])
hold on

plot(tau_pre,duration_pre_asia,'k-','LineWidth',2)

p1  = fill(AA_tau_pre_asia,BB_tau_pre_asia,'blue');
p1.FaceColor = [0.81176 0.81176 0.81176];
p1.EdgeColor = 'none';

for k = 1:4
    scatter(Tau_asia(flag_wave_asia == k),duration_asia(flag_wave_asia == k),'o',...
        'filled','SizeData',100,...
        'markerfacecolor',color_k(k,:),'markeredgecolor',color_k(k,:),...
        'MarkerFaceAlpha',0.75,'MarkerEdgeAlpha',0.75)
end
plot(tau_pre,duration_pre_asia,'k-','LineWidth',2)

box on
title(['Asia (N=',num2str(length(Tau_asia)),')'],'interpreter','latex')
ylabel('epidemic duration','interpreter','latex','FontSize',16)
xlabel('$\tau$','interpreter','latex','FontSize',16)
set(gca,'Layer','top');
set(gca,'FontSize',18)
ylim([0,400])
xlim([0,50])
xticks([0,25,50])

legend({['$y$','=',num2str(roundn(para_a_asia,-2)) '$x$'],'95\% CI'},...
    'location','northwest','FontSize',16,'interpreter','latex')
legend('boxoff')

text(0.60,0.15,['$R^2$','=' num2str(roundn(RSD_asia.rsquare,-2))],...
    'FontSize',14,'Units','normalized','interpreter','latex');
text(0.60,0.07,['   $r$',' = ' num2str(roundn(r_p_asia,-2))],...
    'FontSize',14,'Units','normalized','interpreter','latex');


% America
nexttile([1,1])
hold on

plot(tau_pre,duration_pre_america,'k-','LineWidth',2)

p1  = fill(AA_tau_pre_america,BB_tau_pre_america,'blue');
p1.FaceColor = [0.81176 0.81176 0.81176];
p1.EdgeColor = 'none';

for k = 1:4
    scatter(Tau_america(flag_wave_america == k),duration_america(flag_wave_america == k),'o',...
        'filled','SizeData',100,...
        'markerfacecolor',color_k(k,:),'markeredgecolor',color_k(k,:),...
        'MarkerFaceAlpha',0.75,'MarkerEdgeAlpha',0.75)
end
plot(tau_pre,duration_pre_america,'k-','LineWidth',2)


box on
title(['America (N=',num2str(length(Tau_america)),')'],'interpreter','latex')
ylabel('epidemic duration','interpreter','latex','FontSize',16)
xlabel('$\tau$','interpreter','latex','FontSize',16)
set(gca,'Layer','top');
set(gca,'FontSize',18)
ylim([0,400])
xlim([0,50])
xticks([0,25,50])

legend({['$y$','=',num2str(roundn(para_a_america,-2)) '$x$'],'95\% CI'},...
    'location','northwest','FontSize',16,'interpreter','latex')
legend('boxoff')


text(0.60,0.15,['$R^2$','=' num2str(roundn(RSD_america.rsquare,-2))],...
    'FontSize',14,'Units','normalized','interpreter','latex');
text(0.60,0.07,['   $r$',' = ' num2str(roundn(r_p_america,-2))],...
    'FontSize',14,'Units','normalized','interpreter','latex');


annotation(gcf,'textbox',...
    [0.01 0.96 0.025 0.05],...
    'String','a',...
    'FontWeight','bold',...
    'FontSize',24,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(gcf,'textbox',...
    [0.49 0.96 0.025 0.05],...
    'String','b',...
    'FontWeight','bold',...
    'FontSize',24,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(gcf,'textbox',...
    [0.73 0.96 0.025 0.05],...
    'String','c',...
    'FontWeight','bold',...
    'FontSize',24,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(gcf,'textbox',...
    [0.49 0.47 0.025 0.05],...
    'String','d',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(gcf,'textbox',...
    [0.73 0.47 0.025 0.05],...
    'String','e',...
    'FontWeight','bold',...
    'FontSize',24,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');




function [fitresult, gof] = fit_tau_duration(tau,duration)

[xData,yData] = prepareCurveData(tau,duration);

% Set up fittype and options.
ft = fittype('a*x','independent','x','dependent','y' );
opts = fitoptions('Method','NonlinearLeastSquares');
opts.Algorithm = 'Trust-Region';
opts.Display = 'Off';
opts.Robust = 'Off';
opts.Lower = 0;
opts.Upper = 100;
opts.StartPoint = 1;
% Fit model to data.
[fitresult, gof] = fit(xData, yData, ft, opts );

end

