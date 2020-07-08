/* Demos Auditorias Seguridad nativas MSSQL
   Autor: Maximiliano Accotto | owner Triggerdb SRL
          https://www.triggerdb.com 
*/

---------------------------------
------ CREACION DE LOGINS ------
---------------------------------

-- EMULAMOS UN LOGIN DE APLICACION
USE [master]
GO
CREATE LOGIN [DEMO_SEG_APP] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

USE [master]
GO
CREATE LOGIN [DEMO_SEG_APP2] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

-- UN SYSADMIN
USE [master]
GO
CREATE LOGIN [DEMO_SEG_ADM] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [DEMO_SEG_ADM]

-- UN LOGIN NO SYSADMIN Y NO DE APLICACION
USE [master]
GO
CREATE LOGIN [DEMO_SEG_USR] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

-- LE DAMOS PERMISO A LA BASE DE DATOS AdventureWorks2017 A LOS LOGINS

USE [AdventureWorks2017]
GO
CREATE USER [DEMO_SEG_APP] FOR LOGIN [DEMO_SEG_APP]
GO
USE [AdventureWorks2017]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEMO_SEG_APP]
GO

USE [AdventureWorks2017]
GO
CREATE USER [DEMO_SEG_USR] FOR LOGIN [DEMO_SEG_USR]
GO
USE [AdventureWorks2017]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEMO_SEG_USR]
GO

USE [AdventureWorks2017]
GO
CREATE USER [DEMO_SEG_APP2] FOR LOGIN [DEMO_SEG_APP2]
GO
USE [AdventureWorks2017]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEMO_SEG_APP2]
GO


--------------------------------------
------ CREACION DE SERVER AUDIT ------
--------------------------------------

-- Crearemos 2 Server Audits (uno para instancias y otro para DB)

USE [master]
GO

CREATE SERVER AUDIT [Audit-Instancia]
TO FILE 
(	FILEPATH = N'E:\tmp\Auditorias\Instancias'
	,MAXSIZE = 0 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
)
ALTER SERVER AUDIT [Audit-Instancia] 
WITH (STATE = ON)
GO

-- creamos un audit server excluyendo los logins de aplicacion

USE [master]
GO
CREATE SERVER AUDIT [Audit-Db]
TO FILE 
(	FILEPATH = N'E:\tmp\Auditorias\Databases'
	,MAXSIZE = 0 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
)
WHERE ([server_principal_name]<>'DEMO_SEG_APP' 
AND [server_principal_name]<>'DEMO_SEG_APP2'
AND [server_principal_name]<>'MACCOTTO'
  )
go

ALTER SERVER AUDIT [Audit-DB] 
WITH (STATE = ON)

----------------------------------------------------
------ CREACION DE SERVER AUDIT SPECIFICATION ------
----------------------------------------------------

USE [master]
GO

-- CREAMOS UN EJEMPLO PARA AUDITAR LEGIN FAILS Y CAMBIOS DE CLAVE

CREATE SERVER AUDIT SPECIFICATION [Demo_audit_server]
FOR SERVER AUDIT [Audit-Instancia]
ADD (FAILED_LOGIN_GROUP),
ADD (LOGIN_CHANGE_PASSWORD_GROUP)
GO

ALTER SERVER AUDIT SPECIFICATION [Demo_audit_server]
WITH (STATE = ON)

-- HACEMOS UN PAR DE LOGINS FALLIDOS

-- CAMBIAMOS UNA CLAVE DE UN LOGIN

USE [master]
GO
ALTER LOGIN [DEMO_SEG_ADM] WITH PASSWORD=N'12345678'
GO

-- REVISAMOS LOS LOGS DE AUDITORIA

DECLARE @PATH VARCHAR(1024)
SELECT @PATH = LOG_FILE_PATH + '*.*'
FROM sys.server_file_audits 
WHERE name = 'Audit-Instancia'

SELECT A.NAME,
       A.class_desc,
	   A.parent_class_desc,
	   A.covering_parent_action_name,
F.* 
FROM sys.fn_get_audit_file 
(@PATH,default,default) as F
left join sys.dm_audit_actions A
on F.action_id = A.action_id 
ORDER BY EVENT_TIME DESC;
GO


------------------------------------------------------
------ CREACION DE DATABASE AUDIT SPECIFICATION -------
-------------------------------------------------------

USE [AdventureWorks2017]
GO

CREATE DATABASE AUDIT SPECIFICATION [Db-Audit]
FOR SERVER AUDIT [Audit-Db]
ADD (SELECT ON DATABASE::[AdventureWorks2017] BY [public]),
ADD (UPDATE ON DATABASE::[AdventureWorks2017] BY [public]),
ADD (DATABASE_OBJECT_CHANGE_GROUP)
GO

ALTER DATABASE AUDIT SPECIFICATION [Db-Audit]
WITH (STATE = ON)

---- PROBAMOS DE HACER OPERACIONES CON EL USUARIO DE APP
USE AdventureWorks2017 
GO

EXECUTE AS LOGIN = 'DEMO_SEG_APP'

SELECT SUSER_NAME()

SELECT TOP (10) * FROM SALES.Customer

UPDATE SALES.Customer SET ModifiedDate = ModifiedDate 

REVERT

SELECT SUSER_NAME()

