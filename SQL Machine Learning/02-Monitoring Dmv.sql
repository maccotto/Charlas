-- monitoring ML services with DMV

/*
This DMV reports a single row for each worker account that is currently running 
an external script. 
Note that this worker account is different from the credentials of the person 
sending the script. 
If a single Windows user sends multiple script requests, 
only one worker account would be assigned to handle all requests from that user. 
If a different Windows user logs in to run an external script, 
the request would be handled by a separate worker account.
*/

select * from sys.dm_external_script_requests

/*
This DMV is provided for internal monitoring (telemetry) to track how many external 
script calls are made on an instance. 
The telemetry service starts when SQL Server does and increments 
a disk-based counter each time a specific machine learning function is called.
*/

select * from sys.dm_external_script_execution_stats


--- extend events

select o.name as event_name, o.description  
  from sys.dm_xe_objects o  
  join sys.dm_xe_packages p  
    on o.package_guid = p.guid  
 where o.object_type = 'event'  
   and p.name = 'SQLSatellite';