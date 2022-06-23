CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
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
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


SELECT *
FROM sales

SELECT *
FROM menu

SELECT *
FROM members

--What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) AS Amount_Spend
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id

--How many days has each customer visited the restaurant?
SELECT customer_id,  COUNT(DISTINCT order_date) as Number_of_Days
FROM sales s
GROUP BY customer_id;

--What was the first item from the menu purchased by each customer?
WITH NEW_TABLE AS(
SELECT DISTINCT customer_id, product_name, RANK() OVER(partition by customer_id order by order_date) as ordered_item
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
)

SELECT customer_id as Customer, product_name as First_ordered_Item
FROM NEW_TABLE
WHERE ordered_item = 1

--What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1 product_name, COUNT(product_name) as Times_orderd
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY Times_orderd DESC

--Which item was the most popular for each customer?
WITH NEW_TABLE AS(
SELECT customer_id, product_name as Most_Popular,COUNT(product_name) as Number_oftimes_ordered , RANK()OVER(partition by customer_id order by COUNT(product_name) DESC) as RANK_
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id, product_name
)

SELECT customer_id, Most_Popular, Number_oftimes_ordered
FROM NEW_TABLE
WHERE RANK_ = 1


--Which item was purchased first by the customer after they became a member?
WITH NEW_TABLE AS(
SELECT s.customer_id, product_name,order_date, RANK() OVER(partition by s.customer_id order by order_date) as RANK_
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members ms
on  s.customer_id = ms.customer_id
WHERE join_date <= order_date
)

SELECT customer_id as Customer, order_date,product_name as Product_Ordered_After_Membership
FROM NEW_TABLE
WHERE RANK_ = 1 



--Which item was purchased just before the customer became a member?
WITH NEW_TABLE AS(
SELECT  s.customer_id, order_date,product_name, RANK() OVER(partition by s.customer_id order by order_date DESC) as RANK_
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members ms
on  s.customer_id = ms.customer_id
WHERE join_date > order_date
)

SELECT customer_id as Customer, order_date,product_name as Product_Ordered_Before_Membership
FROM NEW_TABLE
WHERE RANK_ = 1 


--What is the total items and amount spent for each member before they became a member?
SELECT  s.customer_id, COUNT(Distinct product_name) as Unique_items, SUM(price) as Amount_Spend
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members ms
on  s.customer_id = ms.customer_id
WHERE join_date > order_date
GROUP BY s.customer_id



--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT customer_id, SUM(CASE WHEN product_name = 'sushi' THEN price *20 
			   ELSE price * 10
			   END) as TOTAL_POINTS
FROM sales s
JOIN menu m
ON s.product_id = m.product_id 
GROUP BY customer_id;

/*
In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A, B and C have at the end of January?
*/
SELECT s.customer_id, 
			   SUM(CASE WHEN join_date <= order_date AND order_date BETWEEN join_date AND DATEADD(DAY, 6, join_date)  THEN price*20
				    ELSE CASE WHEN product_name = 'sushi' THEN price *20 
							  ELSE price * 10
			                  END
			   END) as TOTAL_POINTS
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members as ms
ON s.customer_id = ms.customer_id
WHERE order_date <= '2021-01-31'
GROUP BY s.customer_id
UNION
SELECT customer_id, SUM(CASE WHEN product_name = 'sushi' THEN price *20 
			   ELSE price * 10
			   END) as TOTAL_POINTS
FROM sales s
JOIN menu m
ON s.product_id = m.product_id 
WHERE s.customer_id not in (SELECT s.customer_id FROM sales as s JOIN members as m on s.customer_id = m.customer_id)
GROUP BY s.customer_id;


--BONUS QUESTION 1

SELECT s.customer_id, order_date, product_name, price,
	CASE WHEN join_date <= order_date THEN 'Y'
	ELSE 'N'
	END as member
FROM sales s
LEFT JOIN menu m
on s.product_id = m.product_id
LEFT JOIN members  ms
on s.customer_id = ms.customer_id


--BONUS QUESTION 2
WITH NEW_TABLE AS(
SELECT s.customer_id, order_date, product_name, price,
	CASE WHEN join_date <= order_date THEN 'Y'
	ELSE 'N'
	END as member
FROM sales s
LEFT JOIN menu m
on s.product_id = m.product_id
LEFT JOIN members  ms
on s.customer_id = ms.customer_id
)

SELECT *, CASE WHEN member = 'N' THEN NULL 
			   ELSE RANK() OVER(PARTITION BY CUSTOMER_ID, member order by order_date) 
			   END as Rankings
FROM NEW_TABLE
