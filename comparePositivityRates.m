% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

% Function that calculates 95% bootstrap confidence intervals for greece's
% positivity mean.
% **Arguments**
% --> greece_positivity_rates: (matrix) Positivity rates for 7 days of the week
% --> eu_positivity_rate: (float) Europe positivity rate for this week
% **Outputs**
% --> CI: Confidence interval
% --> difference: (float) difference between greece's and europe's
%                   positivity rates. If this difference is small, 0 is 
%                   returning, else
%                   difference = greece positivity - europe positivity.
% --> greece_positivity_mean: Greece's positivity mean calculated by
%                             bootstrap.

function [CI,difference, greece_positivity_mean] = comparePositivityRates(greece_positivity_rates, eu_positivity_rate)
    B=1000;
    greece_positivity_mean = mean(greece_positivity_rates);
    CI = bootci(B, @mean, greece_positivity_rates);
    if(eu_positivity_rate > CI(1)) && (eu_positivity_rate < CI(2))
        difference = 0;
    else
        difference = greece_positivity_mean - eu_positivity_rate;
    end
end