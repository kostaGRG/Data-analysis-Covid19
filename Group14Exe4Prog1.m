% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

clear
close all
clc

% Our country is Ireland
% The rest 4 countries are: Hungary, Iceland, Italy, Lithuania

% This technique established in an old version of Matlab, Matlab R2016,
% and is the only way that we found to create a string matrix, where double
% quotes are mandatory.
countries=["Ireland","Hungary","Iceland","Italy","Lithuania"];
data = readtable('ECDC-7Days-Testing.xlsx');
for country= countries
    rows = strcmp(data.country,country) & strcmp(data.level,'national');
    data_country = data(rows,{'year_week','positivity_rate'});

    first_week = 42;
    last_week = 50;

    positivity_rates2020 = zeros(last_week - first_week + 1,1);
    positivity_rates2021 = zeros(last_week - first_week + 1,1);
    count = 0;
    
    %In this loop we get positivity rates of every country in those weeks. 
    for week=first_week:last_week
        count = count + 1;
        week2020 = '2020-W' + string(week);
        week2021 = '2021-W' + string(week);
        positivity_rate2020 = data_country(strcmp(data_country.year_week,week2020),'positivity_rate').positivity_rate;
        positivity_rate2021 = data_country(strcmp(data_country.year_week,week2021),'positivity_rate').positivity_rate;

        if isempty(positivity_rate2020)
            positivity_rate2020 = fillData(data,country,2020,week);
        end
        if isempty(positivity_rate2021)
            positivity_rate2021 = fillData(data,country,2021,week);
        end
        positivity_rates2020(count) = positivity_rate2020;
        positivity_rates2021(count) = positivity_rate2021;
    end

    % positivity rates of the country have been calculated and we can now calculate the
    % parametric confidence interval (ci) for mean difference between these
    % periods

    differences = positivity_rates2021 - positivity_rates2020;
    figure();
    clf;
    plot(first_week:last_week,differences,'.-k');
    xlabel('week');
    ylabel('means'' differences');
    title(sprintf('Country: %s',country));
    
    % Parametric confidence interval for mean difference
    [~,~,parametricCI] = ttest2(positivity_rates2021,positivity_rates2020,'alpha',0.05);

    % bootstrap confidence interval for mean difference
    B = 1000;
    n = length(positivity_rates2020);
    bootstrap_means = zeros(B,1);
    for i=1:B
        random_vector = unidrnd(n,n,1);
        mean2020 = mean(positivity_rates2020(random_vector));
        random_vector = unidrnd(n,n,1);
        mean2021 = mean(positivity_rates2021(random_vector));
        bootstrap_means(i) = mean2021 - mean2020;
    end
    alpha = 0.05;
    bootstrap_means = sort(bootstrap_means);
    CI(1) = bootstrap_means(round(B*alpha/2));
    CI(2) = bootstrap_means(round(B*(1-alpha)/2));

    fprintf('\n\n<strong> Country: %s</strong>\n',country);
    fprintf('Parametric confidence interval for means'' differences:\n');
    fprintf('\t\t\t[%.2f %.2f]\n',parametricCI(1),parametricCI(2));

    if 0 > parametricCI(1) && 0 < parametricCI(2)
        fprintf('Based on the 95%% confidence interval, it seems that there are\nno significant differences in positivity rate between 2020 and 2021\n');
    elseif parametricCI(2) < 0
        fprintf('Based on the 95%% confidence interval, it seems that there are\nsignificant differences in positivity rate between 2020 and 2021:\npositivity rate 2021 < positivity rate 2020\n');
    else
        fprintf('Based on the 95%% confidence interval, it seems that there are\nsignificant differences in positivity rate between 2020 and 2021:\npositivity rate 2021 > positivity rate 2020\n');
    end
    
    fprintf('\nBootstrap confidence interval for means'' differences:\n');
    fprintf('\t\t\t[%.2f %.2f]\n',CI(1),CI(2));

    if 0 > CI(1) && 0 < CI(2)
        fprintf('Based on the 95%% confidence interval, it seems that there are\nno significant differences in positivity rate between 2020 and 2021\n');
    elseif CI(2) < 0
        fprintf('Based on the 95%% confidence interval, it seems that there are\nsignificant differences in positivity rate between 2020 and 2021:\npositivity rate 2021 < positivity rate 2020\n');
    else
        fprintf('Based on the 95%% confidence interval, it seems that there are\nsignificant differences in positivity rate between 2020 and 2021:\npositivity rate 2021 > positivity rate 2020\n');
    end
    pause;
end
    
% As we can see from the outputs and the plots, there is no rule that 5
% countries agree to. Each country has its own behaviour, as there are
% countries such as Hungary, where it seems that the results from 2020 and
% 2021 are similar, but if we observe Ireland's results, we can see that
% there is a big difference in positivity rates, where 2021's positivity
% rate is greater than 2020's. Finally, Italy gives us an example of the
% opposite situation, where 2021's positivity rate is lower than 2020's.
% So we are sure that the results differ from country to country.



%In this function we call a function used in exercise1.
%Function fillData is similar to Group14Exe1Func2, but now we use only the 
%5 previous weeks.
function predicted_positivity_rate  = fillData(data,country_name,year,week)
    country_data = Group14Exe1Func3(data,country_name,year,week-5,week);
    positivity_rates = country_data.positivity_rate;
    predicted_positivity_rate = mean(positivity_rates);
end

