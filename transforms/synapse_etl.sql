USE ROLE SYSADMIN;
USE DATABASE SYNAPSE_DATA_WAREHOUSE;
USE SCHEMA SYNAPSE;

-- Created certified question information and loaded the table manually
CREATE TABLE IF NOT EXISTS SYNAPSE_DATA_WAREHOUSE.SYNAPSE.CERTIFIED_QUESTION_INFORMATION (
    QUESTION_INDEX NUMBER,
    QUESTION_GROUP_NUMBER NUMBER,
    VERSION STRING, --noqa: RF04
    FRE_Q FLOAT,
    FRE_HELP FLOAT,
    DIFFERENCE_FRE FLOAT,
    FKGL_Q NUMBER,
    FKGL_HELP FLOAT,
    DIFFERENCE_FKGL FLOAT,
    NOTES STRING,
    TYPE STRING, --noqa: RF04
    QUESTION_TEXT STRING
);

-- Create View of user profile and cert join
CREATE OR REPLACE VIEW SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USER_CERTIFIED AS
WITH CERT AS (
    SELECT
        USER_ID,
        PASSED
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.CERTIFIEDQUIZ_LATEST
),

USER_CERT_JOINED AS (
    SELECT
        USER.*,
        CERT.*
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST AS USER  --noqa: RF04
    LEFT JOIN CERT
        ON USER.ID = CERT.USER_ID
)

SELECT
    ID,
    USER_NAME,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    LOCATION,
    COMPANY,
    POSITION,
    PASSED
FROM USER_CERT_JOINED;

-- Merge into certified quiz
MERGE INTO SYNAPSE_DATA_WAREHOUSE.SYNAPSE.CERTIFIEDQUIZ_LATEST AS TARGET_TABLE
USING (
    WITH CQQ_RANKED AS (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY USER_ID
                ORDER BY INSTANCE DESC, RESPONSE_ID DESC
            ) AS ROW_NUM
        FROM CERTIFIEDQUIZ_STREAM
    )

    SELECT * EXCLUDE ROW_NUM
    FROM CQQ_RANKED
    WHERE ROW_NUM = 1
) AS SOURCE_TABLE ON TARGET_TABLE.USER_ID = SOURCE_TABLE.USER_ID
WHEN MATCHED THEN
    UPDATE SET
        TARGET_TABLE.RESPONSE_ID = SOURCE_TABLE.RESPONSE_ID,
        TARGET_TABLE.PASSED = SOURCE_TABLE.PASSED,
        TARGET_TABLE.PASSED_ON = SOURCE_TABLE.PASSED_ON,
        TARGET_TABLE.STACK = SOURCE_TABLE.STACK,
        TARGET_TABLE.INSTANCE = SOURCE_TABLE.INSTANCE,
        TARGET_TABLE.RECORD_DATE = SOURCE_TABLE.RECORD_DATE
WHEN NOT MATCHED THEN
    INSERT (RESPONSE_ID, USER_ID, PASSED, PASSED_ON, STACK, INSTANCE, RECORD_DATE)
    VALUES (SOURCE_TABLE.RESPONSE_ID, SOURCE_TABLE.USER_ID, SOURCE_TABLE.PASSED, SOURCE_TABLE.PASSED_ON, SOURCE_TABLE.STACK, SOURCE_TABLE.INSTANCE, SOURCE_TABLE.RECORD_DATE);

-- merge into certified quiz questions
MERGE INTO SYNAPSE_DATA_WAREHOUSE.SYNAPSE.CERTIFIEDQUIZQUESTION_LATEST AS TARGET_TABLE
USING (
    WITH CQQ_RANKED AS (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY RESPONSE_ID, QUESTION_INDEX
                ORDER BY IS_CORRECT DESC, INSTANCE DESC
            ) AS ROW_NUM
        FROM CERTIFIEDQUIZQUESTION_STREAM
    )

    SELECT * EXCLUDE ROW_NUM
    FROM CQQ_RANKED
    WHERE ROW_NUM = 1
    ORDER BY RESPONSE_ID DESC, QUESTION_INDEX ASC
) AS SOURCE_TABLE ON TARGET_TABLE.RESPONSE_ID = SOURCE_TABLE.RESPONSE_ID AND TARGET_TABLE.QUESTION_INDEX = SOURCE_TABLE.QUESTION_INDEX
WHEN MATCHED THEN
    UPDATE SET
        TARGET_TABLE.RESPONSE_ID = SOURCE_TABLE.RESPONSE_ID,
        TARGET_TABLE.QUESTION_INDEX = SOURCE_TABLE.QUESTION_INDEX,
        TARGET_TABLE.IS_CORRECT = SOURCE_TABLE.IS_CORRECT,
        TARGET_TABLE.STACK = SOURCE_TABLE.STACK,
        TARGET_TABLE.INSTANCE = SOURCE_TABLE.INSTANCE,
        TARGET_TABLE.RECORD_DATE = SOURCE_TABLE.RECORD_DATE
