close all
clear
clc

%% TEAM MEMBERS
% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

%% READ DATA FROM TABLE
data = readtable('ECDC-7Days-Testing.xlsx','PreserveVariableNames', true);
countries = readtable('EuropeanCountries.xlsx','PreserveVariableNames', true);
countries = table2array(countries(:,2));

%% CALCULATE WEEKS WITH MAXIMUM POSITIVITY RATE FOR YEARS 2020 AND 2021
[index_2020,week_2020] = calculateWeekWithMaxPositiveRate(getCountryData(data,'Ireland',2020,45,50),2020,45);
[index_2021,week_2021] = calculateWeekWithMaxPositiveRate(getCountryData(data,'Ireland',2021,45,50),2021,45);

fprintf('%s is the week with maximum positivity rate for the specified weeks of 2020.\n',week_2020);
fprintf('Additionally, %s is the week with maximum positivity rate for the specified weeks of 2021.\n\n',week_2021);
%% HISTOGRAM OF COUNTRIES' POSITIVITY RATE FOR SPECIFIC WEEK OF 2020
rows = strcmp(data.year_week,week_2020) & strcmp(data.level,'national');
countries_2020 = data(rows,{'country','positivity_rate'}); %countries_2020 is a table with all countries data in a specific week

toDelete = ~ismember(countries_2020.('country'),countries);
countries_2020(toDelete,:) = [];    %Delete countries that are not listed in array named 'countries'

height = height(countries_2020);
if height < 25      %Check if there is some missing data
    fprintf('Data for some countries in week %s are missing.\n',week_2020);
    m = 3;
    fprintf('We will fill this missing data, calculating the positivity rate mean value from %d previous and %d later weeks of this country\n',m,m);
    rows = ~ismember(countries,countries_2020.country);
    country_names = countries(rows);
    for i = 1:length(country_names)
        cell = {string(country_names(i)),fillMissingData(data,country_names(i),2020,index_2020,m)};
        countries_2020 = [countries_2020; cell];    %Fill missing data
    end
end

figure(1);
clf;
positivity_rates = countries_2020.positivity_rate;
pd = fitdist(positivity_rates,'Exponential');
x_2020= 0:0.01*(max(positivity_rates)-min(positivity_rates)):1.5*max(positivity_rates);
y_2020= pdf(pd,x_2020);
bins = 5;
plot(x_2020,y_2020,'-r','LineWidth',2);
hold on;
histogram(countries_2020.positivity_rate,bins,'Facecolor','b','Normalization','pdf');
xlabel('Positivity rate');
ylabel('Probability');
title('Histogram for '+week_2020);


%% HISTOGRAM OF COUNTRIES' POSITIVITY RATE FOR SPECIFIC WEEK OF 2021
% We follow the same steps for week of 2021.
rows = strcmp(data.year_week,week_2021) & strcmp(data.level,'national');
countries_2021 = data(rows,{'country','positivity_rate'});

toDelete = ~ismember(countries_2021.('country'),countries);
countries_2021(toDelete,:) = [];


figure(2);
clf;
positivity_rates = countries_2021.positivity_rate;
pd = fitdist(positivity_rates,'Exponential');
x_2021= 0:0.01*(max(positivity_rates)-min(positivity_rates)):1.5*max(positivity_rates);
y_2021= pdf(pd,x_2021);
plot(x_2021,y_2021,'-r','LineWidth',2);
hold on;
histogram(countries_2021.positivity_rate,5,'Facecolor','b','Normalization','pdf');
xlabel('Positivity rate');
title('Histogram for '+week_2021);

%% CHECK IF WE CAN USE A COMMON DISTRIBUTION FOR BOTH HISTOGRAMS
fprintf('Both histograms can be approached  by  exponential distribution.\n');
fprintf('Now, we will try to approach 2021s histogram by 2020s exponential distribution and vice versa, in order to check if we can use only 1 distribution for both histograms.');
 
figure(3);
clf;
subplot(1,2,1);
histogram(countries_2020.positivity_rate,5,'Facecolor','b','Normalization','pdf');
hold on;
plot(x_2020,y_2020,'-r','LineWidth',2);
plot(x_2021,y_2021,'-g','LineWidth',2);
xlabel('Positivity rate');
legend('2020 histogram','exponential distribution for 2020','exponential distribution for 2021');
title('Histogram for '+week_2020+' using both exponential distributions');
        
subplot(1,2,2);
histogram(countries_2021.positivity_rate,5,'Facecolor','b','Normalization','pdf');
hold on;
plot(x_2020,y_2020,'-r','LineWidth',2);
plot(x_2021,y_2021,'-g','LineWidth',2);
xlabel('Positivity rate');
legend('2021 histogram','exponential distribution for 2020','exponential distribution for 2021');
title('Histogram for '+week_2021+' using both exponential distributions');

% PS: We made effort to keep the code as automated as possible. That's the
% reason we used a dynamic way to calculate the missing data and also we
% tried our program to be able to be used in various situations with some
% little changes.