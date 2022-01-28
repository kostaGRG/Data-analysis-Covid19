% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

% Function to calculate in which week the positivity rate of this country
% is maximized.
function [ind,week] = Group14Exe1Func1(country_data,year,from_week)
    positivity_rates = country_data.('positivity_rate');
    [~,ind] = max(positivity_rates);
    week =string(year)+ '-W' + string(from_week-1+ind); 
end