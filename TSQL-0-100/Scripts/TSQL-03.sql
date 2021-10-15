/*
 T-SQL 0 A 100
 Maximimiliano Damian Accotto
 https://blogs.triggerdb.com
 www.triggerdb.com

 Sub querys

*/

USE AdventureWorks2019 
GO

---------------------------------------------------------------------
-- Scalar Subqueries
---------------------------------------------------------------------

DECLARE @maxid AS INT = (SELECT MAX(SalesOrderID)
                         FROM Sales.SalesOrderHeader );

SELECT SalesOrderID, orderdate, CustomerID 
FROM Sales.SalesOrderHeader 
WHERE SalesOrderID  = @maxid;
GO

SELECT SalesOrderID, orderdate, CustomerID 
FROM Sales.SalesOrderHeader 
WHERE SalesOrderID  = 
                      (SELECT MAX(SalesOrderID)
                       FROM Sales.SalesOrderHeader);

-- Se espera un solo valor
SELECT SalesOrderID, orderdate, CustomerID 
FROM Sales.SalesOrderHeader 
WHERE SalesOrderID  = 
                      (SELECT top 5 SalesOrderID
                       FROM Sales.SalesOrderHeader);

---------------------------------------------------------------------
-- Multi-Valued Subqueries
---------------------------------------------------------------------

-- select * from sales.salesorderheader
select * from Sales.SalesPerson s
inner join [Person].[Person] p
on 
s.BusinessEntityID = p.BusinessEntityID 

SELECT SalesOrderID, orderdate, CustomerID 
FROM Sales.SalesOrderHeader 
WHERE TerritoryID    in 
                      (select  territoryID from 
					   [Sales].[SalesTerritory]
					   where Name like 'S%'
)

-- Clientes que no tienen ventas

select * from Sales.Customer
where CustomerID not in
  (select CustomerID From Sales.SalesOrderHeader) 

---------------------------------------------------------------------
-- Correlated Subqueries
---------------------------------------------------------------------


-- Ultima Orden por cada cliente
SELECT h.* FROM
Sales.SalesOrderHeader AS h
WHERE SalesOrderID =
                    ( SELECT MAX(H2.SALESORDERID)
					  FROM Sales.SalesOrderHeader AS H2
					  WHERE h.CustomerID = H2.CustomerID )


-- Porcentaje del Total

select SalesOrderID,OrderDate,SubTotal,
       customerid ,
cast(100.00 * SubTotal / 
      (select SUM(subtotal) 
	  FROM Sales.SalesOrderHeader h2
	  where h.customerid = h2.customerid )
	  as decimal(18,2)) as Pct
from 
Sales.SalesOrderHeader h
order by h.CustomerID 

---------------------------------------------------------------------
-- EXISTS
---------------------------------------------------------------------

select * from Sales.SalesOrderDetail 
select * from Production.Product 

-- Productos de color Silver con que se han vendido

SELECT  P.ProductID, 
        P.Name  , 
		P.ProductNumber, 
		P.Color  
FROM  Production.Product  P
WHERE color = N'Silver'
  AND EXISTS
    (SELECT * FROM Sales.SalesOrderDetail AS d
     WHERE d.ProductID  = p.ProductID);

-- Productos de color Silver que no se vendieron
SELECT  P.ProductID, 
        P.Name  , 
		P.ProductNumber, 
		P.Color  
FROM  Production.Product  P
WHERE color = N'Silver'
  AND NOT EXISTS
    (SELECT * FROM Sales.SalesOrderDetail AS d
     WHERE d.ProductID  = p.ProductID);