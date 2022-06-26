% This file is used to Plot the figure 6
% Author: Lei Zhang
% Last modified: 1-10-2021


%% Input the country or region that to be fitted
clearvars;close all;clc;

inputarea = 'Switzerland';


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

tableSD = readtable('State-Data-wave1.csv');
indSD   = find(strcmp(tableSD.location,inputarea)==1);
Population = tableSD.population(indSD(1));

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
CDR      = Deaths./Population.*10^5;

date10  = time(find(Deaths>=10,1));
date100 = time(find(Deaths>=100,1));

%% Determine the startpoint and endpoint

endpoint_rough = tableSD.endpoint_rough(indSD);

% Smooth the data of daily deaths to find the peakpoint.
deaths_smooth_10 = smooth(diff(Deaths(1:endpoint_rough)),10);
[peak_y,peak_x]  = max(deaths_smooth_10(1:end));

% Find the startpoint that have grow to the number of 10% times the peak of the daily deaths.
[startpoint,~] = find(deaths_smooth_10(1:peak_x)>0.1*peak_y,1);

% Find the endpoint that have drop to the number of 10% times of the peak of the daily deaths.
if ~isempty(find(deaths_smooth_10(peak_x:end)<0.1*peak_y,1))
    [endpoint_x,~] = find(deaths_smooth_10(peak_x:end)<0.1*peak_y,1);
    flag_endType = 1;
else 
    % It didn't drop to a tenth of its peak
    [~,endpoint_x] = min(abs(deaths_smooth_10(peak_x:end)-0.1*peak_y));
    flag_endType = 2;
end


endpoint   = endpoint_x + peak_x - 1;
ratio_drop = deaths_smooth_10(endpoint)/peak_y;

if flag_endType == 1 && Deaths(endpoint)<100
    flag_endType = 3;
end

%% Fit the data with the self-defining funtion: fit_CDR

CDR_fitted = CDR(startpoint:endpoint);
% ts_CDR is the first day of startpoint.
ts_CDR = 1;
% ts_CDR is the duration of startpoint and endpoint.
te_CDR     = endpoint - startpoint + 1;
t_fit      = 1:te_CDR;


[para_CDR,RSD_CDR] = fit_CDR(t_fit,CDR_fitted);
s0_CDR  = para_CDR.s0;
tau_CDR = para_CDR.tau;
tc_CDR  = para_CDR.tc;

t_pre   = -29:1:length(time(startpoint:end))+60;
CDR_pre = s0_CDR./(1+exp(-1/tau_CDR*(t_pre-tc_CDR)));

time_pre = datetime(datestr(floor(datenum(time(startpoint))-datenum(30))), 'Locale', 'en_US'):...
    1:datetime(datestr(floor(datenum(time(end))+datenum(60))), 'Locale', 'en_US');

% Calculate some key values
duration_tc_ts  = tc_CDR - ts_CDR;
duration_te_tc  = te_CDR - tc_CDR;
duration_te_ts  = te_CDR - ts_CDR;

CDR_ts = CDR(startpoint);
CDR_te = CDR(endpoint);
CDR_tc = CDR(startpoint + round(tc_CDR));

CDR_pre_ts = s0_CDR./(1+exp(-1/tau_CDR*(ts_CDR - tc_CDR)));
CDR_pre_te = s0_CDR./(1+exp(-1/tau_CDR*(te_CDR - tc_CDR)));
CDR_pre_tc = s0_CDR./(1+exp(-1/tau_CDR*(tc_CDR - tc_CDR)));

K_te_ts = log((s0_CDR/CDR_ts-1)/(s0_CDR/CDR_te-1));
K_te_tc = -log(s0_CDR/CDR_te-1);
K_tc_ts = log(s0_CDR/CDR_ts-1);

K_pre_te_ts = log((s0_CDR/CDR_pre_ts-1)/(s0_CDR/CDR_pre_te-1));
K_pre_te_tc = -log(s0_CDR/CDR_pre_te-1);
K_pre_tc_ts = log(s0_CDR/CDR_pre_ts-1);

% Confidence and Prediction Bounds (95%)
confidence_bounds = confint(para_CDR);
s0_lb  = confidence_bounds(1,1);
s0_ub  = confidence_bounds(2,1);
tau_lb = confidence_bounds(1,2);
tau_ub = confidence_bounds(2,2);
tc_lb  = confidence_bounds(1,3);
tc_ub  = confidence_bounds(2,3);

CDR_cb = predint(para_CDR,t_pre,0.95);


%% Plot the result

figure('position',[425,272,1204,490]);
t = tiledlayout(1,2,'TileSpacing','tight','Padding','compact');
nexttile([1,1])
hold on
plot(time(2:endpoint_rough),diff(Deaths(1:endpoint_rough)),'ko','markersize',5,'linewidth',1);
plot(time(2:endpoint_rough),deaths_smooth_10,'-',...
    'color',[0.06275 0.30588 0.5451],'linewidth',2);
plot(time(startpoint+1),deaths_smooth_10(startpoint),'^',...
    'markeredgecolor',[0.80392	0.36078	0.36078],...
    'markersize',10,'linewidth',2);
plot(time(peak_x+1),peak_y,'s','markersize',10,...
    'markeredgecolor',[0.80392	0.36078	0.36078],...
    'linewidth',2);
plot(time(endpoint+1),deaths_smooth_10(endpoint),'v',...
    'markeredgecolor',[0.80392	0.36078	0.36078],...
    'markersize',10,'linewidth',2);

set(gca,'fontsize',16,'fontname','Times New Roman')

ylabel('Cases','interpreter','latex','FontSize',20)
title('Daily deaths','interpreter','latex','FontSize',20)
legend({'daily data','10-day smooth','outbreak date','peak date','saturation date'},...
    'location','northeast','interpreter','latex','FontSize',16)
legend('boxoff')
ylim(get(gca,'ylim'))
box on
annotation(gcf,'textbox',...
    [0.06 0.95 0.025 0.05],...
    'String','a',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

nexttile([1,1])
hold on
plot(time(1:endpoint_rough),Deaths(1:endpoint_rough),'ko','markersize',5,'LineWidth',1);
plot(time(startpoint:endpoint),Deaths(startpoint:endpoint),'o',...
    'markeredgecolor',[0.80392	0.36078	0.36078],...
    'markersize',5,'LineWidth',1);

set(gca,'FontSize',16,'fontname','Times New Roman')

ylabel('Cases','interpreter','latex','FontSize',20)
title('Cumulative deaths','interpreter','latex','FontSize',20)
legend({'cumulative data','duration of the first wave'},...
    'location','southeast','interpreter','latex','FontSize',16)
legend('boxoff')
ylim(get(gca,'ylim'))
box on
annotation(gcf,'textbox',...
    [0.5 0.95 0.025 0.05],...
    'String','b',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');


%% User-Defined Fit Functions

function [fitresult, gof] = fit_CDR(xData,CDR_fitted)

[xData, yData] = prepareCurveData(xData,CDR_fitted);

% Set up fittype and options.
ft = fittype( 's0/(1+exp(-1/tau*(x-tc)))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Trust-Region';
opts.Display = 'Off';
opts.Robust = 'LAR';
opts.Lower=[0,0,0];
opts.Upper=[1000,1000,1000];
opts.StartPoint = [0.1 1 1];
% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
end