% This file is used to fit the data of Crude Death Rate
% Author: Lei Zhang
% Last modified: 2022-06-18



clearvars;
close all;
clc;


%% read the State-Data.csv that including the data of median-age/beds/physicians...

tableSD = readtable('State-Data-all-waves.csv');


%% Input the country or region that to be fitted
prompt = {'\fontsize{10} Please input the country or region that you want to fit:'};
dlgtitle = 'Enter the country or region';
dims = [1,100];
definput = {'Switzerland'};
opts.Resize = 'on';
opts.Interpreter = 'tex';
inputarea = inputdlg(prompt,dlgtitle,dims,definput,opts);
if isempty(inputarea)
   warning('Please enter the country or region and then press the confirmation button ！')
   return
end

%% Download the data from ref [1] and read them with the function getDataCOVID

[tableConfirmed,tableDeaths,tableRecovered,time] = getDataCOVID();
fprintf(['Most recent update: ',datestr(time(end)),'\n'])

% Discuss the different situations of the Recovered
if isempty(find(tableRecovered.CountryRegion==inputarea, 1))
    warning('Could not find the country or region, please check the inputarea. The first letter should be capitalized.')
    return
elseif ~isempty(find((tableRecovered.CountryRegion==inputarea) & (tableRecovered.ProvinceState.ismissing()==1), 1))
    indR = find((tableRecovered.CountryRegion==inputarea) & (tableRecovered.ProvinceState.ismissing()==1));
    Recovered = table2array(tableRecovered(indR,5:end));
    disp(tableRecovered(indR(1),1:2))
else
    indR = find((tableRecovered.CountryRegion==inputarea));
    Recovered = sum(table2array(tableRecovered(indR,5:end)),1);
    disp(tableRecovered(indR(1),2:2))
end

% Discuss the different situations of the Confirmed

if isempty(find(tableConfirmed.CountryRegion==inputarea, 1))
    warning('Could not find the country or region, please check the inputarea (The first letter should be capitalized).')
    return
elseif ~isempty(find((tableConfirmed.CountryRegion==inputarea) & (tableConfirmed.ProvinceState.ismissing()==1), 1))
    indC = find((tableConfirmed.CountryRegion==inputarea) & (tableConfirmed.ProvinceState.ismissing()==1));
    Confirmed = table2array(tableConfirmed(indC,5:end));
    disp(tableConfirmed(indC(1),1:2))
else
    indC = find((tableConfirmed.CountryRegion==inputarea));
    Confirmed = sum(table2array(tableConfirmed(indC,5:end)),1);
    disp(tableConfirmed(indC(1),2:2))
end

% Discuss the different situations of the Deaths

if isempty(find(tableDeaths.CountryRegion==inputarea, 1))
    warning('Could not find the country or region, please check the inputarea (The first letter should be capitalized).')
    return
elseif ~isempty(find((tableDeaths.CountryRegion==inputarea) & (tableDeaths.ProvinceState.ismissing()==1), 1))
    indD = find((tableDeaths.CountryRegion==inputarea) & (tableDeaths.ProvinceState.ismissing()==1));
    Deaths = table2array(tableDeaths(indD,5:end));
    disp(tableDeaths(indD(1),1:2))
else
    indD = find((tableDeaths.CountryRegion==inputarea));
    Deaths = sum(table2array(tableDeaths(indD,5:end)),1);
    disp(tableDeaths(indD(1),2:2))
end


% Quarantined are the cases that are still treated in hospital
Quarantined = Confirmed - Recovered - Deaths;


%% read the State-Data.csv that including the data of median-age/beds/physicians...
indSD   = find(strcmp(tableSD.location,inputarea)==1);
flag_wave = tableSD.flag_wave(indSD);
[~,flag_wave_new] = sort(flag_wave);

indSD_new = indSD(flag_wave_new);
Population = tableSD.population(indSD_new);
tau = tableSD.tau(indSD_new);
s0 = tableSD.s0(indSD_new);
duration = tableSD.duration(indSD_new);
k_CDR = tableSD.K(indSD_new);

flag_type = tableSD.flag_type(indSD_new);


%% Prepare the data from the date when having the deaths 

indRemoved = find(Deaths <= 0);

if ~isempty(indRemoved)
    Recovered = Recovered(indRemoved(end)+1:end);
    Deaths    = Deaths(indRemoved(end)+1:end);
    Confirmed = Confirmed(indRemoved(end)+1:end);
    time      = time(indRemoved(end)+1:end);
end

if isempty(Deaths)
    warning('Deaths is empty.')
    return
end

%% Caculate the Crude Death Rate(CDR)

% startpoint = tableSD.startpoint(indSD);
% endpoint = tableSD.endpoint(indSD);

