-- -------------- --
-- ADMINISTRATIVE --
-- -------------- --
SHOW DATABASES;

USE hw_3_sql_northwinds;

SHOW TABLES;

SELECT table_name, table_rows
FROM information_schema.tables
WHERE TABLE_NAME LIKE 'HW%';

-- ------------------ --
-- HOMEWORK QUESTIONS --
-- ------------------ --

-- 1
SELECT CompanyName, Country 
FROM hwsuppliers 
WHERE country='Japan' OR country='Germany';

-- 2
SELECT ProductName, QuantityPerUnit, UnitPrice
FROM hwproducts
WHERE UnitPrice < 7 AND UnitPrice > 4;

-- 3
SELECT CompanyName, ContactTitle, City
FROM hwcustomers
WHERE (Country = 'USA' AND City = 'Portland')
OR (Country = 'Canada' AND City = 'Vancouver');

-- 4
SELECT ContactName, ContactTitle
FROM hwsuppliers
WHERE SupplierID <= 8 AND SupplierID >= 5
ORDER BY ContactName DESC;

-- 5
SELECT p.ProductName, p.UnitPrice
FROM hwproducts AS p
INNER JOIN
	(SELECT ProductName, UnitPrice
	FROM hwproducts
    ORDER BY UnitPrice ASC
    LIMIT 5) AS q
ON p.ProductName = q.ProductName
ORDER BY p.UnitPrice ASC;

-- 6
SELECT ShipCountry, COUNT(*) AS OrderCounts
FROM hworders
WHERE ShipCountry != 'USA'
AND ShippedDate BETWEEN '2015/05/04' AND '2015/05/05'
GROUP BY ShipCountry;

-- 7
SELECT FirstName, LastName, HireDate
FROM hwemployees
WHERE country != 'USA'
AND DATEDIFF(CURDATE(), HireDate) >= (5*365);

-- 8
SELECT ProductName, (UnitsInStock*UnitPrice) AS InventoryValue
FROM hwproducts
WHERE (UnitsInStock*UnitPrice) < 4000 AND (UnitsInStock*UnitPrice) > 3000;

-- 9
SELECT ProductName, UnitsInStock, ReorderLevel
FROM hwproducts
WHERE ProductName LIKE 'S%'
AND UnitsInStock <= ReorderLevel;

-- 10
SELECT ProductName, UnitPrice
FROM hwproducts
WHERE QuantityPerUnit LIKE '%box%'
AND Discontinued = 1;

-- 11
SELECT ProductName, (UnitsInStock*UnitPrice) AS InventoryValue
FROM hwproducts
INNER JOIN hwsuppliers
ON hwproducts.SupplierID = hwsuppliers.SupplierID
WHERE hwsuppliers.Country = 'Japan';

-- 12
SELECT Country, COUNT(*) AS CustomerCount
FROM hwcustomers
GROUP BY Country
HAVING CustomerCount > 8;

-- 13
SELECT ShipCountry, ShipCity, COUNT(*) AS OrderCount
FROM hworders
WHERE ShipCountry = 'Austria'
OR ShipCountry = 'Argentina'
GROUP BY ShipCountry;

-- 14
SELECT hwsuppliers.CompanyName AS CompanyName, hwproducts.ProductName
FROM hwsuppliers
INNER JOIN hwproducts
ON hwsuppliers.SupplierID = hwproducts.SupplierID
WHERE hwsuppliers.Country = 'Spain';

-- 15
SELECT avg(UnitPrice) AS AverageUnitPrice
FROM hwproducts
WHERE ProductName LIKE '%T';

-- 16
SELECT CONCAT(hwemployees.FirstName, ' ', hwemployees.LastName) AS FullName, hwemployees.Title, COUNT(hworders.EmployeeID) AS OrderCount
FROM hwemployees
LEFT JOIN hworders
ON hwemployees.EmployeeID = hworders.EmployeeID
GROUP BY hworders.EmployeeID
HAVING OrderCount > 120;

-- 17
SELECT CompanyName
FROM  hwcustomers
LEFT JOIN hworders
ON hwcustomers.CustomerID = hworders.CustomerID
WHERE hworders.CustomerID IS NULL;

-- 18
SELECT hwcategories.CategoryName, hwproducts.ProductName
FROM hwcategories
INNER JOIN hwproducts
ON hwcategories.CategoryID = hwproducts.CategoryID
WHERE hwproducts.UnitsInStock = 0;

-- 19
SELECT ProductName, QuantityPerUnit
FROM hwproducts
LEFT JOIN hwsuppliers
ON hwproducts.SupplierID = hwsuppliers.SupplierID
WHERE (hwproducts.QuantityPerUnit LIKE '%pkgs%'
OR hwproducts.QuantityPerUnit LIKE '%jars%')
AND hwsuppliers.Country = 'Japan';

-- 20
SELECT hwcustomers.CompanyName, hworders.ShipName, 
ROUND(SUM((hworderdetails.UnitPrice - hworderdetails.Discount) * hworderdetails.Quantity),2) AS OrderValue
FROM hwcustomers
INNER JOIN hworders
ON hwcustomers.CustomerID = hworders.CustomerID
INNER JOIN hworderdetails
ON hworders.OrderID = hworderdetails.OrderID
WHERE hwcustomers.Country = 'Mexico'
GROUP BY hwcustomers.CompanyName;

-- 21
SELECT hwproducts.ProductName, hwsuppliers.Region
FROM hwproducts
LEFT JOIN hwsuppliers
ON hwproducts.SupplierID = hwsuppliers.SupplierID
WHERE hwproducts.ProductName LIKE'L%'
AND hwsuppliers.Region != '';

-- 22
SELECT ShipCountry, ShipName, DATE_FORMAT(OrderDate, '%M %Y')
FROM hworders
LEFT JOIN hwcustomers
ON hworders.CustomerID = hwcustomers.CustomerID
WHERE ShipCity = 'Versailles'
AND hwcustomers.CustomerID IS NULL;

-- 23
SELECT ProductName, UnitsInStock, RANK() OVER(
	ORDER BY UnitsInStock DESC) AS 'Rank'
FROM hwproducts
WHERE ProductName LIKE 'F%'
ORDER BY UnitsInStock DESC;

-- 24
SELECT ProductName, UnitPrice, RANK() OVER(
	ORDER BY UnitPrice ASC) AS 'Rank'
FROM hwproducts
WHERE ProductID BETWEEN 1 AND 5
ORDER BY UnitPrice ASC;

-- 25
SELECT FirstName, LastName, Country, DATE_FORMAT(BirthDate, '%m/%d/%Y') AS BirthDate, RANK() OVER(
PARTITION BY Country
ORDER BY BirthDate ASC) AS 'Rank'
FROM hwemployees
ORDER BY Country;