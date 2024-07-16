use Data_Bank
go
-- How many unique nodes are there on the Data Bank system?
Select *
from customer_nodes
Select COUNT(distinct(node_id)) as unique_nodes
from customer_nodes

--What is the number of nodes per region?
Select r.region_name, 
	COUNT(node_id) as number_nodes
from customer_nodes as n
join regions as r 
on n.region_id=r.region_id
group by r.region_name

--How many customers are allocated to each region?
Select r.region_name, 
	COUNT(customer_id) as number_customers
from customer_nodes as n
join regions as r 
on n.region_id=r.region_id
group by r.region_name
order by COUNT(customer_id) desc

--What is the unique count and total amount for each transaction type?
select txn_type,
	count(customer_id) as count, 
	sum(txn_amount) as total_amount
from customer_transactions
group by txn_type

--What is the average total historical deposit counts and amounts for all customers?
WITH historical_deposit AS (
  SELECT 
    customer_id, 
    txn_type, 
    COUNT(*) AS txn_count, 
    AVG(txn_amount) AS avg_amount
  FROM customer_transactions
  GROUP BY customer_id, txn_type)
SELECT 
  AVG(txn_count) AS avg_deposit, 
  AVG(avg_amount) AS avg_amount
FROM historical_deposit
WHERE txn_type = 'deposit';

--For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH monthly_transactions AS (
  SELECT 
    customer_id, 
    month(txn_date) AS month_name,
    SUM(CASE WHEN txn_type = 'deposit' THEN 0 ELSE 1 END) AS deposit_count,
    SUM(CASE WHEN txn_type = 'purchase' THEN 0 ELSE 1 END) AS purchase_count,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
  FROM customer_transactions
  GROUP BY customer_id, month(txn_date)
 )

SELECT
  month_name,
  COUNT(DISTINCT customer_id) AS customer_count
FROM monthly_transactions
WHERE deposit_count >= 2 
  AND (purchase_count > 1 OR withdrawal_count > 1)
GROUP BY month_name

--What is the closing balance for each customer at the end of the month?
  SELECT 
    customer_id, 
	month(txn_date) as closing_month, 
    txn_type, 
    txn_amount,
    SUM(CASE WHEN txn_type = 'withdrawal' OR txn_type = 'purchase' THEN (-txn_amount)
      ELSE txn_amount END) AS transaction_balance
  FROM customer_transactions
  GROUP BY customer_id, txn_date, txn_type, txn_amount

