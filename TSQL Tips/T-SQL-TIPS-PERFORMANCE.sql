/*
 Titulo: Tips TSQL Performance 
 Speaker: 
          Maximiliano Damian Accotto
		  Microsoft MVP Data Platform
		  Owner Triggerdb Consulting SRL
		  www.triggerdb.com
		  blogs.triggerdb.com
		  @maxiaccotto
*/

--------------------------------------------------------------
--              COSTO QUERY PLAN = CPU + I/O
--------------------------------------------------------------


---------------------------------------------------------------------
-----   Tipos de datos y performance
---------------------------------------------------------------------

USE MASTER 
GO

DROP DATABASE IF EXISTS DEMOTSQL

CREATE DATABASE DEMOTSQL
GO

USE DEMOTSQL
GO

DROP TABLE IF EXISTS DBO.T1
DROP TABLE IF EXISTS DBO.T2


CREATE TABLE DBO.T1 (ID INT IDENTITY PRIMARY KEY,
          			 C1 VARCHAR(255),
                     C2 VARCHAR(255),
   				     C3 VARCHAR(255),
				     C4 INT
				    	)

CREATE TABLE DBO.T2 ( ID INT IDENTITY PRIMARY KEY,
                  C1 NVARCHAR(255),
                  C2 NVARCHAR(255),
				  C3 NVARCHAR(255),
				  C4 BIGINT
				  )
GO

DECLARE @MAXVALUE INT 
SET @MAXVALUE = 1000000 --1 MILLION

INSERT INTO T1 WITH (TABLOCK) (C1, C2, C3,C4) 
SELECT TOP (@MAXVALUE)
'HOLA MUNDO 12345',
'HOLA MUNDO 234567890000000',
'HOLA MUNDO XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
 ROW_NUMBER() OVER (ORDER BY S1.NAME) AS C4
FROM MASTER.DBO.SYSCOLUMNS S1,
MASTER.DBO.SYSCOLUMNS  S2

INSERT INTO T2 WITH (TABLOCK) (C1, C2, C3,C4) 
SELECT TOP (@MAXVALUE)
'HOLA MUNDO 12345',
'HOLA MUNDO 234567890000000',
'HOLA MUNDO XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
 ROW_NUMBER() OVER (ORDER BY S1.NAME) AS C4
FROM MASTER.DBO.SYSCOLUMNS S1,
MASTER.DBO.SYSCOLUMNS  S2


CREATE INDEX NC_IX1_T1 ON DBO.T1(C4)
CREATE INDEX NC_IX1_T2 ON DBO.T2(C4)


EXEC SP_SPACEUSED 'T1'
EXEC SP_SPACEUSED 'T2'

SELECT TOP  10000 * FROM DBO.T1
SELECT TOP  10000 * FROM DBO.T2


/*
 RML : OSTRESS
 
 ostress -E -dDEMOTSQL  -Q"SELECT TOP 10000 * FROM DBO.T1" –n25 –r25 -q

 ostress -E -dDEMOTSQL  -Q"SELECT TOP 10000 * FROM DBO.T2" –n25 –r25 -q
*/

CREATE TABLE DBO.SUCURSALES (ID INT IDENTITY PRIMARY KEY,
                             NOMBRE VARCHAR(255)
						     )

CREATE TABLE DBO.PAISES (   ID INT IDENTITY PRIMARY KEY,
                            NOMBRE VARCHAR(255)
						  )

DROP TABLE IF EXISTS DBO.MOVIMIENTOS
CREATE TABLE DBO.MOVIMIENTOS (ID BIGINT IDENTITY PRIMARY KEY,
                              FECHA DATETIME,
							  SUCURSAL_ID INT NOT NULL,
							  PAIS_ID INT NOT NULL,
							  C1 CHAR(30),
							  C2 CHAR(30)
							  )

--------------------------------------------------------------------
--- FUNCIONES EN PREDICADO
--------------------------------------------------------------------

USE AdventureWorks2017 
GO

DROP INDEX IX_SALESORDER ON SALES.SALESORDERHEADER

CREATE NONCLUSTERED INDEX IX_SALESORDER ON SALES.SALESORDERHEADER(ORDERDATE) 

SELECT SalesOrderID,OrderDate   FROM
SALES.SalesOrderHeader 
WHERE YEAR(ORDERDATE) = 2013 AND MONTH(ORDERDATE) = 8

SELECT SalesOrderID,OrderDate FROM 
SALES.SalesOrderHeader 
WHERE ORDERDATE >= '20130801' AND ORDERDATE < '20130901'

