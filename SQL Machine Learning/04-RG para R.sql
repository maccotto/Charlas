/*
  RG for R Services
*/

SELECT * FROM sys.resource_governor_resource_pools WHERE name = 'default'

SELECT * FROM sys.resource_governor_external_resource_pools WHERE name = 'default'

ALTER EXTERNAL RESOURCE POOL "default" WITH (max_memory_percent = 40);
