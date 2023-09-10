USE dannys_diner;
SELECT * FROM sales;
SHOW TABLES;
DROP DATABASE dannys_diner;
CREATE SCHEMA dannys_diner;

CREATE TABLE dannys_diner.sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO dannys_diner.sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

CREATE TABLE dannys_diner.menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO dannys_diner.menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE dannys_diner.members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO dannys_diner.members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  select*
  from dannys_diner.menu;
  
  -- disable full_group by
    SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
  
  -- Question 1: What is the total amount each customer spent at the restaurant?  
  SELECT product_id AS customer, price 
  FROM dannys_diner.menu;
  
  -- Question 2: How many days has each customer visited the restaurant?
  SELECT customer_id, COUNT(DISTINCT order_date) Days_Visited
  FROM dannys_diner.sales
  GROUP BY customer_id;
  


  -- Question 3:What was the first item from the menu purchased by each customer?
  SET SESSION sql_mode = (SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
  SELECT s.customer_id AS customer,  MIN(s.order_date) AS first_purchase_date, m.product_name AS first_item_purchased
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m 
  ON s.product_id = m.product_id
  GROUP BY s.customer_id;
  
  -- Question 4: What is the most purchased item on the menu and how many times was it purchased by all customers?
  SELECT COUNT(m.product_id) no_of_time_purchased, m.product_name menu-- COUNT(product_id) no_of_times_purchased
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m
  ON s.product_id = m.product_id
  GROUP BY m.product_id
  ORDER BY no_of_time_purchased DESC;
  
  -- Question 5: Which item was the most popular for each customer?
SELECT s.customer_id AS customer,
       m.product_name AS most_popular_item,
       COUNT(m.product_name) AS no_of_times_purchased
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
HAVING COUNT(m.product_name) = (
  SELECT MAX(purchase_count)
  FROM (
    SELECT customer_id, product_name, COUNT(*) AS purchase_count
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m ON s.product_id = m.product_id
    GROUP BY customer_id, product_name
  ) AS customer_item_counts
  WHERE customer_item_counts.customer_id = s.customer_id
);

-- Question 6: Which item was purchased first by the customer after they became a member?
SELECT *
FROM dannys_diner.members;

SELECT m_join.customer_id,
       m.product_name AS first_item_purchased_after_membership
FROM (
  SELECT s.customer_id, 
         MIN(s.order_date) AS first_purchase_date
  FROM dannys_diner.sales s
  JOIN dannys_diner.members mm ON s.customer_id = mm.customer_id AND s.order_date >= mm.join_date
  GROUP BY s.customer_id
) AS m_join
JOIN dannys_diner.sales s ON m_join.customer_id = s.customer_id AND m_join.first_purchase_date = s.order_date
JOIN dannys_diner.menu m ON s.product_id = m.product_id;

-- Question 7: Which item was purchased just before the customer became a member?
SELECT s.customer_id,
       MAX(s.order_date) AS last_purchase_before_membership,
       m.product_name AS last_item_purchased_before_membership
FROM dannys_diner.sales s
JOIN dannys_diner.members mm 
ON s.customer_id = mm.customer_id AND s.order_date < mm.join_date
JOIN dannys_diner.menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name;


-- Question 8: What is the total items and amount spent for each member before they became a member?
SELECT mm.customer_id,
       mm.join_date,
       COUNT(s.product_id) AS total_items_purchased,
       SUM(m.price) AS total_amount_spent
FROM dannys_diner.members mm
LEFT JOIN dannys_diner.sales s ON mm.customer_id = s.customer_id AND s.order_date < mm.join_date
LEFT JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY mm.customer_id, mm.join_date;


-- Question 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id,
       SUM(CASE WHEN m.product_name = 'sushi' THEN m.price * 2 ELSE m.price END) * 10 AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Question 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?  
SELECT s.customer_id,
       SUM(
           CASE 
               WHEN s.order_date <= DATE_ADD(mm.join_date, INTERVAL 1 WEEK) THEN m.price * 2
               WHEN m.product_name = 'sushi' THEN m.price * 2
               ELSE m.price
           END
       ) * 10 AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
JOIN dannys_diner.members mm ON s.customer_id = mm.customer_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id;
  