WHEN NOT MATCHED THEN
    INSERT (RESPONSE_ID, QUESTION_INDEX, IS_CORRECT, STACK, INSTANCE, RECORD_DATE)
    VALUES (SOURCE_TABLE.RESPONSE_ID, SOURCE_TABLE.QUESTION_INDEX, SOURCE_TABLE.IS_CORRECT, SOURCE_TABLE.STACK, SOURCE_TABLE.INSTANCE, SOURCE_TABLE.RECORD_DATE);


-- merge into node latest

MERGE INTO SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST AS TARGET_TABLE
USING (
    WITH RANKED_NODES AS (
        SELECT
            *,
            "row_number"()
                OVER (
                    PARTITION BY ID
                    ORDER BY CHANGE_TIMESTAMP DESC, SNAPSHOT_TIMESTAMP DESC
                )
                AS N
        FROM NODESNAPSHOTS_STREAM
    )

    SELECT * EXCLUDE N
    FROM RANKED_NODES
    WHERE N = 1
) AS SOURCE_TABLE ON TARGET_TABLE.ID = SOURCE_TABLE.ID
WHEN MATCHED THEN
    UPDATE SET
        TARGET_TABLE.CHANGE_TYPE = SOURCE_TABLE.CHANGE_TYPE,
        TARGET_TABLE.CHANGE_TIMESTAMP = SOURCE_TABLE.CHANGE_TIMESTAMP,
        TARGET_TABLE.CHANGE_USER_ID = SOURCE_TABLE.CHANGE_USER_ID,
        TARGET_TABLE.SNAPSHOT_TIMESTAMP = SOURCE_TABLE.SNAPSHOT_TIMESTAMP,
        TARGET_TABLE.ID = SOURCE_TABLE.ID,
        TARGET_TABLE.BENEFACTOR_ID = SOURCE_TABLE.BENEFACTOR_ID,
        TARGET_TABLE.PROJECT_ID = SOURCE_TABLE.PROJECT_ID,
        TARGET_TABLE.PARENT_ID = SOURCE_TABLE.PARENT_ID,
        TARGET_TABLE.NODE_TYPE = SOURCE_TABLE.NODE_TYPE,
        TARGET_TABLE.CREATED_ON = SOURCE_TABLE.CREATED_ON,
        TARGET_TABLE.CREATED_BY = SOURCE_TABLE.CREATED_BY,
        TARGET_TABLE.MODIFIED_ON = SOURCE_TABLE.MODIFIED_ON,
        TARGET_TABLE.MODIFIED_BY = SOURCE_TABLE.MODIFIED_BY,
        TARGET_TABLE.VERSION_NUMBER = SOURCE_TABLE.VERSION_NUMBER,
        TARGET_TABLE.FILE_HANDLE_ID = SOURCE_TABLE.FILE_HANDLE_ID,
        TARGET_TABLE.NAME = SOURCE_TABLE.NAME,
        TARGET_TABLE.IS_PUBLIC = SOURCE_TABLE.IS_PUBLIC,
        TARGET_TABLE.IS_CONTROLLED = SOURCE_TABLE.IS_CONTROLLED,
        TARGET_TABLE.IS_RESTRICTED = SOURCE_TABLE.IS_RESTRICTED,
        TARGET_TABLE.SNAPSHOT_DATE = SOURCE_TABLE.SNAPSHOT_DATE
