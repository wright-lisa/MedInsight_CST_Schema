USE [MI_CHSD2016]
GO

/****** Object:  StoredProcedure [CST].[CONSOLIDATE_03_SERVICES_KEYS]    Script Date: 3/9/2018 10:00:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE [CST].[CONSOLIDATE_03_SERVICES_KEYS]
	@DB_NAME VARCHAR(50),
	@CID VARCHAR(2)
AS

SET NOCOUNT ON

DECLARE @SQL VARCHAR(4000)
SET @SQL = 'SERVICES KEYS STARTED from ' + @DB_NAME
raiserror (@SQL, 10,1) with nowait

EXEC('

exec sp_mi_droptable ''##MEMBER_MONTH''
SELECT
	S.MEMBER_MONTH_KEY AS S_MEMBER_MONTH_KEY,
	T.MEMBER_MONTH_KEY AS T_MEMBER_MONTH_KEY
INTO ##MEMBER_MONTH
FROM ' + @DB_NAME + '.dbo.MEMBER_MONTH S
	INNER JOIN ##MEMBER M ON S.MEMBER_KEY = M.S_MEMBER_KEY
	INNER JOIN ##RFT_PROD_TYPE PR ON S.PROD_TYPE_KEY = PR.S_PROD_TYPE_KEY
	INNER JOIN MEMBER_MONTH T
		ON S.MEMBER_MONTH_START_DATE = T.MEMBER_MONTH_START_DATE
		AND M.T_MEMBER_KEY = T.MEMBER_KEY
		AND S.EFF_DATE = T.EFF_DATE
		AND S.TERM_DATE = T.TERM_DATE
		AND PR.T_PROD_TYPE_KEY = T.PROD_TYPE_KEY
		AND S.MI_POST_DATE = T.MI_POST_DATE
CREATE UNIQUE CLUSTERED INDEX XPK ON ##MEMBER_MONTH(S_MEMBER_MONTH_KEY)

exec sp_mi_droptable ''##RFT_CHECK''
SELECT
	S.CHK_KEY AS S_CHK_KEY,
	T.CHK_KEY AS T_CHK_KEY,
	S.CHK_NUM AS S_CHK_NUM,
	T.CHK_NUM AS T_CHK_NUM
INTO ##RFT_CHECK
FROM ' + @DB_NAME + '.dbo.RFT_CHECK S
	INNER JOIN RFT_CHECK T 
		ON S.CHK_NUM = T.CHK_NUM 
		OR (S.CHK_KEY = 0 AND T.CHK_KEY = 0)
CREATE UNIQUE CLUSTERED INDEX XPK ON ##RFT_CHECK(S_CHK_KEY)

exec sp_mi_droptable ''##RFT_ICD_DIAG''
SELECT
	S.ICD_DIAG_KEY AS S_ICD_DIAG_KEY,
	T.ICD_DIAG_KEY AS T_ICD_DIAG_KEY,
	S.ICD_DIAG AS S_ICD_DIAG,
	T.ICD_DIAG AS T_ICD_DIAG
INTO ##RFT_ICD_DIAG
FROM ' + @DB_NAME + '.dbo.RFT_ICD_DIAG S
	LEFT JOIN RFT_ICD_DIAG T 
		ON S.ICD_DIAG = T.ICD_DIAG 
		AND S.ICD_10_OR_HIGHER = T.ICD_10_OR_HIGHER
CREATE UNIQUE CLUSTERED INDEX XPK ON ##RFT_ICD_DIAG(S_ICD_DIAG_KEY)
WITH (IGNORE_DUP_KEY = ON)
INSERT INTO ##RFT_ICD_DIAG SELECT 0,0,NULL,NULL

exec sp_mi_droptable ''##RFT_CLAIM_IPA''
SELECT
	S.CLAIM_IPA_KEY AS S_CLAIM_IPA_KEY,
	T.CLAIM_IPA_KEY AS T_CLAIM_IPA_KEY,
	S.CLAIM_IPA AS S_CLAIM_IPA,
	T.CLAIM_IPA AS T_CLAIM_IPA
INTO ##RFT_CLAIM_IPA
FROM ' + @DB_NAME + '.dbo.RFT_CLAIM_IPA S
	LEFT JOIN RFT_CLAIM_IPA T 
		ON S.CLAIM_IPA = T.CLAIM_IPA 
		OR (S.CLAIM_IPA_KEY = 0 AND T.CLAIM_IPA_KEY = 0)
CREATE UNIQUE CLUSTERED INDEX XPK ON ##RFT_CLAIM_IPA(S_CLAIM_IPA_KEY)

exec sp_mi_droptable ''##RFT_POS''
SELECT
	S.POS_KEY AS S_POS_KEY,
	T.POS_KEY AS T_POS_KEY,
	S.POS AS S_POS,
	T.POS AS T_POS
INTO ##RFT_POS
FROM ' + @DB_NAME + '.dbo.RFT_POS S
	LEFT JOIN RFT_POS T 
		ON S.POS = T.POS 
		OR (S.POS_KEY = 0 AND T.POS_KEY = 0)
CREATE UNIQUE CLUSTERED INDEX XPK ON ##RFT_POS(S_POS_KEY)

exec sp_mi_droptable ''##RFT_TOS''
SELECT
	S.TOS_KEY AS S_TOS_KEY,
	T.TOS_KEY AS T_TOS_KEY,
	S.TOS AS S_TOS,
	T.TOS AS T_TOS
INTO ##RFT_TOS
FROM ' + @DB_NAME + '.dbo.RFT_TOS S
	LEFT JOIN RFT_TOS T 
		ON S.TOS = T.TOS 
		OR (S.TOS_KEY = 0 AND T.TOS_KEY = 0)
CREATE UNIQUE CLUSTERED INDEX XPK ON ##RFT_TOS(S_TOS_KEY)

exec sp_mi_droptable ''##RFT_PROC_CODE''
SELECT
	S.PROC_CODE_KEY AS S_PROC_CODE_KEY,
	T.PROC_CODE_KEY AS T_PROC_CODE_KEY,
	S.PROC_CODE AS S_PROC_CODE,
	T.PROC_CODE AS T_PROC_CODE
INTO ##RFT_PROC_CODE
FROM ' + @DB_NAME + '.dbo.RFT_PROC_CODE S
	LEFT JOIN RFT_PROC_CODE T 
		ON S.PROC_CODE = T.PROC_CODE 
		OR (S.PROC_CODE_KEY = 0 AND T.PROC_CODE_KEY = 0)
CREATE UNIQUE CLUSTERED INDEX XPK ON ##RFT_PROC_CODE(S_PROC_CODE_KEY)

exec sp_mi_droptable ''##RFT_CPT_MOD''
SELECT
	S.CPT_MOD_KEY AS S_CPT_MOD_KEY,
	T.CPT_MOD_KEY AS T_CPT_MOD_KEY,
	S.CPT_MOD AS S_CPT_MOD,
	T.CPT_MOD AS T_CPT_MOD
INTO ##RFT_CPT_MOD
FROM ' + @DB_NAME + '.dbo.RFT_CPT_MOD S
	LEFT JOIN RFT_CPT_MOD T 
		ON S.CPT_MOD = T.CPT_MOD AND S.CPT_MOD_KEY=T.CPT_MOD_KEY
		OR (S.CPT_MOD_KEY = 0 AND T.CPT_MOD_KEY = 0)
CREATE UNIQUE CLUSTERED INDEX XPK ON ##RFT_CPT_MOD(S_CPT_MOD_KEY)

exec sp_mi_droptable ''##RFT_MRLINE_TAB''
SELECT
	S.MR_LINE_KEY AS S_MR_LINE_KEY,
	T.MR_LINE_KEY AS T_MR_LINE_KEY,
	S.MR_LINE AS S_MR_LINE,
	T.MR_LINE AS T_MR_LINE
INTO ##RFT_MRLINE_TAB
FROM ' + @DB_NAME + '.dbo.RFT_MRLINE_TAB S
	LEFT JOIN RFT_MRLINE_TAB T 
		ON S.MR_LINE = T.MR_LINE 
		AND S.CODE_SET_YEAR = T.CODE_SET_YEAR
		OR (S.MR_LINE_KEY = 0 AND T.MR_LINE_KEY = 0)
CREATE UNIQUE CLUSTERED INDEX XPK ON ##RFT_MRLINE_TAB(S_MR_LINE_KEY)

exec sp_mi_droptable ''##RFT_PBPLINE_TAB''
SELECT
	S.PBP_LINE_KEY AS S_PBP_LINE_KEY,
	T.PBP_LINE_KEY AS T_PBP_LINE_KEY,
	S.PBP_LINE AS S_PBP_LINE,
	T.PBP_LINE AS T_PBP_LINE
INTO ##RFT_PBPLINE_TAB
FROM ' + @DB_NAME + '.dbo.RFT_PBPLINE_TAB S
	LEFT JOIN RFT_PBPLINE_TAB T 
		ON S.PBP_LINE = T.PBP_LINE 
		AND S.CODE_SET_YEAR = T.CODE_SET_YEAR
		OR (S.PBP_LINE_KEY = 0 AND T.PBP_LINE_KEY = 0)
CREATE UNIQUE CLUSTERED INDEX XPK ON ##RFT_PBPLINE_TAB(S_PBP_LINE_KEY)

exec sp_mi_droptable ''##RFT_NDC''
SELECT
	S.NDC_KEY AS S_NDC_KEY,
	T.NDC_KEY AS T_NDC_KEY,
	S.NDC AS S_NDC,
	T.NDC AS T_NDC,
	T.RX_THER_CLASS_KEY
INTO ##RFT_NDC
FROM ' + @DB_NAME + '.dbo.RFT_NDC S
	LEFT JOIN RFT_NDC T 
		ON S.NDC = T.NDC 
CREATE UNIQUE CLUSTERED INDEX XPK ON ##RFT_NDC(S_NDC_KEY)

')

SET @SQL = 'SERVICES KEYS CREATED from ' + @DB_NAME
raiserror (@SQL, 10,1) with nowait


GO