/* ostress -E -dAdventureworks2017  -Q"SELECT SalesOrderID,OrderDate FROM   SALES.SalesOrderHeader WHERE YEAR(ORDERDATE) = 2013 AND MONTH(ORDERDATE) = 8" –n50 –r50 -q

 ostress -E -dAdventureworks2017  -Q"SELECT SalesOrderID,OrderDate FROM SALES.SalesOrderHeader WHERE ORDERDATE >= '20130801' AND ORDERDATE < '20130901'" –n50 –r50 -q 

*/


--------------------------------------------------------------------
--- OPTIMIZAR LOGICA OR
--------------------------------------------------------------------

DROP INDEX  [IX_OR]
ON [Sales].[SalesOrderDetail]

DROP INDEX [IX_OR2]
ON [Sales].[SalesOrderDetail]


CREATE NONCLUSTERED INDEX [IX_OR]
ON [Sales].[SalesOrderDetail] ([UnitPrice])
INCLUDE ([CarrierTrackingNumber],[ProductID])

CREATE NONCLUSTERED INDEX [IX_OR2]
ON [Sales].[SalesOrderDetail] ([productid])
INCLUDE ([CarrierTrackingNumber],[unitprice])


SELECT SalesOrderID,
       ProductID, 
       UnitPrice, 
       CarrierTrackingNumber
FROM Sales.SalesOrderDetail 
WHERE ProductID = 709   
OR UnitPrice =  5.7

-- union

SELECT SalesOrderID,
       ProductID, 
       UnitPrice, 
       CarrierTrackingNumber
FROM Sales.SalesOrderDetail 
WHERE ProductID = 709   
UNION
SELECT SalesOrderID,
       ProductID, 
       UnitPrice, 
       CarrierTrackingNumber
FROM Sales.SalesOrderDetail 
WHERE  UnitPrice =  5.7


drop index [IX_OR2]
ON [Sales].[SalesOrderDetail]

drop index [IX_OR]
ON [Sales].[SalesOrderDetail]

----------------------------------------------------------
---- ORDER BY SIN TOP
----------------------------------------------------------

USE AdventureWorks2017 
GO

SELECT SalesOrderID,OrderDate   FROM
SALES.SalesOrderHeader H
WHERE ORDERDATE >= '20130801' AND ORDERDATE < '20130901'
ORDER BY H.CustomerID 

SELECT SalesOrderID,OrderDate   FROM
SALES.SalesOrderHeader H
WHERE ORDERDATE >= '20130801' AND ORDERDATE < '20130901'

SELECT SalesOrderID,OrderDate   FROM
SALES.SalesOrderHeader H
WHERE ORDERDATE >= '20130801' AND ORDERDATE < '20130901'
ORDER BY H.OrderDate 

/*
CREATE NONCLUSTERED INDEX IX_22
ON [Sales].[SalesOrderHeader] ([OrderDate])
INCLUDE ([CustomerID]) 

*/


----------------------------------------------------------------
----- CONVERT_IMPLICIT
-----------------------------------------------------------------
USE AdventureWorks2017 
GO

SELECT NationalIDNumber, LoginID
FROM HumanResources.Employee
WHERE NationalIDNumber = 112457891


SELECT NationalIDNumber, LoginID
FROM HumanResources.Employee
WHERE NationalIDNumber = '112457891'

CREATE OR ALTER PROCEDURE DBO.USP_TEST_CONVERT @P1 INT
AS
 SELECT NationalIDNumber, LoginID
 FROM HumanResources.Employee
 WHERE NationalIDNumber = @P1 
GO

EXEC USP_TEST_CONVERT 112457891



--------------------------------------------------------------
--- --Joins without JOIN
--------------------------------------------------------------

SELECT * 
FROM Production.ProductSubcategory AS s 
WHERE NOT EXISTS 
    (SELECT * FROM Production.Product AS p 
     WHERE p.ProductSubcategoryID = s.ProductSubcategoryID);

SELECT * 
FROM Production.ProductSubcategory AS s 
LEFT OUTER JOIN Production.Product AS p 
ON p.ProductSubcategoryID = s.ProductSubcategoryID 
WHERE p.ProductID IS NULL;

---------------------------------------------------------------
--- PARAMETER SNIFFING
----------------------------------------------------------------
USE AdventureWorks2017 
GO

SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 897;

SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 870;

CREATE OR ALTER PROCEDURE DBO.Get_OrderID_OrderQty
@ProductID INT
AS
SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = @ProductID;
GO

EXEC Get_OrderID_OrderQty @ProductID=870

EXEC Get_OrderID_OrderQty @ProductID=897

SP_RECOMPILE Get_OrderID_OrderQty

EXEC Get_OrderID_OrderQty @ProductID=897

