% This file is used to fit the data of Crude Death Rate
% Author: Lei Zhang
% Last modified: 20-04-2021

function [CDR_fitted,CDR_pre,CDR_cb,s0_CDR,tau_CDR,tc_CDR,time_pre,t_pre] = ...
    FitMortality(inputarea)


% Download the data from ref [1] and read them with the function getDataCOVID

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


% read the State-Data.csv that including the data of median-age/beds/physicians...

tableSD    = readtable('State-Data-wave1.csv');
indSD      = find(strcmp(tableSD.location,inputarea)==1);
Population = tableSD.population(indSD(1));

% Fit the data from the date when having the deaths 

indRemoved = find(Deaths<= 0);

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

% Fit the data of the Crude Death Rate (CDR)

startpoint_rough = tableSD.startpoint_rough(indSD);
endpoint_rough   = tableSD.endpoint_rough(indSD);
startpoint = tableSD.startpoint(indSD);
endpoint   = tableSD.endpoint(indSD);

if startpoint_rough > 1
    Deaths_wave = Deaths(startpoint_rough:endpoint_rough)-...
        Deaths(startpoint_rough);
else
    Deaths_wave = Deaths(startpoint_rough:endpoint_rough);
end

CDR_wave = Deaths_wave./Population.*10^5;
time_wave = time(startpoint_rough:endpoint_rough);



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


% Confidence and Prediction Bounds (95%)
confidence_bounds = confint(para_CDR);
s0_lb  = confidence_bounds(1,1);
s0_ub  = confidence_bounds(2,1);
tau_lb = confidence_bounds(1,2);
tau_ub = confidence_bounds(2,2);
tc_lb  = confidence_bounds(1,3);
tc_ub  = confidence_bounds(2,3);

CDR_cb = predint(para_CDR,t_pre,0.95,'functional','on');

CDR_pre  = CDR_pre(1:140);
CDR_cb   = CDR_cb(1:140,:);
time_pre = time_pre(1:140);
t_pre    = t_pre(1:140);
%% User-Defined Fit Functions

    function [fitresult, gof] = fit_CDR(xData,CDR_fitted)

    [xData, yData] = prepareCurveData(xData,CDR_fitted);

    % Set up fittype and options.
    ft = fittype( 's0/(1+exp(-1/tau*(x-tc)))', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Algorithm = 'Trust-Region';
    opts.Display = 'Off';
%     opts.Robust = 'LAR';
    opts.Lower=[0,0,0];
    opts.Upper=[1000,1000,1000];
    opts.StartPoint = [0.1 1 1];
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    end
end