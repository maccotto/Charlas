/*
 T-SQL 0 A 100
 Maximimiliano Damian Accotto
 https://blogs.triggerdb.com
 www.triggerdb.com

 Single Query 

*/

USE AdventureWorks2019 
GO

----------------------------------------------
--- Clausula FROM
-----------------------------------------------

-- todos los campos

SELECT * 
FROM Person.Person 

-- seleccionar campos

SELECT FirstName,LastName  
FROM Person.Person 

-- usar alias

SELECT p.FirstName as Nombre,
       p.LastName as Apellido  
FROM Person.Person  as p

---------------------------------------------------------------------
-- The WHERE Clause y operadores
---------------------------------------------------------------------

SELECT * FROM 
[HumanResources].[Employee]
WHERE NationalIDNumber = 295847284

SELECT * FROM 
[HumanResources].[Employee]
WHERE MaritalStatus  = 'S' 
AND Gender = 'M'

SELECT * FROM 
[HumanResources].[Employee]
WHERE MaritalStatus  = 'S' 
OR Gender = 'M'

SELECT * FROM 
[HumanResources].[Employee]
WHERE (MaritalStatus  = 'S' 
AND Gender = 'M') 
OR OrganizationLevel = 1

SELECT * FROM 
[HumanResources].[Employee]
WHERE VacationHours > 95

SELECT * FROM 
[HumanResources].[Employee]
WHERE VacationHours <= 90

SELECT * FROM 
[HumanResources].[Employee]
WHERE VacationHours >= 60 
AND VacationHours <= 70

SELECT * FROM 
[HumanResources].[Employee]
WHERE VacationHours between 60 and 70 


SELECT * FROM 
[HumanResources].[Employee]
WHERE NationalIDNumber IN (295847284,245797967)

SELECT * FROM 
[HumanResources].[Employee]
WHERE NationalIDNumber = 295847284
OR    NationalIDNumber = 245797967

SELECT * FROM 
[HumanResources].[Employee]
WHERE NationalIDNumber NOT IN (295847284,245797967)

SELECT * FROM 
[HumanResources].[Employee]
WHERE NationalIDNumber <> 295847284
AND   NationalIDNumber <> 245797967

SELECT * FROM 
[HumanResources].[Employee]
WHERE BirthDate >= '1990-01-01'


SELECT * FROM 
[HumanResources].[Employee]
WHERE JobTitle LIKE  'S%'

SELECT * FROM 
[HumanResources].[Employee]
WHERE JobTitle LIKE  '%S'

SELECT * FROM 
[HumanResources].[Employee]
WHERE JobTitle LIKE  '%Designer%'

-- Second character in last name is e
SELECT FirstName, LastName 
FROM Person.Person
WHERE lastname LIKE N'_e%';

-- First character in last name is A, B or C
SELECT FirstName,LastName 
FROM Person.Person
WHERE lastname LIKE N'[ABC]%';

-- First character in last name is A through E
SELECT FirstName,LastName 
FROM Person.Person
WHERE lastname LIKE N'[A-E]%';

-- First character in last name is not A through E
SELECT FirstName,LastName 
FROM Person.Person
WHERE lastname LIKE N'[^A-E]%';


---------------------------------------------------------------------
-- ORDER BY
---------------------------------------------------------------------

SELECT FirstName,LastName 
FROM Person.Person
ORDER BY LastName 

SELECT FirstName,LastName 
FROM Person.Person
ORDER BY LastName asc

SELECT FirstName,LastName 
FROM Person.Person
ORDER BY LastName desc

SELECT NationalIDNumber,VacationHours,BirthDate    
FROM 
[HumanResources].[Employee]
Order by VacationHours desc,BirthDate asc

---------------------------------------------------------------------
-- TOP
---------------------------------------------------------------------

SELECT TOP (10) NationalIDNumber,VacationHours,BirthDate    
FROM 
[HumanResources].[Employee]
Order by VacationHours desc

SELECT TOP 10 PERCENT NationalIDNumber,VacationHours,BirthDate    
FROM 
[HumanResources].[Employee]
Order by VacationHours desc

SELECT TOP (10) WITH TIES NationalIDNumber,VacationHours,BirthDate    
FROM 
[HumanResources].[Employee]
Order by VacationHours desc

---------------------------------------------------------------------
-- GROUP BY Y FUNCIONES DE AGREGACION 
---------------------------------------------------------------------

-- SUM, MIN, MAX, AVG,COUNT
SELECT YEAR(BirthDate) AS AÑO_NACIMIENTO
FROM
[HumanResources].[Employee]
ORDER BY 1

