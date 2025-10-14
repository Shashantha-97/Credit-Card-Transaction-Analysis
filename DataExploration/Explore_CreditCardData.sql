-- Exploring the data set
select * from credit_card_transactions;


select count(*) as cnt, count(distinct(transaction_id)) from credit_card_transactions;
-- Verified that Transaction ID is unique in the table.

select min(transaction_date),max(transaction_date) from credit_card_transactions;
-- Transaction Date Range is 2013-10-04 to 2015-05-26

select distinct(exp_type) from credit_card_transactions;
-- exp_type-- 'Bills, Food, Entertainment,Grocery,Fuel,Travel'

select distinct(card_type) from credit_card_transactions; 
-- Gold,Platinum,Silver,Signature

-- Analysing the Performance of Card Type over months
select  date_format(transaction_date,'%Y%m') as YOM, 
		card_type, 
        sum(amount) as total_amt from credit_card_transactions
group by date_format(transaction_date,'%Y%m'),card_type
order by YOM,card_type;

-- which card types grow over time
-- Seasonal spikes: do certain months see surges for particular card types (festival months etc.).

-- Top 5 Cities by Spend and number of transactions
SELECT city,
       SUM(amount) AS total_spent,
       COUNT(transaction_id) AS tx_count
FROM credit_card_transactions
GROUP BY city
ORDER BY total_spent DESC
LIMIT 5;

-- TAKEWAY --> What are the Top 5 cities that dominate credit card usage by spend and whether high spenders are 
--             also high transaction count cities or not.

SELECT gender,
	   exp_type,
       avg(amount) AS avg_spent
FROM credit_card_transactions
GROUP BY gender,exp_type
ORDER BY exp_type,avg_spent DESC;
-- LIMIT 5;

-- TAKEAWAY --> Behavior differences: Which expense types differ greatly by gender.