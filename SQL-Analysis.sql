
-- =========================
-- Dvd Rental Chrun Analysis
-- Sai Arvind
-- =========================


----------------------------------------------------------------------------- Auditing

-- Total Revenue
select sum(amount) as revenue
from payment;

-- Total rentals 
select count(*) as total_rentals
from rental;

-- Total customer base active 
select count(distinct customer_id) as active_customers
from rental;

-- AOV %
SELECT AVG(amount) AS avg_order_value
FROM payment;

----------------------------------------------------------------------------- 1. Operational KPIs

-- 1. Late Return Rate (LRR)
SELECT 
    COUNT(*) AS total_returns,
    SUM(
        CASE 
            WHEN r.return_date > DATE_ADD(r.rental_date, INTERVAL f.rental_duration DAY)
            THEN 1 ELSE 0 
        END
    ) AS late_returns,
    ROUND(
        SUM(
            CASE 
                WHEN r.return_date > DATE_ADD(r.rental_date, INTERVAL f.rental_duration DAY)
                THEN 1 ELSE 0 
            END
        ) * 100.0 / COUNT(*), 2
    ) AS late_return_rate_pct
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.return_date IS NOT NULL;



-- 2. Avg Rental Delay
SELECT 
    ROUND(AVG(
        DATEDIFF(
            r.return_date,
            DATE_ADD(r.rental_date, INTERVAL f.rental_duration DAY)
        )
    ), 2) AS avg_delay_days
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.return_date IS NOT NULL
AND r.return_date > DATE_ADD(r.rental_date, INTERVAL f.rental_duration DAY);



-- 3. Revenue per Rental
SELECT 
    ROUND(AVG(p.amount), 2) AS avg_revenue_per_rental
FROM payment p;



-- 4. Rental Duration Utilization
SELECT 
    ROUND(AVG(
        DATEDIFF(r.return_date, r.rental_date)
    ), 2) AS avg_actual_days,
    ROUND(AVG(f.rental_duration), 2) AS avg_allowed_days
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.return_date IS NOT NULL;



----------------------------------------------------------------------------- 2. Inventory KPIs


-- 1. Inventory Turnover
SELECT 
    f.title,
    COUNT(r.rental_id) AS total_rentals,
    COUNT(DISTINCT i.inventory_id) AS total_copies,
    ROUND(COUNT(r.rental_id) / COUNT(DISTINCT i.inventory_id), 2) AS inventory_turnover
FROM film f
JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY inventory_turnover DESC;



-- 2. Asset ROI
SELECT 
    f.title,
    f.replacement_cost,
    SUM(p.amount) AS total_revenue,
    ROUND(SUM(p.amount) / f.replacement_cost, 2) AS asset_roi
FROM film f
JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.title, f.replacement_cost
ORDER BY asset_roi DESC;



-- 3. Revenue per Title
SELECT 
    f.title,
    SUM(p.amount) AS total_revenue
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.title
ORDER BY total_revenue DESC;



-- 4. Demand per Copy
SELECT 
    f.title,
    COUNT(r.rental_id) AS total_rentals,
    COUNT(DISTINCT i.inventory_id) AS copies,
    ROUND(COUNT(r.rental_id) / COUNT(DISTINCT i.inventory_id), 2) AS demand_per_copy
FROM film f
JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY demand_per_copy DESC;


----------------------------------------------------------------------------- 3. Customer KPIs (RFM + Churn)

-- 1. Recency

-- SELECT 
--     c.customer_id,
--     MAX(p.payment_date) AS last_payment_date,
--     DATEDIFF(
--         (SELECT MAX(payment_date) FROM payment),
--         MAX(p.payment_date)
--     ) AS recency_days
-- FROM customer c
-- LEFT JOIN payment p 
--     ON c.customer_id = p.customer_id
-- GROUP BY c.customer_id;

SELECT 
    c.customer_id,
    SUM(p.amount) AS total_spent,
    DATEDIFF(
        (SELECT MAX(payment_date) FROM payment),
        MAX(p.payment_date)
    ) AS recency_days
FROM customer c
JOIN payment p 
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY recency_days DESC;

-- SELECT MAX(payment_date) FROM payment;


-- 2. Frequency
SELECT 
    customer_id,
    COUNT(rental_id) AS total_rentals
FROM rental
GROUP BY customer_id
ORDER BY total_rentals DESC;


-- 3. Monetary (CLV Proxy)
SELECT 
    customer_id,
    SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
ORDER BY total_spent DESC;


-- 4. Churn (Inactive Customers)
SET @max_date = (SELECT MAX(payment_date) FROM payment);

SELECT 
    c.customer_id,
    MAX(p.payment_date) AS last_activity,
    DATEDIFF(@max_date, MAX(p.payment_date)) AS days_inactive
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
HAVING days_inactive > 30
ORDER BY days_inactive DESC;




-- 5. Recency Segmentation Query 
WITH customer_recency AS (
    SELECT 
        c.customer_id,
        SUM(p.amount) AS total_spent,
        DATEDIFF(
            (SELECT MAX(payment_date) FROM payment),
            MAX(p.payment_date)
        ) AS recency_days
    FROM customer c
    JOIN payment p 
        ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
)

SELECT 
    customer_id,
    total_spent,
    recency_days,
    
    CASE 
        WHEN recency_days <= 160 THEN 'Active'
        WHEN recency_days BETWEEN 161 AND 170 THEN 'At Risk'
        ELSE 'Inactive'
    END AS customer_segment

FROM customer_recency
ORDER BY recency_days DESC;


-- Time Series Analysis
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    COUNT(*) AS rentals,
    SUM(amount) AS revenue
FROM payment
GROUP BY month
ORDER BY month;



----------------------------------------------------------------------------- Advanced

-- cohort 

WITH late_users AS (
    SELECT DISTINCT customer_id
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    WHERE r.return_date > DATE_ADD(r.rental_date, INTERVAL f.rental_duration DAY)
),

customer_activity AS (
    SELECT 
        c.customer_id,
        MAX(p.payment_date) AS last_activity,
        DATEDIFF((SELECT MAX(payment_date) FROM payment), MAX(p.payment_date)) AS recency
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
)

SELECT 
    CASE 
        WHEN l.customer_id IS NOT NULL THEN 'Late Users'
        ELSE 'On-Time Users'
    END AS user_type,
    
    COUNT(*) AS customers,
    
    ROUND(AVG(recency),2) AS avg_recency,
    
    ROUND(AVG(CASE WHEN recency > 30 THEN 1 ELSE 0 END)*100,2) AS churn_rate_pct

FROM customer_activity c
LEFT JOIN late_users l 
    ON c.customer_id = l.customer_id

GROUP BY user_type;
