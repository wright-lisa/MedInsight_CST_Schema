USE [MI_CHSD2017]
GO

/****** Object:  StoredProcedure [CST].[CONSOLIDATE_01_REFERENCES]    Script Date: 12/7/2018 9:55:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER PROCEDURE [CST].[CONSOLIDATE_01_REFERENCES] 
	@TRUNCATE VARCHAR(1)
AS

----------------------------------------------------------------
--** THIS PROCEDURE CONSOLIDATES FINAL DATA FROM COMPLETED  **--
--** MEDINSIGHT RUNs ACROSS MULTIPLE DATABASES              **--
--** THE DATABASES NEED TO BE STRUCTURED IN THE SAME OR     **--
--** OR VERY SIMILAR WAYS IN TERMS OF UDDs, UDFs AND PARMS  **--
----------------------------------------------------------------
--** SEVERAL COLUMNS ARE USED TO MAKE THIS HAPPEN AND AS    **--
--** SUCH ARE RENDERED UNUSABLE FOR OTHR PURPOSES. THEY ARE **--
--** PROVIDER_GROUP.[PROV_GRP_EMAIL]                        **--
--** PROVIDER_CW.[PROV_MAILING_ADDR2]                       **--
--** PROVIDER_UDF.[_PROV_UDF_20_]                           **--
--** MEMBER_UDF.[_MEM_UDF_20_]                              **--
----------------------------------------------------------------
--ALTER TABLE PROVIDER_UDF  ALTER COLUMN _PROV_UDF_20_ VARCHAR(40)

--DECLARE @TRUNCATE VARCHAR(1) = 'Y'

IF @TRUNCATE = 'Y' BEGIN
	TRUNCATE TABLE CST.CONSOLIDATE_SERVICEKEY
END

IF EXISTS (SELECT Name FROM sysindexes WHERE Name = 'CONSOLIDATE_SERVICEKEY_XPK') 
	DROP INDEX CST.CONSOLIDATE_SERVICEKEY.CONSOLIDATE_SERVICEKEY_XPK


-------------------------------------------------------
-- LOAD CONSOLIDATION TABLES                         --
-- MUST IDENTIFY THE FINISHED DBs TO BE CONSOLIDATED --
-- THE CID NEEDS TO BE A MAX OF 2 DIGITS             --
-------------------------------------------------------

-- IDENTIFY THE REFERENCE TABLES TO BE CHECKED --
-- ALL OTHERS WILL OT BE UPDATED OR TOUCHED    --
EXEC SP_MI_DROPTABLE '#TEMP_REF_TABLES'
SELECT t1.name AS REF_TABLE
INTO #TEMP_REF_TABLES
FROM sysobjects t1
INNER JOIN sysindexes t2
ON t1.id = t2.id
WHERE t2.indid <= 1
AND t2.rows > 0
AND OBJECTPROPERTY(t1.id,'IsUserTable') = 1
AND T1.name LIKE 'RFT_%'
AND T1.name NOT LIKE '%HEDIS%'
AND T1.name NOT LIKE '%GEN%'
AND T1.name NOT LIKE '%NYU%'
AND T1.name NOT LIKE '%MARA%'
AND T1.name NOT LIKE '%ETG%'
AND T1.name NOT LIKE '%ERG%'
AND T1.name NOT LIKE '%HCC%'
AND T1.name NOT LIKE '%MEG%'
AND T1.NAME NOT LIKE '%IND%'
AND T1.NAME NOT IN ('RFT_CLAIM_ID','RFT_CI_MEASURE','RFT_PERSON_ID','RFT_AMA_CAD_NDC','RFT_DART_PSC','RFT_CPT4_ASSISTSURG','RFT_RELATION',
					'RFT_CPT_ADDONS','RFT_CPT4_NEWPAT','RFT_PANELS','RFT_CPT_51EXEMPT','RFT_SURG_ONLY','RFT_PAYER_MATRIX',
					'RFT_ATTRIB_PROC','RFT_NPI_INFO','RFT_NPI_CODE_ARRAY','RFT_AGE','RFT_AGE_BANDS','RFT_AGE_BAND_ID','RFT_DRG',
					'RFT_MALINE_TAB','RFT_MRLINE_TAB','RFT_PBPLINE_TAB', 'RFT_ZIP_COUNTY_MASK',
					'RFT_ICD_DIAG','RFT_ICD_PROC','RFT_CCHG_ICD_MAP','RFT_DIM_NDC')

------------------------------------------------------------
-- FILL REFERENCE TABLES FROM ALL OF THE SOURCE DATABASES --
------------------------------------------------------------
DECLARE @DB_NAME VARCHAR(50)
DECLARE @CID VARCHAR(2)
DECLARE @SQL VARCHAR(4000) = ''
DECLARE @COLUMNS VARCHAR(4000) = ''
DECLARE @INSERT_COLUMNS VARCHAR(4000) = ''
DECLARE @KEY_COLUMN VARCHAR(4000) = ''
DECLARE @TABLE_NAME VARCHAR(50)
DECLARE table_cursor CURSOR DYNAMIC FOR  
SELECT REF_TABLE
FROM #TEMP_REF_TABLES 

-- OPEN TABLE CURSOR LOOP --
OPEN table_cursor   
FETCH NEXT FROM table_cursor INTO @TABLE_NAME   

WHILE @@FETCH_STATUS = 0 BEGIN   
	
	-- OPEN COLUMN CURSOR AND LOOP --
	SET @COLUMNS = dbo.fn_GET_COLUMNS_STRING(@TABLE_NAME,'R','Y','N')
	SET @INSERT_COLUMNS = dbo.fn_GET_COLUMNS_STRING(@TABLE_NAME,'','Y','N')
	SET @KEY_COLUMN = dbo.fn_GET_COLUMNS_STRING(@TABLE_NAME,'','Y','Y')

	SET @SQL =  'INSERT INTO ' + @TABLE_NAME + '(' + @INSERT_COLUMNS + ') SELECT DISTINCT ' + @COLUMNS + ' FROM ('

	DECLARE db_cursor CURSOR FOR  
	SELECT DBS, CID
	FROM ##TEMP_DBS 
	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @DB_NAME,@CID 
	WHILE @@FETCH_STATUS = 0 BEGIN   
		   SET @SQL = @SQL + 'SELECT * FROM ' + @DB_NAME + '.dbo.' + @TABLE_NAME + ' ' 

		   FETCH NEXT FROM db_cursor INTO @DB_NAME ,@CID  
		   IF @@FETCH_STATUS = 0 BEGIN SET @SQL = @SQL + 'UNION ALL ' END
	END   

	SET @SQL = @SQL + ' ) R '
	SET @SQL = @SQL + 'LEFT JOIN ' + @TABLE_NAME + ' R1 ON R.' + @KEY_COLUMN + ' = R1.' + @KEY_COLUMN + ' '
	SET @SQL = @SQL + 'WHERE R.' + @KEY_COLUMN + ' IS NOT NULL AND R1.' + @KEY_COLUMN + ' IS NULL'
	PRINT @SQL
	EXECUTE(@SQL)
	
	SET @SQL = 'INSERT INTO ' + @TABLE_NAME + '(' + @INSERT_COLUMNS + ') SELECT DISTINCT ' + @COLUMNS + ' FROM ('
	CLOSE db_cursor   
	DEALLOCATE db_cursor 
	FETCH NEXT FROM table_cursor INTO @TABLE_NAME   
END
	
CLOSE table_cursor   
DEALLOCATE table_cursor 

---------------------------------------------------
-- PROCESS SERVICES_KEY AND ICD REFERENCE TABLES --
---------------------------------------------------
DECLARE db_cursor CURSOR FOR  
SELECT DBS,CID
FROM ##TEMP_DBS 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @DB_NAME,@CID

	WHILE @@FETCH_STATUS = 0 BEGIN
	
		-- SET UP THE SERVICES_KEY REFERENCE TABLE
		SET @SQL = '
		INSERT INTO CST.CONSOLIDATE_SERVICEKEY(S_SERVICES_KEY,CID) SELECT SERVICES_KEY AS S_SERVICES_KEY,'''+@CID+''' AS CID FROM '+@DB_NAME+'.dbo.SERVICES '
		PRINT(@SQL)
		EXECUTE(@SQL)
		-- LW 3/9 issue with *NULL* values in ref tables changed to use icd keys
		-- TACKLE ICD CODES TABLES FIRST --
		SET @SQL = '
		INSERT INTO RFT_ICD_DIAG(ICD_10_OR_HIGHER,ICD_DIAG)
		SELECT
			S.ICD_10_OR_HIGHER,S.ICD_DIAG
		FROM '+@DB_NAME+'.dbo.RFT_ICD_DIAG S
			LEFT JOIN RFT_ICD_DIAG T 
			ON S.ICD_DIAG = T.ICD_DIAG AND S.ICD_10_OR_HIGHER = T.ICD_10_OR_HIGHER
		WHERE T.ICD_DIAG IS NULL AND S.ICD_DIAG_KEY <> 0 
		        AND S.ICD_DIAG <> ''*NULL*'''
		PRINT @SQL
		EXECUTE(@SQL)

		SET @SQL = '
		INSERT INTO RFT_ICD_PROC(
			ICD_10_OR_HIGHER,
			ICD_PROC
			)
		SELECT
			S.ICD_10_OR_HIGHER,
			S.ICD_PROC
		FROM '+@DB_NAME+'.dbo.RFT_ICD_PROC S
			LEFT JOIN RFT_ICD_PROC T 
			ON S.ICD_PROC = T.ICD_PROC
			AND S.ICD_10_OR_HIGHER = T.ICD_10_OR_HIGHER
		WHERE T.ICD_PROC IS NULL AND S.ICD_PROC_KEY <> 0
		AND S.ICD_PROC <> ''*NULL*'''
		PRINT @SQL
		EXECUTE(@SQL)

		FETCH NEXT FROM db_cursor INTO @DB_NAME,@CID

	END
	
CLOSE db_cursor   
DEALLOCATE db_cursor 

-- IN SOME WEIRD CASES WE ARE NOT GETTING A ICD TYPE SO DEFAULT TO ICD9 --
UPDATE D SET ICD_10_OR_HIGHER = 0
FROM RFT_ICD_DIAG D
WHERE ICD_10_OR_HIGHER IS NULL

UPDATE RFT_ICD_DIAG SET ICD_10_OR_HIGHER = NULL
WHERE ICD_DIAG_KEY = 0

UPDATE P SET ICD_10_OR_HIGHER = 0
FROM RFT_ICD_PROC P
WHERE ICD_10_OR_HIGHER IS NULL

------------------------------------------------------------
-- FILL EMP_GROUP, EMP_GROUP_ROLLUP, EMP_GROUP_UDF TABLES --
------------------------------------------------------------
--DECLARE @DB_NAME VARCHAR(50)
--DECLARE @SQL VARCHAR(4000) = ''

DECLARE @EMP_GROUP_COLUMNS VARCHAR(4000) =  dbo.fn_GET_COLUMNS_STRING('EMP_GROUP','G','Y','N') 
DECLARE @EMP_GROUP_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('EMP_GROUP','','Y','N')
DECLARE @EMP_GROUP_UDF_COLUMNS VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('EMP_GROUP_UDF','U','Y','N')
DECLARE @EMP_GROUP_UDF_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('EMP_GROUP_UDF','','Y','N')
DECLARE @EMP_GROUP_ROLLUP_COLUMNS VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('EMP_GROUP_ROLLUP','R','Y','N')
DECLARE @EMP_GROUP_ROLLUP_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('EMP_GROUP_ROLLUP','','Y','N')

--SET @EMP_GROUP_UDF_COLUMNS = REPLACE(@EMP_GROUP_UDF_COLUMNS,'U.[_GRP_UDF_20_]',''''+@CID+'-''+GRP_ID AS [_GRP_UDF_20_]')

DECLARE db_cursor CURSOR FOR  
SELECT DBS,CID
FROM ##TEMP_DBS 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @DB_NAME,@CID 

SET @EMP_GROUP_COLUMNS =  dbo.fn_GET_COLUMNS_STRING('EMP_GROUP','G','Y','N') 
SET @EMP_GROUP_UDF_COLUMNS = REPLACE(@EMP_GROUP_UDF_COLUMNS,'U.[_GRP_UDF_20_]',''''+@CID+'-''+GRP_ID AS [_GRP_UDF_20_]')

exec sp_mi_droptable '##TEMP_GROUPS'
SET @SQL = 'SELECT ' + @EMP_GROUP_COLUMNS + ',' + @EMP_GROUP_UDF_COLUMNS + ',' + @EMP_GROUP_ROLLUP_COLUMNS + '
INTO ##TEMP_GROUPS FROM ' + @DB_NAME + '.dbo.EMP_GROUP G 
INNER JOIN ' + @DB_NAME + '.dbo.EMP_GROUP_UDF U ON G.GRP_UDF_KEY = U.GRP_UDF_KEY 
INNER JOIN ' + @DB_NAME + '.dbo.EMP_GROUP_ROLLUP R ON R.GRP_ROLLUP_KEY = R.GRP_ROLLUP_KEY 
' 	 
EXECUTE(@SQL) 

WHILE @@FETCH_STATUS = 0 BEGIN 

	FETCH NEXT FROM db_cursor INTO @DB_NAME,@CID   
	IF @@FETCH_STATUS = 0 BEGIN 

		SET @EMP_GROUP_COLUMNS =  dbo.fn_GET_COLUMNS_STRING('EMP_GROUP','G','Y','N') 
		SET @EMP_GROUP_UDF_COLUMNS = REPLACE(@EMP_GROUP_UDF_COLUMNS,'U.[_GRP_UDF_20_]',''''+@CID+'-''+GRP_ID AS [_GRP_UDF_20_]')
	
		SET @SQL = 'INSERT INTO ##TEMP_GROUPS SELECT ' + @EMP_GROUP_COLUMNS + ',' + @EMP_GROUP_UDF_COLUMNS + ',' + @EMP_GROUP_ROLLUP_COLUMNS + '
		FROM ' + @DB_NAME + '.dbo.EMP_GROUP G 
			INNER JOIN ' + @DB_NAME + '.dbo.EMP_GROUP_UDF U ON G.GRP_UDF_KEY = U.GRP_UDF_KEY 
			INNER JOIN ' + @DB_NAME + '.dbo.EMP_GROUP_ROLLUP R ON R.GRP_ROLLUP_KEY = R.GRP_ROLLUP_KEY  
		'
		EXECUTE(@SQL)

	END
END   

CLOSE db_cursor   
DEALLOCATE db_cursor 

-- INSERT INTO EMP_GROUP_ROLLUP TABLE --
TRUNCATE TABLE EMP_GROUP_ROLLUP
exec SP_MI_TOGGLE_IDX 'EMP_GROUP_ROLLUP','OFF'
SET @SQL = 'INSERT INTO EMP_GROUP_ROLLUP(' + @EMP_GROUP_ROLLUP_COLUMNS_INSERT + ') 
			SELECT DISTINCT ' + @EMP_GROUP_ROLLUP_COLUMNS + ' FROM ##TEMP_GROUPS R'

EXECUTE(@SQL)
exec SP_MI_TOGGLE_IDX 'EMP_GROUP_ROLLUP','ON'


-- INSERT INTO EMP_GROUP_UDF TABLE --
TRUNCATE TABLE EMP_GROUP_UDF
UPDATE MI_USER_FIELDS SET BUSINESS_NAME = 'GRP_ID_UDF',COL_SPEC = 'VARCHAR(60)' WHERE USERFIELD = '_GRP_UDF_20_'
exec SP_MI_TOGGLE_IDX 'EMP_GROUP_UDF','OFF'
SET @SQL = 'INSERT INTO EMP_GROUP_UDF(' + @EMP_GROUP_UDF_COLUMNS_INSERT + ') SELECT DISTINCT ' + @EMP_GROUP_UDF_COLUMNS + ' FROM ##TEMP_GROUPS U'
PRINT @SQL

EXECUTE(@SQL)
exec SP_MI_TOGGLE_IDX 'EMP_GROUP_UDF','ON'


-- INSERT INTO EMP_GROUP TABLE --
TRUNCATE TABLE EMP_GROUP
exec SP_MI_TOGGLE_IDX 'EMP_GROUP','OFF'
SET @SQL = 'INSERT INTO EMP_GROUP(' + @EMP_GROUP_COLUMNS_INSERT + ') SELECT DISTINCT ' + @EMP_GROUP_COLUMNS + ' FROM ##TEMP_GROUPS G'

UPDATE EMP_GROUP SET GRP_TYPE_KEY = 4
WHERE GRP_TYPE_KEY = 0 OR GRP_TYPE_KEY IS NULL

IF (SELECT COUNT(*) FROM EMP_GROUP WHERE GRP_KEY = 0) = 0 BEGIN
	SET IDENTITY_INSERT EMP_GROUP ON
	INSERT INTO EMP_GROUP (
		GRP_KEY,GRP_ID,GRP_START_DATE,GRP_END_DATE,GRP_UDF_KEY,GRP_ROLLUP_KEY,
		GRP_TYPE_KEY,GRP_EFF_DATE,GRP_TERM_DATE,CURRENT_FLAG,ORPHAN_CAT)
	SELECT
		0 AS GRP_KEY,'*' AS GRP_ID,'1900-01-01' AS GRP_START_DATE,'2099-12-31' AS GRP_END_DATE,
		0 AS GRP_UDF_KEY,0 AS GRP_ROLLUP_KEY,4 AS GRP_TYPE_KEY,'1900-01-01' AS GRP_EFF_DATE,
		'2099-12-31' AS GRP_TERM_DATE,1 AS CURRENT_FLAG,0 AS ORPHAN_CAT
	SET IDENTITY_INSERT EMP_GROUP OFF
END

EXECUTE(@SQL)
exec SP_MI_TOGGLE_IDX 'EMP_GROUP','ON'

-- UPDATE ALL OF THE EMP_GROUP LINK TABLE KEYS --
SET IDENTITY_INSERT EMP_GROUP_UDF ON
INSERT INTO EMP_GROUP_UDF(GRP_UDF_KEY) SELECT 0 AS GRP_UDF_KEY
SET IDENTITY_INSERT EMP_GROUP_UDF OFF

UPDATE P SET
	P.PROV_UDF_KEY = COALESCE(U.PROV_UDF_KEY,0)
FROM dbo.PROVIDER P	LEFT JOIN dbo.PROVIDER_UDF U ON P.PROV_ID = U._PROV_UDF_20_


SET IDENTITY_INSERT EMP_GROUP_ROLLUP ON
INSERT INTO EMP_GROUP_ROLLUP(GRP_ROLLUP_KEY) SELECT 0 AS GRP_ROLLUP_KEY
SET IDENTITY_INSERT EMP_GROUP_ROLLUP OFF

UPDATE P SET
	P.GRP_ROLLUP_KEY = 0 --COALESCE(G.GRP_ROLLUP_KEY,0)
FROM EMP_GROUP P --LEFT JOIN EMP_GROUP_ROLLUP G ON P.PROV_ID = G.PROV_GRP_EMAIL

UPDATE EMP_GROUP SET GRP_SIC = NULL
FROM EMP_GROUP E
	LEFT JOIN RFT_SIC S ON E.GRP_SIC = S.SIC
WHERE S.SIC IS NULL

-----------------------------------------------------------------------------------------
-- FILL PROVIDER, PROVIDER_CW, PROVIDER_UDF, PROVIDER_GROUP AND PROVIDER_CLINIC TABLES --
-----------------------------------------------------------------------------------------
--DECLARE @DB_NAME VARCHAR(50)
--DECLARE @SQL VARCHAR(4000) = ''

DECLARE @PROVIDER_COLUMNS VARCHAR(4000) =  dbo.fn_GET_COLUMNS_STRING('PROVIDER','P','Y','N') 
DECLARE @PROVIDER_COLUMNS_NC VARCHAR(4000) =  dbo.fn_GET_COLUMNS_STRING('PROVIDER','P','Y','N') 
DECLARE @PROVIDER_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER','','Y','N')
DECLARE @PROVIDER_UDF_COLUMNS VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_UDF','U','Y','N')
DECLARE @PROVIDER_UDF_COLUMNS_NC VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_UDF','U','Y','N')
DECLARE @PROVIDER_UDF_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_UDF','','Y','N')
DECLARE @PROVIDER_CW_COLUMNS VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_CW','W','N','N')
DECLARE @PROVIDER_CW_COLUMNS_NC VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_CW','W','N','N')
DECLARE @PROVIDER_CW_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_CW','','Y','N')
DECLARE @PROVIDER_GROUP_COLUMNS VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_GROUP','G','Y','N')
DECLARE @PROVIDER_GROUP_COLUMNS_NC VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_GROUP','G','Y','N')
DECLARE @PROVIDER_GROUP_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_GROUP','','Y','N')
DECLARE @PROVIDER_CLINIC_COLUMNS VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_CLINIC','C','Y','N')
DECLARE @PROVIDER_CLINIC_COLUMNS_NC VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_CLINIC','C','Y','N')
DECLARE @PROVIDER_CLINIC_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER_CLINIC','','Y','N')

set @PROVIDER_GROUP_COLUMNS = dbo.fn_GET_COLUMNS_STRING('PROVIDER_GROUP','G','Y','N')
SET @PROVIDER_GROUP_COLUMNS = REPLACE(@PROVIDER_GROUP_COLUMNS,'G.[PROV_GRP_EMAIL]',''''+@CID+'-''+PROV_ID AS [PROV_GRP_EMAIL]')
set @PROVIDER_CLINIC_COLUMNS = dbo.fn_GET_COLUMNS_STRING('PROVIDER_CLINIC','C','Y','N')
SET @PROVIDER_CLINIC_COLUMNS = REPLACE(@PROVIDER_CLINIC_COLUMNS,'C.[PROV_MAILING_ADDR2]',''''+@CID+'-''+PROV_ID AS [PROV_MAILING_ADDR2]')
set @PROVIDER_UDF_COLUMNS = dbo.fn_GET_COLUMNS_STRING('PROVIDER_UDF','U','Y','N')
SET @PROVIDER_UDF_COLUMNS = REPLACE(@PROVIDER_UDF_COLUMNS,'U.[_PROV_UDF_20_]',''''+@CID+'-''+PROV_ID AS [_PROV_UDF_20_]')
set @PROVIDER_COLUMNS =  dbo.fn_GET_COLUMNS_STRING('PROVIDER','P','Y','N') 
SET @PROVIDER_COLUMNS = REPLACE(@PROVIDER_COLUMNS,'P.[PROV_ID]',''''+@CID+'-''+PROV_ID AS [PROV_ID]')

DECLARE db_cursor CURSOR FOR  
SELECT DBS,CID
FROM ##TEMP_DBS 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @DB_NAME,@CID

set @PROVIDER_GROUP_COLUMNS = dbo.fn_GET_COLUMNS_STRING('PROVIDER_GROUP','G','Y','N')
SET @PROVIDER_GROUP_COLUMNS = REPLACE(@PROVIDER_GROUP_COLUMNS,'G.[PROV_GRP_EMAIL]',''''+@CID+'-''+PROV_ID AS [PROV_GRP_EMAIL]')
set @PROVIDER_CLINIC_COLUMNS = dbo.fn_GET_COLUMNS_STRING('PROVIDER_CLINIC','C','Y','N')
SET @PROVIDER_CLINIC_COLUMNS = REPLACE(@PROVIDER_CLINIC_COLUMNS,'C.[PROV_MAILING_ADDR2]',''''+@CID+'-''+PROV_ID AS [PROV_MAILING_ADDR2]')
set @PROVIDER_UDF_COLUMNS = dbo.fn_GET_COLUMNS_STRING('PROVIDER_UDF','U','Y','N')
SET @PROVIDER_UDF_COLUMNS = REPLACE(@PROVIDER_UDF_COLUMNS,'U.[_PROV_UDF_20_]',''''+@CID+'-''+PROV_ID AS [_PROV_UDF_20_]')
set @PROVIDER_COLUMNS =  dbo.fn_GET_COLUMNS_STRING('PROVIDER','P','Y','N') 
SET @PROVIDER_COLUMNS = REPLACE(@PROVIDER_COLUMNS,'P.[PROV_ID]',''''+@CID+'-''+PROV_ID AS [PROV_ID]')

exec sp_mi_droptable '##TEMP_PROVIDERS'
SET @SQL = 'SELECT ' + @PROVIDER_COLUMNS + ',' + @PROVIDER_UDF_COLUMNS + ',' + @PROVIDER_GROUP_COLUMNS + ',' + @PROVIDER_CLINIC_COLUMNS + '
INTO ##TEMP_PROVIDERS FROM ' + @DB_NAME + '.dbo.PROVIDER P 
INNER JOIN ' + @DB_NAME + '.dbo.PROVIDER_UDF U ON P.PROV_UDF_KEY = U.PROV_UDF_KEY 
INNER JOIN ' + @DB_NAME + '.dbo.PROVIDER_GROUP G ON P.PROV_GRP_KEY = G.PROV_GRP_KEY 
INNER JOIN ' + @DB_NAME + '.dbo.PROVIDER_CLINIC C ON P.PROV_CLINIC_KEY = C.PROV_CLINIC_KEY 
' 	 
EXECUTE(@SQL) 

exec sp_mi_droptable '##TEMP_PROVIDERS_CW'
SET @SQL = 'SELECT ' + @PROVIDER_CW_COLUMNS_NC + ',PROV_DATA_SOURCE INTO ##TEMP_PROVIDERS_CW FROM ' + @DB_NAME + '.dbo.PROVIDER_CW W INNER JOIN ' + @DB_NAME + '.dbo.PROVIDER P ON W.PROV_CW_KEY = P.PROV_CW_KEY ' 

EXECUTE(@SQL) 

WHILE @@FETCH_STATUS = 0 BEGIN 

	FETCH NEXT FROM db_cursor INTO @DB_NAME,@CID
	IF @@FETCH_STATUS = 0 BEGIN 

		set @PROVIDER_GROUP_COLUMNS = dbo.fn_GET_COLUMNS_STRING('PROVIDER_GROUP','G','Y','N')
		SET @PROVIDER_GROUP_COLUMNS = REPLACE(@PROVIDER_GROUP_COLUMNS,'G.[PROV_GRP_EMAIL]',''''+@CID+'-''+PROV_ID AS [PROV_GRP_EMAIL]')
		set @PROVIDER_CLINIC_COLUMNS = dbo.fn_GET_COLUMNS_STRING('PROVIDER_CLINIC','C','Y','N')
		SET @PROVIDER_CLINIC_COLUMNS = REPLACE(@PROVIDER_CLINIC_COLUMNS,'C.[PROV_MAILING_ADDR2]',''''+@CID+'-''+PROV_ID AS [PROV_MAILING_ADDR2]')
		set @PROVIDER_UDF_COLUMNS = dbo.fn_GET_COLUMNS_STRING('PROVIDER_UDF','U','Y','N')
		SET @PROVIDER_UDF_COLUMNS = REPLACE(@PROVIDER_UDF_COLUMNS,'U.[_PROV_UDF_20_]',''''+@CID+'-''+PROV_ID AS [_PROV_UDF_20_]')
		set @PROVIDER_COLUMNS =  dbo.fn_GET_COLUMNS_STRING('PROVIDER','P','Y','N') 
		SET @PROVIDER_COLUMNS = REPLACE(@PROVIDER_COLUMNS,'P.[PROV_ID]',''''+@CID+'-''+PROV_ID AS [PROV_ID]')
	
		SET @SQL = 'INSERT INTO ##TEMP_PROVIDERS SELECT ' + @PROVIDER_COLUMNS + ',' + @PROVIDER_UDF_COLUMNS + ',' + @PROVIDER_GROUP_COLUMNS + ',' + @PROVIDER_CLINIC_COLUMNS + '
		FROM ' + @DB_NAME + '.dbo.PROVIDER P 
		INNER JOIN ' + @DB_NAME + '.dbo.PROVIDER_UDF U ON P.PROV_UDF_KEY = U.PROV_UDF_KEY 
		INNER JOIN ' + @DB_NAME + '.dbo.PROVIDER_GROUP G ON P.PROV_GRP_KEY = G.PROV_GRP_KEY 
		INNER JOIN ' + @DB_NAME + '.dbo.PROVIDER_CLINIC C ON P.PROV_CLINIC_KEY = C.PROV_CLINIC_KEY 
		'
		EXECUTE(@SQL)

		SET @SQL = 'INSERT INTO ##TEMP_PROVIDERS_CW SELECT ' + @PROVIDER_CW_COLUMNS + ',PROV_DATA_SOURCE FROM ' + @DB_NAME + '.dbo.PROVIDER_CW W INNER JOIN ' + @DB_NAME + '.dbo.PROVIDER P ON W.PROV_CW_KEY = P.PROV_CW_KEY ' 

		EXECUTE(@SQL) 

	END
END   

CLOSE db_cursor   
DEALLOCATE db_cursor 

-- INSERT INTO PROVIDER_GROUP TABLE --
exec MI_0005_INDEX_MANAGEMENT

TRUNCATE TABLE PROVIDER_GROUP
exec SP_MI_TOGGLE_IDX 'PROVIDER_GROUP','OFF'
SET @SQL = 'INSERT INTO dbo.PROVIDER_GROUP(' + @PROVIDER_GROUP_COLUMNS_INSERT + ') 
			SELECT DISTINCT ' + @PROVIDER_GROUP_COLUMNS_NC + ' FROM ##TEMP_PROVIDERS G'

EXECUTE(@SQL)
exec SP_MI_TOGGLE_IDX 'PROVIDER_GROUP','ON'


-- INSERT INTO PROVIDER_CLINIC TABLE --
TRUNCATE TABLE PROVIDER_CLINIC
exec SP_MI_TOGGLE_IDX 'PROVIDER_CLINIC','OFF'
SET @SQL = 'INSERT INTO dbo.PROVIDER_CLINIC(' + @PROVIDER_CLINIC_COLUMNS_INSERT + ') SELECT DISTINCT ' + @PROVIDER_CLINIC_COLUMNS_NC + ' FROM ##TEMP_PROVIDERS c'
PRINT @SQL

EXECUTE(@SQL)
exec SP_MI_TOGGLE_IDX 'dbo.PROVIDER_CLINIC','ON'


-- INSERT INTO PROVIDER_UDF TABLE --
TRUNCATE TABLE PROVIDER_UDF
UPDATE MI_USER_FIELDS SET BUSINESS_NAME = 'PROV_ID_UDF',COL_SPEC = 'VARCHAR(60)' WHERE USERFIELD = '_PROV_UDF_20_'
exec SP_MI_TOGGLE_IDX 'dbo.PROVIDER_UDF','OFF'
SET @SQL = 'INSERT INTO dbo.PROVIDER_UDF(' + @PROVIDER_UDF_COLUMNS_INSERT + ') SELECT DISTINCT ' + @PROVIDER_UDF_COLUMNS_NC + ' FROM ##TEMP_PROVIDERS U'
PRINT @SQL

EXECUTE(@SQL)
exec SP_MI_TOGGLE_IDX 'PROVIDER_UDF','ON'

--kjs100
--declare @sql varchar(4000)
--DECLARE @PROVIDER_COLUMNS VARCHAR(4000) =  dbo.fn_GET_COLUMNS_STRING('PROVIDER','P','Y','N') 
--DECLARE @PROVIDER_COLUMNS_NC VARCHAR(4000) =  dbo.fn_GET_COLUMNS_STRING('PROVIDER','P','Y','N') 
--DECLARE @PROVIDER_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('PROVIDER','','Y','N')

-- INSERT INTO PROVIDER TABLE --
TRUNCATE TABLE PROVIDER
exec SP_MI_TOGGLE_IDX 'PROVIDER','OFF'
SET @SQL = 'INSERT INTO dbo.PROVIDER(' + @PROVIDER_COLUMNS_INSERT + ') SELECT DISTINCT ' + @PROVIDER_COLUMNS_NC + ' FROM ##TEMP_PROVIDERS P'
PRINT @SQL

EXECUTE(@SQL)
DELETE FROM dbo.PROVIDER WHERE PROV_ID IS NULL AND PROV_KEY <> 0
exec SP_MI_TOGGLE_IDX 'PROVIDER','ON'

/*

SET IDENTITY_INSERT PROVIDER ON
INSERT INTO PROVIDER(
	PROV_KEY,
	PROV_START_DATE,
	PROV_END_DATE,
	PROV_CW_KEY,
	PROV_CLINIC_KEY,
	PROV_GRP_KEY,
	PROV_UDF_KEY,
	PROV_DOMESTIC,
	CURRENT_FLAG,
	ORPHAN_CAT
)
SELECT
	Z.*
FROM 
	(SELECT 0 AS PROV_KEY,'1900-01-01' AS PROV_START_DATE,'2099-12-31' AS PROV_END_DATE,0 AS PROV_CW_KEY,0 AS PROV_CLINIC_KEY,0 AS PROV_GRP_KEY,0 AS PROV_UDF_KEY,'U' AS PROV_DOMESTIC,1 AS CURRENT_FLAG,0 AS ORPHAN_CAT) Z
LEFT JOIN PROVIDER P ON Z.PROV_KEY = P.PROV_KEY
WHERE P.PROV_KEY IS NULL
SET IDENTITY_INSERT PROVIDER OFF
*/

