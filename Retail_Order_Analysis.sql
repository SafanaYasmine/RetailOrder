select top 5 * from  df_orders;
--1. find top 10 highest reveue generating products 
--select product_id,sum(profit) as Revenue from df_orders group by product_id order by 2 desc;
select top 10 product_id,sum(sale_price) as sales from df_orders group by product_id order by 2 desc;


--2. find top 5 highest selling products in each region
-- cte finds sum of sales in each region for each product
-- ranking it and select top 5 ranks in each region whoch gives top 5 sales in each region
with cte as(
select region,product_id,sum(sale_price) as sales from df_orders group by region,product_id) -- order by region,sales desc)
select * from (
select *,
row_number() over (partition by region order by sales desc) as rn from cte) A where rn<=5;

-- 3. find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
-- cte finds month, year, total_sales
-- pivoting month, total_sales_2022, total_sales_2023
with cte as(
select year(order_date) as order_year, month(order_date) as order_month,sum(sale_price) as sales 
from df_orders group by year(order_date), month(order_date) 
)

/*select order_month,
(case when order_year=2022 then sales else 0 end) as sales_2022,
(case when order_year=2023 then sales else 0  end) as sales_2023  from cte  order by order_month;*/

select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0  end) as sales_2023  from cte group by order_month order by order_month;

--4. for each category which month had highest sales 
-- cte finds month wise inclusive of year category wise total_sales 
-- ranking the data based on total_sales partition by category
-- select rank 1 which gives the top category sales monthwise
with cte as(
select category,format(order_date,'MMyyyy') as order_month,sum(sale_price) as sales 
from df_orders group by format(order_date,'MMyyyy') ,category)-- order by category,sales desc)
select * from (
select *,row_number() over(partition by category order by sales desc) as rn from cte) A where rn=1;


--5. which sub category had highest growth by profit in 2023 compare to 2022
-- cte --> finding total profit of 2022 and 2023 in each sub_category
-- cte2 --> structuring the table to give sub_category,2022_profit,2023_profit
-- finds sub_category, profit diff in 2022 & 2023 and select  sub_ctaegory whose profit diff is high
with cte as(
select sub_category,year(order_date) order_year, sum(profit) total_profit from df_orders group by year(order_date) , sub_category) -- order by total_profit desc
,cte2 as (
select sub_category,
sum(case when order_year=2022 then total_profit else 0 end) as profit_2022,
sum(case when order_year=2023 then total_profit else 0 end) as profit_2023 from cte group by sub_category)
select top 1 sub_category,(profit_2023-profit_2022) as growth from cte2 order by (profit_2023-profit_2022) desc; 