CREATE OR ALTER PROCEDURE DBO.Get_OrderID_OrderQty
@ProductID INT
AS
SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = @ProductID
OPTION(RECOMPILE)
GO

EXEC Get_OrderID_OrderQty @ProductID=870

EXEC Get_OrderID_OrderQty @ProductID=897



-----------------------------------------------------
------- DELETE / UPDATE MASIVOS
-----------------------------------------------------

/* ¿QUIEN NO VIO UN CODIGO ASI ALGUNA VEZ?

   DELETE DBO.VENTAS 
   WHERE ORDERDATE < '20130101'

*/


DROP TABLE IF EXISTS DBO.VENTAS

SELECT TOP 1000000  
H.AccountNumber,
h.BillToAddressID,
h.CustomerID,
h.OrderDate,
h.SalesOrderNumber,
h.TotalDue       
INTO DBO.VENTAS FROM Sales.SalesOrderHeader  H
CROSS JOIN sys.columns C

CREATE CLUSTERED INDEX CI_VENTAS ON VENTAS(ORDERDATE)


SELECT COUNT(1)
FROM VENTAS 
WHERE ORDERDATE < '20130101'

-- NO SE DEBE HACER :-( 

BEGIN TRAN
 DELETE FROM DBO.VENTAS 
 WHERE ORDERDATE < '20130101'

  -- LOCK SCALE OUT
   SELECT *
   FROM sys.dm_tran_locks
   WHERE request_session_id = @@SPID
   AND resource_type <> 'DATABASE';

ROLLBACK TRAN

-- ASI ME GUSTA MAS :-)

DBCC TRACEON (1224) -- NO ESCALAN LOS LOKEOS PARA ESTA SESION


WHILE 1 = 1
BEGIN
  DELETE TOP (50000) FROM DBO.VENTAS 
  WHERE orderdate < '20130101';

  IF @@ROWCOUNT = 0 BREAK;
END;

------------------------------------------
--- USANDO CTE ---------------------------
------------------------------------------
USE AdventureWorks2017 
GO

SELECT WO.WorkOrderID, WO.ProductID, WO.OrderQty, WO.StockedQty,        
       WO.ScrappedQty, WO.StartDate, WO.EndDate, WO.DueDate,        
	   WO.ScrapReasonID, WO.ModifiedDate, WOR.WorkOrderID,        
	   WOR.ProductID, WOR.LocationID 
FROM Production.WorkOrder 
     AS WO LEFT JOIN 
	 Production.WorkOrderRouting AS WOR        
ON 
WO.WorkOrderID = WOR.WorkOrderID 
AND WOR.WorkOrderID = 12345; 

;WITH cte AS ( 
              SELECT WorkOrderID, ProductID, LocationID    
              FROM Production.WorkOrderRouting 
			  WHERE WorkOrderID = 12345 ) 
SELECT WO.WorkOrderID, 
       WO.ProductID, 
	   WO.OrderQty, 
	   WO.StockedQty,        
	   WO.ScrappedQty, 
	   WO.StartDate, 
	   WO.EndDate, 
	   WO.DueDate,        
	   WO.ScrapReasonID, 
	   WO.ModifiedDate, 
	   WOR.WorkOrderID, 
       WOR.ProductID, 
	   WOR.LocationID 
FROM Production.WorkOrder AS WO 
LEFT JOIN cte AS WOR 
ON WO.WorkOrderID = WOR.WorkOrderID;

-----------------------------------------------------
---- vistas
-----------------------------------------------------

USE AdventureWorks2017
GO

CREATE or alter VIEW DBO.ORDENES
AS

SELECT        Sales.SalesOrderDetail.SalesOrderID, Sales.SalesOrderDetail.SalesOrderDetailID, Sales.SalesOrderDetail.OrderQty, Sales.SalesOrderDetail.ProductID, Sales.SalesOrderDetail.UnitPrice, 
                         Sales.Customer.AccountNumber, 
						 Sales.SalesOrderDetail.LineTotal,
						 Sales.SalesOrderHeader.TotalDue 
FROM            Sales.Customer INNER JOIN
                         Sales.SalesOrderHeader 
						 ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID INNER JOIN
                         Sales.SalesOrderDetail 
						 ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID 
                         
GO

SELECT SalesOrderID ,AccountNumber,TotalDue 
   FROM dbo.ORDENES 
WHERE TotalDue > 100

SELECT DISTINCT SalesOrderID ,AccountNumber,TotalDue 
   FROM dbo.ORDENES 
WHERE TotalDue > 100



SELECT S.SalesOrderID,AccountNumber,TotalDue  from Sales.SalesOrderHeader  S
WHERE TotalDue > 100




