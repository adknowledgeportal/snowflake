USE ROLE PUBLIC;
USE WAREHOUSE COMPUTE_ORG;
USE DATABASE SYNAPSE_DATA_WAREHOUSE;

-- Get distribution of file extensions
WITH FILE_EXTENSIONS AS (
    SELECT split_part(NAME, '.', -1) AS FILEEXT
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    WHERE
        NODE_TYPE NOT IN ('project', 'folder')
)

SELECT
    FILEEXT,
    count(*) AS NUMBER_OF_FILES
FROM FILE_EXTENSIONS
GROUP BY FILEEXT
ORDER BY NUMBER_OF_FILES DESC;

-- Summary statistic for files with mp4 extensions
-- Project Id
-- Is it public?
-- Is it controlled?
-- Is it restricted?
-- Number of mp4s
-- Total size in terabytes
WITH NODE_FILE_EXTENSIONS AS (
    SELECT
        ID,
        FILE_HANDLE_ID,
        PROJECT_ID,
        PARENT_ID,
        IS_PUBLIC,
        IS_CONTROLLED,
        IS_RESTRICTED,
        split_part(NAME, '.', -1) AS FILEEXT
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    WHERE
        FILEEXT ILIKE 'MP4'
        AND NODE_TYPE NOT IN ('project', 'folder')
),

FILE_SIZES AS (
    SELECT
        ID AS FD_FILE_HANDLE_ID,
        CONTENT_SIZE
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST
)

SELECT
    NODE_FILE_EXTENSIONS.PROJECT_ID,
    NODE_FILE_EXTENSIONS.IS_PUBLIC,
    NODE_FILE_EXTENSIONS.IS_CONTROLLED,
    NODE_FILE_EXTENSIONS.IS_RESTRICTED,
    count(*) AS NUMBER_OF_MP4S,
    sum(FILE_SIZES.CONTENT_SIZE) / power(2, 40) AS TOTAL_SIZE_IN_TERABYTES
FROM
    NODE_FILE_EXTENSIONS
LEFT JOIN
    FILE_SIZES
    ON
        NODE_FILE_EXTENSIONS.FILE_HANDLE_ID = FILE_SIZES.FD_FILE_HANDLE_ID
GROUP BY
    NODE_FILE_EXTENSIONS.PROJECT_ID,
    NODE_FILE_EXTENSIONS.IS_PUBLIC,
    NODE_FILE_EXTENSIONS.IS_CONTROLLED,
    NODE_FILE_EXTENSIONS.IS_RESTRICTED
ORDER BY
    NUMBER_OF_MP4S DESC;

-- Synapse file info
-- Number of nodes with file handle ids
-- and count of data size in terabytes
WITH FILE_STATS AS (
    SELECT
        NODE_LATEST.ID AS NODE_ID,
        NODE_LATEST.FILE_HANDLE_ID,
        FILE_LATEST.CONTENT_SIZE
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    INNER JOIN
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST
        ON
            NODE_LATEST.FILE_HANDLE_ID = FILE_LATEST.ID
)

SELECT
    count(*) AS NUMBER_OF_NODES,
    sum(CONTENT_SIZE) / power(2, 40) AS NUMBER_OF_TERABYTES
FROM
    FILE_STATS;

-- traffic via portals via "ORIGIN"> The host name of the portal making the request,
-- e.g., https://staging.synapse.org, https://adknowledgeportal.synapse.org,
-- https://dhealth.synapse.org.
SELECT
    ORIGIN,
    count(*) AS NUMBER_OF_REQUESTS,
    count(DISTINCT USER_ID) AS NUMBER_OF_UNIQUE_USERS
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE.PROCESSEDACCESS
WHERE
    ORIGIN LIKE '%synapse.org'
    AND ORIGIN NOT LIKE '%staging%'
    AND RECORD_DATE > '2023-01-01'
GROUP BY ORIGIN
ORDER BY NUMBER_OF_REQUESTS DESC;

