# 📊 Sales Data Analysis using SQL

## 📌 Project Overview
This project performs **data analysis on a retail sales dataset** using SQL.  
The objective of the project is to analyze **customer behavior, product performance, and revenue trends** in order to generate meaningful business insights.

The dataset is structured using a **data warehouse star schema** consisting of **fact and dimension tables**.

---

## 🗂️ Dataset Structure

The project uses the following tables:

### 1️⃣ Customers Dimension
**Table:** `gold_dim_customers`

Contains customer information such as:

- customer_id
- first_name
- last_name
- gender
- country
- birthdate

---

### 2️⃣ Products Dimension
**Table:** `gold_dim_products`

Contains product-related information:

- product_key
- product_name
- category
- subcategory
- cost

---

### 3️⃣ Sales Fact Table
**Table:** `gold_fact_sales`

Contains transactional sales data:

- order_number
- order_date
- product_key
- customer_key
- quantity
- price
- sales_amount

---

# 🎯 Project Objectives

This project answers important business questions such as:

- What is the **total revenue generated**?
- Which **products generate the most revenue**?
- Which **customers contribute the most sales**?
- Which **countries have the highest number of customers**?
- What are the **monthly and yearly sales trends**?
- Which products are **growing or declining over time**?

---
## 🎯 What This Project Demonstrates

This project demonstrates my ability to:

- Perform **advanced SQL analysis**
- Use **window functions for business analytics**
- Generate **business insights from raw data**
- Structure data projects for real-world analysis
