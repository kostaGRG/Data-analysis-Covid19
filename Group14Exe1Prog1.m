close all
clear
clc

%% MEMBERS
% Konstantinos Gerogiannis
% Stavros Tsimpoukis

%% READ DATA FROM TABLE
data = readtable('ECDC-7Days-Testing.xlsx');
countries = readtable('EuropeanCountries.xlsx');
countries = table2array(countries(:,2));


%% CALCULATE WEEKS WITH MAXIMUM POSITIVITY RATE FOR YEARS 2020 AND 2021
rows = strcmp(data.country,'Ireland')& string(data.year_week) >= '2020-W45' & string(data.year_week) <= '2020-W50';
ireland_data = data(rows,:);    
positivity_rates = ireland_data.('positivity_rate');
[~,ind] = max(positivity_rates);
week_2020 = '2020-W' + string(44+ind);

rows = strcmp(data.country,'Ireland')& string(data.year_week) >= '2021-W45' & string(data.year_week) <= '2021-W50';
ireland_data = data(rows,:);    
positivity_rates = ireland_data.('positivity_rate');
[~,ind] = max(positivity_rates);
week_2021 = '2021-W' + string(44+ind);

%% HISTOGRAM OF COUNTRIES' POSITIVITY RATE FOR SPECIFIC WEEK OF 2020
rows = strcmp(data.year_week,week_2020) & strcmp(data.level,'national');
countries_2020 = data(rows,{'country','positivity_rate'});

toDelete = ~ismember(countries_2020.('country'),countries);
countries_2020(toDelete,:) = [];
if height(countries_2020) < 25
    fprintf('Data for some countries in week %s are missing.',week_2020);
end

figure(1);
clf;
positivity_rates = countries_2020.positivity_rate;
pd = fitdist(positivity_rates,'Exponential');
x_2020= 0:0.01*(max(positivity_rates)-min(positivity_rates)):1.5*max(positivity_rates);
y_2020= pdf(pd,x_2020);
plot(x_2020,y_2020,'-r','LineWidth',2);
hold on;
histogram(countries_2020.positivity_rate,5,'Facecolor','b','Normalization','pdf');
xlabel('Positivity rate');
title('Histogram for '+week_2020);


%% HISTOGRAM OF COUNTRIES' POSITIVITY RATE FOR SPECIFIC WEEK OF 2021
rows = strcmp(data.year_week,week_2021) & strcmp(data.level,'national');
countries_2021 = data(rows,{'country','positivity_rate'});

toDelete = ~ismember(countries_2021.('country'),countries);
countries_2021(toDelete,:) = [];
if height(countries_2021) < 25
    fprintf('Data for some countries in week %s are missing.',week_2021);
end

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
fprintf('Kai ta dyo istogrammata mporoun na parapempsoun se ek8etikh katanomh');
fprintf('8a prospa8hsoume twra na xrhsimopoihsoume thn katanomh tou 2020 sto istogramma tou 2021 kai to anti8eto, wste na doume an mporoun na proseggistoun me mia koinh katanomh');
 
figure(3);
clf;
histogram(countries_2020.positivity_rate,5,'Facecolor','b','Normalization','pdf');
hold on;
plot(x_2020,y_2020,'-r','LineWidth',2);
plot(x_2021,y_2021,'-g','LineWidth',2);
xlabel('Positivity rate');
legend('2020 histogram','exponential distribution for 2020','exponential distribution for 2021');
title('Histogram for '+week_2020+' using both exponential distributions');
        
figure(4);
clf;
histogram(countries_2021.positivity_rate,5,'Facecolor','b','Normalization','pdf');
hold on;
plot(x_2020,y_2020,'-r','LineWidth',2);
plot(x_2021,y_2021,'-g','LineWidth',2);
xlabel('Positivity rate');
legend('2021 histogram','exponential distribution for 2020','exponential distribution for 2021');
title('Histogram for '+week_2021+' using both exponential distributions');