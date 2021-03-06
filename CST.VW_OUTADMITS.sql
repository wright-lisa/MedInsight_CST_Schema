USE [MI_reg2017]
GO

/****** Object:  View [CST].[VW_OUTADMITS]    Script Date: 11/21/2018 6:17:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [CST].[VW_OUTADMITS]
/* SVN Version #    */
	AS SELECT
	[CASEADMITID]
      ,[CONTRACTID]
      ,[MI_PERSON_KEY]
      ,[PROVIDERID]
      ,[ADMITDATE]
      ,[DISCHARGEDATE]
      ,[LOS]
      ,[ICDVERSION]
      ,[ADMITDIAG]
      ,[ICDDIAG1]
      ,[ICDDIAG2]
      ,[ICDDIAG3]
      ,[ICDDIAG4]
      ,[ICDDIAG5]
      ,[ICDDIAG6]
      ,[ICDDIAG7]
      ,[ICDDIAG8]
      ,[ICDDIAG9]
      ,[ICDDIAG10]
      ,[ICDDIAG11]
      ,[ICDDIAG12]
      ,[ICDDIAG13]
      ,[ICDDIAG14]
      ,[ICDDIAG15]
      ,[ICDDIAG16]
      ,[ICDDIAG17]
      ,[ICDDIAG18]
      ,[ICDDIAG19]
      ,[ICDDIAG20]
      ,[ICDDIAG21]
      ,[ICDDIAG22]
      ,[ICDDIAG23]
      ,[ICDDIAG24]
      ,[ICDDIAG25]
      ,[ICDDIAG26]
      ,[ICDDIAG27]
      ,[ICDDIAG28]
      ,[ICDDIAG29]
      ,[ICDDIAG30]
      ,[POA1]
      ,[POA2]
      ,[POA3]
      ,[POA4]
      ,[POA5]
      ,[POA6]
      ,[POA7]
      ,[POA8]
      ,[POA9]
      ,[POA10]
      ,[POA11]
      ,[POA12]
      ,[POA13]
      ,[POA14]
      ,[POA15]
      ,[POA16]
      ,[POA17]
      ,[POA18]
      ,[POA19]
      ,[POA20]
      ,[POA21]
      ,[POA22]
      ,[POA23]
      ,[POA24]
      ,[POA25]
      ,[POA26]
      ,[POA27]
      ,[POA28]
      ,[POA29]
      ,[POA30]
      ,[ICDPROC1]
      ,[ICDPROC2]
      ,[ICDPROC3]
      ,[ICDPROC4]
      ,[ICDPROC5]
      ,[ICDPROC6]
      ,[ICDPROC7]
      ,[ICDPROC8]
      ,[ICDPROC9]
      ,[ICDPROC10]
      ,[ICDPROC11]
      ,[ICDPROC12]
      ,[ICDPROC13]
      ,[ICDPROC14]
      ,[ICDPROC15]
      ,[ICDPROC16]
      ,[ICDPROC17]
      ,[ICDPROC18]
      ,[ICDPROC19]
      ,[ICDPROC20]
      ,[ICDPROC21]
      ,[ICDPROC22]
      ,[ICDPROC23]
      ,[ICDPROC24]
      ,[ICDPROC25]
      ,[ICDPROC26]
      ,[ICDPROC27]
      ,[ICDPROC28]
      ,[ICDPROC29]
      ,[ICDPROC30]
      ,[DISCHARGESTATUS]
      ,[ADMITSOURCE]
      ,[ADMITTYPE]
      ,[DOB]
      ,[GENDER]
      ,[MR_BILLED]
      ,[MR_ALLOWED]
      ,[MR_PATIENTPAY]
      ,[COB]
      ,[MR_PAID]
      ,[MS_DRG] AS HCG_DRG
      ,[MDC]
      ,[CMS_ERRORCODE]as HCG_ERRORCODE
      ,[YEARMO]
      ,[MR_LINE_CASE]
      ,[MR_UNITS_DAYS]
      ,[DAYS_MATCHBASIS]
      ,[DAYS_ICU]
      ,[DAYS_CCU]
      ,[DAYS_INTICU]
      ,[DAYS_INTCCU]
      ,[DAYS_REHAB]
      ,[DAYS_NUR1]
      ,[DAYS_NUR2]
      ,[DAYS_NUR3]
      ,[DAYS_NUR4]
      ,[DAYS_NURX]
      ,[DAYS_PSYCH]
      ,[DAYS_DETOX]
      ,[DAYS_BHALT]
      ,[DAYS_OTH]
      ,[DAYS_ALL]
      ,[DAYS_XXX]
      ,[DAYS_BAD]
      ,[TELE_FLAG]
      ,[ER_FLAG]
      ,[OBSERVATION_FLAG]
      ,[CLAIMCOUNT]
      ,[LOB]
      ,[PRODUCT]
      ,[GROUPID]
      ,[ZIP]
      ,[COUNTY]
      ,[STATE]
      ,[MSA]
      ,[EXCLUSIONCODE]
      ,[PARTIALYEARGROUP]
      ,[HCGINDICATOR]
      ,[MEMBERAGEBAND]
      ,[CONTRACTAGEBAND]
      ,[HCGAGEBAND]
      ,[DEMOGRAPHICGROUP]
      ,[EligAnchorFlagHWR]
      ,[EligAnchorFlagIPF]
      ,[AnchorAdmitFlag]
      ,[ReadmitFlag]
      ,[ReadmitId]
      ,[AnchorAdmitId]
      ,[ROM]
      ,[SOI]
	
	 FROM [dbo].[HCG_ADMITS_REPORT]


--$LastChangedDate: 2017-06-19 12:15:24 -0700 (Mon, 19 Jun 2017) $
--$LastChangedRevision: 31782 $
--$Author: ssamario $
--$HeadURL: https://topsvcs.medinsight.milliman.com/svn/MedInsight/branches/Database/MI_11/HRT/Core/Schemas/cst/Views/CST.VW_OUTADMITS.sql $	

GO


