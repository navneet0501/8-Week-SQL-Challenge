# 🍜 Case Study #1: Danny's Diner


### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT customer_id, SUM(price) AS Amount_Spend
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id; 
````

#### Answer:
| customer_id | Amount_spend |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT customer_id,  COUNT(DISTINCT order_date) as Number_of_Days
FROM sales s
GROUP BY customer_id;;
````


#### Answer:
| customer_id | Number_of_Days |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
WITH NEW_TABLE AS(
SELECT DISTINCT customer_id, product_name, RANK() OVER(partition by customer_id order by order_date) as ordered_item
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
)

SELECT customer_id as Customer, product_name as First_ordered_Item
FROM NEW_TABLE
WHERE ordered_item = 1;
````

#### Answer:
| customer_id | First_ordered_Item | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first orders are curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT TOP 1 product_name, COUNT(product_name) as Times_orderd
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY Times_orderd DESC;
````


#### Answer:
| product_name |  Times_orderd  |
| -----------  | -----------    |
| ramen        |      8         |


- Most purchased item on the menu is ramen which is 8 times.

***

### 5. Which item was the most popular for each customer?

````sql
WITH NEW_TABLE AS(
SELECT customer_id, product_name as Most_Popular,COUNT(product_name) as Number_oftimes_ordered , 
RANK()OVER(partition by customer_id order by COUNT(product_name) DESC) as RANK_
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id, product_name
)

SELECT customer_id, Most_Popular, Number_oftimes_ordered
FROM NEW_TABLE
WHERE RANK_ = 1
;
````

#### Answer:
| customer_id | Most_Popular | Number_oftimes_ordered |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- Customer A and C's favourite item is ramen.
- Customer B enjoys all items on the menu.

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
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
WHERE RANK_ = 1 ;
````

#### Answer:
| customer_id | order_date  | Product_Ordered_After_Membership |
| ----------- | ---------- |----------  |
| A           | 2021-01-07 | curry        |
| B           | 2021-01-11 | sushi        |

- Customer A's first order as member is curry.
- Customer B's first order as member is sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
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
WHERE RANK_ = 1;
````

#### Answer:
| customer_id | order_date  | Product_Ordered_Before_Membership |
| ----------- | ---------- |----------  |
| A           | 2021-01-01 |  sushi        |
| A           | 2021-01-01 |  curry        |
| B           | 2021-01-04 |  sushi        |

- Customer A’s last order before becoming a member is sushi and curry.
- Whereas for Customer B, it's sushi.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT  s.customer_id, COUNT(Distinct product_name) as Unique_items, SUM(price) as Amount_Spend
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members ms
on  s.customer_id = ms.customer_id
WHERE join_date > order_date
GROUP BY s.customer_id
;

````

| customer_id | Unique_items | Amount_Spend |
| ----------- | ---------- |----------  |
| A           |    2       |  25       |
| B           |    2       |  40       |

Before becoming members,
- Customer A spent $ 25 on 2 items.
- Customer B spent $40 on 2 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql

SELECT customer_id, SUM(CASE WHEN product_name = 'sushi' THEN price *20 
			   ELSE price * 10
			   END) as TOTAL_POINTS
FROM sales s
JOIN menu m
ON s.product_id = m.product_id 
GROUP BY customer_id;

````


#### Answer:
| customer_id | TOTAL_POINTS | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for Customer A is 860.
- Total points for Customer B is 940.
- Total points for Customer C is 360.

***

### 10. 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer  A, B and C have at the end of January?

````sql
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
````

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |
| C           | 360 |

- Total points for Customer A is 1,370.
- Total points for Customer B is 820.
- I changed the question a little bit and added the total points for Customer C as well, Total points for Customer C is 360

***

## BONUS QUESTIONS

### Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

````sql
SELECT s.customer_id, order_date, product_name, price,
	CASE WHEN join_date <= order_date THEN 'Y'
	ELSE 'N'
	END as member
FROM sales s
LEFT JOIN menu m
on s.product_id = m.product_id
LEFT JOIN members  ms
on s.customer_id = ms.customer_id;
 ````
 
#### Answer: 
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

***

### Rank All The Things - Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.

````sql
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
FROM NEW_TABLE;
````

#### Answer: 
| customer_id | order_date | product_name | price | member | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL


***
