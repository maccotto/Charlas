--- logins SQL y control de claves

USE [master]
GO
CREATE LOGIN [sql1] WITH PASSWORD=N'123' MUST_CHANGE, 
DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO

USE [master]
GO
CREATE LOGIN [sql1] WITH PASSWORD=N'Pa$$w0rd' , 
DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO

--- Rename y disable SA

USE [master]
GO
DENY CONNECT SQL TO [sa]
GO
ALTER LOGIN [sa] DISABLE
GO

---- Custom Server Roles

USE [master]
GO

DROP SERVER ROLE [DBAJR]

CREATE SERVER ROLE [DBAJR]
GO

use [master]
GO

GRANT ALTER TRACE TO [DBAJR]
GO

use [master]
GO

GRANT VIEW SERVER STATE TO [DBAJR]
GO

USE [master]
GO
CREATE LOGIN [DBA1] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
ALTER SERVER ROLE [DBAJR] ADD MEMBER [DBA1]
GO

-- execute as para probar seguridad

EXECUTE AS LOGIN = 'DBA1'

SELECT SUSER_NAME()

CREATE DATABASE TEST

SELECT * FROM SYS.dm_os_wait_stats ORDER BY 3 DESC

REVERT 

---------------------------------
--- permisos nuevos

USE [master]
GO

CREATE SERVER ROLE [Auditor]
GO
use [master]
GO
GRANT CONNECT ANY DATABASE TO [Auditor]
GO
use [master]
GO
GRANT VIEW ANY DATABASE TO [Auditor]
GO
use [master]
GO
GRANT SELECT ALL USER SECURABLES TO [Auditor]
GO

-- test de login


USE [master]
GO
CREATE LOGIN [auditor1] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
ALTER SERVER ROLE [Auditor] ADD MEMBER [auditor1]
GO

EXECUTE AS LOGIN = 'auditor1'
select suser_sname()

use WideWorldImporters 
go

select * from Sales.Customers 
use master
go
revert

---- limpiamos todo
USE [master]
GO

DROP LOGIN [auditor1]
GO

USE [master]
GO
DROP LOGIN [DBA1]
GO

USE [master]
GO


DROP SERVER ROLE [Auditor]
GO

DROP SERVER ROLE [DBAJR]