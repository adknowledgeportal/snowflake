USE WAREHOUSE COMPUTE_ORG;

use role securityadmin;

// Grant system roles to users
GRANT ROLE SYSADMIN
TO USER "kevin.boske@sagebase.org";

// GENIE
USE ROLE USERADMIN;
CREATE ROLE IF NOT EXISTS genie_admin;

USE ROLE SECURITYADMIN;
grant role genie_admin
to role useradmin;
GRANT ROLE genie_admin
TO USER "alex.paynter@sagebase.org";
grant role genie_admin
to user "xindi.guo@sagebase.org";
grant role genie_admin
to user "chelsea.nayan@sagebase.org";
grant USAGE on database genie
to role genie_admin;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE GENIE
TO ROLE genie_admin;
GRANT SELECT ON FUTURE TABLES IN DATABASE GENIE
TO ROLE genie_admin;
-- GRANT USAGE ON ALL SCHEMAS IN DATABASE GENIE
-- TO ROLE genie_admin;
-- GRANT SELECT ON ALL TABLES IN DATABASE GENIE
-- TO ROLE genie_admin;
GRANT USAGE ON WAREHOUSE tableau
TO ROLE genie_admin;

// RECOVER
USE ROLE USERADMIN;
CREATE ROLE IF NOT EXISTS recover_data_engineer;

USE ROLE SECURITYADMIN;
grant role recover_data_engineer
to role useradmin;
GRANT CREATE SCHEMA, USAGE ON DATABASE RECOVER
TO ROLE recover_data_engineer;
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE recover
TO ROLE recover_data_engineer;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN DATABASE recover
TO ROLE recover_data_engineer;
GRANT ROLE recover_data_engineer
TO USER "phil.snyder@sagebase.org";
GRANT ROLE recover_data_engineer
TO USER "rixing.xu@sagebase.org";
GRANT ROLE recover_data_engineer
TO USER "thomas.yu@sagebase.org";
GRANT USAGE ON WAREHOUSE recover_xsmall
TO ROLE recover_data_engineer;

// AD
USE ROLE USERADMIN;
CREATE ROLE IF NOT EXISTS ad_team;
USE ROLE SECURITYADMIN;
GRANT ROLE ad_team
TO ROLE useradmin;
GRANT ROLE ad_team
TO USER "abby.vanderlinden@sagebase.org";
GRANT USAGE ON DATABASE sage
TO ROLE ad_team;

// Public role
// Synapse data warehouse
// GRANT SELECT ON ALL TABLES IN SCHEMA synapse_data_warehouse.synapse TO ROLE PUBLIC;
GRANT SELECT ON FUTURE TABLES IN SCHEMA synapse_data_warehouse.synapse
TO ROLE PUBLIC;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE sage
TO ROLE PUBLIC;
GRANT SELECT ON FUTURE TABLES IN DATABASE sage
TO ROLE PUBLIC;
GRANT USAGE ON DATABASE sage
TO ROLE PUBLIC;

USE ROLE USERADMIN;
CREATE ROLE IF NOT EXISTS masking_admin;
use role securityadmin;
GRANT ROLE masking_admin
TO ROLE useradmin;
GRANT ROLE masking_admin
TO USER "thomas.yu@sagebase.org";
GRANT CREATE MASKING POLICY ON SCHEMA SYNAPSE_DATA_WAREHOUSE.synapse
TO ROLE masking_admin;
USE ROLE accountadmin;
GRANT APPLY MASKING POLICY on ACCOUNT
TO ROLE masking_admin;