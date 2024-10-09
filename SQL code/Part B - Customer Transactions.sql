----------------------------
--B. Customer Transactions--
----------------------------


--Author: Ela Wajdzik
--Date: 9.10.2024
--Tool used: Microsoft SQL Server


-- 1. What is the unique count and total amount for each transaction type?

SELECT 
	txn_type AS transaction_type,
	COUNT(*) AS number_of_transactions,
	SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?

WITH customer_total_deposites AS (
-- calculate the number and total amount of deposits for each customer
	SELECT 
		customer_id,
		COUNT(*) AS number_of_transaction,
		SUM(txn_amount) AS total_amount
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY customer_id)

SELECT 
	AVG(number_of_transaction) AS avg_number_of_deposit,
	AVG(total_amount) AS avg_total_amount_deposit
FROM customer_total_deposites;

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH customer_month_deposits AS (
-- calculate the number of deposits for each customer with by month
	SELECT 
		customer_id,
		DATETRUNC(month,txn_date) AS txn_month,
		COUNT(*) AS number_of_deposit
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY customer_id, DATETRUNC(month,txn_date)),

customer_month_purchases_withdrawal AS (
-- calculate the number of purchases and withdrawals for each customer by month
	SELECT 
		customer_id,
		DATETRUNC(month,txn_date) AS txn_month,
		COUNT(*) AS number_of_purchase_or_withdrawal
	FROM customer_transactions
	WHERE txn_type IN ('purchase', 'withdrawal')
	GROUP BY customer_id, DATETRUNC(month,txn_date))

SELECT 
	cd.txn_month,
	COUNT(*) AS number_of_custoomer
FROM customer_month_deposits cd
LEFT JOIN customer_month_purchases_withdrawal cpw
	ON cd.customer_id = cpw.customer_id
	AND cd.txn_month = cpw.txn_month
WHERE cpw.number_of_purchase_or_withdrawal IS NOT NULL -- filter the customers who have made purchases or withdrawals in each month
GROUP BY cd.txn_month;


-- 4. What is the closing balance for each customer at the end of the month?

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
	WHERE customer_id = 429
	GROUP BY customer_id, DATETRUNC(month, txn_date))

SELECT 
	customer_id,
	DATEADD(day, -1, DATEADD(month, 1, txn_month)) AS end_of_month,
	SUM(month_balance) OVER (PARTITION BY customer_id ORDER BY txn_month ASC) AS closing_balance
FROM customer_month_balances;

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?

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
	--WHERE customer_id =3
	GROUP BY customer_id, DATETRUNC(month, txn_date)),

customer_balances AS (
	SELECT 
		customer_id,
		txn_month,
		DATEADD(month, 1, txn_month) AS next_month,
		SUM(month_balance) OVER (PARTITION BY customer_id ORDER BY txn_month ASC) AS balance
	FROM customer_month_balances),

customer_balances_increase AS (

	SELECT 
		cb.customer_id,
		cb.txn_month,
		cb1.balance AS opening_balance,
		cb.balance AS closing_balance,
		-- calculate the percentage increase in the account balance from the start to the end of the month
		(cb.balance - cb1.balance ) * 1.0 / ABS(cb1.balance) AS perc_increase,
		CASE WHEN (cb.balance - cb1.balance ) * 1.0 / ABS(cb1.balance)  > 0.05 THEN 1 ELSE 0 END AS flag_more_than_5_perc_increase
	FROM customer_balances cb
	INNER JOIN customer_balances cb1
	ON cb.customer_id = cb1.customer_id 
	AND cb.txn_month = cb1.next_month
	WHERE cb1.balance != 0 -- filter the months where the opening balance was 0, bacouse the percentage increase is undefined
	)

SELECT 
	-- combination of customer_id and month 
	CAST(SUM(flag_more_than_5_perc_increase) * 1.0 / COUNT(*) * 100 AS NUMERIC(4,1)) AS perc_of_observation_increasing_balance
FROM customer_balances_increase
/*
SELECT 
	COUNT(*) AS number_of_customers,
	COUNT(DISTINCT customer_id) AS number_of_unique_customers
FROM customer_balances_increase
WHERE flag_more_than_5_perc_increase = 1
*/