-- INSERT INTO PROVIDER_CW TABLE --
UPDATE W SET
	W.PROV_EMAIL = P.PROV_ID
FROM ##TEMP_PROVIDERS_CW W
	INNER JOIN ##TEMP_PROVIDERS P ON W.PROV_CW_KEY = P.PROV_CW_KEY AND W.PROV_DATA_SOURCE = P.PROV_DATA_SOURCE

TRUNCATE TABLE PROVIDER_CW
exec SP_MI_TOGGLE_IDX 'PROVIDER_CW','OFF'
INSERT INTO dbo.PROVIDER_CW
SELECT 
	P.PROV_KEY AS PROV_CW_KEY,
	P.PROV_KEY AS PROV_KEY,
	P.PROV_ID,
	W.PROV_TYPE,
	W.PROV_NPI,
	W.PROV_TIN,
	W.PROV_TAXONOMY,
	W.PROV_LIC,
	W.PROV_MEDICAID,
	W.PROV_DEA,
	W.PROV_NET_FLAG,
	W.PROV_PAR_FLAG,
	W.PROV_LNAME,
	W.PROV_FNAME,
	W.PROV_MNAME,
	W.PROV_GENDER,
	W.PROV_DOB,
	NULL AS PROV_EMAIL,
	W.PROV_SPEC_CODE,
	W.PROV_SPEC_DESC,
	W.PROV_GROUP_IPA_NAME,
	W.PROV_GROUP_ACO_NAME,
	W.PROV_DOMESTIC,
	W.ORPHAN_CAT
