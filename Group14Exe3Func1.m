% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

function [CI,difference, greece_positivity_mean] = Group14Exe3Func1(greece_positivity_rates, eu_positivity_rate)
    B=1000;
    greece_positivity_mean = mean(greece_positivity_rates);
    CI = bootci(B, @mean, greece_positivity_rates);
    if (eu_positivity_rate > CI(1)) && (eu_positivity_rate < CI(2))
        difference = 0;
    else
        difference = greece_positivity_mean - eu_positivity_rate;
end