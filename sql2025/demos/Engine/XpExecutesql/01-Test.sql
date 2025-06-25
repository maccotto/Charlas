
-- Apagamos OPTIMIZED_SP_EXECUTESQL
USE AdventureWorks2022;
GO
ALTER DATABASE SCOPED CONFIGURATION
SET OPTIMIZED_SP_EXECUTESQL = OFF;
GO


-- Limpiamos la cache de la base
USE Adventureworks2022;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- Observamos las compilaciones
SELECT 
    cp.cacheobjtype,
    cp.objtype,
    cp.usecounts,
    st.text AS sql_text
FROM 
    sys.dm_exec_cached_plans AS cp
CROSS APPLY 
    sys.dm_exec_sql_text(cp.plan_handle) AS st
CROSS APPLY 
    sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE st.text LIKE '%BusinessEntityID%'
AND cp.objtype = 'Prepared';
GO

-- Hacemos la carga de stress 

-- Revisamos de nuevo los planes

SELECT 
    cp.cacheobjtype,
    cp.objtype,
    cp.usecounts,
    st.text AS sql_text
FROM 
    sys.dm_exec_cached_plans AS cp
CROSS APPLY 
    sys.dm_exec_sql_text(cp.plan_handle) AS st
CROSS APPLY 
    sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE st.text LIKE '%BusinessEntityID%'
AND cp.objtype = 'Prepared';
GO

-- Prendemos OPTIMIZED_SP_EXECUTESQL
USE AdventureWorks2022;
GO
ALTER DATABASE SCOPED CONFIGURATION
SET OPTIMIZED_SP_EXECUTESQL = ON;
GO

-- Limpiamos cache de la base 
-- Limpiamos la cache de la base
USE Adventureworks2022;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- Corremos de nuevo Stress

-- Revisamos planes

SELECT 
    cp.cacheobjtype,
    cp.objtype,
    cp.usecounts,
    st.text AS sql_text
FROM 
    sys.dm_exec_cached_plans AS cp
CROSS APPLY 
    sys.dm_exec_sql_text(cp.plan_handle) AS st
CROSS APPLY 
    sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE st.text LIKE '%BusinessEntityID%'
AND cp.objtype = 'Prepared';
GO