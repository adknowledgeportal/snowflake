USE SCHEMA {{database_name}}.synapse_raw; --noqa: JJ01,PRS,TMP
ALTER TABLE USERPROFILESNAPSHOT ADD COLUMN created_on TIMESTAMP;