FROM ##TEMP_PROVIDERS_CW W
	INNER JOIN dbo.PROVIDER P ON W.PROV_EMAIL = P.PROV_ID

exec SP_MI_TOGGLE_IDX 'PROVIDER_CW','ON'

-- UPDATE ALL OF THE PROVIDER LINK TABLE KEYS --
SET IDENTITY_INSERT dbo.PROVIDER_GROUP ON
INSERT INTO dbo.PROVIDER_GROUP(PROV_GRP_KEY) SELECT 0 AS PROV_GRP_KEY
SET IDENTITY_INSERT dbo.PROVIDER_GROUP OFF

SET IDENTITY_INSERT dbo.PROVIDER_CLINIC ON
INSERT INTO dbo.PROVIDER_CLINIC(PROV_CLINIC_KEY) SELECT 0 AS PROV_CLINIC_KEY
SET IDENTITY_INSERT dbo.PROVIDER_CLINIC OFF

SET IDENTITY_INSERT dbo.PROVIDER_UDF ON
INSERT INTO dbo.PROVIDER_UDF(PROV_UDF_KEY) SELECT 0 AS PROV_UDF_KEY
SET IDENTITY_INSERT dbo.PROVIDER_UDF OFF

UPDATE P SET
	P.PROV_CW_KEY = COALESCE(W.PROV_CW_KEY,0)
