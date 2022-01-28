% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

clear
close all
clc

data = readtable('FullEodyData.xlsx');

% As we calculated in Exercise1, 2021-W46 is the week with the highest
% Ireland's positivity rate among the last weeks of 2021.
% So we are gonna work with the last 12 weeks, starting from 2021-W35 to 2021-W46.
final_week = 46;
total_weeks = 12;
start_week = final_week-total_weeks+1;
% The following europe positivity rates have been collected from the url: https://www.stelios67pi.eu/testing.html
eu_positivity_rates = [2.7 2.5 2.2 2.1 2 2.2 2.5 2.8 3.7 4.5 5 5.5];

greece_positivity_rates = zeros(7,1);
% Rapid and PCR tests are calculated based on their previous value, but we
% want to calculate them daily. For that purpose, we have to find out their
% value the previous day before the starting point of our calculations.

week = '2021-W'+string(final_week - total_weeks);
rows = strcmp(data.Week,week);
previous_day = data(rows,{'PCR_Tests','Rapid_Tests'});


previous_day_pcr = previous_day.PCR_Tests;
previous_day_rapid = previous_day.Rapid_Tests;
previous_day_pcr = previous_day_pcr(7);
previous_day_rapid = previous_day_rapid(7);

modified_pcrTests = zeros(7,1);
modified_rapidTests = zeros(7,1);
greece_positivity_means = zeros(total_weeks,1);
down_confidence_intervals = zeros(total_weeks,1);
up_confidence_intervals = zeros(total_weeks,1);

for i = start_week:final_week
    count = i - final_week+total_weeks;
    week = '2021-W'+string(i);
    eu_positivity_rate = eu_positivity_rates(count);
    rows = strcmp(data.Week,week);
    days = data(rows,{'NewCases','PCR_Tests','Rapid_Tests'});
    
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
    
    fprintf('\n\n\nWeek: %d',i);
    greece_positivity_rates = 100*newCases./(modified_pcrTests+modified_rapidTests);
    [CI, difference, greece_positivity_mean] = Group14Exe3Func1(greece_positivity_rates, eu_positivity_rate);
    greece_positivity_means(count) = greece_positivity_mean; 
    down_confidence_intervals(count) = CI(1);
    up_confidence_intervals(count) = CI(2);
    fprintf('\n95 %% confidence intervals for greece''s positivity rates mean');
    fprintf('\n[%.3f%% %.3f%%]',CI(1),CI(2));
    fprintf('\nEurope positivity rate: %.2f%%',eu_positivity_rate);
    
    if difference ~= 0
        fprintf('\nIn this week we observe a big difference in greece''s and europe''s means of positivity rate:');
        fprintf('\nGreece''s positivity rate - Europe''s positivity rate = %.2f%%',difference);
    end
end

fprintf('\n\n\nThe previous statistics are summarized in the following plot:\n');
figure(1);
clf;
plot(start_week:final_week,greece_positivity_means,'.-c');
hold on;
plot(start_week:final_week,eu_positivity_rates,'.-k');
plot(start_week:final_week,down_confidence_intervals,'--r');
plot(start_week:final_week,up_confidence_intervals,'--r');
title('Weekly Greece''s and Europe''s positivity rates');
xlabel('Week number');
ylabel('Positivity rate');
legend('Greece''s positivity rate','Europe''s positivity rate','Greece''s positivity rate 95%% confidence intervals','Location','northwest');

