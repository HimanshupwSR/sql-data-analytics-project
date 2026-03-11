-- ==============================
-- TABLE OVERVIEW
-- ==============================

USE `datawarehouseanalytics`;

SELECT * FROM gold_dim_customers;
SELECT * FROM gold_dim_products;
SELECT * FROM gold_fact_sales;

SELECT * FROM INFORMATION_SCHEMA.TABLES;

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'gold_dim_customers';


-- ==============================
-- PRODUCT STRUCTURE
-- ==============================
SELECT DISTINCT
       category,
       subcategory,
       product_name
FROM gold_dim_products
ORDER BY category, subcategory, product_name;

-- ==============================
-- SALES DATE RANGE
-- ==============================
SELECT
    MIN(order_date)                                          AS first_order_date,
    MAX(order_date)                                          AS last_order_date,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date))   AS months
FROM gold_fact_sales;

-- ==============================
-- CUSTOMER AGE EXTREMES
-- ==============================
SELECT
    MIN(birthdate)                                           AS oldest_birthdate,
    TIMESTAMPDIFF(YEAR, MIN(birthdate), NOW())               AS age_of_oldest_customer,
    MAX(birthdate)                                           AS youngest_birthdate,
    TIMESTAMPDIFF(YEAR, MAX(birthdate), NOW())               AS age_of_youngest_customer
FROM gold_dim_customers;

-- ==============================
-- KPI SUMMARY REPORT
-- ==============================
SELECT 'Total Sales'         AS measure_name, SUM(sales_amount)                    AS measure_value FROM gold_fact_sales
UNION ALL
SELECT 'Total Quantity',      SUM(quantity)                                          FROM gold_fact_sales
UNION ALL
SELECT 'Avg Price',           ROUND(AVG(price), 0)                                   FROM gold_fact_sales
UNION ALL
SELECT 'Total Orders',        COUNT(DISTINCT order_number)                           FROM gold_fact_sales
UNION ALL
SELECT 'Total Products',      COUNT(product_key)                                     FROM gold_fact_sales
UNION ALL
SELECT 'Total Customers',     COUNT(DISTINCT customer_key)                           FROM gold_fact_sales;

-- ==============================
-- CUSTOMER DISTRIBUTION
-- ==============================
SELECT
    country,
    COUNT(customer_key)                                      AS total_customers
FROM gold_dim_customers
GROUP BY country
ORDER BY total_customers DESC;

SELECT
    gender,
    COUNT(customer_id)                                       AS total_customers
FROM gold_dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- ==============================
-- PRODUCT ANALYSIS
-- ==============================
SELECT
    category,
    COUNT(product_key)                                       AS total_products
FROM gold_dim_products
GROUP BY category;

SELECT
    category,
    ROUND(AVG(cost), 0)                                       AS avg_cost
FROM gold_dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- ==============================
-- REVENUE ANALYSIS
-- ==============================
SELECT
    p.category,
    SUM(fc.sales_amount)                                      AS total_revenue
FROM gold_fact_sales fc
JOIN gold_dim_products p
  ON p.product_key = fc.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(fc.sales_amount)                                      AS total_revenue
FROM gold_fact_sales fc
LEFT JOIN gold_dim_customers c
  ON fc.customer_key = c.customer_key
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_revenue DESC;

SELECT
    c.country,
    SUM(fc.quantity)                                          AS total_items_sold
FROM gold_fact_sales fc
JOIN gold_dim_customers c
  ON fc.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_items_sold DESC;

-- ==============================
-- TOP / BOTTOM PRODUCTS
-- ==============================
SELECT
    p.product_name,
    SUM(fc.sales_amount)                                      AS total_revenue
FROM gold_fact_sales fc
JOIN gold_dim_products p
  ON p.product_key = fc.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

SELECT
    p.product_name,
    SUM(fc.sales_amount)                                      AS total_revenue
FROM gold_fact_sales fc
JOIN gold_dim_products p
  ON p.product_key = fc.product_key
GROUP BY p.product_name
ORDER BY total_revenue
LIMIT 5;

-- ==============================
-- PRODUCT RANKING
-- ==============================
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(fc.sales_amount)                                  AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(fc.sales_amount) DESC) AS rank_no
    FROM gold_fact_sales fc
    JOIN gold_dim_products p
      ON p.product_key = fc.product_key
    GROUP BY p.product_name
) t
WHERE rank_no <= 5;

-- ==============================
-- TIME SERIES ANALYSIS
-- ==============================
SELECT
    YEAR(order_date)                                          AS order_year,
    MONTH(order_date)                                         AS order_month,
    SUM(sales_amount)                                         AS total_sales
FROM gold_fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

-- ==============================
-- RUNNING TOTAL
-- ==============================
SELECT
    order_year,
    order_month,
    total_sales,
    SUM(total_sales) OVER (PARTITION BY order_year ORDER BY order_month) AS running_total,
    AVG(avg_price)   OVER (PARTITION BY order_year ORDER BY order_month) AS running_avg_price
FROM (
    SELECT
        YEAR(order_date)      AS order_year,
        MONTH(order_date)     AS order_month,
        SUM(sales_amount)     AS total_sales,
        AVG(price)            AS avg_price
    FROM gold_fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), MONTH(order_date
) ) t;

-- ==============================
-- YEAR OVER YEAR ANALYSIS OF PRODUCT WHETHER SALES IS INCREASING OR NOT 
-- ==============================
WITH year_sales AS (
    SELECT
        YEAR(fc.order_date)                                    AS order_year,
        p.product_name,
        SUM(fc.sales_amount)                                   AS current_sales
    FROM gold_fact_sales fc
    LEFT JOIN gold_dim_products p
      ON fc.product_key = p.product_key
    WHERE fc.order_date IS NOT NULL
    GROUP BY YEAR(fc.order_date), p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    LAG(current_sales) OVER(PARTITION BY product_name) AS py_sales,
    current_sales -  LAG(current_sales) OVER(PARTITION BY product_name) AS diff_from_py,
    CASE WHEN  current_sales -  LAG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Increament'
         WHEN  current_sales -  LAG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Decreament'
         ELSE'No sales'
    END AS Growth,
    ROUND(  AVG(current_sales) OVER (PARTITION BY product_name)  ,0)      AS avg_sales,
    current_sales - ROUND(  AVG(current_sales) OVER (PARTITION BY product_name)  ,0) AS diff,
    CASE WHEN current_sales - ROUND(  AVG(current_sales) OVER (PARTITION BY product_name)  ,0) > 0 THEN 'Above avg'
         WHEN current_sales - ROUND(  AVG(current_sales) OVER (PARTITION BY product_name)  ,0) < 0 THEN 'Below avg'
         ELSE 'Avg'
	END AS Avg_rate
FROM year_sales
