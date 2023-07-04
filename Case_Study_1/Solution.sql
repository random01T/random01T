use case1;

select * from weekly_sales limit 10;

# DATA CLEANSING

create table clean_weekly_sales as 
select week_date, week(week_date) as week_number,
month(week_date) as month_number, year(week_date) as calender_year,
region, platform,
case 
when segment = null then 'Unknown'
else segment
end as segment,
case 
when right(segment,1) = '1' then 'Young Adults'
when right(segment,1) = '2' then 'Middle Aged'
when right(segment,1) in('3','4') then 'Retirees'
else 'Unknown'
end as age_band , 
case 
when left(segment,1) = 'C' then 'Couples'
when left(segment,1) = 'F' then 'Families'
else 'Unknown'
end as demographic,
customer_type, transactions, sales,
round(sales/transactions,2) as avg_transaction
from weekly_sales;

select * from weekly_sales limit 10;
select * from clean_weekly_sales limit 10;

## DATA EXPLORATION
#1. Which week numbers are missing from the dataset? 

# create a table with numbers from 1-100
create table seq100(x int auto_increment primary key); 
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 select x+50 from seq100;
select * from seq100;

#from the above table filter the numbers upto 52 'As there are 52 weeks in a year'
create table seq52 as (select x from seq100 limit 52);
select * from seq52;

#Solution
select distinct x as week_num from seq52
where x not in (select distinct week_number from clean_weekly_sales);

select distinct week_number from clean_weekly_sales;

#2.How many total transactions were there for each year in the dataset?
select calender_year,count(transactions) as No_of_Total_transactions
from clean_weekly_sales
group by calender_year;

select calender_year,sum(transactions) as Total_transactions
from clean_weekly_sales
group by calender_year;

#3. What are the total sales for each region for each month?
select region, month_number, sum(sales) as Total_Sales
from clean_weekly_sales
group by month_number, region;

#4. What is the total count of transactions for each platform?
select platform, count(transactions) as Total_count
from clean_weekly_sales
group by platform;

#5.What is the percentage of sales for Retail vs Shopify for each month?

with cte_monthly_platform_sales as
(select month_number, calender_year,platform,
sum(sales) as monthly_sales
from clean_weekly_sales
group by month_number,calender_year,platform)

select month_number,calender_year,
round(100*max(case when platform = 'Retail'
then monthly_sales else null end)/sum(monthly_sales),2)
as retail_percentage,
round(100*max(case when platform = 'shopify'
then monthly_sales else null end)/sum(monthly_sales),2)
as shopify_percentage
from cte_monthly_platform_sales
group by month_number, calender_year;

#6. What is the percentage of sales by demographic for each year in the dataset?
select calender_year, demographic,
sum(sales) as yearly_sales,
round(100*sum(sales)/sum(sum(sales))
over (partition by demographic),2)as percentage
from clean_weekly_sales
group by calender_year,demographic;

#7. Which age_band and demographic values contribute the most to Retail sales?
select age_band, demographic,sum(sales) as total_sales
from clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by total_sales desc;