-- Top downloaded public projects since 2022-01-01
WITH DEDUP_FILEHANDLE AS (
    SELECT DISTINCT
        USER_ID,
        FILE_HANDLE_ID AS FD_FILE_HANDLE_ID,
        RECORD_DATE,
        PROJECT_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
),

PUBLIC_PROJECTS AS (
    SELECT DISTINCT PROJECT_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    WHERE
        IS_PUBLIC
        AND NODE_TYPE = 'project'
)

SELECT
    'https://www.synapse.org/#!Synapse:syn'
    || cast(PROJECT_ID AS VARCHAR) AS PROJECT,
    count(*) AS DOWNLOADS_PER_PROJECT,
    count(DISTINCT USER_ID) AS NUMBER_OF_UNIQUE_USERS_DOWNLOADED,
    count(DISTINCT FD_FILE_HANDLE_ID) AS NUMBER_OF_UNIQUE_FILES_DOWNLOADED
FROM
    DEDUP_FILEHANDLE
WHERE
    PROJECT_ID IN (SELECT PROJECT_ID FROM PUBLIC_PROJECTS)
GROUP BY
    PROJECT_ID
ORDER BY
    DOWNLOADS_PER_PROJECT DESC;

-- Top downloaded public projects for September 2023
WITH DEDUP_FILEHANDLE AS (
    SELECT DISTINCT
        USER_ID,
        FILE_HANDLE_ID AS FD_FILE_HANDLE_ID,
        RECORD_DATE,
        PROJECT_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
    WHERE
        RECORD_DATE >= '2023-09-01' AND RECORD_DATE < '2023-10-01'
),

PUBLIC_PROJECTS AS (
    SELECT DISTINCT PROJECT_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    WHERE
        IS_PUBLIC
        AND NODE_TYPE = 'project'
)

SELECT
    'https://www.synapse.org/#!Synapse:syn'
    || cast(PROJECT_ID AS VARCHAR) AS PROJECT,
    count(*) AS DOWNLOADS_PER_PROJECT,
    count(DISTINCT USER_ID) AS NUMBER_OF_UNIQUE_USERS_DOWNLOADED,
    count(DISTINCT FD_FILE_HANDLE_ID) AS NUMBER_OF_UNIQUE_FILES_DOWNLOADED
FROM
    DEDUP_FILEHANDLE
WHERE
    PROJECT_ID IN (SELECT PROJECT_ID FROM PUBLIC_PROJECTS)
GROUP BY
    PROJECT_ID
ORDER BY
    DOWNLOADS_PER_PROJECT DESC;

-- Number of new certified users in September 2023
SELECT
    PASSED,
    count(*) AS NUMBER_OF_USERS
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE.CERTIFIEDQUIZ_LATEST
WHERE
    RECORD_DATE >= '2023-09-01'
    AND RECORD_DATE < '2023-10-01'
GROUP BY
    PASSED;

-- number of non-sage email users
WITH USER AS (
    SELECT ID AS PROFILE_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST
    WHERE
        EMAIL NOT LIKE '%@sagebase.org'
)

SELECT count(DISTINCT USER_ID)
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE.PROCESSEDACCESS
WHERE
    USER_ID IN (SELECT PROFILE_ID FROM USER)
    AND RECORD_DATE >= '2023-09-01'
    AND RECORD_DATE < '2023-10-01';

-- number of different governance types in synapse
-- and the size of those files
WITH FILE_FD AS (
    SELECT
        ID AS FILE_ID,
        CONTENT_SIZE
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST
)

SELECT
    NODE.IS_PUBLIC,
    NODE.IS_CONTROLLED,
    NODE.IS_RESTRICTED,
    count(*) AS NUMBER_OF_FILES,
    -- A terabyte is 2^40 bytes
    sum(FILE_FD.CONTENT_SIZE) / power(2, 40) AS TOTAL_SIZE_IN_TERABYTES
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST AS NODE
LEFT JOIN
    FILE_FD
    ON
        NODE.FILE_HANDLE_ID = FILE_FD.FILE_ID
WHERE
    NODE.NODE_TYPE = 'file'
