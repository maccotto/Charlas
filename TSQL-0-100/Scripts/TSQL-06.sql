/*
 T-SQL 0 A 100
 Maximimiliano Damian Accotto
 https://blogs.triggerdb.com
 www.triggerdb.com

 Programacion TSQL y algunas funciones

*/

---------------------------------------------------------------------
-- Variables
---------------------------------------------------------------------

-- Declare a variable and initialize it with a value
DECLARE @i AS INT;
SET @i = 100;
GO

DECLARE @i AS INT = 100;


-- asignacion en consultas
DECLARE @lastname AS VARCHAR(250);

SET @lastname = (SELECT lastname 
                FROM [Person].[Person]
                WHERE BusinessEntityID = 1)
				
				

SELECT @lastname AS empname;
GO
------

DECLARE @firstname AS NVARCHAR(20), @lastname AS NVARCHAR(40);

SELECT
  @firstname = firstname,
  @lastname  = lastname
  FROM [Person].[Person]
                WHERE BusinessEntityID = 1;


select @firstname as firstname,@lastname as lastname 


---------------------------------------------------------------------
-- Flow Elements
---------------------------------------------------------------------

-- The IF ... ELSE Flow Element
IF YEAR(GETDATE()) = 2021 
  select 'Es 2021'
ELSE
  select 'No es 2021 '
GO

IF YEAR(GETDATE()) = 2021 
  select 'Es 2021'
ELSE if YEAR(GETDATE()) = 2020
  select 'No es 2020 '
ELSE
  select 'No es 2021 ni 2020 '
go

------------------------------------------------------
---  while
------------------------------------------------------

DECLARE @i AS INT;
SET @i = 1;
WHILE @i <= 10
BEGIN
  print @i;
  SET @i = @i + 1;
END;
GO

DECLARE @i AS INT;
SET @i = 1;
WHILE @i <= 10
BEGIN
  print @i;
  SET @i+= 1 ;
END;
GO

---- break

-- BREAK
DECLARE @i AS INT;
SET @i = 1
WHILE @i <= 10
BEGIN
  IF @i = 6 BREAK;
  PRINT @i;
  SET @i+= 1;
END;
GO

-- CONTINUE
DECLARE @i AS INT;
SET @i = 0
WHILE @i < 10
BEGIN
  SET @i+= 1;
  IF @i = 6 CONTINUE;
  PRINT @i;
END;
GO

------------------------------------------------------
--- Algunas  Funciones 
------------------------------------------------------

-- Fechas

SELECT GETDATE() AS FECHA,GETUTCDATE() AS FECHAUTC

SELECT  YEAR(GETDATE()) AS AÑO,
        MONTH(GETDATE()) AS MES,
		DAY(GETDATE()) AS DIA,
		DATEPART(DW,GETDATE()) AS DIA_SEMANA,
		DATEPART(WEEK,GETDATE()) AS NRO_SEMANA
		

SELECT DATEDIFF(DAY,'20210101',GETDATE()) AS DIAS,
       DATEDIFF(MONTH,'20210101',GETDATE()) AS MESES

SELECT DATEADD(DAY,1,GETDATE()) AS SUMAMOS_UN_DIA,
       DATEADD(MONTH,-1,GETDATE()) AS RESTAMOS_UN_MES 

SELECT EOMONTH(GETDATE()) ULTIMO_DIA_DEL_MES

-- Forma correcta de consultas un rango de fechas en SQL Server

SELECT SalesOrderID,OrderDate,SubTotal   
FROM Sales.SalesOrderHeader 
WHERE OrderDate >='20110101'
AND OrderDate < '20120101'


--- CAST Y CONVERT


SELECT CONVERT(VARCHAR(10),GETDATE()) AS FECHA
SELECT CONVERT(VARCHAR(10),GETDATE(),112) AS FECHA_CONFORMATO

SELECT CAST(GETDATE() AS varchar(10))

-- CONCATENAR VARIABLES O VALORES

DECLARE @INT INT = 1,
        @N VARCHAR(255) = 'TRIGGERDB.COM'

SELECT @INT + @N 

DECLARE @INT INT = 1,
        @N VARCHAR(255) = 'TRIGGERDB.COM'


SELECT CONVERT(VARCHAR(10),@INT) + @N

DECLARE @INT INT = 1,
        @N VARCHAR(255) = NULL


SELECT CONVERT(VARCHAR(10),@INT) + @N

DECLARE @INT INT = 1,
        @N VARCHAR(255) = NULL,
		@N2 DATETIME = GETDATE()

SELECT CONCAT(@INT,'-',@N,'-',@N2)

SELECT Title,FirstName,LastName,
       Title + '-' + FirstName + '-' + LastName,
	   ISNULL(Title,'') + '-' + ISNULL(FirstName,'') + '-' + ISNULL(LastName,''),
	   CONCAT(TITLE,'-',FirstName,'-',LastName)  

       FROM Person.Person 

-- Concat_ws
SELECT CONCAT_WS( ' - ', database_id, recovery_model_desc, containment_desc) AS DatabaseInfo
FROM sys.databases;

-- TRY_convert

SELECT   
    CASE WHEN TRY_CONVERT(float, 'test') IS NULL   
    THEN 'Cast failed'  
    ELSE 'Cast succeeded'  
END AS Result;  

-- choose

SELECT CHOOSE ( 3, 'Manager', 'Director', 'Developer', 'Tester' ) AS Result;

-- iif

DECLARE @a INT = 45, @b INT = 40;
SELECT [Result] = IIF( @a > @b, 'TRUE', 'FALSE' );

-- Left (String)

SELECT LEFT(Name, 5),name   
FROM Production.Product  
ORDER BY ProductID;  
GO  

-- right (String)

SELECT right(Name, 5),name   
FROM Production.Product  
ORDER BY ProductID;  

-- len (String)

SELECT len(name),name   
FROM Production.Product  
ORDER BY ProductID;  


-- replicate (String)

SELECT REPLICATE('h',10),name   
FROM Production.Product  
ORDER BY ProductID;  

-- CharIndex (String)

DECLARE @document VARCHAR(64);  
SELECT @document = 'Triggerdb Consulting SRL ' +  
                   ' www.triggerdb.com';  
SELECT CHARINDEX('Triggerdb', @document);  
GO


DECLARE @document VARCHAR(64);  
SELECT @document = 'Triggerdb Consulting SRL ' +  
                   ' www.triggerdb.com';  
SELECT CHARINDEX('triggerdb', @document,10);  
GO

--- SubString (string)

SELECT name, SUBSTRING(name, 1, 1) AS Initial ,
SUBSTRING(name, 3, 2) AS ThirdAndFourthCharacters
FROM sys.databases  
WHERE database_id < 5;
