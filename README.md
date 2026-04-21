# Retail Store Movie Business Analysis

- **Industry:** Rental & Subscription Retail (Netflix DVD Era Simulation)

- **Demand** & **Inventory Optimization** using Customer, Product & Store Insight
- Demand is widely distributed across categories, with the top category contributing only ~7% and even the top 5 categories accounting for just ~35% of total demand, indicating no strong category dominance.




<img width="1280" height="720" alt="image" src="https://github.com/user-attachments/assets/c8759eac-a1d2-4239-afee-1dc7f47237b2" />

---

### ⚡ Executive Summary

1. This project simulates a 2005-era DVD rental business (Netflix / Rent-the-Runway style model) where
 - Physical Inventory
 - Customer Loyalty
 - Return Behavior directly impact revenue and availability.


---

### 🚩 Business Problem
Key challenges:

- Inventory Mismatch: Why does the store with more stock generate less revenue?
- Loyalty Gaps: Who are the 'Elite' users driving the most value?
- Revenue Leakage: How many potential rentals are lost due to late returns?
- Genre Concentration: Is the business too reliant on specific niches like Sports and Sci-Fi?

---

### 🎯 Objective

To build a scalable analytics framework that:

- Tracks Rental Health (Total Revenue, AOV, and Active Base).
- Identifies High-Value Tiers (Elite VIP vs. Occasional).
- Optimizes Store Inventory (balancing supply vs. demand).
- Detects Late Return Patterns to improve stock availability.


---

### 📊 Primary KPI Framework ⭐

| Category         | KPIs                                   | Insight                                 |
|----------------|----------------------------------------|------------------------------------------|
| Business Health | Total Revenue, Total Rentals, AOV      | Overall financial scale.                 |
| Customer Active | Customers, CLV, Loyalty Tiers          | User retention and value.                |
| Product         | Revenue by Genre, Inventory Velocity   | Content demand vs. supply.               |
| Operations      | Avg Rental Duration, Late Return Count | Asset turnover and efficiency.           |


---


### 🗄️ Dataset

