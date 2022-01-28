% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

% Function that returns the data for a specific country in some weeks
function country_data = Group14Exe1Func3(data,country_name,year,from_week,to_week)
    rows = strcmp(data.country,country_name) & string(data.year_week) >= (string(year)+'-W'+string(from_week)) & string(data.year_week) <= (string(year)+'-W'+string(to_week));
    country_data = data(rows,:);    
end