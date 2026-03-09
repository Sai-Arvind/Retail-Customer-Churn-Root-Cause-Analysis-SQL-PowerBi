# 🎞️ Product Demand & Inventory Analysis for a Multi Store Rental Business

![movie1](https://github.com/user-attachments/assets/2fb575c5-2957-41b5-a2b9-337ee91fc36d)

**Project Overview:**
Created by **Mike Hillyer in 2005**, the Sakila Sample Database is a standardized relational dataset for SQL practice.

- Customer behavior
- Product demand
- Inventory utilization
- Store-level revenue performance

The goal is to demonstrate how SQL can be used to generate **business insights that support inventory planning, demand analysis and revenue monitoring.**

### 🧩 Business Problem

A multi store rental business needs visibility into operational performance

- Which movie genres generate the most revenue
- Which customers drive the most rentals
- How often customers rent movies
- Whether rental durations impact inventory availability
- How revenue is distributed across stores

Without structured analysis, these operational insights remain hidden within multiple relational tables.

### 🎯 Project Objective

Utilizing SQL to analyze rental transactions and uncover insights

- Revenue contribution by movie genre
- Customer lifetime value
- Rental frequency and customer engagement
- Late return patterns affecting inventory availability
- Inventory utilization across films
- Store-level revenue performance

## 📊 Dataset

Dataset Source: [MySQL Sakila Sample Database](https://github.com/jOOQ/sakila) 

Dataset **Size**:
- **50,000+** rental and payment records
- Handling **16+ relational tables** representing customers, inventory, films, and stores

<img width="799" height="521" alt="Sakila - ERD" src="https://github.com/user-attachments/assets/4ffc3c2f-1090-4a1a-88f1-1b94ca97054d" />

# 🗂️ Data Model

### Key Tables Used

| Table | Business Meaning |
|------|------------------|
| Films | Product catalog |
| Inventory | Stock |
| Store | Distribution |
| Category | Movie genres |
| Rental | Customer transactions |
| Payment | Revenue transactions |
| Customer | Customer profiles |

---

# 📈 SQL Business Analysis

## 1️⃣ Revenue by Genre

### Business Question
Which movie genres generate the highest revenue?

### Metric Utilized
`SUM(payment.amount) AS total_revenue`

### SQL Query

```sql
SELECT 
    c.name AS genre,
    SUM(p.amount) AS total_revenue
FROM payment p
JOIN rental r 
    ON p.rental_id = r.rental_id
JOIN inventory i 
    ON r.inventory_id = i.inventory_id
JOIN film f 
    ON i.film_id = f.film_id
JOIN film_category fc 
    ON f.film_id = fc.film_id
JOIN category c 
    ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_revenue DESC;
```

|Output|(Top Genres)|
|------|------------------|
|Genre | Total Revenue |
|Sports	| 5314 |
|Sci-Fi | 4756 |
|Animation | 4656 |

**Insight**

The **Sports genre** generated the highest revenue **($5.3K)** followed by **Sci-Fi ($4.7K)** indicating stronger demand for these categories and suggesting higher inventory allocation for these genres.

---

## 2️⃣ Customer Lifetime Value (CLV)

### Business Question
Which customers generate the highest lifetime revenue?

### Metric Used
`SUM(payment.amount) AS customer_lifetime_value`

### SQL Query

```sql
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS customer_lifetime_value
FROM customer c
JOIN payment p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY customer_lifetime_value DESC;
```

|Output | (Top Customers) |
|------|------------------|
|Customer |	CLV |
|Eleanor Hunt	|211|
|Karl Seal	|208|
|Clara Shaw	|205|

**Insight**
- The **top 3** customers generated over **$200 in lifetime revenue**, highlighting a small group of high-value customers driving significant recurring revenue.
---

## 3️⃣ Rental Frequency Analysis

### Business Question
How frequently do customers rent movies?

### Metric Used
`COUNT(rental_id) AS total_rentals`

### SQL Query

```sql
SELECT 
    customer_id,
    COUNT(rental_id) AS total_rentals
FROM rental
GROUP BY customer_id
ORDER BY total_rentals DESC;
```

Output
|Customer ID|	Total Rentals|
|------|------------------|
|148	| 46|
|526	|45|
|236 |	42|

**Insight**

- The **3 most active customers** rented **40+ movies**, showing that a small segment of users contributes disproportionately to rental activity.
---

## 4️⃣ Late Return Analysis

### Business Question
How long do customers keep rented movies before returning them?

### Metric Used
`DATEDIFF(return_date, rental_date) AS rental_duration`

### SQL Query

```sql
SELECT 
    rental_id,
    customer_id,
    DATEDIFF(return_date, rental_date) AS rental_duration
FROM rental;
```

Output (Sample)
|Rental ID	| Customer |	Rental Duration|
|------|------------------|-------|
|1023 |	45	|5 days
|2045| 	122	|6 days
|3156	|98	|4 days

**Insight**

Most **rentals last 4–6 days**, meaning inventory remains **unavailable during this period**, impacting product circulation.

---

## 5️⃣ Revenue by Store

### Business Question
How does revenue differ between store locations?

### Metric Used
`SUM(payment.amount) AS total_revenue`

### SQL Query

```sql
SELECT 
    s.store_id,
    SUM(p.amount) AS total_revenue
FROM payment p
JOIN staff st
    ON p.staff_id = st.staff_id
JOIN store s
    ON st.store_id = s.store_id
GROUP BY s.store_id
ORDER BY total_revenue DESC;
```

Output
|Store	|Revenue|
|------|------------------|
|Store 1	|33,902|
|Store 2	|33,079|

**Insight**

- **2 stores generated** similar **revenue (~$33K)**, indicating balanced demand and comparable store performance.
---

# 📊 Dashboard Visualization

A **Power BI dashboard** was built to visualize key operational metrics including:

- Revenue by genre  
- Customer lifetime value distribution  
- Rental frequency trends  
- Inventory utilization  
- Store revenue comparison

<img width="788" height="446" alt="image" src="https://github.com/user-attachments/assets/8ec4f433-cc0c-421f-955c-7cbe037865f0" />


---

# 📁 Repository Structure

```
Movie-Rental-Inventory-Analytics-SQL
│
├── Data
│   └── rental_records.csv
│
├── ER_Diagram
│   └── Sakila_ERD.png
|
├── SQL_Queries
│   ├── 01_revenue_by_genre.sql
│   ├── 02_customer_lifetime_value.sql
│   ├── 03_rental_frequency.sql
│   ├── 04_late_return_analysis.sql
│   ├── 05_revenue_by_store.sql
│
├── Visuals
│   ├── demand_by_genre_chart.png
│   └── rental_dashboard.png
│
├── README.md
└── .gitignore
```

---

# 🛠️ Tools & Technologies

- **SQL (MySQL)**
- **Power BI**
- Relational Data Modeling
- Data Analysis

---

# 📚 Skills Demonstrated

- Advanced SQL joins across multiple tables  
- Business metric calculations using aggregations  
- Customer analytics and segmentation   
- Revenue performance analysis  
- Data storytelling using analytical insights  

---

# 👤 About Me

**A. Sai Arvind**  
Data Analyst | SQL | Power BI | Business Analytics  

📧 Email: saiarvind5081@gmail.com  
🔗 LinkedIn: https://www.linkedin.com/in/saiarvindofficial/  
💻 GitHub: https://github.com/Sai-Arvind  

⭐ If you found this project useful, consider giving it a star.
