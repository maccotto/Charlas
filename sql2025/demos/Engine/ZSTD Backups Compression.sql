/*
SQL 2025 
ZSTD compression algorithm
*/

/*
BACKUP DATABASE successfully processed 1096538 pages in 47.780 seconds (179.294 MB/sec).

 SQL Server Execution Times:
   CPU time = 1094 ms,  elapsed time = 47889 ms.

*/

SET STATISTICS TIME ON
BACKUP DATABASE StackOverflow 
TO DISK = 'D:\TEMP\S1.bak' WITH INIT, FORMAT, COMPRESSION, STATS = 5;

-- New Compression

/*
BACKUP DATABASE successfully processed 1096538 pages in 29.780 seconds (287.666 MB/sec).

 SQL Server Execution Times:
   CPU time = 1235 ms,  elapsed time = 30029 ms.
*/

SET STATISTICS TIME ON
BACKUP DATABASE StackOverflow 
TO DISK = 'D:\TEMP\S2.bak' WITH INIT, FORMAT, 
COMPRESSION (ALGORITHM = ZSTD), STATS = 5

SET STATISTICS TIME ON
BACKUP DATABASE StackOverflow 
TO DISK = 'D:\TEMP\S2.bak' WITH INIT, FORMAT, 
COMPRESSION (ALGORITHM = ZSTD, LEVEL=MEDIUM), STATS = 5

SET STATISTICS TIME ON
BACKUP DATABASE StackOverflow 
TO DISK = 'D:\TEMP\S2.bak' WITH INIT, FORMAT, 
COMPRESSION (ALGORITHM = ZSTD, LEVEL=HIGH), STATS = 5

SELECT TOP 10
    b.database_name AS BaseDeDatos,                    
    b.backup_start_date AS FechaBackup,                   
    DATEDIFF(SECOND, b.backup_start_date, b.backup_finish_date) AS DuracionSegundos,  
    b.backup_size / 1024 / 1024 AS TamanoMB,               
    b.compressed_backup_size / 1024 / 1024 AS TamanoComprimidoMB,
    CAST(1.0 * b.backup_size / NULLIF(b.compressed_backup_size, 0) AS DECIMAL(5,2)) AS RatioCompresion, 
    f.physical_device_name AS ArchivoBackup,
    b.compression_algorithm
FROM msdb.dbo.backupset b
INNER JOIN msdb.dbo.backupmediafamily f
    ON b.media_set_id = f.media_set_id
WHERE b.backup_finish_date IS NOT NULL
  AND b.database_name = 'StackOverflow'
ORDER BY b.backup_start_date DESC;

----------------------------------
-- Probamos Restores
----------------------------------

-- Restore  Nuevo Algoritmo

USE [master]
RESTORE DATABASE [StackOverflow2] 
FROM  DISK = N'D:\Temp\S2.bak' WITH  FILE = 1,
MOVE N'StackOverflow2010' 
TO N'D:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\StackOverflow22010_2.mdf',  
MOVE N'StackOverflow2010_log' 
TO N'D:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\StackOverflow22010_2_log.ldf',  
NOUNLOAD,  STATS = 5,REPLACE

/*
RESTORE DATABASE successfully processed 1096538 pages in 17.347 seconds (493.843 MB/sec).

20 Seconds

*/


-- Restore  viejo Algoritmo

USE [master]
RESTORE DATABASE [StackOverflow2] 
FROM  DISK = N'D:\Temp\S1.bak' WITH  FILE = 1,
MOVE N'StackOverflow2010' 
TO N'D:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\StackOverflow22010_2.mdf',  
MOVE N'StackOverflow2010_log' 
TO N'D:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\StackOverflow22010_2_log.ldf',  
NOUNLOAD,  STATS = 5,REPLACE

/*
RESTORE DATABASE successfully processed 1096538 pages in 23.918 seconds (358.169 MB/sec).

24 Sec

*/

---------------------------------
----     Probamos con TDE
---------------------------------

-- Antivamos TDE
USE master;
GO

-- Solo si no existe una master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StrongPassword_123!';
GO


CREATE CERTIFICATE Certificado_TDE_StackOverflow2
WITH SUBJECT = 'Certificado para TDE en StackOverflow2';
GO

USE StackOverflow2;
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE Certificado_TDE_StackOverflow2;
GO


ALTER DATABASE StackOverflow2
SET ENCRYPTION ON;
GO

SELECT
    db.name AS BaseDeDatos,
    CASE dek.encryption_state
        WHEN 0 THEN 'Sin clave de cifrado'
        WHEN 1 THEN 'Sin cifrar'
        WHEN 2 THEN 'En proceso de cifrado'
        WHEN 3 THEN 'Cifrada'
        WHEN 4 THEN 'En proceso de descifrado'
        WHEN 5 THEN 'Esperando reinicio'
        WHEN 6 THEN 'En proceso de reinicio'
    END AS Estado,
    dek.percent_complete,
    dek.key_algorithm,
    dek.key_length
FROM sys.databases db
LEFT JOIN sys.dm_database_encryption_keys dek 
    ON db.database_id = dek.database_id
WHERE db.name = 'StackOverflow2';

-- Probamos backups

SET STATISTICS TIME ON
BACKUP DATABASE StackOverflow2 
TO DISK = 'D:\TEMP\S1_TDE.bak' WITH INIT, FORMAT, COMPRESSION, STATS = 5;

BACKUP DATABASE StackOverflow2 
TO DISK = 'D:\TEMP\S2_TDE.bak' WITH INIT, FORMAT, COMPRESSION (ALGORITHM = ZSTD), STATS = 5

-- Vemos Resultados

SELECT TOP 10
    b.database_name AS BaseDeDatos,                    
    b.backup_start_date AS FechaBackup,                   
    DATEDIFF(SECOND, b.backup_start_date, b.backup_finish_date) AS DuracionSegundos,  
    b.backup_size / 1024 / 1024 AS TamanoMB,               
    b.compressed_backup_size / 1024 / 1024 AS TamanoComprimidoMB,
    CAST(1.0 * b.backup_size / NULLIF(b.compressed_backup_size, 0) AS DECIMAL(5,2)) AS RatioCompresion, 
    f.physical_device_name AS ArchivoBackup,
    b.compression_algorithm
FROM msdb.dbo.backupset b
INNER JOIN msdb.dbo.backupmediafamily f
    ON b.media_set_id = f.media_set_id
WHERE b.backup_finish_date IS NOT NULL
  AND b.database_name like 'StackOverflow%'
  ORDER BY b.backup_start_date DESC;

-- Limpiamos history Backups

USE msdb;
GO

EXEC sp_delete_backuphistory @oldest_date = '2026-01-01';


