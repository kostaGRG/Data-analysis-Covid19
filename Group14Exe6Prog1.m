% Konstantinos Gerogiannis  AEM:9638
% Stavros Tsimpoukis        AEM:9963

clear
close all
clc

%% init
alpha = 0.05; % significance level
B = 1000; % Bootstrap iterations

% From the previous exercise we can conclude that the biggest correlation,
% among Greece and the foreign countries, is between Greece-Lithuania and
% Greece-Hungary. So now we are going to check wether the difference
% between their correlation factor is significant or not.

countries=["Hungary","Lithuania"];
foreign_data = readtable('ECDC-7Days-Testing.xlsx', 'PreserveVariableNames', true);
greek_data = readtable('FullEodyData.xlsx', 'PreserveVariableNames', true);

first_week = 38;
last_week = 50;
total_weeks = last_week - first_week + 1;

positivity_rates_foreign = zeros(total_weeks , 2);
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

Pair_Samples = [positivity_rates_greek positivity_rates_foreign(:,1);positivity_rates_greek positivity_rates_foreign(:,2)]; % common sample { [AB], [AC] }

boot_rho_diff = zeros(B,1);

for i = 1:B
    u = unidrnd(2*length(positivity_rates_greek), 2*length(positivity_rates_greek), 1); % random selecion
    limit = length(u)/2; 
    first = u(1 : limit); % first 'n' samples from common sample ( n is reference to Lecture 3 Bootstrap hypothesis testing, Data Analysis Course THMMY)
    last = u( (limit+1) : length(u)); % last 'm' samples from common sample ( m is reference to Lecture 3 Bootstrap hypothesis testing, Data Analysis Course THMMY)
    grc_hun = Pair_Samples( first, :  ) ; % Greece Hungary pair sample 
    grc_lith = Pair_Samples( last, : ) ; % Greece Lithuania pair sample
    
    rhoGH = corrcoef(grc_hun);   
    rhoGL = corrcoef(grc_lith);
    
    boot_rho_diff(i) = rhoGH(1,2) - rhoGL(1,2); 
end

R = corrcoef([positivity_rates_greek positivity_rates_foreign]);

bootSample_plus_original = [ ( R(1,2) - R(1,3)) ; boot_rho_diff ];
[~, i ] = sort(bootSample_plus_original);
rank = find( i == 1 );


acceptance_area = [(B+1)*alpha/2 (B+1)*(1-alpha/2)]; % area where null Hypothesis is not rejected

if ( rank > acceptance_area(1) && rank < acceptance_area(2) )
    fprintf('The rank of the original difference of correlation factors between Greece and the other two countries (Hungary, Lithuania) is included in the acceptance area.\nSo we cannot reject the null Hypothesis, at a significance level of a=0.05. In that case we can say that there is no significant difference between the two correlation factors.\n');
else
    fprintf('The rank of the original difference of correlation factors between Greece and the other two countries (Hungary, Lithuania) is not included in the acceptance area.\nSo we can reject the null Hypothesis, at a significance level of a=0.05. In that case we can say that there is significant difference between the two correlation factors.\n');
end