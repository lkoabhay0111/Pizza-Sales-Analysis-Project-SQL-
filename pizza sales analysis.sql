use pizzahut;
select * from orders;
select * from order_details;
select * from pizza_types;
select * from pizzas;
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
 -- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS Total_revenue
FROM
    order_details AS o
        JOIN
    pizzas AS p ON o.pizza_id = p.pizza_id;
    
    
-- Identify the highest-priced pizza

select
    t.name, p.price
FROM
    pizza_types AS t
        JOIN
    pizzas AS p ON t.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(*) AS total_orders
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY total_orders desc;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    t.name, SUM(o.quantity) AS total_quantity
FROM
    pizza_types AS t
        JOIN
    pizzas AS p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
GROUP BY t.name
ORDER BY total_quantity DESC
LIMIT 5; 

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    t.category, SUM(quantity) AS total_quantity
FROM
    pizza_types AS t
        JOIN
    pizzas AS p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
GROUP BY t.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS order_hour,
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY order_hour
ORDER BY order_count DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS order_count
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

with cte1 as (
select o.order_date,sum(d.quantity) as total_quantity
from orders as o
join order_details as d
on o.order_id=d.order_id
group by order_date) 
select avg(total_quantity) from cte1;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    t.name, SUM(o.quantity * p.price) AS revenue
FROM
    pizza_types AS t
        JOIN
    pizzas AS p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
GROUP BY t.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    t.category,
    SUM(o.quantity * p.price) AS revenue,
    ROUND(SUM(o.quantity * p.price) * 100 / (SELECT 
                    SUM(od.quantity * pi.price)
                FROM
                    pizzas AS pi
                        JOIN
                    order_details AS od ON pi.pizza_id = od.pizza_id),
            2) AS revenue_percentage
FROM
    pizza_types AS t
        JOIN
    pizzas AS p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
GROUP BY t.category
ORDER BY revenue_percentage DESC;


-- Analyze the cumulative revenue generated over time

select o.order_date,round(sum(od.quantity * p.price),2) as daily_revenue,
round(sum(sum(od.quantity * p.price)) over (order by o.order_date ),2) as cumulative_revenue
from orders as o
join order_details as od
on o.order_id=od.order_id
join pizzas as p 
on od.pizza_id=p.pizza_id
group by o.order_date
order by o.order_date;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH pizza_revenue AS (
    SELECT 
        t.category,
        t.name,
        SUM(o.quantity * p.price) AS revenue
    FROM pizza_types t
    JOIN pizzas p
      ON t.pizza_type_id = p.pizza_type_id
    JOIN order_details o
      ON p.pizza_id = o.pizza_id
    GROUP BY t.category, t.name
),
ranked_pizzas AS (
    SELECT *,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM pizza_revenue
)
SELECT category, name, revenue
FROM ranked_pizzas
WHERE rnk <= 3
ORDER BY category, revenue DESC;



