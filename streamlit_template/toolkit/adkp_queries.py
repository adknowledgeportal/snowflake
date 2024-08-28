def query_project_summary(synapse_id=2580853):
    """Returns the number of files for a given project (synapse_id)."""

    return f"""
    SELECT
        COUNT(DISTINCT(FILE_LATEST.ID)) AS TOTAL_FILES,
        ROUND(SUM(FILE_LATEST.CONTENT_SIZE) / POWER(2, 40), 2) AS TOTAL_SIZE_IN_TB,
        ROUND(SUM(FILE_LATEST.CONTENT_SIZE) / POWER(2, 30) * 0.023 * 12, 2) AS STORAGE_COST_PER_YEAR
    FROM
        SYNAPSE_DATA_WAREHOUSE.FILE_LATEST
    JOIN
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
        ON FILE_LATEST.ID = NODE_LATEST.FILE_HANDLE_ID
    WHERE
        NODE_LATEST.PROJECT_ID = {synapse_id};
    """

def a_different_query():
    return "stuff"

def query_monthly_downloads_per_study(study):
    """Return the number of monthly unique users for each ADKP study."""

    #return f"""
    return "stuff"
    # WITH NODE_ANNOTATIONS AS (
    #     SELECT
    #         FILE_HANDLE_ID,
    #         ANNOTATIONS:ANNOTATIONS:STUDY:VALUE[0]::STRING AS STUDY,
    #     FROM
    #         SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST
    #     WHERE
    #         PROJECT_ID IN (
    #             2580853
    #         )
    # ), DEDUP_DOWNLOADS AS (
    #     SELECT
    #         DISTINCT FILEDOWNLOAD.USER_ID, FILEDOWNLOAD.RECORD_DATE, FILEDOWNLOAD.FILE_HANDLE_ID, NODE_ANNOTATIONS.STUDY
    #     FROM
    #         SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
    #     INNER JOIN
    #         NODE_ANNOTATIONS
    #     ON
    #         FILEDOWNLOAD.FILE_HANDLE_ID = NODE_ANNOTATIONS.FILE_HANDLE_ID
            
    # ), FILE_SIZE AS(
    #     SELECT
    #         ID,
    #         CONTENT_SIZE  
    #     FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST
    # )
    # SELECT
    #     STUDY,
    #     DATE_TRUNC('MONTH', RECORD_DATE) AS MONTH,
    #     COUNT(RECORD_DATE) AS NUMBER_OF_DOWNLOADS,
    #     COUNT(DISTINCT DEDUP_DOWNLOADS.USER_ID) AS NUMBER_OF_UNIQUE_USERS,
    #     ROUND(SUM(FILE_SIZE.CONTENT_SIZE) / POWER(2, 30), 2) AS GIB_DOWNLOADED
    # FROM
    #     DEDUP_DOWNLOADS
    # LEFT JOIN
    #     FILE_SIZE
    # ON
    #     DEDUP_DOWNLOADS.FILE_HANDLE_ID = FILE_SIZE.ID
    # WHERE STUDY IS NOT NULL
    # GROUP BY
    #     MONTH, STUDY
    # ORDER BY
    #     MONTH DESC, NUMBER_OF_UNIQUE_USERS DESC, STUDY DESC;
    # """