WHEN NOT MATCHED THEN
    INSERT (CHANGE_TYPE, CHANGE_TIMESTAMP, CHANGE_USER_ID, SNAPSHOT_TIMESTAMP, ID, BENEFACTOR_ID, PROJECT_ID, PARENT_ID, NODE_TYPE, CREATED_ON, CREATED_BY, MODIFIED_ON, MODIFIED_BY, VERSION_NUMBER, FILE_HANDLE_ID, NAME, IS_PUBLIC, IS_CONTROLLED, IS_RESTRICTED, SNAPSHOT_DATE)
    VALUES (SOURCE_TABLE.CHANGE_TYPE, SOURCE_TABLE.CHANGE_TIMESTAMP, SOURCE_TABLE.CHANGE_USER_ID, SOURCE_TABLE.SNAPSHOT_TIMESTAMP, SOURCE_TABLE.ID, SOURCE_TABLE.BENEFACTOR_ID, SOURCE_TABLE.PROJECT_ID, SOURCE_TABLE.PARENT_ID, SOURCE_TABLE.NODE_TYPE, SOURCE_TABLE.CREATED_ON, SOURCE_TABLE.CREATED_BY, SOURCE_TABLE.MODIFIED_ON, SOURCE_TABLE.MODIFIED_BY, SOURCE_TABLE.VERSION_NUMBER, SOURCE_TABLE.FILE_HANDLE_ID, SOURCE_TABLE.NAME, SOURCE_TABLE.IS_PUBLIC, SOURCE_TABLE.IS_CONTROLLED, SOURCE_TABLE.IS_RESTRICTED, SOURCE_TABLE.SNAPSHOT_DATE);
DELETE FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
WHERE CHANGE_TYPE = 'DELETE';

-- merge into file latest

MERGE INTO SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST AS TARGET_TABLE
USING (
    WITH RANKED_NODES AS (
        SELECT
            *,
            "row_number"()
                OVER (
                    PARTITION BY ID
                    ORDER BY CHANGE_TIMESTAMP DESC, SNAPSHOT_TIMESTAMP DESC
                )
                AS N
        FROM FILESNAPSHOTS_STREAM
        WHERE
            NOT IS_PREVIEW
    )

    SELECT * EXCLUDE N
    FROM RANKED_NODES
    WHERE N = 1

) AS SOURCE_TABLE ON TARGET_TABLE.ID = SOURCE_TABLE.ID
WHEN MATCHED THEN
    UPDATE SET
        TARGET_TABLE.CHANGE_TYPE = SOURCE_TABLE.CHANGE_TYPE,
        TARGET_TABLE.CHANGE_TIMESTAMP = SOURCE_TABLE.CHANGE_TIMESTAMP,
        TARGET_TABLE.CHANGE_USER_ID = SOURCE_TABLE.CHANGE_USER_ID,
        TARGET_TABLE.SNAPSHOT_TIMESTAMP = SOURCE_TABLE.SNAPSHOT_TIMESTAMP,
        TARGET_TABLE.ID = SOURCE_TABLE.ID,
        TARGET_TABLE.CREATED_BY = SOURCE_TABLE.CREATED_BY,
        TARGET_TABLE.CREATED_ON = SOURCE_TABLE.CREATED_ON,
        TARGET_TABLE.MODIFIED_ON = SOURCE_TABLE.MODIFIED_ON,
        TARGET_TABLE.CONCRETE_TYPE = SOURCE_TABLE.CONCRETE_TYPE,
        TARGET_TABLE.CONTENT_MD5 = SOURCE_TABLE.CONTENT_MD5,
        TARGET_TABLE.CONTENT_TYPE = SOURCE_TABLE.CONTENT_TYPE,
        TARGET_TABLE.FILE_NAME = SOURCE_TABLE.FILE_NAME,
        TARGET_TABLE.STORAGE_LOCATION_ID = SOURCE_TABLE.STORAGE_LOCATION_ID,
        TARGET_TABLE.CONTENT_SIZE = SOURCE_TABLE.CONTENT_SIZE,
        TARGET_TABLE.BUCKET = SOURCE_TABLE.BUCKET,
        TARGET_TABLE.KEY = SOURCE_TABLE.KEY,
        TARGET_TABLE.PREVIEW_ID = SOURCE_TABLE.PREVIEW_ID,
        TARGET_TABLE.IS_PREVIEW = SOURCE_TABLE.IS_PREVIEW,
        TARGET_TABLE.STATUS = SOURCE_TABLE.STATUS,
        TARGET_TABLE.SNAPSHOT_DATE = SOURCE_TABLE.SNAPSHOT_DATE
