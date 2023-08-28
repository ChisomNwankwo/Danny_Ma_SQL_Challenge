CREATE SCHEMA pizza_runner;
-- SET search_path = pizza_runner;

DROP TABLE IF EXISTS pizza_runner.runners;
CREATE TABLE pizza_runner.runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO pizza_runner.runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS pizza_runner.customer_orders;
CREATE TABLE pizza_runner.customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO pizza_runner.customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS pizza_runner.runner_orders;
CREATE TABLE pizza_runner.runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO pizza_runner.runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_runner.pizza_names;
CREATE TABLE pizza_runner.pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT INTO pizza_runner.pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_runner.pizza_recipes;
CREATE TABLE pizza_runner.pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

INSERT INTO pizza_runner.pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_runner.pizza_toppings;
CREATE TABLE pizza_runner.pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_runner.pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  -- delete database
  -- DROP DATABASE pizza_runner;
  
  -- view tables in database
  SHOW TABLES FROM pizza_runner;
 -- PIZZA METRICS 
 
-- Question 1: How many pizzas were ordered?
SELECT COUNT(*) 'total orders'
FROM pizza_runner.customer_orders;

-- Question 2: How many unique customer orders were made?
SELECT  COUNT(DISTINCT(order_id)) 'unique orders'
FROM pizza_runner.customer_orders;

-- Question 3: How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(*) 'successful orders'
FROM pizza_runner.runner_orders
WHERE pickup_time <> 'null'
GROUP BY runner_id;

-- Question 4: How many of each type of pizza was delivered?
SELECT P.pizza_name,COUNT(*) 'pizza delivered'
FROM pizza_runner.pizza_names P
JOIN pizza_runner.customer_orders C
ON P.pizza_id = C.pizza_id
JOIN pizza_runner.runner_orders R
ON R.order_id = C.order_id
WHERE pickup_time <> 'null'
GROUP BY P.pizza_name;

-- Question 5: How many Vegetarian and Meatlovers were ordered by each customer?
SELECT C.customer_id, P.pizza_name ,COUNT(*) pizza_ordered
FROM pizza_runner.pizza_names P
JOIN pizza_runner.customer_orders C
ON P.pizza_id = C.pizza_id
JOIN pizza_runner.runner_orders R
ON R.order_id = C.order_id
GROUP BY C.customer_id,P.pizza_name
ORDER BY pizza_ordered DESC;

-- Question 6: What was the maximum number of pizzas delivered in a single order?
SELECT C.order_id, COUNT(C.pizza_id) pizza_delivered
FROM pizza_runner.customer_orders C
JOIN pizza_runner.runner_orders R
ON C.order_id = R.order_id
WHERE R.pickup_time <> 'null'
GROUP BY C.order_id
ORDER BY pizza_delivered desc;

-- Question 7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
    C.customer_id,
    SUM(CASE
        WHEN (
            (exclusions IS NOT NULL AND exclusions <> 'null' AND LENGTH(exclusions) > 0)
            OR (extras IS NOT NULL AND extras <> 'null' AND LENGTH(extras) > 0)
        ) THEN 1
        ELSE 0
    END) AS pizzas_with_changes,
    SUM(CASE
        WHEN (
            (exclusions IS NULL OR exclusions = 'null' OR LENGTH(exclusions) = 0)
            AND (extras IS NULL OR extras = 'null' OR LENGTH(extras) = 0)
        ) THEN 1
        ELSE 0
    END) AS pizzas_without_changes
FROM 
    pizza_runner.customer_orders C
JOIN 
    pizza_runner.runner_orders R ON C.order_id = R.order_id
WHERE 
    R.pickup_time IS NOT NULL
GROUP BY 
    C.customer_id;

-- Question 8: How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*) 'Pizzas with extras and exclusions'
FROM pizza_runner.customer_orders C
JOIN pizza_runner.runner_orders R
ON C.order_id = R.order_id
WHERE R.pickup_time <> 'null'
AND (exclusions IS NOT NULL AND exclusions <> 'null'AND LENGTH(exclusions) > 0)
AND (extras IS NOT NULL AND extras <> 'null' AND LENGTH(extras) > 0);

-- Question 9: What was the total volume of pizzas ordered for each hour of the day?
SELECT  EXTRACT(HOUR FROM order_time) AS Hour_ordered, COUNT(pizza_id) 'Volume of Pizza Ordered' -- extract works on mysql
FROM pizza_runner.customer_orders
GROUP BY Hour_ordered
ORDER BY Hour_ordered DESC;


-- Question 10: What was the volume of orders for each day of the week?
SELECT*
FROM pizza_runner.customer_orders; 

SELECT DAYNAME(order_time) AS day_of_week, COUNT(pizza_id) 'Volume of Pizza Ordered' -- extract works on mysql
FROM pizza_runner.customer_orders
GROUP BY day_of_week;

## B. Runner and Customer Experience
-- Question 1: How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

-- Question 2: What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- Question 3: Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- Question 4: What was the average distance travelled for each customer?
-- Question 5: What was the difference between the longest and shortest delivery times for all orders?
-- Question 6: What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- Question 7: What is the successful delivery percentage for each runner?