----------------------------
--B. Customer Transactions--
----------------------------


--Author: Ela Wajdzik
--Date: 23.10.2024 (update 26.10.2024)
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
		DATETRUNC(month, txn_date) AS txn_month,
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
	--WHERE customer_id IN (1, 2, 3) --, 4, 429, 109) -- a sample of customers
	GROUP BY customer_id, DATETRUNC(month, txn_date)),

customer_closing_balances AS (
	SELECT 
		customer_id,
		txn_month,
		SUM(month_balance) OVER (PARTITION BY customer_id ORDER BY txn_month ASC) AS closing_balance  -- closing balance the value of total balance at the end of each month
		--LAG(month_balance, 1) OVER (PARTITION BY customer_id ORDER BY txn_month) -- closing balance from previos month where customers were had activiti
	FROM customer_month_balances)

SELECT 
	txn_month,
	SUM(closing_balance) AS total_data_allocated_per_month,
	SUM(CASE WHEN closing_balance < 0 THEN 0 ELSE closing_balance END) AS total_positive_data_allocated_per_month
FROM customer_closing_balances
GROUP BY txn_month
ORDER BY txn_month;

-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days

WITH customer_balances AS (
	SELECT 
		*,
		DATETRUNC(month, txn_date) AS txn_month,
		SUM(CASE txn_type WHEN 'deposit' THEN 1 * txn_amount ELSE -1 * txn_amount END)
		OVER(PARTITION BY customer_id ORDER BY txn_date, id_transaction) AS running_balance -- id_transaction aby nadać kolejność transakcji wykoananych tego samego dnia
	FROM customer_transactions
	--WHERE customer_id IN (1, 2, 3)
	), -- a sample of customers

customer_all_avg_balances AS (
	SELECT 
		customer_id,
		txn_month,
		AVG(running_balance) OVER (PARTITION BY customer_id, txn_month) AS avg_balance
	FROM customer_balances),

customer_avg_balances AS (
	SELECT 
		customer_id,
		txn_month,
		avg_balance
	FROM customer_all_avg_balances
	GROUP BY customer_id, txn_month, avg_balance)

SELECT 
	txn_month,
	SUM(avg_balance) AS total_avg_data_allocated_per_month
FROM customer_avg_balances 
GROUP BY txn_month;


-- Option 3: data is updated real-time

WITH customers_running_balance AS (
	SELECT 
		customer_id,
		txn_date,
		DATETRUNC(month, txn_date) AS txn_month,
		SUM(CASE txn_type WHEN 'deposit' THEN 1 * txn_amount ELSE -1 * txn_amount END)
			OVER(PARTITION BY customer_id ORDER BY txn_date, id_transaction) AS running_balance -- id_transaction aby nadać kolejność transakcji wykoananych tego samego dnia
	FROM customer_transactions
	--WHERE customer_id IN (1, 2, 3, 4, 429, 109)
	) -- a sample of customers

SELECT 
	txn_month,
	SUM(running_balance) AS total_data_allocated_per_month,
	SUM(CASE WHEN running_balance < 0 THEN 0 ELSE running_balance END) AS total_positive_data_allocated_per_month
FROM customers_running_balance
GROUP BY txn_month
ORDER BY txn_month;