WHEN NOT MATCHED THEN
    INSERT (CHANGE_TYPE, CHANGE_TIMESTAMP, CHANGE_USER_ID, SNAPSHOT_TIMESTAMP, ID, CREATED_BY, CREATED_ON, MODIFIED_ON, CONCRETE_TYPE, CONTENT_MD5, CONTENT_TYPE, FILE_NAME, STORAGE_LOCATION_ID, CONTENT_SIZE, BUCKET, KEY, PREVIEW_ID, IS_PREVIEW, STATUS, SNAPSHOT_DATE)
    VALUES (SOURCE_TABLE.CHANGE_TYPE, SOURCE_TABLE.CHANGE_TIMESTAMP, SOURCE_TABLE.CHANGE_USER_ID, SOURCE_TABLE.SNAPSHOT_TIMESTAMP, SOURCE_TABLE.ID, SOURCE_TABLE.CREATED_BY, SOURCE_TABLE.CREATED_ON, SOURCE_TABLE.MODIFIED_ON, SOURCE_TABLE.CONCRETE_TYPE, SOURCE_TABLE.CONTENT_MD5, SOURCE_TABLE.CONTENT_TYPE, SOURCE_TABLE.FILE_NAME, SOURCE_TABLE.STORAGE_LOCATION_ID, SOURCE_TABLE.CONTENT_SIZE, SOURCE_TABLE.BUCKET, SOURCE_TABLE.KEY, SOURCE_TABLE.PREVIEW_ID, SOURCE_TABLE.IS_PREVIEW, SOURCE_TABLE.STATUS, SOURCE_TABLE.SNAPSHOT_DATE);

DELETE FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST
WHERE CHANGE_TYPE = 'DELETE';

MERGE INTO SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST AS TARGET_TABLE
USING (
    WITH RANKED_NODES AS (
        SELECT
            *,
            "row_number"()
                OVER (
                    PARTITION BY ID
                    ORDER BY CHANGE_TIMESTAMP DESC, SNAPSHOT_TIMESTAMP DESC
                )
                AS N
        FROM
            USERPROFILESNAPSHOT_STREAM
    )

    SELECT * EXCLUDE N
    FROM RANKED_NODES
    WHERE N = 1
) AS SOURCE_TABLE ON TARGET_TABLE.ID = SOURCE_TABLE.ID
WHEN MATCHED THEN
    UPDATE SET
        TARGET_TABLE.CHANGE_TYPE = SOURCE_TABLE.CHANGE_TYPE,
        TARGET_TABLE.CHANGE_TIMESTAMP = SOURCE_TABLE.CHANGE_TIMESTAMP,
        TARGET_TABLE.CHANGE_USER_ID = SOURCE_TABLE.CHANGE_USER_ID,
        TARGET_TABLE.SNAPSHOT_TIMESTAMP = SOURCE_TABLE.SNAPSHOT_TIMESTAMP,
        TARGET_TABLE.ID = SOURCE_TABLE.ID,
        TARGET_TABLE.USER_NAME = SOURCE_TABLE.USER_NAME,
        TARGET_TABLE.FIRST_NAME = SOURCE_TABLE.FIRST_NAME,
        TARGET_TABLE.LAST_NAME = SOURCE_TABLE.LAST_NAME,
        TARGET_TABLE.EMAIL = SOURCE_TABLE.EMAIL,
        TARGET_TABLE.LOCATION = SOURCE_TABLE.LOCATION,
        TARGET_TABLE.COMPANY = SOURCE_TABLE.COMPANY,
        TARGET_TABLE.POSITION = SOURCE_TABLE.POSITION,
        TARGET_TABLE.SNAPSHOT_DATE = SOURCE_TABLE.SNAPSHOT_DATE
