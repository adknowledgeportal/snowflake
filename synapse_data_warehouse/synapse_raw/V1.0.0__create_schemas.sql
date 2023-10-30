USE ROLE SYSADMIN;
CREATE DATABASE IF NOT EXISTS {{database_name}}; --noqa: PRS,TMP
USE DATABASE {{database_name}}; --noqa: TMP
CREATE SCHEMA IF NOT EXISTS synapse_raw
WITH MANAGED ACCESS;
CREATE SCHEMA IF NOT EXISTS synapse
WITH MANAGED ACCESS;