CDR      = Deaths./Population.*10^5;


%% Plot the raw data
% Smooth the data of daily deaths to find the peakpoint.
% Some African countries need larger smoothing steps.
if sum(ismember({'Cameroon','Zambia'},inputarea))
    smooth_step = 20;
else
    smooth_step = 10;
end
daily_death = diff(Deaths);

deaths_smooth = smooth(daily_death,smooth_step);




gcf = figure('position',[305,42,1308,953]);
t = tiledlayout(2,6,'TileSpacing','loose','Padding','compact');
nexttile([1,3])
hold on
bar(time(2:end),daily_death,'facecolor',[0.21176	0.21176	0.21176],'linewidth',0.5);
plot(deaths_smooth,'-','color',[0.80392	0.36078	0.36078],'linewidth',2);

ylabel('daily deaths','FontSize',20)
yRange = get(gca,'ylim');
ylim([0,yRange(2)])
set(gca,'fontsize',16)
box on
legend({'daily deaths','10 days smooth'},'location','northeast','FontSize',16)
legend('boxoff')

   
annotation(gcf,'textbox',[0.065 0.735 0.085 0.05],'String',...
    'early variants SARS-CoV-2','color',[0.21176	0.21176	0.21176],...
    'FontSize',12,'Units','normalized','FitBoxToText','off','EdgeColor','none');
annotation(gcf,'textbox',[0.180 0.825 0.085 0.05],'String',...
    'Beta','color',[0.21176	0.21176	0.21176],...
    'FontSize',12,'Units','normalized','FitBoxToText','off','EdgeColor','none');
annotation(gcf,'textbox',[0.320 0.580 0.085 0.05],'String',...
    'Delta','color',[0.21176	0.21176	0.21176],...
    'FontSize',12,'Units','normalized','FitBoxToText','off','EdgeColor','none');
annotation(gcf,'textbox',[0.370 0.680 0.085 0.05],'String',...
    'Omicron','color',[0.21176	0.21176	0.21176],...
    'FontSize',12,'Units','normalized','FitBoxToText','off','EdgeColor','none');

title('Daily Deaths','FontSize',16,'interpreter','latex')


nexttile([1,3])
hold on
color_k = [...
    0.42353	0.65098	0.80392;...
    0.41176	0.5451	0.41176;...
    0.73725	0.56078	0.56078;...
    0.27843	0.23529	0.5451;];

for k = 1:length(indSD_new)
    clear Confirmed_wave  Recovered_wave Deaths_wave CDR_wave CDR_pre
    startpoint_rough = tableSD.startpoint_rough(indSD_new(k));
    endpoint_rough   = tableSD.endpoint_rough(indSD_new(k));

    if startpoint_rough > 1
        Confirmed_wave = Confirmed(startpoint_rough:endpoint_rough)-...
            Confirmed(startpoint_rough);
        Recovered_wave = Recovered(startpoint_rough:endpoint_rough)-...
            Recovered(startpoint_rough);
        Deaths_wave = Deaths(startpoint_rough:endpoint_rough)-...
            Deaths(startpoint_rough);
    else
        Confirmed_wave = Confirmed(startpoint_rough:endpoint_rough);
        Recovered_wave = Recovered(startpoint_rough:endpoint_rough);
        Deaths_wave = Deaths(startpoint_rough:endpoint_rough);
    end

    CDR_wave = Deaths_wave./Population(1).*10^5;

    
    startpoint = tableSD.startpoint(indSD_new(k));
    endpoint   = tableSD.endpoint(indSD_new(k));
    plot(CDR_wave(startpoint:endpoint),'o','color',color_k(k,:),...
        'markersize',5,'LineWidth',1);
end


