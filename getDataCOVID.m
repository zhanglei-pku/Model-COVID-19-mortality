function [tableConfirmed,tableDeaths,tableRecovered,time] = getDataCOVID()
% The code used to collect the update COVID-19 data from the 
% John Hopkins university [1] is modified from the work of Cheynet, E [2].
%
% Modified: Lei Zhang
% Last Modified Date: 2020-08-29
%
% References:
% [1] https://github.com/CSSEGISandData/COVID-19
% [2] Cheynet, E. Generalized SEIR Epidemic Model (Fitting and Computation). Zenodo, 2020, doi:10.5281/ZENODO.3911854.
%
%% Import the data
status = {'confirmed','deaths','recovered'};
address = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/';

for ii=1:numel(status)
    
    filename = ['time_series_covid19_',status{ii},'_global'];
    fullName = [address,filename,'.csv'];
    options =  weboptions('Timeout',60);
%     websave([status{ii} '.csv'],fullName,options);
    
    if strcmpi(status{ii},'Confirmed')
        tableConfirmed = readtable([status{ii} '.csv']);
        
        widthConfirmed = width(tableConfirmed);
        opts = delimitedTextImportOptions("NumVariables", widthConfirmed);
        opts.VariableNames = ["ProvinceState", "CountryRegion", "Lat", "Long", repmat("data",1,widthConfirmed-4)];
        opts.VariableTypes = ["string", "string", repmat("double",1,widthConfirmed-2)];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        
        tableConfirmed = readtable([status{ii} '.csv'],opts);
    elseif strcmpi(status{ii},'Deaths')
        tableDeaths = readtable([status{ii} '.csv']);
        
        widthDeaths = width(tableDeaths);
        opts = delimitedTextImportOptions("NumVariables", widthDeaths);
        opts.VariableNames = ["ProvinceState", "CountryRegion", "Lat", "Long", repmat("data",1,widthDeaths-4)];
        opts.VariableTypes = ["string", "string", repmat("double",1,widthDeaths-2)];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        
        tableDeaths = readtable([status{ii} '.csv'],opts);
        
    elseif strcmpi(status{ii},'Recovered')
        tableRecovered = readtable([status{ii} '.csv']);
        
        widthRecovered = width(tableRecovered);
        opts = delimitedTextImportOptions("NumVariables", widthRecovered);
        opts.VariableNames = ["ProvinceState", "CountryRegion", "Lat", "Long", repmat("data",1,widthRecovered-4)];
        opts.VariableTypes = ["string", "string", repmat("double",1,widthRecovered-2)];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        
        tableRecovered = readtable([status{ii} '.csv'],opts);
    else
        error('Unknown status')
    end
end

time = datetime(2020,01,22):days(1):datetime(datestr(floor(now)), 'Locale', 'en_US')-datenum(1);

% When the data do not update timely, the actual data time are used.

if length(time)>widthConfirmed-4
    time = time(1:widthConfirmed-4);
end

end