FROM dbo.PROVIDER P LEFT JOIN dbo.PROVIDER_CW W ON P.PROV_ID = W.PROV_ID

UPDATE P SET
	P.PROV_UDF_KEY = COALESCE(U.PROV_UDF_KEY,0)
FROM dbo.PROVIDER P	LEFT JOIN dbo.PROVIDER_UDF U ON P.PROV_ID = U._PROV_UDF_20_


UPDATE P SET
	P.PROV_GRP_KEY = COALESCE(G.PROV_GRP_KEY,0)
FROM dbo.PROVIDER P LEFT JOIN dbo.PROVIDER_GROUP G ON P.PROV_ID = G.PROV_GRP_EMAIL


UPDATE P SET
	P.PROV_CLINIC_KEY = COALESCE(C.PROV_CLINIC_KEY,0)
FROM dbo.PROVIDER P	LEFT JOIN dbo.PROVIDER_CLINIC C ON P.PROV_ID = C.PROV_MAILING_ADDR2

-----------------------------------------------
-- FILL MEMBER, MEMBER_UDF AND PERSON TABLES --
-----------------------------------------------
--DECLARE @DB_NAME VARCHAR(50)
--DECLARE @SQL VARCHAR(4000) = ''

DECLARE @MEMBER_COLUMNS VARCHAR(4000) =  dbo.fn_GET_COLUMNS_STRING('MEMBER','M','Y','N') 
DECLARE @MEMBER_COLUMNS_LOAD VARCHAR(4000) =  dbo.fn_GET_COLUMNS_STRING('MEMBER','M','Y','N') 
DECLARE @MEMBER_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('MEMBER','','Y','N')
DECLARE @MEMBER_UDF_COLUMNS VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('MEMBER_UDF','U','Y','N')
DECLARE @MEMBER_UDF_COLUMNS_LOAD VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('MEMBER_UDF','U','Y','N')
DECLARE @MEMBER_UDF_COLUMNS_INSERT VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('MEMBER_UDF','','Y','N')
DECLARE @PERSON_COLUMNS VARCHAR(4000) = dbo.fn_GET_COLUMNS_STRING('RFT_PERSON_ID','P','Y','N')

