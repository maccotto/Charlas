## Demos DbaTools
## MAxi Accotto | www.youtube.com/@maxiaccotto

Install-Module dbatools -Force # instalar modulo (requiere acceso a internet)

#importar el modulo para poderlo usar

Import-Module dbatools

## Para los nuevos protocolos de seguridad y que nos funcionen las DBA

Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true -Register
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false -Register 

################################
## Ejemplos de seteo
################################

### Maxdop
Test-DbaMaxDop -SqlInstance localhost 

Test-DbaMaxDop -SqlInstance localhost | Where-Object { $_.Database -eq  "N/A" } ## aplicando filtro

#usando credenciales SQL
$credencial = get-credential

Test-DbaMaxDop -SqlInstance localhost -SqlCredential $credencial | Where-Object { $_.Database -eq  "N/A" } ## aplicando filtro

# Configurando

Set-DbaMaxDop  -SqlInstance localhost

Test-DbaMaxDop -SqlInstance localhost | Where-Object { $_.Database -eq  "N/A" } ## aplicando filtro

Set-DbaMaxDop  -SqlInstance localhost -MaxDop 1



### Powerplan Windows
Test-DbaPowerPlan -ComputerName localhost

### Test memory

Test-DbaMaxMemory -SqlInstance localhost

Set-DbaMaxMemory localhost ## set memory

### Test disk Allocation
Test-DbaDiskAllocation -ComputerName localhost

### Test de la tempdb

Test-DbaTempDbConfig -SqlInstance localhost


##########################################
#### Ejemplos instalacion tools comunidad
#########################################

#Brent
Install-DbaFirstResponderKit -SqlInstance localhost -Database master

#OLA 
Install-DbaMaintenanceSolution -SqlInstance localhost -InstallJobs -CleanupTime 72 -ReplaceExisting

# WhoIsActive
Install-DbaWhoIsActive -SqlInstance localhost -Database master 

###########################################
############ Algunas Tareas de DBA 
###########################################

## Poner el modo de compatibilidad de todas las bases de datos a la del servidor

Set-DbaDbCompatibility -SqlInstance localhost 

## Poner el modo de compatibilidad de una base de datos

Set-DbaDbCompatibility -SqlInstance localhost  -Database 'Contoso 1M' -Compatibility Version140

## Configurar el Query Store en todas las bases

Set-DbaDbQueryStoreOption -SqlInstance localhost -State ReadWrite -FlushInterval 600 -CollectionInterval 10 -MaxSize 100 -CaptureMode All -CleanupMode Auto -StaleQueryThreshold 100

## Apagar el query Store de una base

Set-DbaDbQueryStoreOption -SqlInstance localhost -State OFF -Database AdventureWorks2022


###########################################
############ Ejemplos de migracion
###########################################

$Credenciales = Get-Credential ## Credenciales SQL para mi SQL nuevo

# Test de migracion

Test-DbaMigrationConstraint -Source localhost -Destination sql2.mshome.net -DestinationSqlCredential $Credenciales


# Pasar logins entre instancias

Copy-DbaLogin -Source localhost -Destination sql2.mshome.net -DestinationSqlCredential $Credenciales -Force

# Copiar toda la configuracion del agente (jobs, alerts, operadores)

Copy-DbaAgentServer -Source localhost -Destination sql2.mshome.net -DestinationSqlCredential $Credenciales -Force

# Migrar una base de datos con Backup & Restore

Copy-DbaDatabase -Source localhost -Destination sql2.mshome.net -Database AdventureWorksDW2019 -BackupRestore -SharedPath \\172.21.209.93\Compartido\ -DestinationSqlCredential $Credenciales -SetSourceReadOnly


##########################################
######### Backups & Restores 
##########################################

#backup full de todas las bases
Backup-DbaDatabase -SqlInstance localhost -Path \\172.21.209.93\Compartido\ -Type Full -ExcludeDatabase master,model,msdb,tempdb,ssidb,StackOverflow2010,AdventureWorks2022


