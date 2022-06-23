# 🍕 Case Study #2 - Pizza Runner

## 🍝 Solution - A. Pizza Metrics

### 1. How many pizzas were ordered?

````sql
SELECT COUNT(pizza_id) as Numer_of_pizza_ordered
FROM customer_orders;
````

**Answer:**

| Numer_of_pizza_ordered |
| -----------------------|
|          14            |

- Total of 14 pizzas were ordered.

### 2. How many unique customer orders were made?

````sql
SELECT COUNT(DISTINCT order_id) as unique_customer_orders
FROM customer_orders;
````

**Answer:**

| unique_customer_orders |
| -----------------------|
|          10            |

- There are 10 unique customer orders.

### 3. How many successful orders were delivered by each runner?

````sql
SELECT runner_id,COUNT(distance) as Ordered_delivered_by_runners
FROM runner_orders
GROUP BY runner_id;
````

**Answer:**

|  runner_id  |	Ordered_delivered_by_runners  |
|-------------|-------------------------------|
|     1	      |              4                |
|     2	      |              3                |
|     3	      |              1                |

- Runner 1 has 4 successful delivered orders.
- Runner 2 has 3 successful delivered orders.
- Runner 3 has 1 successful delivered order.

### 4. How many of each type of pizza was delivered?

````sql
SELECT CAST(pizza_name as varchar) as pizza_name, COUNT(distance) as pizzas_delivered
FROM customer_orders as co
JOIN runner_orders as ro
on co.order_id = ro.order_id
JOIN pizza_names as pn
on co.pizza_id = pn.pizza_id
WHERE ro.date is NOT NULL
GROUP BY CAST(pizza_name as varchar);
````

**Answer:**

|  pizza_name  |	pizzas_delivered  |
|-------------|-------------------------------|
|     Meatlovers	      |              9                |
|     Vegetarian	      |              3                |

- There are 9 delivered Meatlovers pizzas and 3 Vegetarian pizzas.

### 5. How many Vegetarian and Meatlovers were ordered by each customer?**

````sql
SELECT customer_id ,CAST(pizza_name as varchar) as pizza_name , COUNT(order_id) as pizzas_delivered
FROM customer_orders as co
JOIN pizza_names as pn
on co.pizza_id = pn.pizza_id
GROUP BY customer_id , CAST(pizza_name as varchar)
ORDER BY customer_id;
````

**Answer:**
|  customer_id  |	pizza_name  |  pizzas_delivered  |
|-------------|-------------------------------|-------------|
|     101	      |              Meatlovers                |     2	      |
|     101	      |              Vegetarian                |     1	      |
|     102	      |              Meatlovers              |     2	      |
|     102	      |              Vegetarian                |     1	      |
|     103	      |              Meatlovers              |     3	      |
|     103	      |              Vegetarian                |     1	      |
|     104	      |              Meatlovers              |     3	      |
|     105	      |              Vegetarian                |     1	      |



- Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 102 ordered 2 Meatlovers pizzas and 1 Vegetarian pizzas.
- Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 104 ordered 3 Meatlovers pizza.
- Customer 105 ordered 1 Vegetarian pizza.

### 6. What was the maximum number of pizzas delivered in a single order?

````sql
SELECT co.order_id, COUNT(pizza_id) as pizzas_delivered
FROM customer_orders as co
JOIN runner_orders as ro
on co.order_id = ro.order_id
WHERE cancellation is NULL
GROUP BY co.order_id
ORDER BY pizzas_delivered DESC;
````

**Answer:**

|  order_id  |	pizzas_delivered  |
|-------------|-------------------------------|
|     4	      |              3                |
|     3	      |              2                |
|     10	      |              2                |
|     1	      |              1                |
|     2	      |              1                |
|     5	      |              1                |
|     7	      |              1                |
|     8	      |              1                |

- Maximum number of pizza delivered in a single order is 3 pizzas.

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
SELECT customer_id, SUM(CASE WHEN exclusions is NOT NULL or extras is not NULL THEN  1 
						 ELSE 0
				    END) as atleast_1_change,
					SUM(CASE WHEN exclusions is NULL AND extras is NULL THEN  1
						 ELSE 0
				    END) as no_change
FROM customer_orders as co
JOIN runner_orders as ro
on co.order_id = ro.order_id
WHERE cancellation is NULL
GROUP BY customer_id;
````

**Answer:**

|  customer_id  |	atleast_1_change  |  no_change  |
|-------------|-------------------------------|-------------|
|     101	      |              0                |     2	      |
|     102	      |              0                |     3	      |
|     103	      |              3              |     0	      |
|     104	      |              2                |     1	      |
|     105	      |              1              |     0	      |

