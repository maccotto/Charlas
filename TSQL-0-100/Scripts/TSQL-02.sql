/*
 T-SQL 0 A 100
 Maximimiliano Damian Accotto
 https://blogs.triggerdb.com
 www.triggerdb.com

 JOINS 

*/

USE AdventureWorks2019 
GO

---------------------------------------------------------------------
-- INNER Joins
---------------------------------------------------------------------

-- ANSI SQL-92
SELECT C.AccountNumber,H.DueDate,H.OrderDate,H.SalesOrderID    
FROM 
SALES.Customer AS C
INNER JOIN SALES.SalesOrderHeader AS h
ON C.CustomerID = H.CustomerID 

-- ANSI SQL-89 (DEPRECADO)

SELECT C.AccountNumber,H.DueDate,H.OrderDate,H.SalesOrderID  
FROM 
SALES.Customer AS C
,SALES.SalesOrderHeader AS h
WHERE C.CustomerID = H.CustomerID 

---------------------------------------------------------------------
-- LEFT Joins
---------------------------------------------------------------------

-- ANSI SQL-92
SELECT C.AccountNumber,H.DueDate,H.OrderDate,H.SalesOrderID    
FROM 
SALES.Customer AS C
LEFT JOIN SALES.SalesOrderHeader AS h
ON C.CustomerID = H.CustomerID 

-- ANSI SQL-89 (DEPRECADO)

SELECT C.AccountNumber,H.DueDate,H.OrderDate,H.SalesOrderID  
FROM 
SALES.Customer AS C
,SALES.SalesOrderHeader AS h
WHERE C.CustomerID *= H.CustomerID 


-- Clientes que no tienen ordenes
SELECT C.AccountNumber,H.DueDate,H.OrderDate,H.SalesOrderID    
FROM 
SALES.Customer AS C
LEFT JOIN SALES.SalesOrderHeader AS h
ON C.CustomerID = H.CustomerID 
WHERE H.CustomerID IS NULL
ORDER BY C.AccountNumber 

---------------------------------------------------------------------
-- Right Joins
---------------------------------------------------------------------

SELECT C.AccountNumber,H.DueDate,H.OrderDate,H.SalesOrderID    
FROM 
SALES.Customer AS C
RIGHT JOIN SALES.SalesOrderHeader AS h
ON C.CustomerID = H.CustomerID 
ORDER BY C.AccountNumber 

---------------------------------------------------------------------
-- full Joins
---------------------------------------------------------------------

SELECT C.AccountNumber,H.DueDate,H.OrderDate,H.SalesOrderID    
FROM 
SALES.Customer AS C
FULL JOIN SALES.SalesOrderHeader AS h
ON C.CustomerID = H.CustomerID 
ORDER BY C.AccountNumber 

---------------------------------------------------------------------
-- CROSS Joins
---------------------------------------------------------------------

DROP TABLE IF EXISTS DBO.T1
DROP TABLE IF EXISTS DBO.T2

CREATE TABLE DBO.T1 (NRO INT)
CREATE TABLE DBO.T2 (NRO INT)

INSERT INTO DBO.T1 (NRO)
VALUES (1),(2),(3)

INSERT INTO DBO.T2 (NRO)
VALUES (1),(2),(3)

SELECT * FROM T1
CROSS JOIN T2

---------------------------------------------------------------------
-- Multiple JOINS
---------------------------------------------------------------------

SELECT C.AccountNumber,H.DueDate,H.OrderDate,H.SalesOrderID,D.OrderQty     
FROM 
SALES.Customer AS C
LEFT outer JOIN SALES.SalesOrderHeader AS h
ON (C.CustomerID = H.CustomerID )
INNER JOIN sales.SalesOrderDetail d
ON
(H.SalesOrderID = D.SalesOrderID )
ORDER BY C.AccountNumber 



SELECT C.AccountNumber,H.DueDate,H.OrderDate,H.SalesOrderID,D.OrderQty     
FROM 
SALES.SalesOrderHeader AS h
INNER JOIN sales.SalesOrderDetail d
ON
(H.SalesOrderID = D.SalesOrderID )
right join SALES.Customer AS C
ON (C.CustomerID = H.CustomerID )
ORDER BY C.AccountNumber 
