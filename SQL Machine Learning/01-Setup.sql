--- enable external script services
EXEC sp_configure  'external scripts enabled', 1
RECONFIGURE WITH OVERRIDE

-- Restart Service 

-- verificar configuracion

EXEC sp_configure  'external scripts enabled'

-- test simple script r & phython

EXEC sp_execute_external_script  @language =N'R',
@script=N'
OutputDataSet <- InputDataSet;
',
@input_data_1 =N'SELECT 1 AS hello'
WITH RESULT SETS (([hello] int not null));
GO

EXEC sp_execute_external_script  @language =N'Python',
@script=N'OutputDataSet=InputDataSet',
@input_data_1 = N'SELECT 1 AS col'

/*
  C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\PYTHON_SERVICES
  C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\R_SERVICES
*/

/*
 install Development  environment

 *R Tools for Visual Studio (RTVS) 
 https://www.visualstudio.com/vs/rtvs

 RStudio
 https://www.rstudio.com/

 */

 -- security for logins
USE <database_name>
GO
GRANT EXECUTE ANY EXTERNAL SCRIPT  TO [UserName]