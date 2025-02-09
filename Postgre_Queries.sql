select * from walmart;


--1. What are the different payment methods, and how many transactions anditems were sold with each method?
--Query 1

select payment_method, sum(quantity) as noofitems, count(*) as nooftransactions
from walmart
group by payment_method;

--2. Which category received the highest average rating in each branch?
--Query 2

select * from walmart;

select * from
( 
  select branch,category, 
       avg(rating) as highest_rating,
       rank() over(partition by branch order by avg(rating) desc) as rnk
  from walmart
  group by branch,category
) 
where rnk = 1;


--3 What is the busiest day of the week for each branch based on transaction volume?
--query

--to_date(date,'dd/mm/yy') converts the datatype into date 

select * from walmart;

select * from
(
   select 
     branch,
     count(*) nooftransactions,
     to_char(date, 'Day') as day_name,
     rank() over(partition by branch order by count(*) desc) as rank
   from walmart
   group by 1,3
)
where rank = 1;

select extract(day from (date)) as day_name from walmart;

select to_char(date,'Day') as date1 from walmart;

-- How many items were sold through each payment method?
--Query 4

select * from walmart;

select 
  sum(quantity) as items_sold, 
  payment_method
from walmart
group by payment_method;


--What are the average, minimum, and maximum ratings for each category in each city
--Query 5

select * from walmart;

select city,
       category,
	   round(avg(rating),2) as average, 
	   max(rating) as max_rating, 
	   min(rating) as min_rating
from walmart
group by city, category;



-- What is the total profit for each category, ranked from highest to lowest?
--Query 6

select * from walmart;
--total_profit = quantity * unit_price * profit_margin

select 
   category, 
   (quantity * unit_price * profit_margin) as total_profit
from walmart
group by category,2
order by 2 desc;


-- What is the most frequently used payment method in each branch?
--Query 7
select * from walmart;

select * from 
(
    select 
       branch,
       payment_method, 
       count(*) as nooftransactions,
       rank() over(partition by branch order by count(*) desc) as rank
    from walmart
    group by 1,2
)
where rank = 1;




--How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
--Query 8

select * from walmart;

select branch,time
from walmart
group by branch,time;

select branch, count(*),
 case 
   when time::time between '09:00:00' and '13:00:00' then 'Morning shift'
   when time::time between '13:00:00' and '16:00:00' then 'Afternoon shift'
   when time::time between '16:00:00' and '19:00:00' then 'Evening shift'
   else 'other shift'
   end as shifts
from walmart
group by 1,3;


--other way

select branch,
   case
      when extract(hour from(time::time)) < 12 then 'morning'
	  when extract(hour from(time::time)) between 12 and 17 then 'afternoon'
	  when extract(hour from(time::time)) between 17 and 20 then 'evening'
	  else 'other shift'
	end as shifts,
	count(*)
from walmart
group by 1,2
order by 1,3 desc;



--9 Which branches experienced the largest decrease in revenue compared to the previous year?
--Query

--revenue calculation: (last_year_revenue - current_year_revenue) / last_year_revenue * 100
select * from walmart;
	
--comparision of previous year 2022 data and current year 2023

with last_year_revenue as
(
  select branch,
     sum(total) as revenue
  from walmart
  where extract(year from(date)) = '2022'
  group by branch
),
current_year_revenue as
(
  select branch,
    sum(total) as revenue
  from walmart
  where extract(year from(date)) = '2023'
  group by branch
)

select ls.branch,
    ls.revenue as last_year,
    cs.revenue as current_year,
    round((ls.revenue-cs.revenue)::numeric/ls.revenue::numeric * 100,2) as revenue_decrease
from last_year_revenue  ls
join current_year_revenue cs on cs.branch = ls.branch
where ls.revenue > cs.revenue
order by 4 desc
limit 5;