for k = 1:length(indSD_new)
    clear Confirmed_wave  Recovered_wave Deaths_wave CDR_wave CDR_pre
    startpoint_rough = tableSD.startpoint_rough(indSD_new(k));
    endpoint_rough   = tableSD.endpoint_rough(indSD_new(k));

    if startpoint_rough > 1
        Confirmed_wave = Confirmed(startpoint_rough:endpoint_rough)-...
            Confirmed(startpoint_rough);
        Recovered_wave = Recovered(startpoint_rough:endpoint_rough)-...
            Recovered(startpoint_rough);
        Deaths_wave = Deaths(startpoint_rough:endpoint_rough)-...
            Deaths(startpoint_rough);
    else
        Confirmed_wave = Confirmed(startpoint_rough:endpoint_rough);
        Recovered_wave = Recovered(startpoint_rough:endpoint_rough);
        Deaths_wave = Deaths(startpoint_rough:endpoint_rough);
    end

    Quarantined_wave = Confirmed_wave - Recovered_wave - Deaths_wave;
    CDR_wave = Deaths_wave./Population(1).*10^5;

    startpoint = tableSD.startpoint(indSD_new(k));
    endpoint   = tableSD.endpoint(indSD_new(k));


    %% Fit the data with the self-defining funtion
    
    CDR_fitted = CDR_wave(startpoint:endpoint);
    duration_CDR = endpoint - startpoint + 1;
    t_fit = 1:duration_CDR;

    [para_CDR,RSD_CDR] = fit_CDR(t_fit,CDR_fitted);
    s0_CDR  = para_CDR.s0;
    tau_CDR = para_CDR.tau;
    tc_CDR  = para_CDR.tc;

    t_pre   = -29:1:length(CDR_wave(startpoint:endpoint))+200;
    CDR_pre = s0_CDR./(1+exp(-1/tau_CDR*(t_pre-tc_CDR)));

    CDR_cb = predint(para_CDR,t_pre,0.95,'functional','on');


    % Plot the result
    iend = length(t_pre);
    plot(CDR_pre(31:iend),'k-','LineWidth',2);

    % plot confidence-bounds
    AA = [t_pre(1:iend),t_pre(iend:-1:1)];
    BB = [CDR_cb(1:iend,2);CDR_cb(iend:-1:1,1)];
    p  = fill(AA,BB,'blue');
    p.FaceColor = [0.3010 0.7450 0.9330];
    p.EdgeColor = 'none';

    plot(CDR_wave(startpoint:endpoint),'o','color',color_k(k,:),...
        'markersize',5,'LineWidth',1);
    plot(CDR_pre(31:iend),'k-','LineWidth',2);
    
end

for k = 3
    clear Confirmed_wave  Recovered_wave Deaths_wave CDR_wave CDR_pre
    startpoint_rough = tableSD.startpoint_rough(indSD_new(k));
    endpoint_rough   = tableSD.endpoint_rough(indSD_new(k));

    if startpoint_rough > 1
        Confirmed_wave = Confirmed(startpoint_rough:endpoint_rough)-...
            Confirmed(startpoint_rough);
        Recovered_wave = Recovered(startpoint_rough:endpoint_rough)-...
            Recovered(startpoint_rough);
        Deaths_wave = Deaths(startpoint_rough:endpoint_rough)-...
            Deaths(startpoint_rough);
    else
        Confirmed_wave = Confirmed(startpoint_rough:endpoint_rough);
        Recovered_wave = Recovered(startpoint_rough:endpoint_rough);
        Deaths_wave = Deaths(startpoint_rough:endpoint_rough);
    end

    Quarantined_wave = Confirmed_wave - Recovered_wave - Deaths_wave;
    CDR_wave = Deaths_wave./Population(1).*10^5;

    startpoint = tableSD.startpoint(indSD_new(k));
    endpoint   = tableSD.endpoint(indSD_new(k));


    %% Fit the data with the self-defining funtion
    
    CDR_fitted = CDR_wave(startpoint:endpoint);
    duration_CDR = endpoint - startpoint + 1;
    t_fit = 1:duration_CDR;

    [para_CDR,RSD_CDR] = fit_CDR(t_fit,CDR_fitted);
    s0_CDR  = para_CDR.s0;
    tau_CDR = para_CDR.tau;
    tc_CDR  = para_CDR.tc;

    t_pre   = -29:1:length(CDR_wave(startpoint:endpoint))+200;
    CDR_pre = s0_CDR./(1+exp(-1/tau_CDR*(t_pre-tc_CDR)));

    CDR_cb = predint(para_CDR,t_pre,0.95,'functional','on');


    % Plot the result
    iend = length(t_pre);
    plot(CDR_pre(31:iend),'k-','LineWidth',2);

    % plot confidence-bounds
    AA = [t_pre(1:iend),t_pre(iend:-1:1)];
    BB = [CDR_cb(1:iend,2);CDR_cb(iend:-1:1,1)];
    p  = fill(AA,BB,'blue');
    p.FaceColor = [0.3010 0.7450 0.9330];
    p.EdgeColor = 'none';

    plot(CDR_wave(startpoint:endpoint),'o','color',color_k(k,:),...
        'markersize',5,'LineWidth',1);
    plot(CDR_pre(31:iend),'k-','LineWidth',2);
    
end

ylabel('deaths per 100k population','FontSize',20)
legend({'1st wave','2nd wave','3rd wave','4th wave','model','95% CI'},...
    'location','northwest','FontSize',14)
legend('boxoff')

xlim([0 250]);
set(gca,'FontSize',16)
set(gca,'Layer','top');
box on
    
