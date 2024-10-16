# <p align="center">  Case Study #4: 💲 Data Bank
 
## <p align="center"> A. Customer Nodes Exploration



### 1. How many unique nodes are there on the Data Bank system?

````sql
SELECT COUNT(DISTINCT node_id) AS number_of_nodes
FROM customer_nodes;
````

#### Result:
| number_of_nodes |
| --------------- |
| 5               |


### 2 What is the number of nodes per region?

````sql
SELECT 
	r.region_name,
	COUNT(DISTINCT cn.node_id) AS number_of_nodes
FROM customer_nodes cn
LEFT JOIN regions r
ON r.region_id = cn.region_id
GROUP BY r.region_name;
````

#### Result:
|region_name | number_of_nodes |
|------------| --------------- |
| Africa     | 5               |
| America    | 5               |
| Asia       | 5               |
| Australia  | 5               |
| Europe     | 5               |


### 3. How many customers are allocated to each region?

````sql
SELECT 
	r.region_name,
	COUNT(DISTINCT cn.customer_id) AS number_of_customers
FROM customer_nodes cn
LEFT JOIN regions r
ON r.region_id = cn.region_id
GROUP BY r.region_name;
````

#### Result:
| region_name | number_of_customers |
|-------------| ------------------- |
| Africa      | 102                 |
| America     | 105                 |
| Asia        | 95                  |
| Australia   | 110                 |
| Europe      | 88                  |

Every customer is allocated to only one region (the total number of customers in the database is 500). Each region has around 100 customers.

### 4. How many days on average are customers reallocated to a different node?


````sql
WITH days_in_node AS (
	SELECT 
		customer_id,
		node_id,
		 -- because the start and the end dates have different meanings, we need to add 1 to correctly calculate the number of days between those dates
		 -- start_date -> time 00:00:01 
		 -- end_date -> time 23:59:59
		SUM(DATEDIFF(day, start_date, end_date) + 1.0) AS number_of_days	
	FROM customer_nodes
	WHERE end_date IS NOT NULL
	GROUP BY customer_id, node_id)
	
SELECT 
	CAST(AVG(number_of_days) AS NUMERIC(4,0)) AS avg_number_of_days_in_node
FROM days_in_node;
````

#### Steps:
- Some of data have ```end_data``` set to '9999-12-31'. In my understanding, this indicates that the data is still associated with this node. In such cases, I change the ```end_data``` to ```NULL```.

    ````sql
    -- change the end date to NULL if the data is still associated with this node
    UPDATE customer_nodes
    SET end_date = NULL
    WHERE end_date = '9999-12-31';
    ````

- Check if customers can switch regions.
    ````sql
    -- verify if customers can have data in different regions
    SELECT 
        customer_id,
        COUNT(DISTINCT region_id) AS number_of_regions
    FROM customer_nodes
    GROUP BY customer_id
    HAVING COUNT(DISTINCT region_id) > 1;
    ````
- Exclude the data where ```end_date``` is ```NULL```.
- Calculate the number of days in each node for each customer using the functions ```SUM()```, ```DATADIFF()``` and ```GROUP BY```.
- Calculate the average number of days spent in node for all customers.


#### Result:
| avg_number_of_days_in_node |
| -------------------------- |
| 25                         |

### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?


````sql
WITH customer_unique_nodes AS (
-- calculate the number of days in each node and region for each customer
    SELECT 
        region_id,
		customer_id,
		node_id,
        SUM(DATEDIFF(day, start_date, end_date) + 1) AS number_of_days
    FROM customer_nodes
    WHERE end_date IS NOT NULL
	GROUP BY  region_id, customer_id, node_id),

customer_unique_nodes_with_percentile AS (
-- add percentile ranking to each observation
	SELECT 
		*,
		ROUND( PERCENT_RANK() OVER( PARTITION BY region_id ORDER BY number_of_days),2) AS percentile_rank
	FROM customer_unique_nodes),

percentile_80th AS (
-- extract the information about the 80th percentil for each region
	SELECT 
		region_id,
		MIN(number_of_days) AS perc_80th
	FROM customer_unique_nodes_with_percentile
	WHERE percentile_rank >= 0.8
	GROUP BY region_id),

percentile_95th AS (
-- extract the information about the 95th percentil for each region
	SELECT 
		region_id,
		MIN(number_of_days) AS perc_95th
	FROM customer_unique_nodes_with_percentile
	WHERE percentile_rank >= 0.95
	GROUP BY region_id),

percentile_50th AS (
-- extract the information about the 50th percentil for each region
	SELECT 
		region_id,
		MIN(number_of_days) AS perc_50th
	FROM customer_unique_nodes_with_percentile
	WHERE percentile_rank >= 0.5
	GROUP BY region_id),

avg_number AS (
-- calculate the average number of days in nodes in each region
	SELECT 
		region_id,
		CAST(AVG(number_of_days) AS NUMERIC(4,0)) AS avg_number_of_days_in_node
	FROM customer_unique_nodes
	GROUP BY region_id)

SELECT 
    r.region_name,
	an.avg_number_of_days_in_node,
    p50.perc_50th,
    p80.perc_80th,
    p95.perc_95th
FROM regions r
LEFT JOIN percentile_50th AS p50
    ON p50.region_id = r.region_id
LEFT JOIN percentile_80th AS p80
    ON p80.region_id = r.region_id
LEFT JOIN percentile_95th AS p95
    ON p95.region_id = r.region_id
LEFT JOIN avg_number an
	ON an.region_id = r.region_id;
````

#### Steps:
- As in question 4, I calculate the number of days in each node and region for each customer, excluding the data where ```end_date``` is ```NULL```.
- Add percentile ranking to each observation using ```PERCENT_RANK() OVER()```
- Extract the information about the 80th, 95th and 50th percentil for each region.
- Calculate the average number of days in nodes in each region.
- Combine all the information about average and percentils in one table.

#### Result:
