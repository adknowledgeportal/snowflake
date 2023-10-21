// Follow this blog https://www.snowflake.com/blog/how-to-load-terabytes-into-snowflake-speeds-feeds-and-techniques/#:~:text=Best%20Practices%20for%20Parquet%20and%20ORC
USE DATABASE synapse_data_warehouse;
USE SCHEMA synapse_raw;
USE WAREHOUSE COMPUTE_MEDIUM;
LIST @synapse_prod_warehouse_s3_stage;

-- * Ingest data for the first time
-- * SNOW-11 add user profile snapshots
CREATE TABLE IF NOT EXISTS userprofilesnapshot (
  change_type STRING,
  change_timestamp TIMESTAMP,
  change_user_id NUMBER,
  snapshot_timestamp TIMESTAMP,
  id NUMBER,
  user_name STRING,
  first_name STRING,
  last_name STRING,
  email STRING,
  location STRING,
  company STRING,
  position STRING,
  snapshot_date DATE
)
CLUSTER BY (snapshot_date);
copy into
  userprofilesnapshot
from (
  select
    $1:change_type as change_type,
    $1:change_timestamp as change_timestamp,
    $1:change_user_id as change_user_id,
    $1:snapshot_timestamp as snapshot_timestamp,
    $1:id as id,
    $1:user_name as user_name,
    $1:first_name as first_name,
    $1:last_name as last_name,
    $1:email as email,
    $1:location as location,
    $1:company as company,
    $1:position as position,
      NULLIF(
        regexp_replace(
          metadata$filename,
          '.*userprofilesnapshots\/snapshot_date\=(.*)\/.*', '\\1'
        ), 
        '__HIVE_DEFAULT_PARTITION__'
      ) as snapshot_date
  from
    @synapse_prod_warehouse_s3_stage/userprofilesnapshots
  )
pattern='.*userprofilesnapshots/snapshot_date=.*/.*'
;
-- * SNOW-1
CREATE TABLE IF NOT EXISTS NODESNAPSHOTS (
	change_type STRING,
	change_timestamp TIMESTAMP,
	change_user_id NUMBER,
	snapshot_timestamp TIMESTAMP,
	id NUMBER,
	benefactor_id NUMBER,
	project_id NUMBER,
	parent_id NUMBER,
	node_type STRING,
	created_on TIMESTAMP,
	created_by NUMBER,
	modified_on TIMESTAMP,
	modified_by NUMBER,
	version_number NUMBER,
	file_handle_id NUMBER,
	name STRING,
	is_public BOOLEAN,
	is_controlled BOOLEAN,
	is_restricted BOOLEAN,
	snapshot_date DATE
)
CLUSTER BY (snapshot_date);

copy into
  NODESNAPSHOTS
from (
  select
    $1:change_type as change_type,
    $1:change_timestamp as change_timestamp,
    $1:change_user_id as change_user_id,
    $1:snapshot_timestamp as snapshot_timestamp,
    $1:id as id,
    $1:benefactor_id as benefactor_id,
    $1:project_id as project_id,
    $1:parent_id as parent_id,
    $1:node_type as node_type,
    $1:created_on as created_on,
    $1:created_by as created_by,
    $1:modified_on as modified_on,
    $1:modified_by as modified_by,
    $1:version_number as version_number,
    $1:file_handle_id as file_handle_id,
    CASE
        WHEN POSITION('.' IN $1:name) > 0 THEN CONCAT(MD5($1:name), '.', REGEXP_REPLACE($1:name , '^(.*)[.](.*)', '\\2'))
        ELSE MD5($1:name)
    END as name,
    $1:is_public as is_public,
    $1:is_controlled as is_controlled,
    $1:is_restricted as is_restricted,
    NULLIF(
      regexp_replace (
      METADATA$FILENAME,
      '.*nodesnapshots\/snapshot_date\=(.*)\/.*',
      '\\1'),
      '__HIVE_DEFAULT_PARTITION__'
    )                         as snapshot_date
  from @synapse_prod_warehouse_s3_stage/nodesnapshots/)
pattern='.*nodesnapshots/snapshot_date=.*/.*'
;
-- * SNOW-4 create certified quiz
CREATE TABLE IF NOT EXISTS certifiedquiz (
    response_id NUMBER,
    user_id NUMBER,
    passed BOOLEAN,
    passed_on TIMESTAMP,
    stack STRING,
    instance STRING,
    record_date DATE
)
CLUSTER BY (record_date);

copy into
  certifiedquiz
from (
  select
     $1:response_id as response_id,
     $1:user_id as user_id,
     $1:passed as passed,
     $1:passed_on as passed_on,
     $1:stack as stack,
     $1:instance as instance,
     NULLIF(
       regexp_replace (
       METADATA$FILENAME,
       '.*certifiedquizrecords\/record_date\=(.*)\/.*',
       '\\1'),
       '__HIVE_DEFAULT_PARTITION__'
     )                         as record_date
  from
    @synapse_prod_warehouse_s3_stage/certifiedquizrecords
  )
pattern='.*certifiedquizrecords/record_date=.*/.*'
;

CREATE TABLE IF NOT EXISTS certifiedquizquestion (
    response_id NUMBER,
    question_index NUMBER,
    is_correct BOOLEAN,
    stack STRING,
    instance STRING,
    record_date DATE
)
CLUSTER BY (record_date);

copy into
  certifiedquizquestion
from (
  select
     $1:response_id as response_id,
     $1:question_index as question_index,
     $1:is_correct as is_correct,
     $1:stack as stack,
     $1:instance as instance,
     NULLIF(
       regexp_replace (
       METADATA$FILENAME,
       '.*certifiedquizquestionrecords\/record_date\=(.*)\/.*',
       '\\1'),
       '__HIVE_DEFAULT_PARTITION__'
     )                         as record_date
  from
    @synapse_prod_warehouse_s3_stage/certifiedquizquestionrecords
  )
pattern='.*certifiedquizquestionrecords/record_date=.*/.*'
;
-- * SNOW-5
CREATE TABLE IF NOT EXISTS filedownload (
    timestamp TIMESTAMP,
    user_id NUMBER,
    project_id NUMBER,
    file_handle_id NUMBER,
    downloaded_file_handle_id NUMBER,
    association_object_id NUMBER,
    association_object_type STRING,
    stack STRING,
    instance STRING,
    record_date DATE
)
CLUSTER BY (record_date);

copy into
  filedownload
from (
  select
     $1:timestamp as timestamp,
     $1:user_id as user_id,
     $1:project_id as project_id,
     $1:file_handle_id as file_handle_id,
     $1:downloaded_file_handle_id as downloaded_file_handle_id,
     $1:association_object_id as association_object_id,
     $1:association_object_type as association_object_type,
     $1:stack as stack,
     $1:instance as instance,
     NULLIF(
       regexp_replace (
       METADATA$FILENAME,
       '.*filedownloadrecords\/record_date\=(.*)\/.*',
       '\\1'),
       '__HIVE_DEFAULT_PARTITION__'
     )                         as record_date
  from
    @synapse_prod_warehouse_s3_stage/filedownloadrecords
  )
pattern='.*filedownloadrecords/record_date=.*/.*'
;
-- * SNOW-2
create table IF NOT EXISTS aclsnapshots (
  change_timestamp TIMESTAMP,
  change_type STRING,
  snapshot_timestamp TIMESTAMP,
  owner_id NUMBER,
  owner_type STRING,
  created_on TIMESTAMP,
  resource_access STRING,
  snapshot_date DATE
)
CLUSTER BY (snapshot_date);

copy into
  aclsnapshots
from (
  select
    $1:change_timestamp as change_timestamp,
    $1:change_type as change_type,
    $1:snapshot_timestamp as snapshot_timestamp,
    $1:owner_id as owner_id,
    $1:owner_type as owner_type,
    $1:created_on as created_on,
    $1:resource_access as resource_access,
    NULLIF(
       regexp_replace (
       METADATA$FILENAME,
       '.*aclsnapshots\/snapshot_date\=(.*)\/.*',
       '\\1'),
       '__HIVE_DEFAULT_PARTITION__'
    )                         as snapshot_date
  from
    @synapse_prod_warehouse_s3_stage/aclsnapshots
  )
pattern='.*aclsnapshots/snapshot_date=.*/.*'
;
-- * SNOW-9
CREATE TABLE IF NOT EXISTS teamsnapshots (
  change_type STRING,
  change_timestamp TIMESTAMP,
  change_user_id NUMBER,
  snapshot_timestamp TIMESTAMP,
  id NUMBER,
  name STRING,
  can_public_join BOOLEAN,
  created_on TIMESTAMP,
  created_by NUMBER,
  modified_on TIMESTAMP,
  modified_by NUMBER,
  snapshot_date DATE
)
CLUSTER BY (snapshot_date);

copy into
  teamsnapshots
from (
  select
    $1:change_type as change_type,
    $1:change_timestamp as change_timestamp,
    $1:change_user_id as change_user_id,
    $1:snapshot_timestamp as snapshot_timestamp,
    $1:id as id,
    $1:name as name,
    $1:can_public_join as can_public_join,
    $1:created_on as created_on,
    $1:created_by as created_by,
    $1:modified_on as modified_on,
    $1:modified_by as modified_by,
    NULLIF(
       regexp_replace (
       METADATA$FILENAME,
       '.*teamsnapshots\/snapshot_date\=(.*)\/.*',
       '\\1'),
       '__HIVE_DEFAULT_PARTITION__'
    )                         as snapshot_date
  from
    @synapse_prod_warehouse_s3_stage/teamsnapshots
  )
pattern='.*teamsnapshots/snapshot_date=.*/.*'
;
-- * SNOW-10 add user group snapshots
create TABLE IF NOT EXISTS usergroupsnapshots (
  change_type STRING,
	change_timestamp TIMESTAMP,
  change_user_id NUMBER,
	snapshot_timestamp TIMESTAMP,
	id NUMBER,
	is_individual BOOLEAN,
	created_on TIMESTAMP,
	snapshot_date DATE
)
CLUSTER BY (snapshot_date);
copy into
  usergroupsnapshots
from (
  select
    $1:change_type as change_type,
    $1:change_timestamp as change_timestamp,
    $1:change_user_id as change_user_id,
    $1:snapshot_timestamp as snapshot_timestamp,
    $1:id as id,
    $1:is_individual as is_individual,
    $1:created_on as created_on,
    NULLIF(
       regexp_replace (
       METADATA$FILENAME,
       '.*usergroupsnapshots\/snapshot_date\=(.*)\/.*',
       '\\1'),
       '__HIVE_DEFAULT_PARTITION__'
    )                         as snapshot_date
  from
    @synapse_prod_warehouse_s3_stage/usergroupsnapshots
  )
pattern='.*usergroupsnapshots/snapshot_date=.*/.*'
;

// Create verification submission snapshots table
create TABLE IF NOT EXISTS verificationsubmissionsnapshots (
  change_timestamp TIMESTAMP,
  change_type STRING,
	snapshot_timestamp TIMESTAMP,
  id NUMBER,
	created_on TIMESTAMP,
	created_by NUMBER,
  state_history STRING,
	snapshot_date DATE
)
CLUSTER BY (snapshot_date);

copy into verificationsubmissionsnapshots from (
  select
    $1:change_timestamp as change_timestamp,
    $1:change_type as change_type,
    $1:snapshot_timestamp as snapshot_timestamp,
    $1:id as id,
    $1:created_on as created_on,
    $1:created_by as created_by,
    $1:state_history as state_history,
    NULLIF(
      regexp_replace (
      METADATA$FILENAME,
      '.*verificationsubmissionsnapshots\/snapshot_date\=(.*)\/.*',
      '\\1'),
      '__HIVE_DEFAULT_PARTITION__'
    )                         as snapshot_date
  from
    @synapse_prod_warehouse_s3_stage/verificationsubmissionsnapshots
  )
pattern='.*verificationsubmissionsnapshots/snapshot_date=.*/.*'
;
-- * SNOW-8
CREATE TABLE IF NOT EXISTS teammembersnapshots (
  change_type STRING,
  change_timestamp TIMESTAMP,
  change_user_id NUMBER,
	snapshot_timestamp TIMESTAMP,
  team_id NUMBER,
  member_id NUMBER,
  is_admin BOOLEAN,
	snapshot_date DATE
)
CLUSTER BY (snapshot_date);

copy into teammembersnapshots from (
  select
    $1:change_type as change_type,
    $1:change_timestamp as change_timestamp,
    $1:change_user_id as change_user_id,
    $1:snapshot_timestamp as snapshot_timestamp,
    $1:team_id as team_id,
    $1:member_id as member_id,
    $1:is_admin as is_admin,
    NULLIF(
      regexp_replace (
      METADATA$FILENAME,
      '.*teammembersnapshots\/snapshot_date\=(.*)\/.*',
      '\\1'),
      '__HIVE_DEFAULT_PARTITION__'
    )                         as snapshot_date
  from
    @synapse_prod_warehouse_s3_stage/teammembersnapshots
  )
pattern='.*teammembersnapshots/snapshot_date=.*/.*'
;

CREATE TABLE IF NOT EXISTS fileupload (
	timestamp TIMESTAMP,
  user_id NUMBER,
  project_id NUMBER,
  file_handle_id NUMBER,
  association_object_id NUMBER,
  association_object_type STRING,
  stack STRING,
  instance STRING,
	record_date DATE
)
CLUSTER BY (record_date);

copy into fileupload from (
  select
    $1:timestamp as timestamp,
    $1:user_id as user_id,
    $1:project_id as project_id,
    $1:file_handle_id as file_handle_id,
    $1:association_object_id as association_object_id,
    $1:association_object_type as association_object_type,
    $1:stack as stack,
    $1:instance as instance,
    NULLIF(
      regexp_replace (
      METADATA$FILENAME,
      '.*fileuploadrecords\/record_date\=(.*)\/.*',
      '\\1'),
      '__HIVE_DEFAULT_PARTITION__'
    )                         as record_date
  from
    @synapse_prod_warehouse_s3_stage/fileuploadrecords
  )
pattern='.*fileuploadrecords/record_date=.*/.*'
;
-- * SNOW-6
CREATE TABLE IF NOT EXISTS filesnapshots (
	change_type STRING,
  change_timestamp TIMESTAMP,
  change_user_id NUMBER,
  snapshot_timestamp TIMESTAMP,
  id NUMBER,
  created_by NUMBER,
  created_on TIMESTAMP,
  modified_on TIMESTAMP,
	concrete_type STRING,
  content_md5 STRING,
  content_type STRING,
  file_name STRING,
  storage_location_id NUMBER,
  content_size NUMBER,
  bucket STRING,
  key STRING,
  preview_id NUMBER,
  is_preview BOOLEAN,
  status STRING,
  snapshot_date DATE
)
CLUSTER BY (snapshot_date);

copy into filesnapshots from (
  select
    $1:change_type as change_type,
    $1:change_timestamp as change_timestamp,
    $1:change_user_id as change_user_id,
    $1:snapshot_timestamp as snapshot_timestamp,
    $1:id as id,
    $1:created_by as created_by,
    $1:created_on as created_on,
    $1:modified_on as modified_on,
    $1:concrete_type as concrete_type,
    $1:content_md5 as content_md5,
    $1:content_type as content_type,
    MD5($1:file_name) as file_name,
    $1:storage_location_id as storage_location_id,
    $1:content_size as content_size,
    $1:bucket as bucket,
    REGEXP_REPLACE($1:key, '^(.*)/(.*)/.*', '\\1/\\2') as key,
    $1:preview_id as preview_id,
    $1:is_preview as is_preview,
    $1:status as status,
    NULLIF(
       regexp_replace (
       metadata$filename,
       '.*filesnapshots\/snapshot_date\=(.*)\/.*',
       '\\1'),
       '__HIVE_DEFAULT_PARTITION__'
    ) as snapshot_date
  from
    @synapse_prod_warehouse_s3_stage/filesnapshots
  )
pattern='.*filesnapshots/snapshot_date=.*/.*'
;

-- * SNOW-7
CREATE TABLE IF NOT EXISTS processedaccess (
	session_id STRING,
  timestamp TIMESTAMP,
  user_id NUMBER,
  method STRING,
  request_url STRING,
  user_agent STRING,
  host STRING,
  origin STRING,
  x_forwarded_for STRING,
  via STRING,
  thread_id NUMBER,
  elapse_ms NUMBER,
  success BOOLEAN,
  stack STRING,
  instance STRING,
  vm_id STRING,
  return_object_id STRING,
  query_string STRING,
  response_status NUMBER,
  oauth_client_id STRING,
  basic_auth_username STRING,
  auth_method STRING,
  normalized_method_signature STRING,
  client STRING,
  client_version STRING,
  entity_id NUMBER,
  record_date DATE
)
CLUSTER BY (record_date);

copy into processedaccess from (
  select
     $1:session_id as session_id,
     $1:timestamp as timestamp,
     $1:user_id as user_id,
     $1:method as method,
     $1:request_url as request_url,
     $1:user_agent as user_agent,
     $1:host as host,
     $1:origin as origin,
     $1:x_forwarded_for as x_forwarded_for,
     $1:via as via,
     $1:thread_id as thread_id,
     $1:elapse_ms as elapse_ms,
     $1:success as success,
     $1:stack as stack,
     $1:instance as instance,
     $1:vm_id as vm_id,
     $1:return_object_id as return_object_id,
     $1:query_string as query_string,
     $1:response_status as response_status,
     $1:oauth_client_id as oauth_client_id,
     $1:basic_auth_username as basic_auth_username,
     $1:auth_method as auth_method,
     $1:normalized_method_signature as normalized_method_signature,
     $1:client as client,
     $1:client_version as client_version,
     $1:entity_id as entity_id,
     NULLIF(
       regexp_replace (
       METADATA$FILENAME,
       '.*processedaccessrecord\/record_date\=(.*)\/.*',
       '\\1'),
       '__HIVE_DEFAULT_PARTITION__'
     )                         as record_date
   from @synapse_prod_warehouse_s3_stage/processedaccessrecord)
   pattern='.*processedaccessrecord/record_date=.*/.*'
;