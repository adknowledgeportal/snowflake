USE SCHEMA {{database_name}}.synapse; --noqa: JJ01,PRS,TMP
ALTER TABLE CERTIFIEDQUIZ_LATEST ADD COLUMN revoked BOOLEAN;
ALTER TABLE CERTIFIEDQUIZ_LATEST ADD COLUMN revoked_on TIMESTAMP;
ALTER TABLE CERTIFIEDQUIZ_LATEST ADD COLUMN certified BOOLEAN;
