% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

% Function that calculates which week has the maximum positivity rate for
% this country.
% ***Arguments***
% --> country_data: (table) data for a specific country
% --> year: (int) in which year to search
% --> from_week: (int) starting week of the data given in table
%                 country_data.
% **Outputs**
% --> ind:(int) country_data table's index  where positivity rate is
%           maximized.
% --> week:(string) week where positivity rate is maximized, using the
%           suitable format.

function [ind,week] = Group14Exe1Func1(country_data,year,from_week)
    positivity_rates = country_data.('positivity_rate');
    [~,ind] = max(positivity_rates);
    week =string(year)+ '-W' + string(from_week-1+ind); 
end