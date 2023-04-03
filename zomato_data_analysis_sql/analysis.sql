ANALYSIS

1.What is the total amount each customer spent on zomato?
2.How many days has each customer visited zomato?
3.What was the first product purchased by each customer?
4.What is the most purchased item on the menu & how many times was it purchased by all customers?
5.Which item was most popular for each customer?
6.Which item was purchased first by customers after they become a member?
7.Which item was purchased just before the customer became a member?
8.What are the total orders and amount spent for each member before they become a member?
9.Rank all transactions of the customers
10.Rank all transaction for each member whenever they are zomato gold member for every non gold member transaction mark as na





What is the total amount each customer spent on zomato?

select 
  a.userid, 
  sum(b.price) total_amt_spent 
from 
  sales a 
  inner join product b on a.product_id = b.product_id 
group by 
  a.userid
  
How many days has each customer visited zomato?

select 
  userid, 
  count(distinct created_date) distinct_days 
from 
  sales 
group by 
  userid;


what was the first product purchased by each customer?

select 
  * 
from 
  (
    select 
      *, 
      rank() over (
        partition by userid 
        order by 
          created_date
      ) rnk 
    from 
      sales
  ) a 
where 
  rnk = 1


what is the most purchased item on the menu & how many times was it purchased by all customers?

select 
  userid, 
  count(product_id) cnt 
from 
  sales 
where 
  product_id = (
    select 
      top 1 product_id 
    from 
      sales 
    group by 
      product_id 
    order by 
      count(product_id) desc
  ) 
group by 
  userid
Which item was most popular for each customer?

select 
  * 
from 
  (
    select 
      *, 
      rank() over(
        partition by userid 
        order by 
          cnt desc
      ) rnk 
    from 
      (
        select 
          userid, 
          product_id, 
          count(product_id) cnt 
        from 
          sales 
        group by 
          userid, 
          product_id
      ) a
  ) b 
where 
  rnk = 1


Which item was purchased first by customers after they become a member?

SELECT *
FROM   (SELECT c.*,
               Rank()
                 OVER (
                   partition BY userid
                   ORDER BY created_date ) rnk
        FROM   (SELECT a.userid,
                       a.created_date,
                       a.product_id,
                       b.gold_signup_date
                FROM   sales a
                       INNER JOIN goldusers_signup b
                               ON a.userid = b.userid
                                  AND created_date >= gold_signup_date) c)d
WHERE  rnk = 1; 

Which item was purchased just before the customer became a member?

SELECT *
FROM   (SELECT c.*,
               Rank()
                 OVER (
                   partition BY userid
                   ORDER BY created_date DESC ) rnk
        FROM   (SELECT a.userid,
                       a.created_date,
                       a.product_id,
                       b.gold_signup_date
                FROM   sales a
                       INNER JOIN goldusers_signup b
                               ON a.userid = b.userid
                                  AND created_date <= gold_signup_date) c)d
WHERE  rnk = 1; 

what are the total orders and amount spent for each member before they become a member?

SELECT userid,
       Count(created_date) order_purchased,
       Sum(price)          total_amt_spent
FROM   (SELECT c.*,
               d.price
        FROM   (SELECT a.userid,
                       a.created_date,
                       a.product_id,
                       b.gold_signup_date
                FROM   sales a
                       INNER JOIN goldusers_signup b
                               ON a.userid = b.userid
                                  AND created_date <= gold_signup_date) c
               INNER JOIN product d
                       ON c.product_id = d.product_id)e
GROUP  BY userid; 

Rnk all transactions of the customers

SELECT*,
      Rank()
        OVER (
          partition BY userid
          ORDER BY created_date ) rnk
FROM   sales; 

SQL
Rank all transactions for each member whenever they are zomato gold members for every nongold member transaction marked as NA

SELECT e.*,
       CASE
         WHEN rnk = 0 THEN 'na'
         ELSE rnk
       END AS rnkk
FROM   (SELECT c.*,
               Cast(( CASE
                        WHEN gold_signup_date IS NULL THEN 0
                        ELSE Rank()
                               OVER (
                                 partition BY userid
                                 ORDER BY created_date DESC)
                      END ) AS VARCHAR) AS rnk
        FROM   (SELECT a.userid,
                       a.created_date,
                       a.product_id,
                       b.gold_signup_date
                FROM   sales a
                       LEFT JOIN goldusers_signup b
                              ON a.userid = b.userid
                                 AND created_date >= gold_signup_date)c)e; 

