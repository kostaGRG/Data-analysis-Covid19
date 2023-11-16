% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

% Function that returns the data for a specific country in some weeks.
% **Arguments**
% --> data: (table) pass the data to the function
% --> country_name: (string) name of the country
% --> year:(int) year to search
% --> from_week:(int) starting week of the search
% --> to_week:(int) last week of the search
% **Outputs**
% --> country_data: (table) return the asked data.
function country_data = getCountryData(data,country_name,year,from_week,to_week)
    rows = strcmp(data.country,country_name) & string(data.year_week) >= (string(year)+'-W'+string(from_week)) & string(data.year_week) <= (string(year)+'-W'+string(to_week));
    country_data = data(rows,:);    
end
