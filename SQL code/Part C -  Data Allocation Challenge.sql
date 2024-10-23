----------------------------
--B. Customer Transactions--
----------------------------


--Author: Ela Wajdzik
--Date: 23.10.2024
--Tool used: Microsoft SQL Server



--add id_transaction to the table customer_balances to have unique identyfitator for every transaction 

ALTER TABLE customer_transactions
ADD id_transaction INT IDENTITY (1,1)

-- running customer balance column that includes the impact each transaction

SELECT 
	customer_id,
	txn_date,
	SUM(CASE txn_type WHEN 'deposit' THEN 1 * txn_amount ELSE -1 * txn_amount END)
	OVER(PARTITION BY customer_id ORDER BY txn_date, id_transaction) AS running_balance -- id_transaction aby nadać kolejność transakcji wykoananych tego samego dnia
FROM customer_transactions
WHERE customer_id IN (1, 2, 3, 4, 429, 109); -- a sample of customers

-- customer balance at the end of each month

WITH customer_month_balances AS (
-- calculate the monthly total value of transactions for each customer
	SELECT
		customer_id,
		DATETRUNC(month, txn_date) AS txn_month,
		SUM(
			CASE txn_type
				WHEN 'deposit' THEN txn_amount
				ELSE txn_amount * (-1)
			END) AS month_balance
	FROM customer_transactions
	WHERE customer_id IN (1, 2, 3, 4, 429, 109) -- a sample of customers
	GROUP BY customer_id, DATETRUNC(month, txn_date))

SELECT 
	customer_id,
	txn_month,
	month_balance, -- the value of balance at the end of ech month
	SUM(month_balance) OVER (PARTITION BY customer_id ORDER BY txn_month ASC) AS closing_balance -- closing balance the value of total balance at the end of each month
FROM customer_month_balances;

-- minimum, average and maximum values of the running balance for each customer

WITH customer_balances AS (
	SELECT 
		*,
		DATETRUNC(month, txn_date) AS month_date,
		SUM(CASE txn_type WHEN 'deposit' THEN 1 * txn_amount ELSE -1 * txn_amount END)
		OVER(PARTITION BY customer_id ORDER BY txn_date, id_transaction) AS running_balance -- id_transaction aby nadać kolejność transakcji wykoananych tego samego dnia
	FROM customer_transactions
	WHERE customer_id IN (1, 2, 3, 4, 429, 109)) -- a sample of customers

SELECT 
	customer_id,
	MIN(running_balance) AS min_balance,
	MAX(running_balance) AS max_balance,
	AVG(running_balance) AS avg_balance
FROM customer_balances
GROUP BY customer_id;

-- Option 1: data is allocated based off the amount of money at the end of the previous month

-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days

-- Option 3: data is updated real-time