GROUP BY
    NODE.IS_PUBLIC, NODE.IS_CONTROLLED, NODE.IS_RESTRICTED
ORDER BY
    NUMBER_OF_FILES DESC;

-- number of async calls to get DOIs
SELECT count(DISTINCT REQUEST_URL)
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE.PROCESSEDACCESS
WHERE
    NORMALIZED_METHOD_SIGNATURE = 'GET /doi/async/get/#'
    AND SUCCESS;

-- Distribution of API calls made by different clients
SELECT
    CLIENT,
    count(*) AS NUMBER_OF_CALLS
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE.PROCESSEDACCESS
GROUP BY
    CLIENT
ORDER BY
    NUMBER_OF_CALLS DESC;

-- The number of downloads ranked by users that downloaded the most to least
WITH DEDUP_FILEHANDLE AS (
    SELECT DISTINCT
        USER_ID,
        FILE_HANDLE_ID AS FD_FILE_HANDLE_ID,
        RECORD_DATE,
        PROJECT_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
),

USERS AS (
    SELECT
        ID,
        USER_NAME,
        LOCATION,
        COMPANY
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST
)

SELECT
    USERS.ID,
    USERS.USER_NAME,
    USERS.LOCATION,
    USERS.COMPANY,
    count(*) AS NUMBER_OF_DOWNLOADS
FROM
    DEDUP_FILEHANDLE
LEFT JOIN
    USERS
    ON
        DEDUP_FILEHANDLE.USER_ID = USERS.ID
GROUP BY
    USERS.ID, USERS.USER_NAME, USERS.LOCATION, USERS.COMPANY
ORDER BY
    NUMBER_OF_DOWNLOADS DESC;

-- locations based on what users put on their most current user profiles
-- NOTE: this does not mean the downloads have to happen
-- from that location, what users have in their user profile could
-- be wrong.
WITH DEDUP_FILEHANDLE AS (
    SELECT DISTINCT
        USER_ID,
        FILE_HANDLE_ID AS FD_FILE_HANDLE_ID,
        RECORD_DATE,
        PROJECT_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
),

USERS AS (
    SELECT
        ID,
        USER_NAME,
        LOCATION,
        COMPANY
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST
)

SELECT
    USERS.LOCATION,
    count(*) AS NUMBER_OF_DOWNLOADS
FROM
    DEDUP_FILEHANDLE
LEFT JOIN
    USERS
    ON
        DEDUP_FILEHANDLE.USER_ID = USERS.ID
GROUP BY
    USERS.LOCATION
ORDER BY
    NUMBER_OF_DOWNLOADS DESC;

-- Number of downloads
-- Number of unique files downloaded
-- Number of unique users downloaded
-- In the month of September 2023
WITH USER AS (
    SELECT ID AS PROFILE_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST
    WHERE
        EMAIL NOT LIKE '%@sagebase.org'
),

DEDUP_FILEHANDLE AS (
    SELECT DISTINCT
        USER_ID,
        FILE_HANDLE_ID AS FD_FILE_HANDLE_ID,
        RECORD_DATE
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
    WHERE
        RECORD_DATE >= '2023-09-01'
        AND RECORD_DATE < '2023-10-01'
)

SELECT
    count(*) AS NUMBER_OF_DOWNLOADS,
    count(DISTINCT FD_FILE_HANDLE_ID) AS NUMBER_OF_UNIQUE_FILES_DOWNLOADED,
    count(DISTINCT USER_ID) AS NUMBER_OF_UNIQUE_USERS_DOWNLOADED
FROM
    DEDUP_FILEHANDLE
WHERE
    USER_ID IN (SELECT PROFILE_ID FROM USER);

-- Number of users that downloaded data in September 2023
WITH USER AS (
    SELECT ID AS PROFILE_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST
    WHERE
        EMAIL NOT LIKE '%@sagebase.org'
)

SELECT count(DISTINCT USER_ID)
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE.PROCESSEDACCESS
WHERE
    USER_ID IN (SELECT PROFILE_ID FROM USER)
    AND RECORD_DATE >= '2023-09-01'
    AND RECORD_DATE < '2023-10-01';

