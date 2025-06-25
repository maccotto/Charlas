/*
SQL 2025 
Tempdb space resource
*/

-- Creamos un usuario para la demo

USE [master]
GO
CREATE LOGIN [app1] WITH PASSWORD=N'12345678', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [app1]
GO

-- Configuramos RG 

CREATE WORKLOAD GROUP limited_tempdb_space_group
WITH (GROUP_MAX_TEMPDB_DATA_MB = 1);

USE master;
GO

CREATE OR ALTER FUNCTION dbo.rg_classifier()
RETURNS sysname
WITH SCHEMABINDING
AS
BEGIN

DECLARE @WorkloadGroupName sysname = N'default';

IF SUSER_NAME() = N'app1'
    SELECT @WorkloadGroupName = N'limited_tempdb_space_group';

RETURN @WorkloadGroupName;

END;
GO

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.rg_classifier);
ALTER RESOURCE GOVERNOR RECONFIGURE;

-- Probamos

-- Nos conectamos n una nueva ventana con APP1


-- Test 1

SELECT REPLICATE('S', 100) AS c
INTO #t1;

SELECT REPLICATE(CAST('F' AS nvarchar(max)), 10000000) AS c
INTO #t33;

-- Apagamos RG

ALTER RESOURCE GOVERNOR DISABLE;
GO

