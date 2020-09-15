/*    Auditorias Nativas
*/

USE [master]

GO

CREATE SERVER AUDIT [AuditoriaInstancia]
TO FILE 
(	FILEPATH = N'C:\Tmp'
	,MAXSIZE = 0 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
)

GO


USE [master]

GO

CREATE SERVER AUDIT [AuditoriasDB]
TO FILE 
(	FILEPATH = N'C:\Tmp'
	,MAXSIZE = 0 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
)

GO

ALTER SERVER AUDIT [AuditoriasDB] WITH (STATE=ON)
ALTER SERVER AUDIT [AuditoriaInstancia] WITH (STATE=ON)

USE [WideWorldImporters]

GO

CREATE DATABASE AUDIT SPECIFICATION [DbAudit]
FOR SERVER AUDIT [AuditoriasDB]
ADD (SELECT ON DATABASE::[WideWorldImporters] BY [public]),
ADD (UPDATE ON DATABASE::[WideWorldImporters] BY [public])
with (state=on)
GO

-- test

select * from sales.Customers 

ALTER DATABASE AUDIT SPECIFICATION [DbAudit]
WITH (STATE=OFF)

DROP  DATABASE AUDIT SPECIFICATION [DbAudit]

--- auditoria instancia

/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2017 (14.0.1000)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [master]

GO

CREATE SERVER AUDIT SPECIFICATION [AuditoInstancia]
FOR SERVER AUDIT [AuditoriaInstancia]
ADD (FAILED_LOGIN_GROUP)
WITH (STATE=ON)
GO

--- TEST DE LOGIN FAIL

ALTER SERVER AUDIT SPECIFICATION [AuditoInstancia]
WITH (STATE=OFF)

DROP SERVER AUDIT SPECIFICATION [AuditoInstancia]

--- LEER AUDITORIA DESDE TSQL

SELECT * FROM sys.fn_get_audit_file 
('C:\TMP\*.sqlaudit',default,default);  
GO

