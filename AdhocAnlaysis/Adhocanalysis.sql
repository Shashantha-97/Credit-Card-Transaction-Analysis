-- ===========================================================================================================================
-- SQL Question 1
-- Print top 5 cities with highest spends and their percentage contribution of total credit card spends 
-- ===========================================================================================================================
	select 
	city,
	sum(amount) city_sales,
	concat(cast(round(sum(amount)*1.0 *100/(select sum(amount) from credit_card_transactions),2) as char),"%") as percentage_contribution
	from credit_card_transactions
	group by city
	order by city_sales desc
	limit 5;

-- Alternate Method
	with cte1 as (
	select city,sum(amount) as total_spend
	from credit_card_transactions
	group by city)
	,total_spent as (select sum(amount) as total_amount from credit_card_transactions)
	select cte1.*, round(total_spend*1.0/total_amount * 100,2) as percentage_contribution from 
	cte1 inner join total_spent on 1=1
	order by total_spend desc
	limit 5;
    
-- ===============================================================================================
-- SQL Question 2
-- Print highest spend month and amount spent in that month for each card type
-- ===============================================================================================
	with cte as
	 (
	select card_type, date_format(transaction_date,'%Y-%b') as yr_mnth,  sum(amount) total_spend from credit_card_transactions
	group by card_type,date_format(transaction_date,'%Y-%b'))
	,ranking as
	(
	select *, rank() over(partition by card_type order by total_spend desc) as rn
	from cte )
	select * from ranking
	where rn=1;

-- ===============================================================================================
-- SQL Question 3
  /* Print the transaction details(all columns from the table) for each card type when
    it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)*/
-- ===============================================================================================
	with cte as(
	select *,sum(amount) over(partition by card_type order by transaction_date, transaction_id) as cumulative_sum
	from credit_card_transactions)
	select * from 
	(
	select *,rank() over(partition by card_type order by cumulative_sum) as rn from cte 
	where cumulative_sum >= 1000000) A
	where rn=1;
    
-- ===============================================================================================
-- SQL Question 4
-- To find city which had lowest percentage spend for gold card type
-- ===============================================================================================
	select city, 
	sum(case when card_type='Gold' then amount end)  * 1.0 /sum(amount) as total_amt
	from credit_card_transactions
	group by city
	having sum(case when card_type='Gold' then amount end) > 0
	order by total_amt
	limit 1;
	 
    -- Alternate Method 
	with cte as (
	select city,card_type,sum(amount) as amount
	,sum(case when card_type='Gold' then amount end) as gold_amount
	from credit_card_transactions
	group by city,card_type)
	select 
	city,sum(gold_amount)*100.0/sum(amount) as gold_ratio
	from cte
	group by city
	having  sum(gold_amount) is not null
	order by gold_ratio
	limit 1;

-- ===============================================================================================
-- SQL Question 5
-- Print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
-- ===============================================================================================
	with cte as
	(
	select  city, 
			exp_type, 
			sum(amount) as expense
	from credit_card_transactions
	group by city, exp_type)
	,ranking as
	(
	select 
			*, 
			rank()over(partition by city order by expense desc) as highest,
			rank()over(partition by city order by expense asc) as lowest
			from cte)
	select 
			city, 
			min(case when highest = 1 then exp_type end) as highest_expense_type, -- max or min just to get one value as rest all are NULL
			max(case when lowest = 1 then exp_type end ) as lowest_expense_type -- max or min just to get one value as rest all are NULL
			from ranking
			group by city;

-- ===============================================================================================
-- SQL Question 6
-- To find percentage contribution of spends by females for each expense type
-- ===============================================================================================
	with cte as
	(
	select 
			exp_type, 
			sum(amount) as total_amt,
			sum(case when gender = 'F' then amount else 0 end) as female_amt
	 from credit_card_transactions
	 group by exp_type)
	 select exp_type, female_amt/total_amt as pcnt_cnt_female
	 from cte
	 order by pcnt_cnt_female desc;
     
-- ===============================================================================================
-- SQL Question 7
-- To Print which card and expense type combination saw highest month over month growth in Jan-2014
-- ===============================================================================================
	 with total_Sales as
	 (
	 select 
	 card_type,exp_type, date_format(transaction_date,'%Y-%m') as yr_mnth,
	 sum(amount) as total_amt
	 from credit_card_transactions
	 group by card_type,exp_type, date_format(transaction_date,'%Y-%m')
	 )
	 ,
	last_mnth_sales as
	 (
	 select 
	 *
	 ,lag(total_amt,1) over(partition by card_type,exp_type order by yr_mnth) as previous_mnth_amt
	 from total_Sales)
	 select *
	 ,(total_amt - previous_mnth_amt)*1.0/previous_mnth_amt as mom_growth
	 from last_mnth_sales
	 where yr_mnth = '2014-01' and previous_mnth_amt is not null 
	 order by mom_growth desc limit 1;
  
  
-- ===============================================================================================
-- SQL Question 8
-- During weekends which city has highest total spend to total no of transcations ratio 
-- ===============================================================================================  
	  select city, sum(amount)*1.0/count(*) as spend_to_cnt_ratio
	  from credit_card_transactions
	  where date_format(transaction_date,'%a') in ('Sat','Sun')
	  group by city
	  order by spend_to_cnt_ratio desc limit 1;
	  
	  -- Alternate Method - REASON - Filtering on Numbers is Faster when compared with Strings.
	 select city, sum(amount)*1.0/count(*) as spend_to_cnt_ratio
	  from credit_card_transactions
	  where weekday(transaction_date) in (5,6)
	  group by city
	  order by spend_to_cnt_ratio desc limit 1;
  
  
-- ===============================================================================================
-- SQL Question 9
-- Which city took least number of days to reach its 500th transaction after the first transaction in that city
-- ===============================================================================================  
	  with cte as
	  (
	  select 
	  *,
	  row_number() over(partition by city order by transaction_date,transaction_id) as transaction_num
	  from credit_card_transactions)
	  , 
	  only_having_500_transaction as
	  (
	  select *, min(transaction_date) order_1_date,max(transaction_date) order_500_date from cte
	  where transaction_num =1 or transaction_num=500
	  group by city
	  having count(*)>1)
	  select *, timestampdiff(day,order_1_date,order_500_date) as num_of_days
	  from only_having_500_transaction
	  order by num_of_days 
	  limit 1;
  
  -- Alternate Method
	 with cte as (
	 select *
	 ,row_number() over(partition by city order by transaction_date,transaction_id) as rn
	 from credit_card_transactions)
	 select  city,TIMESTAMPDIFF(day,min(transaction_date),max(transaction_date)) as datediff1
	 from cte
	 where rn=1 or rn=500
	 group by city
	 having count(1)=2
	 order by datediff1 
	 limit 1;