-- Number of all time synapse users
WITH USER AS (
    SELECT ID AS PROFILE_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST
    WHERE
        EMAIL NOT LIKE '%@sagebase.org'
)

SELECT count(DISTINCT USER_ID)
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE.PROCESSEDACCESS
WHERE
    USER_ID IN (SELECT PROFILE_ID FROM USER);

-- public project all time download activity
-- Top downloaded public projects for September 2023

WITH DEDUP_FILEHANDLE AS (
    SELECT DISTINCT
        USER_ID,
        FILE_HANDLE_ID AS FD_FILE_HANDLE_ID,
        RECORD_DATE,
        PROJECT_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
),

PUBLIC_PROJECTS AS (
    SELECT DISTINCT PROJECT_ID
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    WHERE
        IS_PUBLIC
        AND NODE_TYPE = 'project'
)

SELECT
    'https://www.synapse.org/#!Synapse:syn'
    || cast(PROJECT_ID AS VARCHAR) AS PROJECT,
    count(*) AS DOWNLOADS_PER_PROJECT,
    count(DISTINCT USER_ID) AS NUMBER_OF_UNIQUE_USERS_DOWNLOADED,
    count(DISTINCT FD_FILE_HANDLE_ID) AS NUMBER_OF_UNIQUE_FILES_DOWNLOADED
FROM
    DEDUP_FILEHANDLE
WHERE
    PROJECT_ID IN (SELECT PROJECT_ID FROM PUBLIC_PROJECTS)
GROUP BY
    PROJECT_ID
ORDER BY
    DOWNLOADS_PER_PROJECT DESC;

-- Synapse file info
WITH FILE_STATS AS (
    SELECT
        NODE_LATEST.ID AS NODE_ID,
        NODE_LATEST.FILE_HANDLE_ID,
        FILE_LATEST.CONTENT_SIZE
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    INNER JOIN
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST
        ON
            NODE_LATEST.FILE_HANDLE_ID = FILE_LATEST.ID
)

SELECT
    count(*) AS NUMBER_OF_NODES,
    sum(CONTENT_SIZE) / power(2, 40) AS NUMBER_OF_TERABYTES
FROM
    FILE_STATS;

-- File handle status
-- This may contain file handles that are different versions
-- or unlinked from nodes that currently exist in Synapse
SELECT
    STATUS,
    count(*) AS NUMBER_OF_FILES,
    sum(CONTENT_SIZE) / power(2, 40) AS NUMBER_OF_TERABYTES
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST
GROUP BY
    STATUS
ORDER BY
    NUMBER_OF_FILES DESC;

-- storage bucket summary
WITH FILE_STATS AS (
    SELECT
        NODE_LATEST.ID AS NODE_ID,
        NODE_LATEST.FILE_HANDLE_ID,
        FILE_LATEST.CONTENT_SIZE,
        FILE_LATEST.BUCKET
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    INNER JOIN
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST
        ON
            NODE_LATEST.FILE_HANDLE_ID = FILE_LATEST.ID
)

SELECT
    BUCKET,
    count(*) AS NUMBER_OF_FILES,
    sum(CONTENT_SIZE) / power(2, 40) AS NUMBER_OF_TERABYTES
FROM
    FILE_STATS
GROUP BY
    BUCKET
ORDER BY
    NUMBER_OF_TERABYTES DESC;

-- Top 1000 projects based on storage usage
-- Note: some projects have both private and public files...
WITH FILE_STATS AS (
    SELECT
        NODE_LATEST.ID AS NODE_ID,
        NODE_LATEST.FILE_HANDLE_ID,
        NODE_LATEST.PROJECT_ID,
        NODE_LATEST.IS_PUBLIC,
        FILE_LATEST.CONTENT_SIZE,
        FILE_LATEST.BUCKET
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    INNER JOIN
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST
        ON
            NODE_LATEST.FILE_HANDLE_ID = FILE_LATEST.ID
)

