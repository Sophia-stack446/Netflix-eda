-- ================================================
-- WEEK 3 SQL ASSIGNMENT
-- AnalystLab Africa Internship Program
-- Name: Sophia
-- Dataset 1: Chinook Database
-- Dataset 2: Sales Dataset
-- ================================================

-- ================================================
-- SECTION 1: CHINOOK DATABASE
-- ================================================

USE Chinook;
GO

-- 1. Top 10 most expensive tracks
SELECT TOP 10 Name, UnitPrice
FROM Track
ORDER BY UnitPrice DESC;

-- 2. Total revenue per customer
SELECT 
    C.FirstName + ' ' + C.LastName AS CustomerName,
    SUM(I.Total) AS TotalSpent
FROM Customer C
INNER JOIN Invoice I ON C.CustomerId = I.CustomerId
GROUP BY C.FirstName, C.LastName
ORDER BY TotalSpent DESC;

-- 3. Top 10 artists by revenue
SELECT TOP 10
    AR.Name AS ArtistName,
    SUM(IL.UnitPrice * IL.Quantity) AS TotalRevenue
FROM InvoiceLine IL
INNER JOIN Track T ON IL.TrackId = T.TrackId
INNER JOIN Album AL ON T.AlbumId = AL.AlbumId
INNER JOIN Artist AR ON AL.ArtistId = AR.ArtistId
GROUP BY AR.Name
ORDER BY TotalRevenue DESC;

-- 4. Rank customers by spending within each country (Window Function)
SELECT 
    C.Country,
    C.FirstName + ' ' + C.LastName AS CustomerName,
    SUM(I.Total) AS TotalSpent,
    RANK() OVER (PARTITION BY C.Country ORDER BY SUM(I.Total) DESC) AS RankInCountry
FROM Customer C
INNER JOIN Invoice I ON C.CustomerId = I.CustomerId
GROUP BY C.Country, C.FirstName, C.LastName
ORDER BY C.Country, RankInCountry;

-- 5. Customers who spent above average (Subquery)
SELECT 
    C.FirstName + ' ' + C.LastName AS CustomerName,
    SUM(I.Total) AS TotalSpent
FROM Customer C
INNER JOIN Invoice I ON C.CustomerId = I.CustomerId
GROUP BY C.FirstName, C.LastName
HAVING SUM(I.Total) > (SELECT AVG(TotalPerCustomer) 
                        FROM (SELECT SUM(Total) AS TotalPerCustomer 
                              FROM Invoice 
                              GROUP BY CustomerId) AS AvgTable)
ORDER BY TotalSpent DESC;

-- 6. Monthly revenue trend
SELECT 
    YEAR(InvoiceDate) AS Year,
    MONTH(InvoiceDate) AS Month,
    SUM(Total) AS MonthlyRevenue
FROM Invoice
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY Year, Month;

-- ================================================
-- SECTION 2: SALES DATASET
-- ================================================

USE SalesDB;
GO

-- 7. Top 10 customers by total sales
SELECT TOP 10
    CUSTOMERNAME,
    ROUND(SUM(SALES), 2) AS TotalRevenue
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY TotalRevenue DESC;

-- 8. Sales by product line
SELECT 
    PRODUCTLINE,
    ROUND(SUM(SALES), 2) AS TotalRevenue,
    COUNT(ORDERNUMBER) AS TotalOrders
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY TotalRevenue DESC;

-- 9. Revenue by year
SELECT 
    YEAR_ID,
    ROUND(SUM(SALES), 2) AS TotalRevenue,
    COUNT(ORDERNUMBER) AS TotalOrders
FROM sales_data_sample
GROUP BY YEAR_ID
ORDER BY YEAR_ID;

-- 10. Rank products by revenue within each product line (Window Function)
SELECT 
    PRODUCTLINE,
    PRODUCTCODE,
    ROUND(SUM(SALES), 2) AS TotalRevenue,
    RANK() OVER (PARTITION BY PRODUCTLINE ORDER BY SUM(SALES) DESC) AS RankInCategory
FROM sales_data_sample
GROUP BY PRODUCTLINE, PRODUCTCODE
ORDER BY PRODUCTLINE, RankInCategory;