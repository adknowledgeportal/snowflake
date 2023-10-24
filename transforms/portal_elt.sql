USE ROLE SYSADMIN;
USE DATABASE SAGE;
USE SCHEMA PORTAL_RAW;

CREATE OR REPLACE VIEW SAGE.PORTAL_RAW.PORTAL_MERGE AS (
    SELECT
        "id",
        'ad' AS PORTAL,
        "name",
        "study",
        "dataType",
        "assay",
        "organ",
        "tissue",
        "species",
        "sex",
        "consortium",
        "grant",
        "modelSystemName",
        "treatmentType",
        TO_VARIANT(ARRAY_CONSTRUCT("specimenID")) AS "specimenID",
        "individualID",
        "individualIdSource",
        "specimenIdSource",
        "resourceType",
        "dataSubtype",
        "metadataType",
        "assayTarget",
        "analysisType",
        "cellType",
        "nucleicAcidSource",
        "fileFormat",
        "group",
        "isModelSystem",
        "isConsortiumAnalysis",
        "isMultiSpecimen",
        TO_TIMESTAMP_NTZ("createdOn" / 1000) AS "createdOn",
        "createdBy",
        "parentId",
        "currentVersion",
        "benefactorId",
        "projectId",
        "modifiedOn",
        "modifiedBy",
        "dataFileHandleId",
        "metaboliteType",
        "chromosome",
        "modelSystemType",
        "libraryPrep",
        "dataFileSizeBytes",
        -- ELITE
        NULL AS "type",
        NULL AS "consent",
        NULL AS "libraryType",
        NULL AS "platform",
        NULL AS "project",
        NULL AS "etag",
        -- NF
        NULL AS "isMultiIndividual",
        NULL AS "diagnosis",
        NULL AS "tumorType",
        NULL AS "fundingAgency",
        NULL AS "nf1Genotype",
        NULL AS "nf2Genotype",
        NULL AS "isCellLine",
        NULL AS "studyId",
        NULL AS "age",
        NULL AS "readPair",
        NULL AS "accessType",
        NULL AS "accessTeam",
        NULL AS "modelOf",
        NULL AS "compoundName",
        NULL AS "experimentalCondition",
        NULL AS "isXenograft",
        NULL AS "transplantationType",
        NULL AS "isPairedEnd",
        NULL AS "isStranded",
        NULL AS "libraryPreparationMethod",
        NULL AS "initiative",
        NULL AS "progressReportNumber",
        NULL AS "Resource_id",
        NULL AS "genePerturbationType",
        NULL AS "genePerturbationMethod",
        NULL AS "genePerturbed",
        NULL AS "contentType",
        -- psych only
        NULL AS "referenceSet",
        NULL AS "processing",
        NULL AS "Contributor",
        NULL AS "PI",
        NULL AS "BrodmannArea",
        NULL AS "PMI",
        NULL AS "pH",
        NULL AS "RIN",
        NULL AS "reprogrammedCellType",
        NULL AS "terminalDifferentiationPoint",
        NULL AS "passage",
        NULL AS "runType",
        NULL AS "readEnd",
        NULL AS "rnaBatch",
        NULL AS "transposaseBatch",
        NULL AS "libraryBatch",
        NULL AS "alignmentMethod",
        NULL AS "meanCoverage",
        NULL AS "meanGCContent",
        NULL AS "failedQC"
    FROM
        AD
    UNION ALL
    SELECT
        "id",
        'elite' AS PORTAL,
        "name",
        TO_VARIANT(ARRAY_CONSTRUCT("study")) AS "study",
        TO_VARIANT(ARRAY_CONSTRUCT("dataType")) AS "dataType",
        TO_VARIANT(ARRAY_CONSTRUCT("assay")) AS "assay",
        NULL AS "organ",
        NULL AS "tissue",
        TO_VARIANT(ARRAY_CONSTRUCT("species")) AS "species",
        NULL AS "sex",
        "consortium",
        TO_VARIANT(ARRAY_CONSTRUCT("grant")) AS "grant",
        NULL AS "modelSystemName",
        NULL AS "treatmentType",
        NULL AS "specimenID",
        NULL AS "individualID",
        NULL AS "individualIdSource",
        NULL AS "specimenIdSource",
        "resourceType",
        CAST("dataSubtype" AS VARCHAR) AS "dataSubtype",
        "metadataType",
        NULL AS "assayTarget",
        "analysisType",
        NULL AS "cellType",
        NULL AS "nucleicAcidSource",
        "fileFormat",
        NULL AS "group",
        "isModelSystem",
        "isConsortiumAnalysis",
        "isMultiSpecimen",
        NULL AS "createdOn",
        NULL AS "createdBy",
        NULL AS "parentId",
        "currentVersion",
        NULL AS "benefactorId",
        NULL AS "projectId",
        NULL AS "modifiedOn",
        NULL AS "modifiedBy",
        NULL AS "dataFileHandleId",
        NULL AS "metaboliteType",
        NULL AS "chromosome",
        CAST("modelSystemType" AS VARCHAR) AS "modelSystemType",
        CAST("libraryPrep" AS VARCHAR) AS "libraryPrep",
        NULL AS "dataFileSizeBytes",
        "type",
        "consent",
        "libraryType",
        CAST("platform" AS VARCHAR) AS "platform",
        "project",
        "etag",
        -- NF
        NULL AS "isMultiIndividual",
        NULL AS "diagnosis",
        NULL AS "tumorType",
        NULL AS "fundingAgency",
        NULL AS "nf1Genotype",
        NULL AS "nf2Genotype",
        NULL AS "isCellLine",
        NULL AS "studyId",
        NULL AS "age",
        NULL AS "readPair",
        NULL AS "accessType",
        NULL AS "accessTeam",
        NULL AS "modelOf",
        NULL AS "compoundName",
        NULL AS "experimentalCondition",
        NULL AS "isXenograft",
        NULL AS "transplantationType",
        NULL AS "isPairedEnd",
        NULL AS "isStranded",
        NULL AS "libraryPreparationMethod",
        NULL AS "initiative",
        NULL AS "progressReportNumber",
        NULL AS "Resource_id",
        NULL AS "genePerturbationType",
        NULL AS "genePerturbationMethod",
        NULL AS "genePerturbed",
        NULL AS "contentType",
        -- psych only
        NULL AS "referenceSet",
        NULL AS "processing",
        NULL AS "Contributor",
        NULL AS "PI",
        NULL AS "BrodmannArea",
        NULL AS "PMI",
        NULL AS "pH",
        NULL AS "RIN",
        NULL AS "reprogrammedCellType",
        NULL AS "terminalDifferentiationPoint",
        NULL AS "passage",
        NULL AS "runType",
        NULL AS "readEnd",
        NULL AS "rnaBatch",
        NULL AS "transposaseBatch",
        NULL AS "libraryBatch",
        NULL AS "alignmentMethod",
        NULL AS "meanCoverage",
        NULL AS "meanGCContent",
        NULL AS "failedQC"
    FROM
        ELITE
    UNION ALL
    SELECT
        "id",
        'NF' AS PORTAL,
        "name",
        TO_VARIANT(ARRAY_CONSTRUCT("studyName")) AS "study",
        TO_VARIANT(ARRAY_CONSTRUCT("dataType")) AS "dataType",
        TO_VARIANT(ARRAY_CONSTRUCT("assay")) AS "assay",
        NULL AS "organ",
        TO_VARIANT(ARRAY_CONSTRUCT("tissue")) AS "tissue",
        TO_VARIANT(ARRAY_CONSTRUCT("species")) AS "species",
        TO_VARIANT(ARRAY_CONSTRUCT("sex")) AS "sex",
        "consortium",
        NULL AS "grant",
        TO_VARIANT(ARRAY_CONSTRUCT("modelSystemName")) AS "modelSystemName",
        NULL AS "treatmentType",
        "specimenID",
        "individualID",
        NULL AS "individualIdSource",
        NULL AS "specimenIdSource",
        "resourceType",
        "dataSubtype",
        NULL AS "metadataType",
        NULL AS "assayTarget",
        NULL AS "analysisType",
        TO_VARIANT(ARRAY_CONSTRUCT("cellType")) AS "cellType",
        NULL AS "nucleicAcidSource",
        "fileFormat",
        NULL AS "group",
        NULL AS "isModelSystem",
        NULL AS "isConsortiumAnalysis",
        TO_BOOLEAN("isMultiSpecimen") AS "isMultiSpecimen", --convert to Bool VARCHAR(16777216),
        TO_TIMESTAMP_NTZ("createdOn" / 1000) AS "createdOn",
        "createdBy",
        "parentId",
        NULL AS "currentVersion",
        "benefactorId",
        "projectId",
        "modifiedOn", -- these should be timestamp
        "modifiedBy",
        NULL AS "dataFileHandleId",
        NULL AS "metaboliteType",
        NULL AS "chromosome",
        NULL AS "modelSystemType",
        "libraryPrep",
        "dataFileSizeBytes",
        "type",
        NULL AS "consent",
        NULL AS "libraryType",
        "platform", -- cast this to string elsewhere VARCHAR(16777216),
        NULL AS "project",
        "etag",
        -- NF only
        TO_BOOLEAN("isMultiIndividual") AS "isMultiIndividual", -- converting VARCHAR(16777216),
        "diagnosis", --Add new VARIANT
        "tumorType", -- add new  VARIANT,
        "fundingAgency", -- add new varchar,
        "nf1Genotype", -- add new VARCHAR(16777216),
        "nf2Genotype", -- add new VARCHAR(16777216),
        "isCellLine", -- add new VARCHAR(16777216),
        "studyId", -- add new VARCHAR(16777216),
        "age", -- add new VARCHAR(16777216), (why is this a string)
        "readPair", -- add new FLOAT,
        "accessType", -- add new VARCHAR(16777216),
        "accessTeam", -- add new FLOAT,
        "modelOf", -- add new VARCHAR(16777216),
        "compoundName", --add new VARCHAR(16777216),
        "experimentalCondition", --add new VARCHAR(16777216),
        "isXenograft", -- add new VARCHAR(16777216), why str
        "transplantationType", -- add new VARCHAR(16777216),
        "isPairedEnd", -- add new VARCHAR(16777216), why str?
        "isStranded", -- add new VARCHAR(16777216), why str?
        "libraryPreparationMethod", -- add new VARCHAR(16777216), is this the same as libraryType
        "initiative", -- new column VARCHAR(16777216),
        "progressReportNumber", -- add new FLOAT,
        "Resource_id", --add new variant,
        "genePerturbationType", -- ad new VARCHAR(16777216),
        "genePerturbationMethod", -- add new NUMBER(38,0),
        "genePerturbed", --add new VARCHAR(16777216),
        "contentType", -- add new VARCHAR(16777216),
        -- psych only
        NULL AS "referenceSet",
        NULL AS "processing",
        NULL AS "Contributor",
        NULL AS "PI",
        NULL AS "BrodmannArea",
        NULL AS "PMI",
        NULL AS "pH",
        NULL AS "RIN",
        NULL AS "reprogrammedCellType",
        NULL AS "terminalDifferentiationPoint",
        NULL AS "passage",
        NULL AS "runType",
        NULL AS "readEnd",
        NULL AS "rnaBatch",
        NULL AS "transposaseBatch",
        NULL AS "libraryBatch",
        NULL AS "alignmentMethod",
        NULL AS "meanCoverage",
        NULL AS "meanGCContent",
        NULL AS "failedQC"
    FROM
        NF
    UNION ALL
    SELECT
        "id",
        'psychencode' AS PORTAL,
        "name",
        "study", --VARIANT
        "dataType", --VARIANT
        TO_VARIANT(ARRAY_CONSTRUCT("assay")) AS "assay",
        "organ",
        TO_VARIANT(ARRAY_CONSTRUCT("tissue")) AS "tissue",
        TO_VARIANT(ARRAY_CONSTRUCT("species")) AS "species",
        NULL AS "sex",
        NULL AS "consortium",
        NULL AS "grant",
        NULL AS "modelSystemName",
        NULL AS "treatmentType",
        "specimenID", --VARIANT
        "individualID",
        CAST("individualIDSource" AS VARCHAR) AS "individualIdSource",
        "specimenIDSource" AS "specimenIdSource",
        "resourceType",
        "dataSubtype",
        "metadataType",
        "assayTarget",
        NULL AS "analysisType",
        "cellType", --VARIANT
        "nucleicAcidSource",
        "fileFormat",
        NULL AS "group",
        NULL AS "isModelSystem",
        NULL AS "isConsortiumAnalysis",
        "isMultiSpecimen",
        TO_TIMESTAMP_NTZ("createdOn" / 1000) AS "createdOn",
        "createdBy",
        "parentId",
        "currentVersion",
        "benefactorId",
        NULL AS "projectId",
        "modifiedOn",
        "modifiedBy",
        "dataFileHandleId",
        NULL AS "metaboliteType",
        NULL AS "chromosome",
        NULL AS "modelSystemType",
        "libraryPrep",
        "dataFileSizeBytes",
        -- ELITE
        NULL AS "type",
        NULL AS "consent",
        NULL AS "libraryType",
        "platform",
        NULL AS "project",
        "etag",
        -- NF
        NULL AS "isMultiIndividual",
        NULL AS "diagnosis",
        NULL AS "tumorType",
        NULL AS "fundingAgency",
        NULL AS "nf1Genotype",
        NULL AS "nf2Genotype",
        NULL AS "isCellLine",
        NULL AS "studyId",
        NULL AS "age",
        NULL AS "readPair",
        NULL AS "accessType",
        NULL AS "accessTeam",
        NULL AS "modelOf",
        NULL AS "compoundName",
        NULL AS "experimentalCondition",
        NULL AS "isXenograft",
        NULL AS "transplantationType",
        NULL AS "isPairedEnd",
        "isStranded",
        "libraryPreparationMethod",
        NULL AS "initiative",
        NULL AS "progressReportNumber",
        NULL AS "Resource_id",
        NULL AS "genePerturbationType",
        NULL AS "genePerturbationMethod",
        NULL AS "genePerturbed",
        NULL AS "contentType",
        -- psyehencode only
        "referenceSet",
        "processing",
        "Contributor",
        "PI",
        "BrodmannArea",
        "PMI",
        "pH",
        "RIN",
        "reprogrammedCellType",
        "terminalDifferentiationPoint",
        "passage",
        "runType",
        "readEnd",
        "rnaBatch",
        "transposaseBatch",
        "libraryBatch",
        "alignmentMethod",
        "meanCoverage",
        "meanGCContent",
        "failedQC"
    FROM
        PSYCHENCODE

);

