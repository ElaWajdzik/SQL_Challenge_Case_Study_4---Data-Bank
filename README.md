
I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# <p align="center"> Case Study #4: 💲 Data Bank
<p align="center"><img src="https://8weeksqlchallenge.com/images/case-study-designs/4.png" alt="Image Data Bank - That's money" height="400">

***

## Table of Contents

- [Business Case](#business-case)
- [Relationship Diagram](#relationship-diagram)
- [Available Data](#available-data)
- [Case Study Questions](#case-study-questions)


## Business Case
There is a new innovation in the financial industry called Neo-Banks: new aged digital only banks without physical branches.

Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

## Relationship Diagram

<img width="600" alt="graf1" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/d2a49141-8636-4c35-a3f8-fdb765201af9">


## Available Data

<details><summary>
    All datasets exist in database schema.
  </summary> 

#### ``Table 1: Regions``

region_id | region_name
-- | --
1 | Africa
2 | America
3 | Asia
4 | Europe
5 | Oceania


#### ``Table 2: Customer Nodes``
*Note: sample of data*
customer_id | region_id | node_id | start_date | end_date
-- | -- | -- | -- | --
1 | 3 | 4 | 2020-01-02 | 2020-01-03
2 | 3 | 5 | 2020-01-03 | 2020-01-17
3 | 5 | 4 | 2020-01-27 | 2020-02-18
4 | 5 | 4 | 2020-01-07 | 2020-01-19
5 | 3 | 3 | 2020-01-15 | 2020-01-23
6 | 1 | 1 | 2020-01-11 | 2020-02-06
7 | 2 | 5 | 2020-01-20 | 2020-02-04

#### ``Table 3: Customer Transactions``
*Note: sample of data*

customer_id | txn_date | txn_type | txn_amount
-- | -- | -- | --
429 | 2020-01-21 | deposit | 82
155 | 2020-01-10 | deposit | 712
398 | 2020-01-01 | deposit | 196
255 | 2020-01-14 | deposit | 563
185 | 2020-01-29 | deposit | 626
309 | 2020-01-13 | deposit | 995
312 | 2020-01-20 | deposit | 485
376 | 2020-01-03 | deposit | 706
188 | 2020-01-13 | deposit | 601
138 | 2020-01-11 | deposit | 520


  </details>



## Case Study Questions

- [A. Customer Nodes Exploration](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_4---Data-Bank/blob/main/A.%20Customer%20Nodes%20Exploration.md)
- [B. Customer Transactions](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_4---Data-Bank/blob/main/B.%20Customer%20Transactions.md)
- [C. Data Allocation Challenge](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_4---Data-Bank/blob/main/C.%20Data%20Allocation%20Challenge.md)
- D. Extra Challenge

<br/>

*** 

 # <p align="center"> Thank you for your attention! 🫶️

**Thank you for reading.** If you have any comments on my work, please let me know. My email address is ela.wajdzik@gmail.com.

***
