
USE ROLE SYSADMIN;
USE DATABASE SYNAPSE_DATA_WAREHOUSE;
USE SCHEMA SYNAPSE;

// GENIE
select genie."id", genie."name", genie."version", count(*) as number_of_downloads
from sage.portal_raw.genie genie
LEFT JOIN
    synapse_data_warehouse.synapse_raw.filedownload fd
ON
    genie."dataFileHandleId" = fd.file_handle_id
GROUP BY
    genie."id", genie."name", genie."version"
ORDER BY
    number_of_downloads DESC
;

// Download counts for AD files
select ad."id", ad."name", ad."study", count(*) as number_of_downloads
from sage.portal_raw.ad
LEFT JOIN
    synapse_data_warehouse.synapse_raw.filedownload fd
ON
    ad."dataFileHandleId" = fd.file_handle_id
GROUP BY
    ad."id", ad."name", ad."study"
ORDER BY
    number_of_downloads DESC
;