DESCRIBE TABLE PORTAL_MERGE;
SELECT *
FROM
    SAGE.PORTAL_RAW.PORTAL_MERGE;

SELECT
    "dataType",
    COUNT(*) AS NUMBER_OF_FILES
FROM
    SAGE.PORTAL_RAW.PORTAL_MERGE
GROUP BY
    "dataType"
ORDER BY
    NUMBER_OF_FILES DESC;

-- Of the files with missing data types, how many also have missing assays
WITH FLATTEN_DATATYPE AS (
    SELECT
        PORTAL_MERGE.*,
        FLATTENED.VALUE AS SINGLE_DATATYPE
    FROM
        SAGE.PORTAL_RAW.PORTAL_MERGE,
        LATERAL FLATTEN("dataType", OUTER => TRUE) AS FLATTENED
)

SELECT COUNT_IF("assay" = []) AS NUMBER_OF_MISSING_ASSAYS
FROM
    FLATTEN_DATATYPE
WHERE
    SINGLE_DATATYPE IS NULL;


-- Get all null values of the portal
with null_counts as (
SELECT column_name, null_count
FROM (
  SELECT
    SUM(CASE WHEN "PMI" IS NULL THEN 1 ELSE 0 END) AS PMI_null_count,
    SUM(CASE WHEN "diagnosis" IS NULL THEN 1 ELSE 0 END) AS diagnosis_null_count,
    SUM(CASE WHEN "fileFormat" IS NULL THEN 1 ELSE 0 END) AS fileFormat_null_count,
    SUM(CASE WHEN "nf2Genotype" IS NULL THEN 1 ELSE 0 END) AS nf2Genotype_null_count,
    SUM(CASE WHEN "createdOn" IS NULL THEN 1 ELSE 0 END) AS createdOn_null_count,
    SUM(CASE WHEN "currentVersion" IS NULL THEN 1 ELSE 0 END) AS currentVersion_null_count,
    SUM(CASE WHEN "studyId" IS NULL THEN 1 ELSE 0 END) AS studyId_null_count,
    SUM(CASE WHEN "chromosome" IS NULL THEN 1 ELSE 0 END) AS chromosome_null_count,
    SUM(CASE WHEN "modifiedBy" IS NULL THEN 1 ELSE 0 END) AS modifiedBy_null_count,
    SUM(CASE WHEN "isStranded" IS NULL THEN 1 ELSE 0 END) AS isStranded_null_count,
    SUM(CASE WHEN "cellType" IS NULL THEN 1 ELSE 0 END) AS cellType_null_count,
    SUM(CASE WHEN "isMultiSpecimen" IS NULL THEN 1 ELSE 0 END) AS isMultiSpecimen_null_count,
    SUM(CASE WHEN "specimenID" IS NULL THEN 1 ELSE 0 END) AS specimenID_null_count,
    SUM(CASE WHEN "name" IS NULL THEN 1 ELSE 0 END) AS name_null_count,
    SUM(CASE WHEN "sex" IS NULL THEN 1 ELSE 0 END) AS sex_null_count,
    SUM(CASE WHEN "type" IS NULL THEN 1 ELSE 0 END) AS type_null_count,
    SUM(CASE WHEN "isCellLine" IS NULL THEN 1 ELSE 0 END) AS isCellLine_null_count,
    SUM(CASE WHEN "alignmentMethod" IS NULL THEN 1 ELSE 0 END) AS alignmentMethod_null_count,
    SUM(CASE WHEN "Resource_id" IS NULL THEN 1 ELSE 0 END) AS Resource_id_null_count,
    SUM(CASE WHEN "nf1Genotype" IS NULL THEN 1 ELSE 0 END) AS nf1Genotype_null_count,
    SUM(CASE WHEN "dataFileSizeBytes" IS NULL THEN 1 ELSE 0 END) AS dataFileSizeBytes_null_count,
    SUM(CASE WHEN "dataFileHandleId" IS NULL THEN 1 ELSE 0 END) AS dataFileHandleId_null_count,
    SUM(CASE WHEN "individualID" IS NULL THEN 1 ELSE 0 END) AS individualID_null_count,
    SUM(CASE WHEN "processing" IS NULL THEN 1 ELSE 0 END) AS processing_null_count,
    SUM(CASE WHEN "libraryBatch" IS NULL THEN 1 ELSE 0 END) AS libraryBatch_null_count,
    SUM(CASE WHEN "progressReportNumber" IS NULL THEN 1 ELSE 0 END) AS progressReportNumber_null_count,
    SUM(CASE WHEN "treatmentType" IS NULL THEN 1 ELSE 0 END) AS treatmentType_null_count,
    SUM(CASE WHEN "createdBy" IS NULL THEN 1 ELSE 0 END) AS createdBy_null_count,
    SUM(CASE WHEN "platform" IS NULL THEN 1 ELSE 0 END) AS platform_null_count,
    SUM(CASE WHEN "pH" IS NULL THEN 1 ELSE 0 END) AS pH_null_count,
    SUM(CASE WHEN "referenceSet" IS NULL THEN 1 ELSE 0 END) AS referenceSet_null_count,
    SUM(CASE WHEN "metadataType" IS NULL THEN 1 ELSE 0 END) AS metadataType_null_count,
    SUM(CASE WHEN "id" IS NULL THEN 1 ELSE 0 END) AS id_null_count,
    SUM(CASE WHEN "terminalDifferentiationPoint" IS NULL THEN 1 ELSE 0 END) AS terminalDifferentiationPoint_null_count,
    SUM(CASE WHEN "tumorType" IS NULL THEN 1 ELSE 0 END) AS tumorType_null_count,
    SUM(CASE WHEN "consent" IS NULL THEN 1 ELSE 0 END) AS consent_null_count,
    SUM(CASE WHEN "etag" IS NULL THEN 1 ELSE 0 END) AS etag_null_count,
    SUM(CASE WHEN "fundingAgency" IS NULL THEN 1 ELSE 0 END) AS fundingAgency_null_count,
    SUM(CASE WHEN "age" IS NULL THEN 1 ELSE 0 END) AS age_null_count,
    SUM(CASE WHEN "PORTAL" IS NULL THEN 1 ELSE 0 END) AS PORTAL_null_count,
    SUM(CASE WHEN "parentId" IS NULL THEN 1 ELSE 0 END) AS parentId_null_count,
    SUM(CASE WHEN "species" IS NULL THEN 1 ELSE 0 END) AS species_null_count,
    SUM(CASE WHEN "modelSystemName" IS NULL THEN 1 ELSE 0 END) AS modelSystemName_null_count,
    SUM(CASE WHEN "failedQC" IS NULL THEN 1 ELSE 0 END) AS failedQC_null_count,
    SUM(CASE WHEN "modelSystemType" IS NULL THEN 1 ELSE 0 END) AS modelSystemType_null_count,
    SUM(CASE WHEN "analysisType" IS NULL THEN 1 ELSE 0 END) AS analysisType_null_count,
    SUM(CASE WHEN "Contributor" IS NULL THEN 1 ELSE 0 END) AS Contributor_null_count,
    SUM(CASE WHEN "libraryPreparationMethod" IS NULL THEN 1 ELSE 0 END) AS libraryPreparationMethod_null_count,
    SUM(CASE WHEN "modifiedOn" IS NULL THEN 1 ELSE 0 END) AS modifiedOn_null_count,
    SUM(CASE WHEN "study" IS NULL THEN 1 ELSE 0 END) AS study_null_count,
    SUM(CASE WHEN "accessTeam" IS NULL THEN 1 ELSE 0 END) AS accessTeam_null_count,
    SUM(CASE WHEN "assay" IS NULL THEN 1 ELSE 0 END) AS assay_null_count,
    SUM(CASE WHEN "genePerturbationType" IS NULL THEN 1 ELSE 0 END) AS genePerturbationType_null_count,
    SUM(CASE WHEN "BrodmannArea" IS NULL THEN 1 ELSE 0 END) AS BrodmannArea_null_count,
    SUM(CASE WHEN "experimentalCondition" IS NULL THEN 1 ELSE 0 END) AS experimentalCondition_null_count,
    SUM(CASE WHEN "genePerturbed" IS NULL THEN 1 ELSE 0 END) AS genePerturbed_null_count,
    SUM(CASE WHEN "grant" IS NULL THEN 1 ELSE 0 END) AS grant_null_count,
    SUM(CASE WHEN "isPairedEnd" IS NULL THEN 1 ELSE 0 END) AS isPairedEnd_null_count,
    SUM(CASE WHEN "contentType" IS NULL THEN 1 ELSE 0 END) AS contentType_null_count,
    SUM(CASE WHEN "runType" IS NULL THEN 1 ELSE 0 END) AS runType_null_count,
    SUM(CASE WHEN "assayTarget" IS NULL THEN 1 ELSE 0 END) AS assayTarget_null_count,
    SUM(CASE WHEN "readPair" IS NULL THEN 1 ELSE 0 END) AS readPair_null_count,
    SUM(CASE WHEN "meanCoverage" IS NULL THEN 1 ELSE 0 END) AS meanCoverage_null_count,
    SUM(CASE WHEN "transposaseBatch" IS NULL THEN 1 ELSE 0 END) AS transposaseBatch_null_count,
    SUM(CASE WHEN "compoundName" IS NULL THEN 1 ELSE 0 END) AS compoundName_null_count,
    SUM(CASE WHEN "modelOf" IS NULL THEN 1 ELSE 0 END) AS modelOf_null_count,
    SUM(CASE WHEN "individualIdSource" IS NULL THEN 1 ELSE 0 END) AS individualIdSource_null_count,
    SUM(CASE WHEN "initiative" IS NULL THEN 1 ELSE 0 END) AS initiative_null_count,
    SUM(CASE WHEN "isModelSystem" IS NULL THEN 1 ELSE 0 END) AS isModelSystem_null_count,
    SUM(CASE WHEN "organ" IS NULL THEN 1 ELSE 0 END) AS organ_null_count,
    SUM(CASE WHEN "metaboliteType" IS NULL THEN 1 ELSE 0 END) AS metaboliteType_null_count,
    SUM(CASE WHEN "dataSubtype" IS NULL THEN 1 ELSE 0 END) AS dataSubtype_null_count,
    SUM(CASE WHEN "PI" IS NULL THEN 1 ELSE 0 END) AS PI_null_count,
    SUM(CASE WHEN "dataType" IS NULL THEN 1 ELSE 0 END) AS dataType_null_count,
    SUM(CASE WHEN "RIN" IS NULL THEN 1 ELSE 0 END) AS RIN_null_count,
    SUM(CASE WHEN "project" IS NULL THEN 1 ELSE 0 END) AS project_null_count,
    SUM(CASE WHEN "isConsortiumAnalysis" IS NULL THEN 1 ELSE 0 END) AS isConsortiumAnalysis_null_count,
    SUM(CASE WHEN "reprogrammedCellType" IS NULL THEN 1 ELSE 0 END) AS reprogrammedCellType_null_count,
    SUM(CASE WHEN "benefactorId" IS NULL THEN 1 ELSE 0 END) AS benefactorId_null_count,
    SUM(CASE WHEN "resourceType" IS NULL THEN 1 ELSE 0 END) AS resourceType_null_count,
    SUM(CASE WHEN "isMultiIndividual" IS NULL THEN 1 ELSE 0 END) AS isMultiIndividual_null_count,
    SUM(CASE WHEN "accessType" IS NULL THEN 1 ELSE 0 END) AS accessType_null_count,
    SUM(CASE WHEN "nucleicAcidSource" IS NULL THEN 1 ELSE 0 END) AS nucleicAcidSource_null_count,
    SUM(CASE WHEN "specimenIdSource" IS NULL THEN 1 ELSE 0 END) AS specimenIdSource_null_count,
    SUM(CASE WHEN "projectId" IS NULL THEN 1 ELSE 0 END) AS projectId_null_count,
    SUM(CASE WHEN "libraryType" IS NULL THEN 1 ELSE 0 END) AS libraryType_null_count,
    SUM(CASE WHEN "libraryPrep" IS NULL THEN 1 ELSE 0 END) AS libraryPrep_null_count,
    SUM(CASE WHEN "isXenograft" IS NULL THEN 1 ELSE 0 END) AS isXenograft_null_count,
    SUM(CASE WHEN "meanGCContent" IS NULL THEN 1 ELSE 0 END) AS meanGCContent_null_count,
    SUM(CASE WHEN "rnaBatch" IS NULL THEN 1 ELSE 0 END) AS rnaBatch_null_count,
    SUM(CASE WHEN "readEnd" IS NULL THEN 1 ELSE 0 END) AS readEnd_null_count,
    SUM(CASE WHEN "passage" IS NULL THEN 1 ELSE 0 END) AS passage_null_count,
    SUM(CASE WHEN "transplantationType" IS NULL THEN 1 ELSE 0 END) AS transplantationType_null_count,
    SUM(CASE WHEN "genePerturbationMethod" IS NULL THEN 1 ELSE 0 END) AS genePerturbationMethod_null_count,
    SUM(CASE WHEN "tissue" IS NULL THEN 1 ELSE 0 END) AS tissue_null_count,
    SUM(CASE WHEN "consortium" IS NULL THEN 1 ELSE 0 END) AS consortium_null_count,
    SUM(CASE WHEN "group" IS NULL THEN 1 ELSE 0 END) AS group_null_count
  FROM sage.portal_raw.PORTAL_MERGE
)
UNPIVOT (
  null_count FOR column_name IN (
    PMI_null_count, diagnosis_null_count, fileFormat_null_count, nf2Genotype_null_count, createdOn_null_count, currentVersion_null_count, studyId_null_count, chromosome_null_count, modifiedBy_null_count, isStranded_null_count, cellType_null_count, isMultiSpecimen_null_count, specimenID_null_count, name_null_count, sex_null_count, type_null_count, isCellLine_null_count, alignmentMethod_null_count, Resource_id_null_count, nf1Genotype_null_count, dataFileSizeBytes_null_count, dataFileHandleId_null_count, individualID_null_count, processing_null_count, libraryBatch_null_count, progressReportNumber_null_count, treatmentType_null_count, createdBy_null_count, platform_null_count, pH_null_count, referenceSet_null_count, metadataType_null_count, id_null_count, terminalDifferentiationPoint_null_count, tumorType_null_count, consent_null_count, etag_null_count, fundingAgency_null_count, age_null_count, PORTAL_null_count, parentId_null_count, species_null_count, modelSystemName_null_count, failedQC_null_count, modelSystemType_null_count, analysisType_null_count, Contributor_null_count, libraryPreparationMethod_null_count, modifiedOn_null_count, study_null_count, accessTeam_null_count, assay_null_count, genePerturbationType_null_count, BrodmannArea_null_count, experimentalCondition_null_count, genePerturbed_null_count, grant_null_count, isPairedEnd_null_count, contentType_null_count, runType_null_count, assayTarget_null_count, readPair_null_count, meanCoverage_null_count, transposaseBatch_null_count, compoundName_null_count, modelOf_null_count, individualIdSource_null_count, initiative_null_count, isModelSystem_null_count, organ_null_count, metaboliteType_null_count, dataSubtype_null_count, PI_null_count, dataType_null_count, RIN_null_count, project_null_count, isConsortiumAnalysis_null_count, reprogrammedCellType_null_count, benefactorId_null_count, resourceType_null_count, isMultiIndividual_null_count, accessType_null_count, nucleicAcidSource_null_count, specimenIdSource_null_count, projectId_null_count, libraryType_null_count, libraryPrep_null_count, isXenograft_null_count, meanGCContent_null_count, rnaBatch_null_count, readEnd_null_count, passage_null_count, transplantationType_null_count, genePerturbationMethod_null_count, tissue_null_count, consortium_null_count, group_null_count
  )
)
)
select *
from null_counts
order by null_count DESC;
