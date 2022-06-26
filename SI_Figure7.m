% This file is used to plot the 17 countries in the second wave, which is 
% shown in the Figure 4 of supplementary meterial.
% Author: Lei Zhang
% Last modified: 18-07-2021

clearvars;
close all;
clc;
% read the State-Data.csv that including the data of median-age/beds/physicians...
tableSD = readtable('State-Data-under-100.csv');


figure('position',[425,272,1204,490]);
t = tiledlayout(1,2,'TileSpacing','tight','Padding','compact');
nexttile([1,1])
hold on
tableSD = Fit_mortality('New Zealand',tableSD);
nexttile([1,1])
tableSD = Fit_mortality('Iceland',tableSD);


title(t,'Countries with deaths under 100','FontWeight','bold','FontSize',20)

annotation(gcf,'textbox',...
    [0.018 0.87 0.025 0.05],...
    'String','a',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(gcf,'textbox',...
    [0.505 0.87 0.025 0.05],...
    'String','b',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');


writetable(tableSD,'State-Data-under-100.csv');    










function tableSD = Fit_mortality(inputarea,tableSD)


%% Download the data from ref [1] and read them with the function getDataCOVID

[tableConfirmed,tableDeaths,tableRecovered,time] = getDataCOVID();
fprintf(['Most recent update: ',datestr(time(end)),'\n'])

if strcmp(inputarea,'Wuhan')
    tableWuhan = readtable('Wuhan.csv');
    widthRecovered = width(tableWuhan);
    opts = delimitedTextImportOptions("NumVariables", widthRecovered);
    opts.VariableNames = ["ProvinceState", "CountryRegion", "Lat", "Long", repmat("data",1,widthRecovered-4)];
    opts.VariableTypes = ["string", "string", repmat("double",1,widthRecovered-2)];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    tableWuhan = readtable('Wuhan.csv',opts);
        
    Confirmed = table2array(tableWuhan(2,5:end));
    Recovered = table2array(tableWuhan(3,5:end));
    Deaths    = table2array(tableWuhan(4,5:end));
    
    time = datetime(2020,01,22):days(1):datetime(2020,01,22)+length(Deaths)-1;
    
    clear opts
else
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
end

% Quarantined are the cases that are still treated in hospital
Quarantined = Confirmed - Recovered - Deaths;


%% read the State-Data.csv that including the data of median-age/beds/physicians...


indSD   = find(strcmp(tableSD.location,inputarea)==1);

if isempty(indSD)
    prompt = {'\fontsize{10} Please enter the population manually:'};
    dlgtitle = 'Enter the population';
    dims = [1 60];
    definput = {'11210000'};% 11210000 is the population of Wuhan
    opts.Interpreter = 'tex';
    Population = inputdlg(prompt,dlgtitle,dims,definput,opts);
    Population = str2double(Population{:});
else
    Population = tableSD.population(indSD(1));
end

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


%% Determine the startpoint and endpoint

if isempty(tableSD.endpoint_rough(indSD))
    
    % 1.Manual preliminary selection
    prompt = {'Start point:','End point'};
    dlgtitle = 'Set the rough fitting range';
    dims = [1 60];
    if isempty(indSD)
        definput = {'1',num2str(length(CDR))};
    elseif isempty(tableSD.startpoint_rough(indSD))
        definput = {'1',num2str(tableSD.endpoint_rough(indSD))};
    elseif isnan(tableSD.startpoint_rough(indSD))
        definput = {'1',num2str(tableSD.endpoint_rough(indSD))};
    else    
        definput = {num2str(tableSD.startpoint_rough(indSD)),num2str(tableSD.endpoint_rough(indSD))};
    end
    opts.Interpreter = 'tex';
    fitRange         = inputdlg(prompt,dlgtitle,dims,definput,opts);
    startpoint_rough = str2double(fitRange{1,1});
    endpoint_rough   = str2double(fitRange{2,1});
else
    startpoint_rough = tableSD.startpoint_rough(indSD);
    endpoint_rough   = tableSD.endpoint_rough(indSD);
end

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
CDR_wave = Deaths_wave./Population.*10^5;
time_wave = time(startpoint_rough:endpoint_rough);

% Then determine the exact startpoint and endpoint
% Smooth the data of daily deaths to find the peakpoint.
% Some African countries need larger smoothing steps.
if sum(ismember({'Cameroon','Zambia'},inputarea))
    smooth_step = 20;
else
    smooth_step = 10;
end
new_death = diff(Deaths_wave);
% if sum(new_death<0)
%     new_death(new_death<0) = '';
% end
deaths_smooth_10 = smooth(new_death,smooth_step);
[peak_y,peak_x]  = max(deaths_smooth_10(1:end));

% Find the startpoint that have grow to the number of 10% times the peak of the daily deaths.

[startpoint1,~] = find(deaths_smooth_10(1:peak_x) < 0.1*peak_y);
if isempty(startpoint1)
    [~,startpoint1] = min(abs(deaths_smooth_10(1:peak_x) - 0.1*peak_y));
end
if startpoint1(1)==1
    startpoint = startpoint1(end);
else
    startpoint = startpoint1(end);
end


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

if flag_endType == 1 && Deaths_wave(endpoint)<100
    flag_endType = 3;
end

%% Fit the data with the self-defining funtion: fit_CDR

CDR_fitted = CDR_wave(startpoint:endpoint);

duration_CDR = endpoint - startpoint + 1;
t_fit = 1:duration_CDR;


[para_CDR,RSD_CDR] = fit_CDR(t_fit,CDR_fitted);
s0_CDR  = para_CDR.s0;
tau_CDR = para_CDR.tau;
tc_CDR  = para_CDR.tc;

t_pre   = -29:1:length(time_wave(startpoint:endpoint))+60;
CDR_pre = s0_CDR./(1+exp(-1/tau_CDR*(t_pre-tc_CDR)));

time_pre = datetime(datestr(floor(datenum(time_wave(startpoint))-datenum(30))), 'Locale', 'en_US'):...
    1:datetime(datestr(floor(datenum(time_wave(endpoint))+datenum(60))), 'Locale', 'en_US');

% Calculate the value of K
t_start = 1;
t_end   = duration_CDR; 
CDR_start = s0_CDR./(1+exp(-1/tau_CDR*(t_start - tc_CDR))); 
CDR_end = s0_CDR./(1+exp(-1/tau_CDR*(t_end - tc_CDR))); 
K_CDR     = log((s0_CDR/CDR_start-1)/(s0_CDR/CDR_end-1)); 

% Confidence and Prediction Bounds (95%)
confidence_bounds = confint(para_CDR);
s0_lb  = confidence_bounds(1,1);
s0_ub  = confidence_bounds(2,1);
tau_lb = confidence_bounds(1,2);
tau_ub = confidence_bounds(2,2);
tc_lb  = confidence_bounds(1,3);
tc_ub  = confidence_bounds(2,3);

CDR_cb = predint(para_CDR,t_pre,0.95,'functional','on');





hold on
if endpoint+60>length(time_pre)
    iend = length(time_pre);
else
    iend = endpoint+60;
end

plot(time_wave(startpoint:endpoint),CDR_wave(startpoint:endpoint),'o',...
    'markeredgecolor',[0.80392	0.36078	0.36078],...
    'markersize',5,'LineWidth',2);
plot(time_pre(1:iend),CDR_pre(1:iend),'k-','LineWidth',1.5);

% plot confidence-bounds
AA = [time_pre(1:iend),time_pre(iend:-1:1)];
BB = [CDR_cb(1:iend,2);CDR_cb(iend:-1:1,1)];
p  = fill(AA,BB,'blue');
p.FaceColor = [0.3010 0.7450 0.9330];
p.EdgeColor = 'none';


plot(time_wave(startpoint:endpoint),CDR_wave(startpoint:endpoint),'o',...
    'markeredgecolor',[0.80392	0.36078	0.36078],...
    'markersize',5,'LineWidth',2);

plot(time_pre(1:iend),CDR_pre(1:iend),'k-','LineWidth',1.5);


ylabel('Deaths per 100k population','FontSize',20)
legend({'data','model','95% CI'},'location','northwest','FontSize',20)
legend('boxoff')
temp=ylim;
ylim([0 temp(2)]);
title([inputarea,' (Deaths = ',num2str(Deaths(startpoint_rough+endpoint-1)),')'],...
    'FontSize',16)
set(gca,'FontSize',16)
set(gca,'Layer','top');
box on


%% Save the data for analysis and drawing
if isempty(indSD)
    indSD = length(tableSD.confirmed_wave)+1;
    tableSD.iso_code(indSD) = inputarea;
    tableSD.location(indSD) = inputarea;
    tableSD.population(indSD) = Population;
end

tableSD.confirmed_wave(indSD)     = Confirmed(startpoint_rough+endpoint-1);
tableSD.deaths_wave(indSD)        = Deaths(startpoint_rough+endpoint-1);
tableSD.maxQuarantined_wave(indSD)= max(Quarantined(1:startpoint_rough+endpoint-1));

tableSD.flag_wave(indSD)= 1;

tableSD.flag_type(indSD)= flag_endType;

tableSD.tau(indSD)    = tau_CDR;
tableSD.tau_lb(indSD) = tau_lb;
tableSD.tau_ub(indSD) = tau_ub;

tableSD.s0(indSD)    = s0_CDR;
tableSD.s0_lb(indSD) = s0_lb;
tableSD.s0_ub(indSD) = s0_ub;

tableSD.tc(indSD)    = tc_CDR;
tableSD.tc_lb(indSD) = tc_lb;
tableSD.tc_ub(indSD) = tc_ub;

tableSD.duration(indSD)  = duration_CDR;
tableSD.K(indSD) = K_CDR;

tableSD.startpoint(indSD) = startpoint;
tableSD.endpoint(indSD)   = endpoint;
tableSD.startpoint_rough(indSD) = startpoint_rough;
tableSD.endpoint_rough(indSD) = endpoint_rough;

%% User-Defined Fit Functions

function [fitresult,gof] = fit_CDR(tData,CDR_fitted)

[tData,yData] = prepareCurveData(tData,CDR_fitted);

% Set up fittype and options.
ft = fittype( 's0/(1+exp(-1/tau*(x-tc)))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Trust-Region';
opts.Display = 'Off';
% opts.Robust  = 'LAR';
opts.Lower   = [0,0,0];
opts.Upper   = [1000,1000,1000];
opts.StartPoint = [0.1 1 1];
% Fit model to data.
[fitresult, gof] = fit( tData, yData, ft, opts );
end
end
