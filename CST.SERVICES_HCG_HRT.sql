USE [MI_reg2017]
GO

/****** Object:  View [CST].[SERVICES_HCG_HRT]    Script Date: 11/21/2018 6:25:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [CST].[SERVICES_HCG_HRT]
/* SVN Version #    */
	AS SELECT 
	SERVICE_MONTH_START_DATE
,	SERVIcES_KEY
,	CLAIM_ID_KEY
,	YEAR_MO
,	PAID_MO 
,	STATE 
,	MSA 
,	EXCLUSION_CODE as HCG_EXCLUSIONCODE 
,	PARTIAL_YEAR_GROUP 
,	MEDICARE_COVERED 
,	MEMBER_AGEBAND 
,	CONTRACT_AGEBAND 
,	HCG_AGEBAND 
,	DEMOGRAPHIC_GROUP 
,	MS_DRG AS HCG_DRG
,	CMS_ERRORCODE AS HCG_ERRORCODE
,	CASE_ADMIT_ID 
,	MR_LINE 
,	MR_LINE_DET 
,	MR_LINE_CASE 
,	PBP_LINE
,	MA_LINE 
,	MA_LINE_DET 
,	SPEC_TYPE 
,	FACILITY_CASE_ID_KEY 
,	MR_ADMITS_CASES
,	MR_UNITS_DAYS 
,	MR_PROCS 
,	MR_CASES_ADMITS_PATIENTPAY 
,	MR_UNITS_DAYS_PATIENTPAY 
,	MR_PROCS_PATIENTPAY
,	MR_BILLED 
,	MR_ALLOWED 
,	MR_PAID 
,	MR_COPAY 
,	MR_COINSURANCE 
,	MR_DEDUCTIBLE 
,	MR_PATIENTPAY 
,	PBP_CASES_ADMITS 
,	PBP_CASES_ADMITS_PATIENT_PAY 
 FROM DBO.SERVICES_HCG



--$LastChangedDate: 2017-07-11 14:37:58 -0700 (Tue, 11 Jul 2017) $
--$LastChangedRevision: 32330 $
--$Author: WrightL $
--$HeadURL: https://topsvcs.medinsight.milliman.com/svn/MedInsight/branches/Database/MI_11/HRT/Core/Schemas/cst/Views/CST.SERVICES_HCG_HRT.sql $	


GO