- Customer 101 and 102 likes their pizzas per the original recipe.
- Customer 103, 104 and 105 have their own preference for pizza topping and requested at least 1 change (extra or exclusion topping) on their pizza.

### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
SELECT SUM(CASE WHEN exclusions is NOT NULL AND extras is NOT NULL THEN 1 else 0 END) as both_exclusions_and_extras
FROM customer_orders as co
JOIN runner_orders as ro
on co.order_id = ro.order_id
WHERE cancellation is NULL;
````

**Answer:**

| both_exclusions_and_extras |
| -----------------------|
|          1            |

- Only 1 pizza delivered that had both extra and exclusion topping. That’s one fussy customer!

### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql

SELECT CONCAT(DATEPART(HOUR, time),' - ', DATEPART(HOUR, time) +1) as time_intervals_in_hour, COUNT(order_id) as number_of_orders
FROM customer_orders
GROUP BY DATEPART(HOUR, time),DATEPART(HOUR, time) +1 ;
````

**Answer:**
|  time_intervals_in_hour  |	number_of_orders  |
|-------------|-------------------------------|
|     11 - 12	      |              1                |
|     13 - 14	      |              3                |
|     18 - 19	      |              3                |
|     19 - 20	      |              1                |
|     21 - 22	      |              3                |
|     23 - 24	      |              3                |

- Highest volume of pizza ordered is between 13 - 14 (1:00 - 2:00 pm), 18 - 19 (6:00 - 7:00 pm), 21 - 22 (9:00 - 10:00 pm) and 23 - 24 (11:00pm - 12:00am).
- Lowest volume of pizza ordered is at 11 - 12 (11:00am - 12:00pm), 19 - 20 (7:00 - 8:00 pm).

### 10. What was the volume of orders for each day of the week?

````sql
SELECT  DATENAME(WEEKDAY, DATEADD(DAY,2,date)) as weekday, COUNT(order_id) as number_of_orders
FROM customer_orders
GROUP BY DATENAME(WEEKDAY, DATEADD(DAY,2,date));
````

**Answer:**

|  weekday  |	number_of_orders  |
|-------------|-------------------------------|
|     Friday	      |              5                |
|     Monday	      |              5                |
|     Saturday      |              3                |
|     Sunday      |              1                |

- 5 pizzas were ordered on Friday and Monday.
- 3 were pizzas ordered on Saturday.
- 1 was pizza ordered on Sunday.

## Solution - B. Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
SELECT 
  DATEPART(WEEK, registration_date) AS registration_week,
  COUNT(runner_id) AS runner_signup
FROM runners
GROUP BY DATEPART(WEEK, registration_date);
````

**Answer:**

|  registration_week  |	runner_signup  |
|-------------|-------------------------------|
|     1	      |              1                |
|     2	      |              2                |
|     3      |              1                |

- On Week 1 of Jan 2021, 1 new runners signed up.
- On Week 2 of Jan 2021, 2 new runner signed up.
- On Week 3 of Jan 2021, 1 new runners signed up

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
WITH TIME_TABLE AS(
SELECT DISTINCT co.order_id, runner_id,
CASE WHEN DATEPART(HOUR, co.time) = 23 AND DATEPART(HOUR, ro.time) = 00  THEN DATEDIFF(mi, DATEADD(HOUR,-1,co.time), DATEADD(HOUR,-1,ro.time))
			ELSE DATEDIFF(mi, co.time, ro.time) END as Time_Taken_to_Reach_HQ
FROM customer_orders co
JOIN runner_orders ro
on co.order_id = ro.order_id
)
SELECT runner_id, ROUND(AVG(CAST(Time_Taken_to_Reach_HQ AS FLOAT)),2) as AVG_Minutes_Taken_to_Reach_HQ
FROM TIME_TABLE
GROUP BY runner_id;

````

**Answer:**

|  runner_id  |	AVG_Minutes_Taken_to_Reach_HQ  |
|-------------|-------------------------------|
|     1	      |              14.25                |
|     2	      |              20.33               |
|     3      |              10                |

- The average time taken in minutes by runner 1 to arrive at Pizza Runner HQ to pick up the order is 14.25 minutes.
- The average time taken in minutes by runner 2 to arrive at Pizza Runner HQ to pick up the order is 20.33 minutes.
- The average time taken in minutes by runner 3 to arrive at Pizza Runner HQ to pick up the order is 10 minutes.

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
WITH NEW_TABLE AS(
SELECT co.order_id,
AVG(CASE WHEN DATEPART(HOUR, co.time) = 23 AND DATEPART(HOUR, ro.time) = 00  THEN DATEDIFF(mi, DATEADD(HOUR,-1,co.time), DATEADD(HOUR,-1,ro.time))
			ELSE DATEDIFF(mi, co.time, ro.time) END ) as Time_Taken_to_Pepare, COUNT(pizza_id) as Number_of_pizzas
FROM customer_orders co
JOIN runner_orders ro
on co.order_id = ro.order_id
WHERE cancellation is NULL
GROUP BY co.order_id
)


