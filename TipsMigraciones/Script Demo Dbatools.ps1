import-module dbatools

$CRED = Get-Credential sa


Copy-DbaDatabase -Source "localhost,14033" -Destination "localhost,15033" -Database Adventureworks2017 -BackupRestore -SharedPath /var/opt/mssql/share -SourceSqlCredential $CRED -DestinationSqlCredential $CRED -SetSourceReadOnly -Force 

Copy-DbaLogin -Source "localhost,14033" -Destination "localhost,15033" -Force -KillActiveConnection -SourceSqlCredential $CRED -DestinationSqlCredential $CRED


Repair-DbaDbOrphanUser -SqlInstance "localhost,15033" -SqlCredential $CRED

Set-DbaDbCompatibility -SqlInstance "localhost,15033" -SqlCredential $cred 



