-- -------------- --
-- ADMINISTRATIVE --
-- -------------- --
USE hw_4_sql_sales_dw;

SELECT 'Table', 'Rows' FROM dim_customer
UNION
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION
SELECT 'dim_salesperson', COUNT(*) FROM dim_salesperson
UNION
SELECT 'dim_store', COUNT(*) FROM dim_store
UNION
SELECT 'fact_productsales', COUNT(*) FROM fact_productsales;


-- ------------------ --
-- HOMEWORK QUESTIONS --
-- ------------------ --

-- 1
SELECT DISTINCT CustomerName, Gender, SalesPersonName, City
FROM dim_customer C 
INNER JOIN fact_productsales P
ON C.CustomerID = P.CustomerID
INNER JOIN dim_salesperson S
ON S.SalesPersonID = P.SalesPersonID
INNER JOIN dim_date D
ON P.SalesDateKey = D.DateKey
INNER JOIN dim_product L
ON L.ProductKey = P.ProductID
WHERE D.MONTH = 9
AND D.YEAR = '2015'
AND L.ProductSalesPrice > 20
AND P.Quantity > 8;

-- 2
SELECT StoreName, City, ProductName
FROM dim_store S
INNER JOIN fact_productsales P
ON S.StoreID = P.StoreID
INNER JOIN dim_product L
ON L.ProductKey = P.ProductID
INNER JOIN dim_date D
ON P.SalesDateKey = D.DateKey
WHERE D.MONTH = 3 
AND D.YEAR = '2017'
AND L.ProductActualCost < 50
AND S.City = 'Boulder';

-- 3
SELECT SalesPersonName
FROM dim_salesperson S
LEFT JOIN fact_productsales P
ON P.SalesPersonID = S.SalesPersonID
LEFT JOIN dim_date D
ON P.SalesDateKey = D.DateKey 
WHERE D.YEAR = '2017'
GROUP BY S.SalesPersonID
ORDER BY (SUM(SalesPrice * Quantity)) DESC
LIMIT 2;

-- 4
SELECT CustomerName, SUM(SalesPrice * Quantity) AS TotalRevenue
FROM  dim_customer C
LEFT JOIN fact_productsales F
ON F.CustomerID = C.CustomerID
INNER JOIN dim_date D
ON D.datekey = F.SalesDateKey
WHERE D.YEAR = '2017'
GROUP BY C.CustomerID
ORDER BY TotalRevenue ASC
LIMIT 1;

-- 5
SELECT StoreName, SUM(SalesPrice) AS TotalSalesPrice
FROM dim_store S
RIGHT JOIN fact_productsales F
ON F.StoreID = S.StoreID
INNER JOIN dim_date D
ON D.DateKey = F.SalesDateKey
WHERE D.DATE BETWEEN '2010-01-01' AND '2017-12-31'
GROUP BY S.StoreName
ORDER BY StoreName ASC;

-- 6
SELECT StoreName, ProductName, SUM((SalesPrice * Quantity)-(ProductCost * Quantity)) AS TotalProfit
FROM fact_productsales F
LEFT JOIN dim_store S
ON S.StoreID = F.StoreID
LEFT JOIN dim_product P
ON P.ProductKey = F.ProductID
INNER JOIN dim_date D
ON D.DateKey = F.SalesDateKey
WHERE ProductName LIKE '%Jasmine Rice%'
AND D.YEAR = '2010'
GROUP BY F.StoreID;

-- 7
SELECT QUARTER AS Quarter, SUM(SalesPrice * Quantity) AS TotalRevenue
FROM dim_date D
LEFT JOIN fact_productsales F
ON F.SalesDateKey = D.DateKey
LEFT JOIN dim_store S
ON S.StoreID = F.StoreID
WHERE S.StoreName = 'ValueMart Boulder'
AND D.YEAR = '2016'
GROUP BY QUARTER
ORDER BY QUARTER ASC;

-- 8
SELECT CustomerName, SUM(SalesPrice) AS TotalSalesPrice
FROM dim_customer C
RIGHT JOIN fact_productsales F
ON C.CustomerID = F.CustomerID
WHERE CustomerName = 'Melinda Gates'
OR CustomerName = 'Harrison Ford'
GROUP BY F.CustomerID;

-- 9
SELECT StoreName, SalesPrice, Quantity
FROM dim_store S
RIGHT JOIN fact_productsales F
ON S.StoreID = F.StoreID
INNER JOIN dim_date D
ON F.SalesDateKey = D.DateKey
WHERE D.DATE = '2017-03-12';

-- 10
SELECT SalesPersonName, SUM(SalesPrice*Quantity) AS TotalRevenue
FROM dim_salesperson S
RIGHT JOIN fact_productsales F
ON S.SalesPersonID = F.SalesPersonID
GROUP BY F.SalesPersonID
ORDER BY TotalRevenue DESC
LIMIT 1;

-- 11
SELECT ProductName
FROM dim_product P
RIGHT JOIN fact_productsales F
ON P.ProductKey = F.ProductID
GROUP BY F.ProductID
ORDER BY SUM((SalesPrice - ProductCost)*Quantity) DESC
LIMIT 3;

-- 12
SELECT D.YEAR AS Year, D.MonthName AS 'Month', SUM(SalesPrice*Quantity) AS TotalRevenue
FROM fact_productsales F
INNER JOIN dim_date D
ON F.SalesDateKey = F.SalesDateKey
WHERE D.DATE BETWEEN '2017-01-01' AND '2017-03-31'
GROUP BY D.MonthName;

-- 13
SELECT ProductName, ROUND(AVG(ProductCost), 2) AS AverageProductCost, ROUND(AVG(SalesPrice), 2) AS AverageSalesPrice
FROM dim_product P
RIGHT JOIN fact_productsales F
ON P.ProductKey = F.ProductID
INNER JOIN dim_date D
ON F.SalesDateKey = D.DateKey
WHERE D.YEAR = '2017'
GROUP BY F.ProductID;

-- 14
SELECT CustomerName, ROUND(AVG(SalesPrice), 2) AS AverageSalesPrice, ROUND(AVG(Quantity), 2) AS AverageQuantity
FROM dim_customer C
RIGHT JOIN fact_productsales F
ON C.CustomerID = F.CustomerID
WHERE C.CustomerName = 'Melinda Gates';

-- 15
SELECT StoreName, ROUND(MAX(SalesPrice), 2) AS MaximumSalesPrice, ROUND(MIN(SalesPrice), 2) AS MinimumSalesPrice
FROM dim_store S
RIGHT JOIN fact_productsales F
ON S.StoreID = F.StoreID
WHERE City = 'Boulder'
GROUP BY F.StoreID;