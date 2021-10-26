/*
 T-SQL 0 A 100
 Maximimiliano Damian Accotto
 https://blogs.triggerdb.com
 www.triggerdb.com

 Set Operation / funciones de Ranking / pivot & unpivot

*/

use AdventureWorks2019 
go

---------------------------------------------------------------------
-- UNION 
---------------------------------------------------------------------

DROP TABLE IF EXISTS  T1 
DROP TABLE IF EXISTS  T2

CREATE TABLE DBO.T1 (NRO INT)
CREATE TABLE DBO.T2 (NRO INT)

INSERT INTO dbo.T1 VALUES (1),(2),(3)
INSERT INTO dbo.T2 VALUES (1),(2),(3),(4)

SELECT NRO FROM T1
UNION 
SELECT NRO FROM T2

SELECT NRO FROM T1
UNION ALL
SELECT NRO FROM T2

---------------------------------------------------------------------
-- INTERSECT & EXCEPT
---------------------------------------------------------------------

SELECT NRO FROM T1
INTERSECT 
SELECT NRO FROM T2

SELECT NRO FROM T2
EXCEPT
SELECT NRO FROM T1

SELECT NRO FROM T1
EXCEPT
SELECT NRO FROM T2 

---------------------------------------------------------------------
-- Row Number
---------------------------------------------------------------------

SELECT customerid, subtotal,
  ROW_NUMBER() OVER(ORDER BY subtotal) AS rownum
FROM Sales.SalesOrderHeader 
ORDER BY SubTotal 

SELECT customerid, subtotal,
  ROW_NUMBER() OVER(ORDER BY subtotal) AS rownum,
  ROW_NUMBER() OVER(ORDER BY subtotal desc,orderdate) AS rownum2
FROM Sales.SalesOrderHeader 
ORDER BY SubTotal ;

---------------------------------------------------------------------
-- Partitioning
---------------------------------------------------------------------


SELECT SalesOrderID,customerid, subtotal,
  ROW_NUMBER() OVER(PARTITION BY CUSTOMERID ORDER BY subtotal) AS rownum
FROM Sales.SalesOrderHeader 
ORDER BY CustomerID,SubTotal ;

---------------------------------------------------------------------
-- RANK y DENSE_RANK 
---------------------------------------------------------------------

SELECT customerid, subtotal,
  rank() OVER(ORDER BY subtotal) AS rank1,
  dense_rank() OVER(ORDER BY subtotal) AS rank2
FROM Sales.SalesOrderHeader 
ORDER BY SubTotal ;

SELECT i.ProductID, p.Name, i.LocationID, i.Quantity  
    ,DENSE_RANK() OVER   
    (PARTITION BY i.LocationID ORDER BY i.Quantity DESC) AS Rank  
FROM Production.ProductInventory AS i   
INNER JOIN Production.Product AS p   
    ON i.ProductID = p.ProductID  
WHERE i.LocationID BETWEEN 3 AND 4  
ORDER BY i.LocationID;  

---------------------------------------------------------------------
-- NTILE Function
---------------------------------------------------------------------

SELECT customerid, subtotal,
  ntile(5) OVER(ORDER BY subtotal) AS rank1

FROM Sales.SalesOrderHeader 
ORDER BY SubTotal ;


---------------------------------------------------------------------
-- Pivot Function
---------------------------------------------------------------------

SELECT DaysToManufacture, AVG(StandardCost) AS AverageCost   
FROM Production.Product  
GROUP BY DaysToManufacture; 

SELECT 'AverageCost' AS Cost_Sorted_By_Production_Days,   
  [0], [1], [2], [3], [4]  
FROM  
(
  SELECT DaysToManufacture, StandardCost   
  FROM Production.Product
) AS SourceTable  
PIVOT  
(  
  AVG(StandardCost)  
  FOR DaysToManufacture IN ([0], [1], [2], [3], [4])  
) AS PivotTable;  


SELECT VendorID, [250] AS Emp1, [251] AS Emp2, [256] AS Emp3, [257] AS Emp4, [260] AS Emp5  
FROM   
(
 SELECT PurchaseOrderID, EmployeeID, VendorID  
 FROM Purchasing.PurchaseOrderHeader) p  
 PIVOT  
 (  
 COUNT (PurchaseOrderID)  
 FOR EmployeeID IN  
( [250], [251], [256], [257], [260] )  
) AS pvt  
ORDER BY pvt.VendorID;  


---------------------------------------------------------------------
-- UnPivot Function
---------------------------------------------------------------------
drop table if exists pvt

CREATE TABLE pvt (VendorID INT, Emp1 INT, Emp2 INT,  
    Emp3 INT, Emp4 INT, Emp5 INT);  
GO  

INSERT INTO pvt VALUES (1,4,3,5,4,4);  
INSERT INTO pvt VALUES (2,4,1,5,5,5);  
INSERT INTO pvt VALUES (3,4,3,5,4,4);  
INSERT INTO pvt VALUES (4,4,2,5,5,4);  
INSERT INTO pvt VALUES (5,5,1,5,5,5);  
GO  

select * from pvt

-- Unpivot the table.  
SELECT VendorID, Employee, Orders  
FROM   
   (SELECT VendorID, Emp1, Emp2, Emp3, Emp4, Emp5  
   FROM pvt) p  
UNPIVOT  
   (Orders FOR Employee IN   
      (Emp1, Emp2, Emp3, Emp4, Emp5)  
)AS unpvt;  
GO  

------------------------------------------------------------
---- TableSample
------------------------------------------------------------

SELECT *  
FROM Sales.Customer TABLESAMPLE SYSTEM (11 PERCENT) ;

-----------------------------------------------------------
---  Paginacion
------------------------------------------------------------

DECLARE    @PageSize    TINYINT = 5,    
           @CurrentPage INT     = 1;
		   
SELECT SalesOrderID /* , ... */    
FROM Sales.SalesOrderHeader    
ORDER BY SalesOrderID    
OFFSET (@PageSize * (@CurrentPage - 1)) 
ROWS    
FETCH NEXT @PageSize ROWS ONLY; --- PAGINACION NATIVA

-- Paginacion con CTE
DECLARE    @NumberOfRowsPerPage    TINYINT = 5,    
           @PageNumber INT     = 1;


 WITH OrderedRows AS
  ( SELECT ROW_NUMBER() OVER(ORDER BY ProductID) AS RowNumber,
           ProductID,
	       Name,
           Size,
           Color 
    FROM Production.Product 
  )
  SELECT ProductID, Name, Size, Color 
  FROM OrderedRows
  WHERE RowNumber BETWEEN (((@PageNumber - 1) * @NumberOfRowsPerPage) + 1)
                  AND (@PageNumber * @NumberOfRowsPerPage)
  ORDER BY ProductID;