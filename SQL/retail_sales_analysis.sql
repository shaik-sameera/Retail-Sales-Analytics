
-- ==========================================
-- RETAIL SALES ANALYSIS
-- Week 4 SQL Portfolio Project
-- ==========================================

-- 1. Overall Sales KPIs
SELECT
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(AVG(Sales), 2) AS Average_Sales,
    COUNT(*) AS Total_Records,
    ROUND(MIN(Sales), 2) AS Minimum_Sale,
    ROUND(MAX(Sales), 2) AS Maximum_Sale
FROM retail_sales;


-- 2. Sales by Product Category
SELECT
    Category,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM retail_sales
GROUP BY Category
ORDER BY Total_Sales DESC;


-- 3. Sales by Customer Segment
SELECT
    Segment,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    COUNT(DISTINCT "Customer ID") AS Unique_Customers
FROM retail_sales
GROUP BY Segment
ORDER BY Total_Sales DESC;


-- 4. Top 10 Customers
SELECT
    "Customer ID",
    "Customer Name",
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM retail_sales
GROUP BY "Customer ID", "Customer Name"
ORDER BY Total_Sales DESC
LIMIT 10;


-- 5. Sales by Region
SELECT
    Region,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM retail_sales
GROUP BY Region
ORDER BY Total_Sales DESC;


-- 6. Top 3 Products in Each Category
WITH ProductSales AS (
    SELECT
        Category,
        "Product Name",
        SUM(Sales) AS Total_Sales
    FROM retail_sales
    GROUP BY Category, "Product Name"
),
RankedProducts AS (
    SELECT
        Category,
        "Product Name",
        Total_Sales,
        DENSE_RANK() OVER (
            PARTITION BY Category
            ORDER BY Total_Sales DESC
        ) AS Product_Rank
    FROM ProductSales
)
SELECT
    Category,
    "Product Name",
    ROUND(Total_Sales, 2) AS Total_Sales,
    Product_Rank
FROM RankedProducts
WHERE Product_Rank <= 3
ORDER BY Category, Product_Rank;


-- 7. Yearly Sales Growth
WITH YearlySales AS (
    SELECT
        strftime('%Y', "Order Date") AS Sales_Year,
        SUM(Sales) AS Total_Sales
    FROM retail_sales
    GROUP BY strftime('%Y', "Order Date")
),
SalesComparison AS (
    SELECT
        Sales_Year,
        Total_Sales,
        LAG(Total_Sales) OVER (
            ORDER BY Sales_Year
        ) AS Previous_Year_Sales
    FROM YearlySales
)
SELECT
    Sales_Year,
    ROUND(Total_Sales, 2) AS Total_Sales,
    ROUND(Previous_Year_Sales, 2) AS Previous_Year_Sales,
    ROUND(
        (Total_Sales - Previous_Year_Sales) * 100.0 /
        NULLIF(Previous_Year_Sales, 0),
        2
    ) AS Growth_Percentage
FROM SalesComparison
ORDER BY Sales_Year;
