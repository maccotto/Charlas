--- backup encryption

/*
  Encryptacion de Backups
*/

-- Creamos la master Key

USE master 
GO 
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'mY_P@$$w0rd'

-- Creamos un certificado

Use Master 
GO

CREATE CERTIFICATE CertificadoBK 
WITH SUBJECT = 'Certificado para Backups'
,EXPIRY_DATE = '20201031'; 

-- hacemos un backup del certificado

USE master 
GO 
BACKUP CERTIFICATE CertificadoBK  
TO FILE = 'c:\tmp\BKPCERT.cer' 
WITH PRIVATE KEY (FILE = 'C:\TMP\BKP_Key.pvk' , 
ENCRYPTION BY PASSWORD = 'mY_P@$$w0rd' ) 
GO 

-- Hacemos el Backup

BACKUP DATABASE [AdventureWorksDW2019]
TO DISK = N'e:\tmp\dw_encrypt.bak' 
 WITH 
 INIT,
 ENCRYPTION 
 ( 
 ALGORITHM = AES_256, 
 SERVER CERTIFICATE = CertificadoBK 
 ), 
 COMPRESSION,
 FORMAT,
 STATS = 10 
 GO


BACKUP DATABASE [AdventureWorksDW2019]
TO DISK = N'C:\tmp\dw_encrypt_compress.bak' 
 WITH 
 INIT,
 COMPRESSION,
 STATS = 10 
 GO


---- server restore

USE master 
GO 
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'mY_P@$$w0rd'

 CREATE CERTIFICATE CertificadoBK 
 FROM FILE = 'c:\tmp\BKPCERT.cer'
 WITH PRIVATE KEY (FILE = 'C:\TMP\BKP_Key.pvk',  
 DECRYPTION BY PASSWORD = 'mY_P@$$w0rd'); 
 GO  

 -------------------
 -- LIMPIAR

 DROP CERTIFICATE CertificadoBK