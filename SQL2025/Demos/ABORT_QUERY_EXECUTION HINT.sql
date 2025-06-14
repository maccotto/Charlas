/*
SQL 2025 :  ABORT_QUERY_EXECUTION 

*/

USE [master]
GO
ALTER DATABASE [AdventureWorks2022] SET QUERY_STORE = ON
GO
ALTER DATABASE [AdventureWorks2022] SET QUERY_STORE (OPERATION_MODE = READ_WRITE)
GO

--- Query molesta 

use AdventureWorks2022 
go

select * from sales.SalesOrderHeader h
inner join 
sales.SalesOrderDetail d
on
d.SalesOrderID = h.SalesOrderID 

-- No te dejamos correr :-)

EXEC sys.sp_query_store_set_hints
     @query_id = 23,
     @query_hints = N'OPTION (USE HINT (''ABORT_QUERY_EXECUTION''))';

-- volvemos a probar

select * from sales.SalesOrderHeader h
inner join 
sales.SalesOrderDetail d
on
d.SalesOrderID = h.SalesOrderID 

-- Vemos que querys tienen hints

SELECT query_hint_id,
    query_id,
    query_hint_text,
    last_query_hint_failure_reason,
    last_query_hint_failure_reason_desc,
    query_hint_failure_count,
    source,
    source_desc
FROM sys.query_store_query_hints

-- te liberamos de nuevo
EXEC sys.sp_query_store_clear_hints @query_id = 23;

-- volvemos a probar

select * from sales.SalesOrderHeader h
inner join 
sales.SalesOrderDetail d
on
d.SalesOrderID = h.SalesOrderID 