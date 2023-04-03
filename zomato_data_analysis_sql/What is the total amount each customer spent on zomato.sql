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
