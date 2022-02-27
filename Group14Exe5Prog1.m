% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

clear
close all
clc

%% init

countries=["Ireland","Hungary","Iceland","Italy","Lithuania"];
foreign_data = readtable('ECDC-7Days-Testing.xlsx', 'PreserveVariableNames', true);
greek_data = readtable('FullEodyData.xlsx', 'PreserveVariableNames', true);

first_week = 38;
last_week = 50;
total_weeks = last_week - first_week + 1;

positivity_rates_foreign = zeros(total_weeks , 5);
positivity_rates_greek = zeros(total_weeks , 1);


%% Foreign Countries

count = 0;
for country= countries
    count = count + 1;
    rows = strcmp(foreign_data.country,country) & strcmp(foreign_data.level,'national');
    data_country = foreign_data(rows,{'year_week','positivity_rate'});
    
    
   
    
    i=0;
    for week=first_week:last_week       
        i = i+1;
        week2021 = '2021-W' + string(week);
        positivity_rates_foreign(i, count) = data_country(strcmp(data_country.year_week,week2021),'positivity_rate').positivity_rate; 
    end
end


%% Greece

% Rapid and PCR tests are calculated based on their previous value, but we
% want to calculate them daily. For that purpose, we have to find out their
% value the previous day before the starting point of our calculations.

week = '2021-W'+string(first_week-1);
rows = strcmp(greek_data.Week,week);
previous_day = greek_data(rows,{'PCR_Tests','Rapid_Tests'});


previous_day_pcr = previous_day.PCR_Tests;
previous_day_rapid = previous_day.Rapid_Tests;
previous_day_pcr = previous_day_pcr(7);
previous_day_rapid = previous_day_rapid(7);

modified_pcrTests = zeros(7,1);
modified_rapidTests = zeros(7,1);

for i = first_week:last_week
    count = i - last_week+total_weeks;
    week = '2021-W'+string(i);
    rows = strcmp(greek_data.Week,week);
    days = greek_data(rows,{'NewCases','PCR_Tests','Rapid_Tests'});
    
    newCases = days.NewCases;
    pcrTests= days.PCR_Tests;
    rapidTests = days.Rapid_Tests;
    
    modified_pcrTests(1) = pcrTests(1) - previous_day_pcr;
    modified_rapidTests(1) = rapidTests(1) - previous_day_rapid;
    for j =2:length(pcrTests)
        modified_pcrTests(j) = pcrTests(j) - pcrTests(j-1);
        modified_rapidTests(j) = rapidTests(j) - rapidTests(j-1);
    end
    previous_day_pcr = pcrTests(7);
    previous_day_rapid = rapidTests(7);
    
    positivity_rates_greek(count, 1) = 100*sum(newCases)/(sum(modified_pcrTests)+sum(modified_rapidTests));
end

%% Plotting

weeks = first_week:1:last_week;

for i = 1:5
    subplot(2,3,i);
    plot(weeks, positivity_rates_foreign(:,i),'.');
    title('Evolution of Positivity-Rate for: '+countries(i));
end

subplot(2,3,6)
plot(weeks, positivity_rates_greek,'.');
title('Evolution of Positivity-Rate for: Greece');

%% Correlation

Positivity_Rates = [ positivity_rates_greek positivity_rates_foreign ];

[pearson, p_param] = corrcoef(Positivity_Rates);

fprintf('<strong>Correlation factors between Greece and foreign countries</strong>\n');
for i = 1:5
    fprintf('The pearson correlation between Greece and '+countries(i)+' is rho = %.2f.\n',pearson(1,i+1));
end

fprintf('\n<strong>Significance Test for correlation about weekly positivity rate between Greece and foreign countries, using sigificance level of a =0.05 .</strong>\n');
for i =1:5
    if p_param(1, i+1) > 0.05
        fprintf('The p-value for hypothesis testing of no correlation is greater than alpha=0.05. So there is no proof that there is correlation between Greece and '+countries(i)+' weekly positivity rate.\n');
    else
        fprintf('The p-value for hypothesis testing of no correlation is less than alpha=0.05. So there is  proof that there is correlation between Greece and '+countries(i)+' weekly positivity rate.\n');
    end
    fprintf('The p-value is %.5f\n', p_param(1, i+1));
end

fprintf('\n<strong>Significance Test for correlation about weekly positivity rate between Greece and foreign countries, using sigificance level of a =0.01 .</strong>\n');
for i =1:5
    if p_param(1, i+1) > 0.01
        fprintf('The p-value for hypothesis testing of no correlation is greater than alpha=0.01. So there no is proof that there is correlation between Greece and '+countries(i)+' weekly positivity rate.\n');
    else
        fprintf('The p-value for hypothesis testing of no correlation is less than alpha=0.01. So there is  proof that there is correlation between Greece and '+countries(i)+' weekly positivity rate.\n');
    end
    fprintf('The p-value is %.5f\n', p_param(1, i+1));
end

% Randomization

n = length(positivity_rates_greek(:,1));
m = length(positivity_rates_foreign(:,1));
common_rates = zeros(n+m, 5);
for j = 1:5
    common_rates(:,j) = [ positivity_rates_greek; positivity_rates_foreign(:,j)];
end

B = 1000; % random iterations

rho_random = zeros(B,5);
for j =1:5
    for iB = 1:B
        rV = randperm(n+m);
        greek_rates = common_rates(rV(1:n));
        foreign_rates = common_rates(rV(n+1,n+m));
        R = corrcoef(greek_rates, foreign_rates);
        rho_random(iB,j) = R(1,2);
    end
end

total_rho_random = [];