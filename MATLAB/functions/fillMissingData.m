% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

% Returns a possible value for the missing field, based on the previous and
% the next m weeks' results.
% **Arguments**
% --> data: (table) pass the data to the function
% --> country_name: (string) name of the country
% --> year:(int) year to search
% --> week:(int) week to search
% **Outputs**
% --> predicted_positivity_rate: (float)
function predicted_positivity_rate  = fillMissingData(data,country_name,year,week,m)
    country_data = getCountryData(data,country_name,year,week-m,week+m);
    positivity_rates = country_data.positivity_rate;
    predicted_positivity_rate = mean(positivity_rates);
end
