/*
 T-SQL 0 A 100
 Maximimiliano Damian Accotto
 https://blogs.triggerdb.com
 www.triggerdb.com

 Table Expression

*/

USE AdventureWorks2019 
GO

---------------------------------------------------------------------
-- Derived Tables
---------------------------------------------------------------------

SELECT * FROM 
( SELECT * FROM Sales.SalesOrderHeader 
  WHERE CustomerID=29825
 ) AS VENTAS


SELECT * FROM 
( SELECT * FROM Sales.SalesOrderHeader 
  WHERE CustomerID=29825
 ) AS VENTAS
WHERE SubTotal > 30000

-- Multiple Referencias

SELECT * FROM 

    ( SELECT COUNT(1) AS CANTIDAD,
	         YEAR(ORDERDATE) AS AÑO
       FROM  Sales.SalesOrderHeader 
       GROUP BY YEAR(OrderDate)
    ) AS V1
LEFT JOIN V1 AS V2
ON
V1.AÑO = V2.AÑO + 1

SELECT V1.AÑO,
       V1.CANTIDAD,
	   ISNULL(V2.CANTIDAD,0)  AS CANTIDAD_AÑO_ANTERIOR
	   FROM 

    ( SELECT COUNT(1) AS CANTIDAD,
	         YEAR(ORDERDATE) AS AÑO
       FROM  Sales.SalesOrderHeader 
       GROUP BY YEAR(OrderDate)
    ) AS V1
LEFT JOIN 
    (
	 SELECT COUNT(1) AS CANTIDAD,
	         YEAR(ORDERDATE) AS AÑO
       FROM  Sales.SalesOrderHeader 
       GROUP BY YEAR(OrderDate)
	) AS V2
ON
V1.AÑO = V2.AÑO + 1
ORDER BY V1.AÑO 

---------------------------------------------------------------------
-- Common Table Expressions
---------------------------------------------------------------------

WITH DATOS AS
(
  SELECT COUNT(1) AS CANTIDAD,
	         YEAR(ORDERDATE) AS AÑO
       FROM  Sales.SalesOrderHeader 
       GROUP BY YEAR(OrderDate)
     
)
SELECT * FROM DATOS ;

-- Multiple referencias 

WITH DATOS AS
(
  SELECT COUNT(1) AS CANTIDAD,
	         YEAR(ORDERDATE) AS AÑO
       FROM  Sales.SalesOrderHeader 
       GROUP BY YEAR(OrderDate)
     
)
SELECT DATOS.AÑO,
       DATOS.CANTIDAD,
	   ISNULL(DATOS2.CANTIDAD,0) AS CANTIDAD_AÑO_ANTERIOR
	   
FROM DATOS 
LEFT JOIN DATOS AS DATOS2
ON 
DATOS.AÑO = DATOS2.AÑO + 1
ORDER BY DATOS.AÑO 

--- Multiples CTE

WITH C1 As
( SELECT YEAR(ORDERDATE) AS AÑO,CustomerID 
  FROM Sales.SalesOrderHeader 
),
C2 AS
(
 SELECT AÑO, COUNT(DISTINCT CustomerID) AS Cantidad_CLIENTES
 FROM C1 
 GROUP BY AÑO
)
SELECT * FROM 
C2 
WHERE Cantidad_CLIENTES > 2000

---------------------------------------------------------------------
-- Recursive CTEs
---------------------------------------------------------------------

IF OBJECT_ID('DBO.EMPLEADOS') IS NOT NULL
   DROP TABLE DBO.EMPLEADOS
GO

CREATE TABLE DBO.EMPLEADOS (ID INT NOT NULL,
                            JEFE_ID INT NULL,
                            NOMBRE VARCHAR(300),
							Puesto varchar(300))
GO

INSERT INTO DBO.EMPLEADOS VALUES (100,NULL,'Maximiliano','CEO')
INSERT INTO DBO.EMPLEADOS VALUES (101,100,'Gaston','Gerente Sistemas')
INSERT INTO DBO.EMPLEADOS VALUES (102,100,'Ignacio','Gerente Calidad')
INSERT INTO DBO.EMPLEADOS VALUES (103,101,'Javier','Analista SR')
INSERT INTO DBO.EMPLEADOS VALUES (104,101,'Gabriel','DBA')
INSERT INTO DBO.EMPLEADOS VALUES (105,102,'Ana','Auditora')
INSERT INTO DBO.EMPLEADOS VALUES (106,103,'Luis','Programador')
INSERT INTO DBO.EMPLEADOS VALUES (107,105,'Jose','Asistente')
GO

-- MOSTRAMOS EL ORGANIGRAMA HASTA EL NIVEL 2

WITH REPORTE(JEFE_ID, ID,NOMBRE,PUESTO,NIVEL) AS 
(
    SELECT JEFE_ID, ID,NOMBRE,PUESTO, 0 AS NIVEL
    FROM DBO.EMPLEADOS
    WHERE JEFE_ID IS NULL -- TRAEMOS TODOS LOS QUE NO TIENEN JEFES 
    UNION ALL
    SELECT e.JEFE_ID, e.ID, E.NOMBRE,E.PUESTO,NIVEL + 1
    FROM DBO.EMPLEADOS e
        INNER JOIN REPORTE d
        ON e.JEFE_ID = d.ID 
)
SELECT REPORTE.JEFE_ID, REPORTE.ID, REPORTE.NOMBRE,REPORTE.PUESTO,
EMPLEADOS.NOMBRE AS JEFE_NOMBRE, EMPLEADOS.PUESTO AS PUESTO_JEFE 
FROM REPORTE LEFT JOIN DBO.EMPLEADOS ON
REPORTE.JEFE_ID = EMPLEADOS.ID
WHERE NIVEL <= 2 

---------------------------------------------------------------------
-- APPLY
---------------------------------------------------------------------

SELECT C.CustomerID , C.AccountNumber, A.SalesOrderID 
FROM sales.Customer AS C 
  CROSS APPLY 
    (SELECT TOP (2) O.SalesOrderID, O.CustomerID 
     FROM sales.SalesOrderHeader  AS O 
     WHERE O.CustomerID  = C.customerid
     ORDER BY OrderDate DESC) AS A;

-- Traemos las dos ultimas ordenes por cliente y si no hay trae Null

SELECT C.CustomerID , C.AccountNumber, A.SalesOrderID 
FROM sales.Customer AS C 
  outer APPLY 
    (SELECT TOP (2) O.SalesOrderID, O.CustomerID 
     FROM sales.SalesOrderHeader  AS O 
     WHERE O.CustomerID  = C.customerid
     ORDER BY OrderDate DESC) AS A;