SELECT Number_of_pizzas, AVG(CAST(Time_Taken_to_Pepare as FLOAT)) as AVG_Time_Taken_To_Prepare_Order
FROM NEW_TABLE
GROUP BY Number_of_pizzas
````

**Answer:**

|  Number_of_pizzas  |	AVG_Time_Taken_To_Prepare_Order  | Number_of_pizzas  |
|-------------|-------------------------------|-------------|
|     1	      |              12.2                |    12.2	      |
|     2	      |              18.5               |    9.25	      |
|     3      |              30                |    10	      |

- On average, a single pizza order takes 12.2 minutes to prepare.
- It takes 18.5 minutes to prepare an order with 2 pizzas which is 9.25 minutes per pizza — making 2 pizzas in a single order the ultimate efficiency rate.
- An order with 3 pizzas takes 30 minutes at an average of 10 minutes per pizza.

### 4. What was the average distance travelled for each customer?

````sql
SELECT customer_id, CONCAT(AVG(DISTINCT distance),' km') as Avg_distance_travelled_by_runner
FROM customer_orders co
JOIN runner_orders ro
on co.order_id = ro.order_id
WHERE cancellation is NULL
GROUP BY customer_id;
````

**Answer:**

|  customer_id  |	Avg_distance_travelled_by_runner  |
|-------------|-------------------------------|
|     101	      |            20 km               |
|     102	      |             18.4 km                |
|     103	      |            23.4 km                |
|     104	      |             10 km               |
|     105	      |              25 km                |

_(Assuming that distance is calculated from Pizza Runner HQ to customer’s place)_

- Runners travelled a distance of 10 km on average for customer 104 which is the lowest average distance
- Runners travelled a distance of 25 km on average for customer 105 which is the highest travelled distance.
- 

### 5. What was the difference between the longest and shortest delivery times for all orders?

 -- Work in Progress

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
SELECT r.order_id, runner_id, CONCAT(ROUND(distance*1.0/(duration*1.0/60),2),' km/hr') as runner_speed,duration, distance, COUNT(pizza_id) as number_of_pizzas
FROM runner_orders r
JOIN customer_orders c
ON r.order_id = c.order_id
WHERE cancellation is NULL
GROUP BY r.order_id, runner_id, distance, duration;
````

**Answer:**
|  order_id  |	runner_id  |  runner_speed  |  duration  |  distance  |  number_of_pizzas  |
|-------------|-------------------------------|-------------|-------------|-------------|-------------|
|     1	      |              1                |     2	      |     37.5 km/hr	      |     20	      |     1	      |
|     2	      |              1                |     1	      |    44.44 km/hr	      |     20	      |     1	      |
|     3	      |              1              |     2	      |    40.2 km/hr	      |     13.4	      |     2	      |
|     4	      |              2                |     1	      |    35.1 km/hr	      |     23.4	      |     3	      |
|     5	      |              3              |     3	      |    40 km/hr	      |     10	      |     1	      |
|     7	      |              2                |     1	      |    60 km/hr	      |     25	      |     1	      |
|     8	      |              2              |     3	      |    93.6 km/hr	      |     23.4	      |     1	      |
|     10	      |              1                |     1	      |    60 km/hr	      |     10	      |     2	      |


_(Average speed = Distance in km / Duration in hour)_
- Runner 1’s highest speed was 44.44 km/hr , lowest speed was 37.5 km/hr and average speed was 45.53km/hr.
- Runner 1’s highest speed was 93.6 km/hr , lowest speed was 35.1 km/hr and average speed was 62.9km/hr.
- Runner 3’s only delivered 1 order so his highest, lowest and average speed was 40km/hr.

### 7. What is the successful delivery percentage for each runner?

````sql
SELECT runner_id, SUM(CASE WHEN cancellation is NULL THEN 1 ELSE 0 END)*100/COUNT(*)as Success_percentage
FROM runner_orders
GROUP BY runner_id;
````

**Answer:**
|  runner_id  |	Success_percentage  |
|-------------|-------------------------------|
|     1	      |              100                |
|     2	      |              75                |
|     3      |              50                |


- Runner 1 has 100% successful delivery.
- Runner 2 has 75% successful delivery.
- Runner 3 has 50% successful delivery

_(It’s not right to attribute successful delivery to runners as order cancellations are out of the runner’s control.)_