-- HACEMOS LA PRUEBA CON OTRO LOGIN NO EXCLUIDO
USE AdventureWorks2017 
GO

EXECUTE AS LOGIN = 'DEMO_SEG_USR'

--SELECT SUSER_NAME()

SELECT TOP (10) * FROM SALES.Customer

BEGIN TRAN
  UPDATE SALES.Customer SET ModifiedDate = '19000101' 
ROLLBACK TRAN 

REVERT

SELECT SUSER_NAME()

---- VEMOS LOS EVENTOS DE SEGURIDAD

DECLARE @PATH VARCHAR(1024)
SELECT @PATH = LOG_FILE_PATH + '*.*'
FROM sys.server_file_audits 
WHERE name = 'Audit-DB'

SELECT A.NAME,
       A.class_desc,
	   A.parent_class_desc,
	   A.covering_parent_action_name,
F.* 
FROM sys.fn_get_audit_file 
(@PATH,default,default) as F
left join sys.dm_audit_actions A
on F.action_id = A.action_id
WHERE server_principal_name = 'DEMO_SEG_APP'
AND class_desc = 'OBJECT'
ORDER BY EVENT_TIME DESC;

SELECT A.NAME,
       A.class_desc,
	   A.parent_class_desc,
	   A.covering_parent_action_name,
F.* 
FROM sys.fn_get_audit_file 
(@PATH,default,default) as F
left join sys.dm_audit_actions A
on F.action_id = A.action_id
WHERE server_principal_name = 'DEMO_SEG_USR'
AND class_desc = 'OBJECT'
ORDER BY EVENT_TIME DESC;


GO


------------------------------------------------------
------ SQL 2019 DATOS SENSIBLE       -----------------
-------------------------------------------------------
USE AdventureWorks2017 
GO

ADD SENSITIVITY CLASSIFICATION TO
[PRODUCTION].[PRODUCT].[LISTPRICE]
WITH (LABEL='CONFIDENTIAL', INFORMATION_TYPE='OTHER')
GO

-- Step 2: View all classifications
SELECT o.name as table_name, c.name as column_name, sc.information_type, sc.information_type_id, sc.label, sc.label_id
FROM sys.sensitivity_classifications sc
JOIN sys.objects o
ON o.object_id = sc.major_id
JOIN sys.columns c
ON c.column_id = sc.minor_id
AND c.object_id = sc.major_id
ORDER BY sc.information_type, sc.label
GO

--- PROBAMOS AUDITORIA

USE AdventureWorks2017 
GO

EXECUTE AS LOGIN = 'DEMO_SEG_USR'

--SELECT SUSER_NAME()

SELECT P.Class,P.Color FROM Production.Product P 

SELECT P.Class,P.ListPrice  FROM Production.Product P 



REVERT

SELECT SUSER_NAME()

---- VEMOS LOS EVENTOS DE SEGURIDAD

DECLARE @PATH VARCHAR(1024)
SELECT @PATH = LOG_FILE_PATH + '*.*'
FROM sys.server_file_audits 
WHERE name = 'Audit-DB'

SELECT A.NAME,
       A.class_desc,
	   A.parent_class_desc,
	   A.covering_parent_action_name,
F.* 
FROM sys.fn_get_audit_file 
(@PATH,default,default) as F
left join sys.dm_audit_actions A
on F.action_id = A.action_id
WHERE server_principal_name = 'DEMO_SEG_USR'
AND class_desc = 'OBJECT'
ORDER BY EVENT_TIME DESC;


GO

-----------------------------------
------ LIMPIAMOS  -----------------
-----------------------------------

USE AdventureWorks2017 
GO

DROP USER IF EXISTS DEMO_SEG_APP
DROP USER IF EXISTS DEMO_SEG_APP2
DROP USER IF EXISTS DEMO_SEG_USR 



DROP SENSITIVITY CLASSIFICATION FROM [PRODUCTION].[PRODUCT].[LISTPRICE]

IF EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = 'Db-Audit')
BEGIN
	ALTER DATABASE AUDIT SPECIFICATION [Db-Audit]
	WITH (STATE = OFF)
	DROP DATABASE AUDIT SPECIFICATION [Db-Audit]
END



USE master 
GO

DROP LOGIN DEMO_SEG_APP
DROP LOGIN DEMO_SEG_APP2
DROP LOGIN DEMO_SEG_USR 


USE master
GO
IF EXISTS (SELECT * FROM sys.server_audits WHERE name = 'Audit-db')
BEGIN
	ALTER SERVER AUDIT [audit-db]
	WITH (STATE = OFF)
	DROP SERVER AUDIT [audit-db]
END
GO

IF EXISTS (SELECT * FROM sys.server_audit_specifications WHERE name = 'Demo_audit_Server')
BEGIN
	ALTER SERVER AUDIT SPECIFICATION [Demo_audit_server]
	WITH (STATE = OFF)

	DROP SERVER AUDIT SPECIFICATION [Demo_audit_server]
END
GO

USE master
GO
IF EXISTS (SELECT * FROM sys.server_audits WHERE name = 'Audit-Instancia')
BEGIN
	ALTER SERVER AUDIT [audit-Instancia]
	WITH (STATE = OFF)
	DROP SERVER AUDIT [audit-Instancia]
END
GO