SELECT
    BUCKET,
    IS_PUBLIC,
    'https://www.synapse.org/#!Synapse:syn'
    || cast(PROJECT_ID AS VARCHAR) AS PROJECT,
    count(*) AS NUMBER_OF_FILES,
    sum(CONTENT_SIZE) / power(2, 40) AS NUMBER_OF_TERABYTES
FROM
    FILE_STATS
GROUP BY
    PROJECT_ID, BUCKET, IS_PUBLIC
ORDER BY
    NUMBER_OF_TERABYTES DESC
    NULLS LAST
LIMIT 1000;

-- Public data on proddate.sagebase.org
WITH FILE_STATS AS (
    SELECT
        NODE_LATEST.ID AS NODE_ID,
        NODE_LATEST.FILE_HANDLE_ID,
        NODE_LATEST.PROJECT_ID,
        FILE_LATEST.CONTENT_SIZE
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    INNER JOIN
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST
        ON
            NODE_LATEST.FILE_HANDLE_ID = FILE_LATEST.ID
    WHERE
        NODE_LATEST.IS_PUBLIC
        AND FILE_LATEST.BUCKET = 'proddata.sagebase.org'
)

SELECT
    'https://www.synapse.org/#!Synapse:syn'
    || cast(PROJECT_ID AS VARCHAR) AS PROJECT,
    count(*) AS NUMBER_OF_FILES,
    sum(CONTENT_SIZE) / power(2, 40) AS NUMBER_OF_TERABYTES
FROM
    FILE_STATS
GROUP BY
    PROJECT_ID
ORDER BY
    NUMBER_OF_TERABYTES DESC
    NULLS LAST;

-- Data uploads per user per day
WITH DATA_UPLOADS AS (
    SELECT
        UPL.ID,
        UPL.USER_NAME,
        FU.RECORD_DATE,
        FL.CONTENT_SIZE
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEUPLOAD AS FU
    LEFT JOIN
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST AS UPL
        ON FU.USER_ID = UPL.ID
    INNER JOIN
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST AS FL
        ON FU.FILE_HANDLE_ID = FL.ID
)

SELECT
    ID,
    USER_NAME,
    RECORD_DATE,
    sum(CONTENT_SIZE) AS UPLOAD_SIZE_IN_BYTES
FROM DATA_UPLOADS
GROUP BY ID, USER_NAME, RECORD_DATE;

-- The query first defines a CTE called data_uploads that joins the userprofile_latest,
-- FILEUPLOAD, and FILE_LATEST tables to get the content size of each file
-- uploaded by each user.
-- Then, the query defines another CTE called average_per_user that calculates
-- the total upload size and average upload size per user.
-- Finally, the query calculates the overall average upload size per user in bytes
-- and gigabytes by taking the sum of the average upload size per user and
-- dividing it by the count of users.
WITH DATA_UPLOADS AS (
    SELECT
        UPL.ID,
        UPL.USER_NAME,
        FU.RECORD_DATE,
        FL.CONTENT_SIZE
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEUPLOAD AS FU
    LEFT JOIN
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST AS UPL
        ON FU.USER_ID = UPL.ID
    INNER JOIN
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST AS FL
        ON FU.FILE_HANDLE_ID = FL.ID
),

AVERAGE_PER_USER AS (
    SELECT
        ID,
        USER_NAME,
        sum(CONTENT_SIZE) AS UPLOAD_SIZE_IN_BYTES,
        UPLOAD_SIZE_IN_BYTES / count(*) AS AVERAGE_UPLOAD_SIZE_IN_BYTES
    FROM
        DATA_UPLOADS
    GROUP BY
        ID, USER_NAME
)

SELECT
    sum(AVERAGE_UPLOAD_SIZE_IN_BYTES) / count(*) AS AVERAGE_UPLOAD_PER_USER_IN_BYTES,
    AVERAGE_UPLOAD_PER_USER_IN_BYTES / power(2, 30) AS AVERAGE_UPLOAD_PER_USER_IN_GIGABYTES
FROM
    AVERAGE_PER_USER;
