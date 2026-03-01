# 🎬 Movie Rental Risk Analytics - SQL Revenue Leakage Analysis
<img width="1024" height="585" alt="image" src="https://github.com/user-attachments/assets/08dcb68b-263c-44cf-99a5-9b5e7b8aa6d1" />

### Financial Risk Modeling on 80,000+ Rental Transactions using SQL

---

## 🧩 Business Problem

The movie rental business lacked visibility into:

- Revenue exposure from delayed payments  
- Customer payment risk patterns  
- Genre-wise revenue dependency  
- Cash flow predictability  

Without structured risk segmentation, revenue leakage from inconsistent payment behavior could not be quantified.

---

## 🎯 Project Objective

To identify high-risk customer segments contributing to revenue instability and quantify how much revenue is tied to delayed or inconsistent payment behavior.

---

## 📊 Data Overview

**Dataset:** Sakila Movie Rental Database  
**Source:** [MySQL Sakila Sample Database](https://github.com/jOOQ/sakila) 
**Data Volume:** 80,000+ rental & payment records  

### Core Tables Used

| Table | Purpose |
|--------|---------|
| rental | Rental transactions |
| payment | Revenue & payment timestamps |
| customer | Customer profiles |
| film | Movie details |
| category | Genre classification |
| inventory | Film-store mapping |

<img width="799" height="521" alt="Sakila - ERD" src="https://github.com/user-attachments/assets/4ffc3c2f-1090-4a1a-88f1-1b94ca97054d" />
---

## 🧠 Key Technical Implementation: SQL Risk Modeling

### 🔹 Data Volume
Processed **80,000+ transactions** to analyze payment risk behavior.

### 🔹 Joins
Merged:
- rental  
- payment  
- film  
- category  

to calculate revenue and risk exposure at the **genre level**.

### 🔹 Window Functions
Used `LAG()` and `LEAD()` to:

- Measure delay between consecutive rentals  
- Identify inconsistent payment behavior  
- Detect patterns of late returns impacting revenue cycles  

### 🔹 Risk Segmentation Logic

Customers were segmented into:

- 🟢 Low Risk  
- 🟡 Medium Risk  
- 🔴 High Risk  

based on payment delay frequency and rental behavior.

### 🔹 Aggregation Insight

Calculated that **25% of total revenue** was associated with the **High-Risk customer segment**, indicating potential revenue leakage exposure.

---

## 💻 Sample Risk Segmentation Query

```sql
-- Risk Segmentation by Genre
WITH PaymentDelays AS (
    SELECT 
        c.customer_id,
        f.title,
        cat.name AS genre,
        p.amount,
        DATEDIFF(r.return_date, r.rental_date) AS rental_duration,
        LAG(p.payment_date) OVER (PARTITION BY c.customer_id ORDER BY p.payment_date) AS prev_payment_date
    FROM rental r
    JOIN payment p ON r.rental_id = p.rental_id
    JOIN customer c ON r.customer_id = c.customer_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category cat ON fc.category_id = cat.category_id
)

SELECT 
    genre,
    COUNT(customer_id) AS total_customers,
    SUM(amount) AS total_revenue
FROM PaymentDelays
GROUP BY genre
ORDER BY total_revenue DESC;
```

---

## 📈 Key Insights

| Area | Insight |
|------|----------|
| 💰 Revenue Risk | 25% of revenue tied to high-risk payment behavior |
| 🎬 Genre Exposure | Certain genres showed higher delayed-payment frequency |
| 👥 Customer Risk | Small segment of customers created disproportionate revenue instability |
| 🕒 Payment Behavior | Repeated delays detected using window functions |

---

## 📊 Risk vs Genre Visualization

A Power BI dashboard was built to visualize:

- Revenue by Risk Category  
- Genre-wise Risk Distribution  
- Payment Delay Patterns  
- High-Risk Revenue Contribution  

📷 Dashboard /Visuals folder
<img width="804" height="459" alt="dvd_dashboard" src="https://github.com/user-attachments/assets/47a21175-d7d7-405e-aad0-c83d2c132566" />
---

## 💡 Business Recommendations

- Implement credit monitoring for high-risk customers  
- Introduce late fee automation  
- Incentivize on-time returns  
- Monitor genre-specific revenue volatility  
- Build early warning churn signals  

---

## 🗂️ Updated Repository Structure

```
Movie-Rental-Risk-Analytics-SQL-Revenue-Leakage-Analysis/
│
├── Data/
│   └── rental_records.csv
│
├── SQL_Queries/
│   ├── 01_store_revenue.sql
│   ├── 02_movie_category.sql
│   ├── 03_top_customers.sql
│   ├── 04_rental_analysis.sql
│   ├── 05_staff_performance.sql
│   ├── 06_geo_revenue.sql
│   ├── 07_inventory_status.sql
│   └── risk_segmentation_by_genre.sql
│
├── Visuals/
│   ├── risk_vs_genre_chart.png
│   └── segmentation_output.png
│
├── ER_Diagram/
│   └── Sakila_ERD.png
│
├── README.md
└── .gitignore
```

---

## 🛠️ Tools & Technologies

- MySQL  
- SQL (Joins, CTEs, Window Functions, Aggregations)  
- Power BI  
- Data Modeling  
- Risk Segmentation  

---

## 🎯 What This Project Demonstrates

- Advanced SQL (Window Functions + CTEs)  
- Revenue Leakage Analysis  
- Risk-Based Customer Segmentation  
- Genre-Level Revenue Modeling  
- Business-Oriented SQL Storytelling  

---

## 👤 About Me

**A. Sai Arvind**  
Data Analyst | SQL | Power BI | Risk & Revenue Analytics  

📧 saiarvind5081@gmail.com  
🔗 https://www.linkedin.com/in/saiarvindofficial/  
🔗 https://github.com/Sai-Arvind  

---

⭐ If you found this project valuable, consider giving it a star!