SELECT YEAR(BirthDate) AS AÑO_NACIMIENTO
FROM
[HumanResources].[Employee]
GROUP BY YEAR(BirthDate)
ORDER BY 1

SELECT YEAR(BirthDate) AS AÑO_NACIMIENTO
FROM
[HumanResources].[Employee]
GROUP BY YEAR(BirthDate)
ORDER BY 1

SELECT COUNT(1) AS CANTIDAD 
FROM
[HumanResources].[Employee]

SELECT 
YEAR(BirthDate) AS AÑO_NACIMIENTO,
COUNT(1) AS CANTIDAD 
FROM
[HumanResources].[Employee]

SELECT 
YEAR(BirthDate) AS AÑO_NACIMIENTO,
COUNT(1) AS CANTIDAD 
FROM
[HumanResources].[Employee]
GROUP BY YEAR(BirthDate)


SELECT 
YEAR(BirthDate) AS AÑO_NACIMIENTO,
COUNT(1) AS CANTIDAD,
MAX(VacationHours) AS Maximo_hs_vacaciones,
MIN(VacationHours) AS Minimo_hs_vacaciones,
AVG(VacationHours) AS Promedio_hs_vacaciones,
SUM(VacationHours) AS Total_hs_vacaciones
FROM
[HumanResources].[Employee]
GROUP BY YEAR(BirthDate)
ORDER BY 
SUM(VacationHours) DESC

SELECT 
YEAR(BirthDate) AS AÑO_NACIMIENTO,
COUNT(1) AS CANTIDAD,
MAX(VacationHours) AS Maximo_hs_vacaciones,
MIN(VacationHours) AS Minimo_hs_vacaciones,
AVG(VacationHours) AS Promedio_hs_vacaciones,
SUM(VacationHours) AS Total_hs_vacaciones
FROM
[HumanResources].[Employee]
WHERE MaritalStatus = 'S'
GROUP BY YEAR(BirthDate)
ORDER BY 
SUM(VacationHours) DESC

---------------------------------------------------------------------
-- HAVING
---------------------------------------------------------------------

SELECT 
YEAR(BirthDate) AS AÑO_NACIMIENTO,
COUNT(1) AS CANTIDAD,
MAX(VacationHours) AS Maximo_hs_vacaciones,
MIN(VacationHours) AS Minimo_hs_vacaciones,
AVG(VacationHours) AS Promedio_hs_vacaciones,
SUM(VacationHours) AS Total_hs_vacaciones
FROM
[HumanResources].[Employee]
WHERE MaritalStatus = 'S'
GROUP BY YEAR(BirthDate)
HAVING AVG(VacationHours)  > 60
ORDER BY 
SUM(VacationHours) DESC

SELECT 
YEAR(BirthDate) AS AÑO_NACIMIENTO,
COUNT(1) AS CANTIDAD,
MAX(VacationHours) AS Maximo_hs_vacaciones,
MIN(VacationHours) AS Minimo_hs_vacaciones,
AVG(VacationHours) AS Promedio_hs_vacaciones,
SUM(VacationHours) AS Total_hs_vacaciones
FROM
[HumanResources].[Employee]
WHERE MaritalStatus = 'S'
GROUP BY YEAR(BirthDate)
HAVING AVG(VacationHours)  > 60
AND AVG(VacationHours)  < 70
ORDER BY 
SUM(VacationHours) DESC


---------------------------------------------------------------------
-- CASE
---------------------------------------------------------------------

SELECT NationalIDNumber,JobTitle,
       CASE WHEN Gender = 'M' THEN 'Hombres'
	        WHEN Gender = 'F' THEN 'Mujeres'
	        ELSE 'N/A' 
	   END AS SEXO
			
FROM 
[HumanResources].[Employee]

SELECT TOP 10 
       NationalIDNumber,JobTitle,
       CASE WHEN Gender = 'M' THEN 'Hombres'
	        WHEN Gender = 'F' THEN 'Mujeres'
	        ELSE 'N/A' 
	   END AS SEXO
			
FROM 
[HumanResources].[Employee]
WHERE MaritalStatus = 'S'
ORDER BY NationalIDNumber


---------------------------------------------------------------------
-- NULLS
---------------------------------------------------------------------

SELECT *
FROM Person.Person 

SELECT * 
FROM Person.Person 
WHERE Title not in ('Ms.','Mr.')

SELECT * 
FROM Person.Person 
WHERE Title not in ('Ms.','Mr.')
OR Title IS NULL 

SELECT * 
FROM Person.Person 
WHERE Title IS NOT NULL 

SELECT * 
FROM Person.Person 
WHERE Title IS NULL 