Source: [MySQL Sakila Sample Database](https://github.com/jOOQ/sakila) 

Scale:
- **32,000+** rental & payment records
- Across 16+ relational tables
- Customers, Films, Inventory, Stores, Rentals


---


### ⚙️ SQL Deep-Dive Analysis

### Current Business Health

``` sql

-- Revenue
select sum(amount) as revenue from payment;

-- Rentals
select count(*) as total_rentals from rental;

-- Active Customers
select count(distinct customer_id) as active_customers from rental;

-- AOV
select avg(amount) as avg_order_value from payment;

```
### Demand Analysis Layer

``` sql

-- Demand by Category

SELECT 
    c.name AS category,
    COUNT(r.rental_id) AS demand,
    ROUND(
        100 * COUNT(r.rental_id) / SUM(COUNT(r.rental_id)) OVER (), 
        2
    ) AS demand_pct
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY demand DESC;


-- Demand by rating

SELECT 
    f.rating,
    COUNT(r.rental_id) AS demand,
    ROUND(
        100 * COUNT(r.rental_id) / SUM(COUNT(r.rental_id)) OVER (), 
        2
    ) AS demand_pct
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.rating
ORDER BY demand DESC;

 -- What type of content is preferred (PG, R, etc.)

> Demand is evenly distributed across categories, with no single genre dominating consumption.
> Additionally, variation across content ratings indicates diverse audience preferences.


```


### Inventory Layer

``` sql

-- 1. Title wise Demand vs Inventory Efficiency
SELECT 
    f.title,
    COUNT(r.rental_id) AS demand,
    COUNT(DISTINCT i.inventory_id) AS inventory,
    ROUND(
        COUNT(r.rental_id) / COUNT(DISTINCT i.inventory_id), 
        2
    ) AS demand_per_inventory
FROM film f
JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
-- ORDER BY demand_per_inventory DESC
ORDER BY demand_per_inventory ASC
LIMIT 10;
;

-- Inventory utilization varies significantly across titles, with top-performing films achieving ~5 rentals per copy,
-- While lower-performing titles average around ~2, indicating both understocking of high-demand content and overstocking of low-demand titles.



Metric → demand_per_inventory
Comparison → top vs bottom
Insight → imbalance
Business meaning → under/overstock

```



### Customer Layer 

``` SQL


-- 1. Customer Activity

SELECT 
    customer_id,
    COUNT(rental_id) AS total_rentals
FROM rental
GROUP BY customer_id
ORDER BY total_rentals DESC;


-- 2. Customer Segments

SELECT 
    CASE 
        WHEN rental_count >= 30 THEN 'High Value'
        WHEN rental_count BETWEEN 15 AND 29 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS customer_count
FROM (
    SELECT 
        customer_id,
        COUNT(rental_id) AS rental_count
    FROM rental
    GROUP BY customer_id
) t
GROUP BY customer_segment;



-- 3. Revenue Contribution via customer 


SELECT 
    c.customer_id,
    SUM(p.amount) AS total_spent
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;


```


### STORE LAYER


``` sql

-- 1. Store wise Performance

SELECT 
    s.store_id,
    COUNT(r.rental_id) AS total_rentals,
    SUM(p.amount) AS revenue
FROM store s
JOIN staff st ON s.store_id = st.store_id
JOIN rental r ON st.staff_id = r.staff_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY s.store_id;

-- Which store drives more rentals & revenue




-- 2. Store Inventory vs Demand

SELECT 
    s.store_id,
    COUNT(r.rental_id) AS demand,
    COUNT(DISTINCT i.inventory_id) AS inventory,
    ROUND(
        COUNT(r.rental_id) / COUNT(DISTINCT i.inventory_id), 
        2
    ) AS demand_per_inventory
FROM store s
JOIN inventory i ON s.store_id = i.store_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY s.store_id;

-- Which store is:

-- Efficient (high ratio)
-- Inefficient (low ratio)




```


### Sesonality, Ternds over time, date 


``` sql 

-- 1. How does demand/revenue change over time?

-- demand over time 
SELECT 
    DATE_FORMAT(r.rental_date, '%Y-%m') AS month,
    COUNT(*) AS demand
FROM rental r
GROUP BY month
ORDER BY month;


-- 2. rev over time 

SELECT 
    DATE_FORMAT(p.payment_date, '%Y-%m') AS month,
    SUM(p.amount) AS revenue
FROM payment p
GROUP BY month
ORDER BY month;


```



---


### ER Diagram

<img width="799" height="521" alt="Sakila - ERD" src="https://github.com/user-attachments/assets/4ffc3c2f-1090-4a1a-88f1-1b94ca97054d" />



---


### ✨ Power BI Implementation
DAX Measures Utilized:

Average Rental Duration: AVG_Duration = AVERAGE(Rental[Duration])

Customer Tiering: 
```dax
Loyalty_Tier = SWITCH(TRUE(),
[Rental_Count] >= 40, "Elite VIP",
[Rental_Count] >= 20, "Preferred",
"Occasional")

Store Revenue Gap: Revenue_Gap = [Store 2 Revenue] - [Store 1 Revenue]




```

---





### 📈 Business Performance Snapshot
Total Revenue: $67,416.51

Active Customers: 599

Avg Rental Duration: 4.99 Days

Inventory Capacity: 4,581 Units across 1,000 Films


---

### ⚡ Business Meaning (this is key)
❗ No heavy concentration means:
No single category drives the business
Customers have diverse preferences








---


### 📊 Key Insights

### 👥 Customer Intelligence
1. High Stability: The top 10 customers have a narrow spend range ($193–$211), indicating a very stable power-user base.

2. Retention Success: The bulk of users are "Regulars" (11–19 rentals), showing high stickiness.

### 🛍️ Product & Genre Performance

1. Niche Dominance: Sports (21%) and Sci-Fi (19%) drive nearly half of all revenue.
2. Underperformers: Travel and Music genres show significantly lower engagement, suggesting inventory should be shifted.

### ⚙️ Operational Inefficiency

1. The Store Paradox: Store 2 has more inventory but fewer customers than Store 1.
2. Late Returns: High late return counts in specific genres (Sports) are likely causing "out-of-stock" issues during peak windows.

### 💡 Business Recommendations
- Inventory Rebalancing: Relocate underperforming inventory from Store 2 to Store 1 to meet higher customer foot traffic.
- Late Return Mitigation: Introduce a "Loyalty Bonus" for early returns to increase Inventory Velocity and film availability.
- Targeted Niche Expansion: Since Sports and Sci-Fi are the "hooks," bundle these with lower-performing genres to increase AOV.
- Top-of-Funnel Focus: Launch a "First 3 Rentals Free" campaign to convert the "Casual" segment into the "Regular" tier.




--- 


```
📁 Repository Structure
Movie-Rental-Inventory-Analytics-SQL
│
├── Data
│   └── rental_records.csv
│
├── ER_Diagram
│   └── Sakila_ERD.png
│
├── SQL_Queries
│   ├── 01_revenue_by_genre.sql
│   ├── 02_customer_lifetime_value.sql
│   ├── 03_rental_frequency.sql
│   ├── 04_late_return_analysis.sql
│   └── 05_revenue_by_store.sql
│
├── Visuals
|   ├── Key Dataset Metrics
│   └── rental_dashboard.png
│
├── Advanced_SQL_Analysis
│   ├── CTEs
│   └── Window_Function
│
├── README.md
└── .gitignore

```
---

### ⚙️ Tech Stack

| Tool      | Purpose ⭐                                               |
|-----------|----------------------------------------------------------|
| Excel     | ETL, Power Query, Data Cleaning, Transformation          |
| SQL       | Deep analysis, Aggregations, calculations & segmentation |
| Power BI  | Data modeling, DAX measures, dashboards, charts & visualization |

---

![movie1](https://github.com/user-attachments/assets/2fb575c5-2957-41b5-a2b9-337ee91fc36d)


### 👤 About Me

**A Sai Arvind**  

📧 Email: saiarvind5081@gmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/saiarvindofficial/  
💻 GitHub: https://github.com/Sai-Arvind  

⭐ If you found this project useful, consider giving it a star.

