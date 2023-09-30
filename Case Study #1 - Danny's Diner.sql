--DROP SCHEMA dannys_diner CASCADE;
CREATE SCHEMA dannys_diner; 
SET search_path = dannys_diner;

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
  
  
 -- Question 1: What is the total amount each customer spent at the restaurant?  
  SELECT customer_id AS customer, SUM(price) AS total_amount_spent
  FROM menu m
  JOIN sales s ON s.product_id = m.product_id
  GROUP BY 1;
  
  -- Question 2: How many days has each customer visited the restaurant?
  SELECT customer_id, COUNT(DISTINCT order_date) Days_Visited
  FROM sales
  GROUP BY 1;
  


  -- Question 3:What was the first item from the menu purchased by each customer?
  SELECT customer_id, MIN(m.product_name) AS first_item_purchased
  FROM sales s
  JOIN menu m
  ON m.product_id = s.product_Id
  GROUP BY 1
  ORDER BY 1
 

 
  
  -- Question 4: What is the most purchased item on the menu and how many times was it purchased by all customers?
 SELECT product_name AS product, COUNT(*) AS no_of_times_purchased
  FROM sales s
  JOIN menu m 
  ON s.product_id = m.product_id
  GROUP BY 1
  ORDER BY 2 DESC;
  
-- Question 5: Which item was the most popular for each customer?
WITH ItemRank AS (
	SELECT customer_id, product_name,
	RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS item_rank
	FROM sales s
	JOIN menu m ON s.product_id = m.product_id
	GROUP BY 1,2	
)
SELECT customer_id, product_name
FROM ItemRank
WHERE item_rank = 1


-- Question 6: Which item was purchased first by the customer after they became a member?
SELECT M.customer_id, MIN(product_name) AS first_item_purchased, MIN(order_date) AS date_purchased
FROM members M
JOIN sales S ON M.customer_id = S.customer_id
JOIN menu MU ON S.product_id = MU.product_id
WHERE order_date >= join_date
GROUP BY 1
ORDER BY 1;

-- Question 7: What was the last item was purchased just before the customer became a member?
SELECT M.customer_id, MAX(product_name) AS last_item_purchased, MAX(order_date) AS date_purchased
FROM members M
JOIN sales S ON M.customer_id = S.customer_id
JOIN menu MU ON S.product_id = MU.product_id
WHERE order_date < join_date
GROUP BY 1
ORDER BY 1;


-- Question 8: What is the total items and amount spent for each member before they became a member?
SELECT M.customer_id, SUM(price) AS total_amount_spent, COUNT(*) AS total_item_purchased
FROM members M
JOIN sales S ON M.customer_id = S.customer_id
JOIN menu MU ON S.product_id = MU.product_id
WHERE order_date < join_date
GROUP BY 1
ORDER BY 1

-- Question 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id,
       SUM(CASE WHEN m.product_name = 'sushi' THEN m.price * 2 ELSE m.price END) * 10 AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Question 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?  
SELECT S.customer_id,
SUM(CASE WHEN (EXTRACT(WEEK FROM order_date) = 1) THEN price * 2 ELSE price END) * 10 AS total_points
FROM members M
JOIN sales S ON M.customer_id = S.customer_id
JOIN menu MU ON S.product_id = MU.product_id
WHERE order_date > join_date
AND EXTRACT(MONTH FROM order_date) = 1
GROUP BY 1
ORDER BY 1

--Bonus Questions
--Join All The Things
SELECT S.customer_id, order_date, product_name,price,
(CASE WHEN (order_date >= join_date) THEN 'Y' ELSE 'N' END) AS member
FROM members M
FULL JOIN sales S ON M.customer_id = S.customer_id
FULL JOIN menu MU ON S.product_id = MU.product_id
ORDER BY 1

--Rank All The Things
WITH CustomerProgram AS (
SELECT S.customer_id, order_date, product_name,price,
(CASE WHEN (order_date >= join_date) THEN 'Y' ELSE 'N' END) AS member
FROM members M
FULL JOIN sales S ON M.customer_id = S.customer_id
FULL JOIN menu MU ON S.product_id = MU.product_id
ORDER BY 1
),
RankedCustomer AS (
    SELECT customer_id,product_name,
    RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS ranking
    FROM CustomerProgram
    WHERE member = 'Y' -- Filter only members
	GROUP BY 1,2
)
SELECT C.customer_id, order_date,C.product_name, price, member,ranking
FROM RankedCustomer R
FULL JOIN CustomerProgram C
ON R.customer_id = C.customer_id