SET @MEMBER_UDF_COLUMNS = dbo.fn_GET_COLUMNS_STRING('MEMBER_UDF','U','Y','N')
SET @MEMBER_UDF_COLUMNS = REPLACE(@MEMBER_UDF_COLUMNS,'U.[_MEM_UDF_20_]',''''+@CID+'-''+MEMBER_ID AS [_MEM_UDF_20_]')
SET @MEMBER_COLUMNS =  dbo.fn_GET_COLUMNS_STRING('MEMBER','M','Y','N') 
SET @MEMBER_COLUMNS = REPLACE(@MEMBER_COLUMNS,'M.[MEMBER_ID]',''''+@CID+'-''+MEMBER_ID AS [MEMBER_ID]')
SET @MEMBER_COLUMNS = REPLACE(@MEMBER_COLUMNS,'M.[MEMBER_ID_ENCRYPTED]','MEMBER_ID_ENCRYPTED + ''-' + @CID + ''' AS [MEMBER_ID_ENCRYPTED]')
SET @PERSON_COLUMNS = dbo.fn_GET_COLUMNS_STRING('RFT_PERSON_ID','P','Y','N')
SET @PERSON_COLUMNS = REPLACE(@PERSON_COLUMNS,'P.[PERSON_ID]','PERSON_ID+''-'+@CID+''' AS [PERSON_ID]')

UPDATE MI_USER_FIELDS SET BUSINESS_NAME = 'MEMBER_ID_UDF',COL_SPEC = 'VARCHAR(100)' WHERE USERFIELD = '_MEM_UDF_20_'

DECLARE db_cursor CURSOR FOR  
SELECT DBS,CID
FROM ##TEMP_DBS 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @DB_NAME,@CID 

SET @MEMBER_UDF_COLUMNS = dbo.fn_GET_COLUMNS_STRING('MEMBER_UDF','U','Y','N')
SET @MEMBER_UDF_COLUMNS = REPLACE(@MEMBER_UDF_COLUMNS,'U.[_MEM_UDF_20_]',''''+@CID+'-''+MEMBER_ID AS [_MEM_UDF_20_]')
SET @MEMBER_COLUMNS =  dbo.fn_GET_COLUMNS_STRING('MEMBER','M','Y','N') 
SET @MEMBER_COLUMNS = REPLACE(@MEMBER_COLUMNS,'M.[MEMBER_ID]',''''+@CID+'-''+MEMBER_ID AS [MEMBER_ID]')
SET @MEMBER_COLUMNS = REPLACE(@MEMBER_COLUMNS,'M.[MEMBER_ID_ENCRYPTED]','MEMBER_ID_ENCRYPTED + ''-' + @CID + ''' AS [MEMBER_ID_ENCRYPTED]')
SET @PERSON_COLUMNS = dbo.fn_GET_COLUMNS_STRING('RFT_PERSON_ID','P','Y','N')
SET @PERSON_COLUMNS = REPLACE(@PERSON_COLUMNS,'P.[PERSON_ID]','PERSON_ID+''-'+@CID+''' AS [PERSON_ID]')

exec sp_mi_droptable '##TEMP_MEMBERS'
SET @SQL = 'SELECT ' + @MEMBER_COLUMNS + ',' + @MEMBER_UDF_COLUMNS + ',' + @PERSON_COLUMNS + ' INTO ##TEMP_MEMBERS FROM ' + @DB_NAME + '.dbo.MEMBER M INNER JOIN ' + @DB_NAME + '.dbo.RFT_PERSON_ID P ON M.MI_PERSON_KEY = P.PERSON_KEY INNER JOIN ' + @DB_NAME + '.dbo.MEMBER_UDF U ON M.MEMBER_UDF_KEY = U.MEMBER_UDF_KEY ' 	 
PRINT @SQL
EXECUTE(@SQL) 



WHILE @@FETCH_STATUS = 0 BEGIN 

		FETCH NEXT FROM db_cursor INTO @DB_NAME,@CID   
		IF @@FETCH_STATUS = 0 BEGIN 
			SET @MEMBER_UDF_COLUMNS = dbo.fn_GET_COLUMNS_STRING('MEMBER_UDF','U','Y','N')
			SET @MEMBER_UDF_COLUMNS = REPLACE(@MEMBER_UDF_COLUMNS,'U.[_MEM_UDF_20_]',''''+@CID+'-''+MEMBER_ID AS [_MEM_UDF_20_]')
			SET @MEMBER_COLUMNS =  dbo.fn_GET_COLUMNS_STRING('MEMBER','M','Y','N') 
			SET @MEMBER_COLUMNS = REPLACE(@MEMBER_COLUMNS,'M.[MEMBER_ID]',''''+@CID+'-''+MEMBER_ID AS [MEMBER_ID]')
			SET @MEMBER_COLUMNS = REPLACE(@MEMBER_COLUMNS,'M.[MEMBER_ID_ENCRYPTED]','MEMBER_ID_ENCRYPTED + ''-' + @CID + ''' AS [MEMBER_ID_ENCRYPTED]')
			SET @PERSON_COLUMNS = dbo.fn_GET_COLUMNS_STRING('RFT_PERSON_ID','P','Y','N')
			SET @PERSON_COLUMNS = REPLACE(@PERSON_COLUMNS,'P.[PERSON_ID]','PERSON_ID+''-'+@CID+''' AS [PERSON_ID]')

			SET @SQL = 'INSERT INTO ##TEMP_MEMBERS SELECT ' + @MEMBER_COLUMNS + ',' + @MEMBER_UDF_COLUMNS + ',' + @PERSON_COLUMNS + ' FROM ' + @DB_NAME + '.dbo.MEMBER M INNER JOIN ' + @DB_NAME + '.dbo.RFT_PERSON_ID P ON M.MI_PERSON_KEY = P.PERSON_KEY INNER JOIN ' + @DB_NAME + '.dbo.MEMBER_UDF U ON M.MEMBER_UDF_KEY = U.MEMBER_UDF_KEY ' 	 
			PRINT @SQL
			EXECUTE(@SQL) 
		END

END   

CLOSE db_cursor   
DEALLOCATE db_cursor 

-- INSERT INTO RFT_PERSON_ID --
TRUNCATE TABLE RFT_PERSON_ID
exec SP_MI_TOGGLE_IDX 'RFT_PERSON_ID','OFF'

INSERT INTO RFT_PERSON_ID(PERSON_ID)
SELECT DISTINCT
	PERSON_ID
FROM ##TEMP_MEMBERS
ORDER BY PERSON_ID

exec SP_MI_TOGGLE_IDX 'RFT_PERSON_ID','ON'

DELETE FROM RFT_PERSON_ID WHERE PERSON_ID IS NULL

SET IDENTITY_INSERT RFT_PERSON_ID ON
INSERT INTO RFT_PERSON_ID(PERSON_KEY) SELECT 0
SET IDENTITY_INSERT RFT_PERSON_ID OFF

UPDATE M SET
	MI_PERSON_KEY =	COALESCE(PERSON_KEY,0)
FROM ##TEMP_MEMBERS M
	LEFT JOIN RFT_PERSON_ID P ON M.PERSON_ID = P.PERSON_ID

-- INSERT INTO MEMBER_UDF TABLE --
TRUNCATE TABLE MEMBER_UDF
exec SP_MI_TOGGLE_IDX 'MEMBER_UDF','OFF'

SET @SQL = 'INSERT INTO MEMBER_UDF(' + @MEMBER_UDF_COLUMNS_INSERT + ') SELECT DISTINCT ' + @MEMBER_UDF_COLUMNS_LOAD + ' FROM ##TEMP_MEMBERS U'
EXECUTE(@SQL)

exec SP_MI_TOGGLE_IDX 'MEMBER_UDF','ON'

SET IDENTITY_INSERT MEMBER_UDF ON
INSERT INTO MEMBER_UDF(MEMBER_UDF_KEY) SELECT 0
SET IDENTITY_INSERT MEMBER_UDF OFF


-- INSERT INTO MEMBER TABLE --
TRUNCATE TABLE MEMBER
exec SP_MI_TOGGLE_IDX 'MEMBER','OFF'
SET @SQL = 'INSERT INTO MEMBER(' + @MEMBER_COLUMNS_INSERT + ') SELECT DISTINCT ' + @MEMBER_COLUMNS_LOAD + ' FROM ##TEMP_MEMBERS M WHERE MEMBER_ID IS NOT NULL'
PRINT @SQL

EXECUTE(@SQL)
exec SP_MI_TOGGLE_IDX 'MEMBER','ON'


UPDATE M SET
	M.MEMBER_UDF_KEY = COALESCE(U.MEMBER_UDF_KEY,0)
FROM MEMBER M
	LEFT JOIN MEMBER_UDF U ON M.MEMBER_ID = U._MEM_UDF_20_


-- INDEX SERVICES_KEY TABLE --
CREATE UNIQUE CLUSTERED INDEX CONSOLIDATE_SERVICEKEY_XPK ON CST.CONSOLIDATE_SERVICEKEY(CID,S_SERVICES_KEY)

-- CLEANUP TEMPORARY TABLES --
exec sp_mi_droptable '##TEMP_PROVIDERS'
exec sp_mi_droptable '##TEMP_PROVIDERS_CW'
exec sp_mi_droptable '##TEMP_MEMBERS'
exec sp_mi_droptable '##TEMP_GROUPS'


GO


