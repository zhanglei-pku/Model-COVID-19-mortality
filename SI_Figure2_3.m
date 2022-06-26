% This file is used to fit the data of Crude Death Rate
% Author: Lei Zhang
% Last modified: 18-07-2021


%% Download and read the COVID-Data with the function getDataCOVID
clearvars;
close all;
clc;
tableSD = readtable('State-Data-wave1.csv');
[tableConfirmed,tableDeaths,tableRecovered,time] = getDataCOVID();
fprintf(['Most recent update: ',datestr(time(end)),'\n'])
CountryD = unique(tableDeaths.CountryRegion);

positon_7p4 = [917,-22,680,1006];%7×4

gcf1 = figure('position',positon_7p4);
gcf_t1 = tiledlayout(7,4,'TileSpacing','tight','Padding','tight');
nn = 0;
inputarea = [];
for k = 1:length(CountryD)
    % Clear the variables before each loop
    clearvars -except tableSD tableConfirmed tableDeaths tableRecovered...
         time CountryD k nn gcf1 gcf_t1 gcf2 gcf_t2 inputarea
    
    
    
    
    if strcmp(inputarea,'Uzbekistan')
        inputarea = 'Wuhan';
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
        inputarea = CountryD(k);
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
    
    
    indSD   = find(strcmp(tableSD.location,inputarea)==1);
    
    if isempty(indSD)
        warning('Could not find the country or region,please check the inputarea (The first letter should be capitalized).')
        continue
    else
        Population = tableSD.population(indSD(1));
        
    end

    %% Fit the data from the date when having the deaths 
    minNum=0;
    indRemoved = find(Deaths<=minNum);
    if ~isempty(indRemoved)
        Recovered = Recovered(indRemoved(end)+1:end);
        Deaths    = Deaths(indRemoved(end)+1:end);
        Confirmed = Confirmed(indRemoved(end)+1:end);
        time0     = time(indRemoved(end)+1:end);
    else
        time0     = time;
    end
    
    if isempty(Deaths)
        warning('"Deaths" is an empty array. Check the value of "minNum". Computation aborted.')
        continue
    end

    
    %% Fit the data with the self-defining funtion: fit_CDR
    % read the State-Data.csv that including the data of countries
    startpoint_rough = tableSD.startpoint_rough(indSD);
    endpoint_rough = tableSD.endpoint_rough(indSD);
    startpoint = tableSD.startpoint(indSD);
    endpoint = tableSD.endpoint(indSD);
    
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
    time_wave = time0(startpoint_rough:endpoint_rough);
    
    CDR_fitted = CDR_wave(startpoint:endpoint);
    
    duration_CDR  = endpoint - startpoint + 1;
    t_fit = 1:duration_CDR;
    
    % Fit the data with the self-defining funtion: fit_CDR
    [para_CDR,RSD_CDR] = fit_CDR(t_fit,CDR_fitted);
    s0_CDR  = para_CDR.s0;
    tau_CDR = para_CDR.tau;
    tc_CDR  = para_CDR.tc;
    
    
    t_pre   = -29:1:length(time0(startpoint:end))+60;
    CDR_pre = s0_CDR./(1+exp(-1/tau_CDR*(t_pre - tc_CDR)));
    
    time_pre = datetime(datestr(floor(datenum(time0(startpoint))-datenum(30))), 'Locale', 'en_US'):...
        1:datetime(datestr(floor(datenum(time0(end))+datenum(60))), 'Locale', 'en_US');

    
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
    
    
    %% Plot the results
    nexttile([1,1])
    hold on
    
    plot(time0(startpoint:endpoint),CDR_wave(startpoint:endpoint),'o',...
        'markeredgecolor',[0.80392	0.36078	0.36078],...
        'markersize',3,'LineWidth',0.5);
    plot(time_pre(1:endpoint+60),CDR_pre(1:endpoint+60),'k-','LineWidth',1);

    % plot confidence-bounds
    AA = [time_pre(1:endpoint+60) time_pre(endpoint+60:-1:1)];
    BB = [CDR_cb(1:endpoint+60,2);CDR_cb(endpoint+60:-1:1,1)];
    p  = fill(AA,BB,'red');
    p.FaceColor = [0.3010 0.7450 0.9330];
    p.EdgeColor = 'none';

    plot(time0(startpoint:endpoint),CDR_wave(startpoint:endpoint),'o',...
        'markeredgecolor',[0.80392	0.36078	0.36078],...
        'markersize',3,'LineWidth',0.5);
    
    plot(time_pre(1:endpoint+60),CDR_pre(1:endpoint+60),'k-','LineWidth',1);
    
    ylabel('Mortality','FontSize',8)

    temp=ylim;
    ylim([0 temp(2)]);
    title(inputarea,'FontSize',12)
    set(gca,'FontSize',8)
    set(gca,'Layer','top');
    box on
    
    nn = nn +1;
    
    if nn == 27
        
        lgd = legend({'data','model','95% CI'},'FontSize',12,'numcolumns',1);
        lgd.Layout.Tile = 28;
        title(gcf_t1,'54 areas in the first wave (1)','FontWeight','bold','FontSize',16)
        
        positon_7p4 = [917,-22,680,1006];
        gcf2 = figure('position',positon_7p4);
        gcf_t2 = tiledlayout(7,4,'TileSpacing','tight','Padding','tight');
    end
    
end
lgd = legend({'data','model','95% CI'},'FontSize',12,'numcolumns',1);
lgd.Layout.Tile = 28;
title(gcf_t2,'54 areas in the first wave (2)','FontWeight','bold','FontSize',16)

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