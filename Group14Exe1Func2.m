% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

% Returns a possible value for the missing field, based on the previous and
% the next 5 weeks results.
function predicted_positivity_rate  = Group14Exe1Func2(data,country_name,year,week)
    country_data = Group14Exe1Func3(data,country_name,year,week-5,week+5);
    positivity_rates = country_data.positivity_rate;
    predicted_positivity_rate = mean(positivity_rates);
end