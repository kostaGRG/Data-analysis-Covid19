% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

clear
close all
clc

%% init
country = 'Ireland'; % country A
data = readtable('ECDC-7Days-Testing.xlsx', 'PreserveVariableNames', true); % reading data 

rows = strcmp(data.country,country) & strcmp(data.level,'national');
data_country = data(rows,{'year_week','positivity_rate'}); % acquiring data concerning country A

% We fetch data from
% https://www.stelios67pi.eu/testing.html concerning weekly deaths.
%Sample1: starting from day 26/04/2020 or 2020-W17
%Sample2: starting from day 07/02/2021 or 2021-W05

data_weekly_deaths1 = [96;44;31;17;13;9;6;5;2;4;1;1;1;2;0;2]; % sample 1 weekly deaths
data_weekly_deaths2 = [76;53;38;37;21;23;11;16;10;13;10;7;7;3;4;0]; % sample 2 weekly deaths

%% Sample 1
% Sample 1: starting from 2020-W13 ( 5 weeks back ) to 2020-W33, we are going to acquire
% weekly positivity rates

first_week = 13;
last_week = 33;
total_weeks = last_week - first_week + 1;

positivity_rates1 = zeros(total_weeks, 1);

i=0;
for week=first_week:last_week       
    i = i+1;
    week2020 = '2020-W' + string(week);
    positivity_rates1(i, 1) = data_country(strcmp(data_country.year_week,week2020),'positivity_rate').positivity_rate; 
end

positivity_rates_matrix1 = [ positivity_rates1(1:16) positivity_rates1(2:17) positivity_rates1(3:18) positivity_rates1(4:19) positivity_rates1(5:20)]; % matrix containing 16 week duration data, going back 5 weeks from first week

stats1 = zeros(4,5); % matrix to contain the stats of each model


% getting stats for the regression model of each week delay
[~,~,~,~,stats1(:,1)] = regress(data_weekly_deaths1, [ ones(size(positivity_rates_matrix1(:,1))) positivity_rates_matrix1(:,1)]);
[~,~,~,~,stats1(:,2)] = regress(data_weekly_deaths1, [ ones(size(positivity_rates_matrix1(:,2))) positivity_rates_matrix1(:,2)]);
[~,~,~,~,stats1(:,3)] = regress(data_weekly_deaths1, [ ones(size(positivity_rates_matrix1(:,3))) positivity_rates_matrix1(:,3)]);
[~,~,~,~,stats1(:,4)] = regress(data_weekly_deaths1, [ ones(size(positivity_rates_matrix1(:,4))) positivity_rates_matrix1(:,4)]);
[~,~,~,~,stats1(:,5)] = regress(data_weekly_deaths1, [ ones(size(positivity_rates_matrix1(:,5))) positivity_rates_matrix1(:,5)]);

% deciding the best delay according to the R-square
max = stats1(1,1); % R-square of first model ( 5 weeks back )
best_week_delay1 = 1;
for i = 2:5
    if stats1(1,i) > max
        best_week_delay1 = i;
    end
end


%% Sample 2
% Sample 2: starting from 2021-W01 ( 5 weeks back ) to 2021-W21, we are going to acquire
% weekly positivity rates

first_week = 1;
last_week = 21;
total_weeks = last_week - first_week + 1;

positivity_rates2 = zeros(total_weeks, 1);

i=0;
for week=first_week:9       
    i = i+1;
    week2021 = '2021-W0' + string(week);
    positivity_rates2(i, 1) = data_country(strcmp(data_country.year_week,week2021),'positivity_rate').positivity_rate; 
end

for week=10:last_week       
    i = i+1;
    week2021 = '2021-W' + string(week);
    positivity_rates2(i, 1) = data_country(strcmp(data_country.year_week,week2021),'positivity_rate').positivity_rate; 
end

positivity_rates_matrix2 = [ positivity_rates2(1:16) positivity_rates2(2:17) positivity_rates2(3:18) positivity_rates2(4:19) positivity_rates2(5:20)]; % matrix containing 16 week duration data, going back 5 weeks from first week

stats2 = zeros(4,5); % matrix to contain the stats of each model

% getting stats for the regression model of each week delay
[~,~,~,~,stats2(:,1)] = regress(data_weekly_deaths2, [ ones(size(positivity_rates_matrix2(:,1))) positivity_rates_matrix2(:,1)]);
[~,~,~,~,stats2(:,2)] = regress(data_weekly_deaths2, [ ones(size(positivity_rates_matrix2(:,2))) positivity_rates_matrix2(:,2)]);
[~,~,~,~,stats2(:,3)] = regress(data_weekly_deaths2, [ ones(size(positivity_rates_matrix2(:,3))) positivity_rates_matrix2(:,3)]);
[~,~,~,~,stats2(:,4)] = regress(data_weekly_deaths2, [ ones(size(positivity_rates_matrix2(:,4))) positivity_rates_matrix2(:,4)]);
[~,~,~,~,stats2(:,5)] = regress(data_weekly_deaths2, [ ones(size(positivity_rates_matrix2(:,5))) positivity_rates_matrix2(:,5)]);

% deciding the best delay according to the R-square
max = stats2(1,1); % R-square of first model ( 5 weeks back )
best_week_delay2 = 1;
for i = 2:5
    if stats2(1,i) > max
        best_week_delay2 = i;
    end
end


%% Results
fprintf('<strong>The most effective models for the two samples</strong>\n\n');
fprintf('Sample 1: The best model is to take a delay of %d weeks.\nThe R-square statistic to this choice is R^2 = %.5f\n\n', (5-best_week_delay1),stats1(1, best_week_delay1)); % normalizing the week delay
fprintf('Sample 2: The best model is to take a delay of %d weeks.\nThe R-square statistic to this choice is R^2 = %.5f\n', (5-best_week_delay2),stats2(1, best_week_delay2)); % % normalizing the week delay

% As we see from the results, the two models do not 'agree' with each
% other.