annotation(gcf,'textbox',[0.885 0.565 0.085 0.05],'String',...
    ['$s_0$=',num2str(roundn(s0(3),-1))],'color',[0.21176	0.21176	0.21176],'interpreter','latex',...
    'FontSize',14,'Units','normalized','FitBoxToText','off','EdgeColor','none');
annotation(gcf,'textbox',[0.885 0.615 0.085 0.05],'String',...
    ['$s_0$=',num2str(roundn(s0(1),-1))],'color',[0.21176	0.21176	0.21176],'interpreter','latex',...
    'FontSize',14,'Units','normalized','FitBoxToText','off','EdgeColor','none');
annotation(gcf,'textbox',[0.885 0.675 0.085 0.05],'String',...
    ['$s_0$=',num2str(roundn(s0(4),-1))],'color',[0.21176	0.21176	0.21176],'interpreter','latex',...
    'FontSize',14,'Units','normalized','FitBoxToText','off','EdgeColor','none');
annotation(gcf,'textbox',[0.885 0.835 0.085 0.05],'String',...
    ['$s_0$=',num2str(roundn(s0(2),-1))],'color',[0.21176	0.21176	0.21176],'interpreter','latex',...
    'FontSize',14,'Units','normalized','FitBoxToText','off','EdgeColor','none');

title('Model Simulation','FontSize',16,'interpreter','latex')



nexttile([1,2])
hold on
for k =1:length(indSD_new)
    b = bar(k,tau(k),0.5,'facecolor',color_k(k,:),'edgecolor',color_k(k,:));
    xtips1 = b(1).XEndPoints;
    ytips1 = b(1).YEndPoints;
    labels1 = string(roundn(b(1).YData,-1));
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','FontSize',14)
end
xlabel('epidemic waves','FontSize',16)
ylabel('days','FontSize',16)
xticks([1,2,3,4])
xticklabels({'1st','2nd','3rd','4th'});
ylim([0,5])
ylim([0,50])
set(gca,'fontsize',16)
box on
set(gca,'Layer','top');
title(['Early mortality growth time (','$\tau$',')'],'FontSize',16,'interpreter','latex')



nexttile([1,2])
hold on
for k =1:length(indSD_new)
    b = bar(k,duration(k),0.5,'facecolor',color_k(k,:),'edgecolor',color_k(k,:));
    xtips1 = b(1).XEndPoints;
    ytips1 = b(1).YEndPoints;
    labels1 = string(roundn(b(1).YData,-1));
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','FontSize',14)
end
xlabel('epidemic waves','FontSize',16)
ylabel('days','FontSize',16)
xticks([1,2,3,4])
xticklabels({'1st','2nd','3rd','4th'});
ylim([0,5])
ylim([0,280])
set(gca,'fontsize',16)
box on
set(gca,'Layer','top');
title('Epidemic Duration','FontSize',16,'interpreter','latex')



nexttile([1,2])
hold on
for k =1:length(indSD_new)
    b = bar(k,k_CDR(k),0.5,'facecolor',color_k(k,:),'edgecolor',color_k(k,:));
    xtips1 = b(1).XEndPoints;
    ytips1 = b(1).YEndPoints;
    labels1 = string(roundn(b(1).YData,-1));
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','FontSize',14)
end
xlabel('epidemic waves','FontSize',16)
ylabel('k','FontSize',16)
xticks([1,2,3,4])
xticklabels({'1st','2nd','3rd','4th'});
ylim([0,5])
ylim([0,10])
set(gca,'fontsize',16)
box on
set(gca,'Layer','top');
title(['Key Coefficient (','$k$',')'],'FontSize',16,'interpreter','latex')

title(t,['The mortality evolution of ' inputarea{:} ' in four waves'],'FontSize',24)

annotation(gcf,'textbox',...
    [0.005 0.90 0.025 0.05],...
    'String','a',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.485 0.90 0.025 0.05],...
    'String','b',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.005 0.42 0.025 0.05],...
    'String','c',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.325 0.42 0.025 0.05],...
    'String','d',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.645 0.42 0.025 0.05],...
    'String','e',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');



%% User-Defined Fit Functions

function [fitresult,gof] = fit_CDR(tData,CDR_fitted)

[tData,yData] = prepareCurveData(tData,CDR_fitted);

% Set up fittype and options.
ft = fittype( 's0/(1+exp(-1/tau*(x-tc)))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Trust-Region';
opts.Display = 'Off';
opts.Robust  = 'LAR';
opts.Lower   = [0,0,0];
opts.Upper   = [1000,1000,1000];
opts.StartPoint = [0.1 1 1];
% Fit model to data.
[fitresult, gof] = fit( tData, yData, ft, opts );
end