WHEN NOT MATCHED THEN
    INSERT (CHANGE_TYPE, CHANGE_TIMESTAMP, CHANGE_USER_ID, SNAPSHOT_TIMESTAMP, ID, USER_NAME, FIRST_NAME, LAST_NAME, EMAIL, LOCATION, COMPANY, POSITION, SNAPSHOT_DATE)
    VALUES (SOURCE_TABLE.CHANGE_TYPE, SOURCE_TABLE.CHANGE_TIMESTAMP, SOURCE_TABLE.CHANGE_USER_ID, SOURCE_TABLE.SNAPSHOT_TIMESTAMP, SOURCE_TABLE.ID, SOURCE_TABLE.USER_NAME, SOURCE_TABLE.FIRST_NAME, SOURCE_TABLE.LAST_NAME, SOURCE_TABLE.EMAIL, SOURCE_TABLE.LOCATION, SOURCE_TABLE.COMPANY, SOURCE_TABLE.POSITION, SOURCE_TABLE.SNAPSHOT_DATE);


MERGE INTO SYNAPSE_DATA_WAREHOUSE.SYNAPSE.TEAMMEMBER_LATEST AS TARGET_TABLE
USING (
    WITH RANKED_NODES AS (
        SELECT
            *,
            "row_number"()
                OVER (
                    PARTITION BY TEAM_ID, MEMBER_ID
                    ORDER BY CHANGE_TIMESTAMP DESC, SNAPSHOT_TIMESTAMP DESC
                )
                AS N
        FROM
            TEAMMEMBERSNAPSHOTS_STREAM
    )

    SELECT * EXCLUDE N
    FROM RANKED_NODES
    WHERE N = 1
) AS SOURCE_TABLE ON TARGET_TABLE.MEMBER_ID = SOURCE_TABLE.MEMBER_ID AND TARGET_TABLE.TEAM_ID = SOURCE_TABLE.TEAM_ID
WHEN MATCHED THEN
    UPDATE SET
        TARGET_TABLE.CHANGE_TYPE = SOURCE_TABLE.CHANGE_TYPE,
        TARGET_TABLE.CHANGE_TIMESTAMP = SOURCE_TABLE.CHANGE_TIMESTAMP,
        TARGET_TABLE.CHANGE_USER_ID = SOURCE_TABLE.CHANGE_USER_ID,
        TARGET_TABLE.SNAPSHOT_TIMESTAMP = SOURCE_TABLE.SNAPSHOT_TIMESTAMP,
        TARGET_TABLE.TEAM_ID = SOURCE_TABLE.TEAM_ID,
        TARGET_TABLE.MEMBER_ID = SOURCE_TABLE.MEMBER_ID,
        TARGET_TABLE.IS_ADMIN = SOURCE_TABLE.IS_ADMIN,
        TARGET_TABLE.SNAPSHOT_DATE = SOURCE_TABLE.SNAPSHOT_DATE
WHEN NOT MATCHED THEN
    INSERT (CHANGE_TYPE, CHANGE_TIMESTAMP, CHANGE_USER_ID, SNAPSHOT_TIMESTAMP, TEAM_ID, MEMBER_ID, IS_ADMIN, SNAPSHOT_DATE)
    VALUES (SOURCE_TABLE.CHANGE_TYPE, SOURCE_TABLE.CHANGE_TIMESTAMP, SOURCE_TABLE.CHANGE_USER_ID, SOURCE_TABLE.SNAPSHOT_TIMESTAMP, SOURCE_TABLE.TEAM_ID, SOURCE_TABLE.MEMBER_ID, SOURCE_TABLE.IS_ADMIN, SOURCE_TABLE.SNAPSHOT_DATE);

-- zero copy clone of processed access records
CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.PROCESSEDACCESS
CLONE
SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.PROCESSEDACCESS;
CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
CLONE SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.FILEDOWNLOAD;

CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEUPLOAD
CLONE SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.FILEUPLOAD;

-- zero copy clone of file download records
-- Only get the latest file download record for each user, file handle, and record date
-- since this is the closest estimate to download records
SELECT *
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.FILEDOWNLOAD
QUALIFY ROW_NUMBER() OVER (PARTITION BY USER_ID, FILE_HANDLE_ID, RECORD_DATE ORDER BY USER_ID, FILE_HANDLE_ID, RECORD_DATE) = 1;
