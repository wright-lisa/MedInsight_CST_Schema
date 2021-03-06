USE [MI_CBC2017]
GO

/****** Object:  View [CST].[VW_MEMBMTHS]    Script Date: 11/1/2018 3:36:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [CST].[VW_MEMBMTHS]
/* SVN Version #    */
/* SVN Version #    */
AS

SELECT 	 
	  '' AS [*=== DATES ===*]
	  ,MM.[MEMBER_MONTH_START_DATE]
	  ,Y.YR_MO AS INCURRED_YEAR_AND_MONTH
	  ,Y.YR AS INCURRED_YEAR
	  ,Y.CALENDAR_QUARTER AS INCURRED_CAL_QUARTER
	  ,Y.FISCAL_YEAR AS INCURRED_FISCAL_YEAR
	  ,Y.FISCAL_QUARTER AS INCURRED_FISCAL_QUARTER
	  ,'' AS [*=== MEMBER/ELIGIBILITY ===*]
      ,MM.MEMBER_KEY
      ,M.MEMBER_ID
	  ,M.MI_PERSON_KEY
      ,M.MEMBER_ID_ENCRYPTED AS MEMBER_ID_ENCRYPTED
      --LW Added 7/21
      ,MM.SUBSCRIBER_KEY
      ,SUBSCR.MEMBER_ID AS SUBSCRIBER_ID
     -- ,dbo.FN_MI_ENCRYPT(SUBSCR.MEMBER_ID) AS SUBSCRIBER_ID_ENCRYPTED
      ,REL.MI_RELATION AS RELATION
      ,MM.EFF_DATE
      ,MM.TERM_DATE
      ,PT.PROD_TYPE
      ,MM.PROD_TYPE_KEY
      ,MM.MI_POST_DATE
     -- ,TR.TERM_RSN
      ,MM.[AGE]
      ,'AGE_MASKED' =
	  CASE
	    WHEN MM.AGE > = 89 THEN 89
	    ELSE MM.AGE
	  END
	  
      ,AB.AGE_BAND_NAME
      ,MM.[GENDER]
       ,M.MEM_DOB
      ,'MEM_DOB_MASKED' =
	   CASE
	   WHEN MM.AGE <  2 THEN M.MEM_DOB
	   WHEN MM.AGE >= 2 AND MM.AGE <= 89 THEN CONVERT(date, '07/15/'+cast(DATEPART(YYYY,M.MEM_DOB) as varchar),101)
	   WHEN MM.AGE > 89 THEN CONVERT(DATE,'07/15/'+cast((y.yr - 89) AS varchar),101)
	   ELSE NULL
	   END
      ,MM.[ZIP3]
	  ,MEMLOC.MEM_ZIP AS MEMBER_ZIP
	  ,MEMLOC.MEM_COUNTY  AS MEMBER_COUNTY 
	  ,MEMLOC.MEM_STATE  AS MEMBER_STATE
	  ,MEMLOC.MEM_MSA_CODE AS MEMBER_MSA_CODE 
	  ,MEMLOC.MEM_MSA_NAME AS MEMBER_MSA_NAME
	 
	,MEMHH.MEMBER_HOSPITAL_REFERRAL_AREA_CITY
	,MEMHH.MEMBER_HOSPITAL_REFERRAL_AREA_NUMBER
	,MEMHH.MEMBER_HOSPITAL_REFERRAL_AREA_STATE
	,MEMHH.MEMBER_HOSPITAL_SERVICE_AREA_CITY
	,MEMHH.MEMBER_HOSPITAL_SERVICE_AREA_NUMBER
	,MEMHH.MEMBER_HOSPITAL_SERVICE_AREA_STATE
	--  ,MS.[MEM_STAT]
    --  ,TT.TIER
      
	  ,MMP.PAYER_TYPE
	  ,MMPL.PAYER_LOB 
	  ,MM.ENR_PRIMARY			
  	  ,MM.MEDICAID_PART_B_BUYIN	 
	  ,MM.MEDICAID_BASIS			 
	  ,MM.MEDICARE_DUAL	AS DualEligibleIndicator	 
	  ,MM.MEDICARE_BASIS
	  --,MM.MEDICARE_BASIS+' - '+MEL.MEDICARE_BASIS_DESC AS MEDICARE_BASIS_DESC
      ,'' AS [*=== EMPLOYER GROUP ===*]
	  ,G.GRP_KEY
  	  ,G.GRP_TYPE AS GROUP_TYPE
	  ,G.MI_GRP_TYPE AS MI_GROUP_TYPE
	  ,G.GRP_ID AS GRP_ID
	  --,G.GRP_NAME AS GRP_NAME
	  ,G.GRP_SIC AS GRP_SIC
	  --,GS.SIC_DESC AS GRP_SIC_DESC
 	  --,GN.NAICS AS GRP_NAICS_DESC
 	  /*
      ,GU._GRP_UDF_01_
      ,GU._GRP_UDF_02_
      ,GU._GRP_UDF_03_
      ,GU._GRP_UDF_04_
      ,GU._GRP_UDF_05_
      ,GU._GRP_UDF_06_
      ,GU._GRP_UDF_07_
      ,GU._GRP_UDF_08_
      ,GU._GRP_UDF_09_
      ,GU._GRP_UDF_10_
      ,GU._GRP_UDF_11_
      ,GU._GRP_UDF_12_
      ,GU._GRP_UDF_13_
      ,GU._GRP_UDF_14_
      ,GU._GRP_UDF_15_
      ,GU._GRP_UDF_16_
      ,GU._GRP_UDF_17_
      ,GU._GRP_UDF_18_
      ,GU._GRP_UDF_19_
      ,GU._GRP_UDF_20_
	  ,GR._GRP_LVL_01_ AS _GRP_LVL_01_
	  ,GR._GRP_LVL_02_ AS _GRP_LVL_02_
	  ,GR._GRP_LVL_03_ AS _GRP_LVL_03_
      ,MM.[HIRE_DATE]
      */
	  ,'' AS [*=== SOURCE PCP ===*]
	  ,CASE WHEN P.PROV_KEY=0 THEN NULL ELSE P.PROV_KEY END AS PCP_PROV_ID
	  --,dbo.FN_MI_ENCRYPT(P.PROV_ID) as PCP_PROV_ID_ENCRYPTED
	  --,P.PROV_LNAME AS PCP_PROV_LNAME
	  --,P.PROV_FNAME AS PCP_PROV_FNAME
	  ,PCPLOC.PROV_ZIP AS PCP_ZIP
	--  ,CST.FN_MASKZIP(PCPLOC.PROV_ZIP) AS PCP_ZIP_MASKED
	  --,PCPLOC.PROV_COUNTY AS PCP_COUNTY
	  /*
	  ,PCPLOC.PROV_STATE AS PCP_STATE
	  ,PCPLOC.PROV_MSA_CODE AS PCP_MSA_CODE
	  ,PCPLOC.PROV_MSA_NAME AS PCP_MSA_NAME
	,PCPCL.PROV_CLINIC_ID AS PCP_PROV_CLINIC_ID
	,PCPCL.PROV_CLINIC_NAME AS PCP_PROV_CLINIC_NAME
	,PCPGRP.PROV_GRP_ID AS PCP_PROV_GRP_ID
	,PCPGRP.PROV_GRP_NAME AS PCP_PROV_GRP_NAME
	,PCPU._PROV_UDF_01_ AS PCP_PROV_UDF_01_
	,PCPU._PROV_UDF_02_ AS PCP_PROV_UDF_02_
	,PCPU._PROV_UDF_03_ AS PCP_PROV_UDF_03_
	,PCPU._PROV_UDF_04_ AS PCP_PROV_UDF_04_
	,PCPU._PROV_UDF_05_ AS PCP_PROV_UDF_05_
	,PCPU._PROV_UDF_06_ AS PCP_PROV_UDF_06_
	,PCPU._PROV_UDF_07_ AS PCP_PROV_UDF_07_
	,PCPU._PROV_UDF_08_ AS PCP_PROV_UDF_08_
	,PCPU._PROV_UDF_09_ AS PCP_PROV_UDF_09_
	,PCPU._PROV_UDF_10_ AS PCP_PROV_UDF_10_
	,PCPU._PROV_UDF_11_ AS PCP_PROV_UDF_11_
	,PCPU._PROV_UDF_12_ AS PCP_PROV_UDF_12_
	,PCPU._PROV_UDF_13_ AS PCP_PROV_UDF_13_
	,PCPU._PROV_UDF_14_ AS PCP_PROV_UDF_14_
	,PCPU._PROV_UDF_15_ AS PCP_PROV_UDF_15_
	,PCPU._PROV_UDF_16_ AS PCP_PROV_UDF_16_
	,PCPU._PROV_UDF_17_ AS PCP_PROV_UDF_17_
	,PCPU._PROV_UDF_18_ AS PCP_PROV_UDF_18_
	,PCPU._PROV_UDF_19_ AS PCP_PROV_UDF_19_
	,PCPU._PROV_UDF_20_ AS PCP_PROV_UDF_20_
	*/
	  ,'' AS [*=== ATTRIBUTED PROVIDERS (MM BASED) ===*]
	  /*
	  ,CONVERT(BIT,CASE WHEN ATPP1.PROV_ID IS NULL THEN 0 ELSE 1 END) AS PCP_PROV_ATTRIBUTED
	  ,ATPP1.PROV_ID AS _ATP1_PROV_ID
	  ,ATPP1.PROV_LNAME AS _ATP1_PROV_LNAME
	  ,ATPP1.PROV_FNAME AS _ATP1_PROV_FNAME
	  ,ATP1SPEC.MI_PROV_SPEC AS _ATP1_SPECIALTY
	  ,ATP1LOC.PROV_ZIP AS _ATP1_ZIP
	  ,ATP1LOC.PROV_COUNTY AS _ATP1_COUNTY
	  ,ATP1LOC.PROV_STATE AS _ATP1_STATE
	  ,ATP1LOC.PROV_MSA_CODE AS _ATP1_MSA_CODE
	  ,ATP1LOC.PROV_MSA_NAME AS _ATP1_MSA_NAME
	,ATP1CL.PROV_CLINIC_ID AS _ATP1_PROV_CLINIC_ID
	,ATP1CL.PROV_CLINIC_NAME AS _ATP1_PROV_CLINIC_NAME
	,ATP1GRP.PROV_GRP_ID AS _ATP1_PCP_PROV_GRP_ID
	,ATP1GRP.PROV_GRP_NAME AS _ATP1_PROV_GRP_NAME
    ,ATPP1.PROV_GROUP_ACO_NAME AS _ATP1_PROV_GROUP_ACO_NAME
	,ATPPU1._PROV_UDF_01_ AS _ATP1_PROV_UDF_01_
	,ATPPU1._PROV_UDF_02_ AS _ATP1_PROV_UDF_02_
	,ATPPU1._PROV_UDF_03_ AS _ATP1_PROV_UDF_03_
	,ATPPU1._PROV_UDF_04_ AS _ATP1_PROV_UDF_04_
	,ATPPU1._PROV_UDF_05_ AS _ATP1_PROV_UDF_05_
	,ATPPU1._PROV_UDF_06_ AS _ATP1_PROV_UDF_06_
	,ATPPU1._PROV_UDF_07_ AS _ATP1_PROV_UDF_07_
	,ATPPU1._PROV_UDF_08_ AS _ATP1_PROV_UDF_08_
	,ATPPU1._PROV_UDF_09_ AS _ATP1_PROV_UDF_09_
	,ATPPU1._PROV_UDF_10_ AS _ATP1_PROV_UDF_10_
	,ATPPU1._PROV_UDF_11_ AS _ATP1_PROV_UDF_11_
	,ATPPU1._PROV_UDF_12_ AS _ATP1_PROV_UDF_12_
	,ATPPU1._PROV_UDF_13_ AS _ATP1_PROV_UDF_13_
	,ATPPU1._PROV_UDF_14_ AS _ATP1_PROV_UDF_14_
	,ATPPU1._PROV_UDF_15_ AS _ATP1_PROV_UDF_15_
	,ATPPU1._PROV_UDF_16_ AS _ATP1_PROV_UDF_16_
	,ATPPU1._PROV_UDF_17_ AS _ATP1_PROV_UDF_17_
	,ATPPU1._PROV_UDF_18_ AS _ATP1_PROV_UDF_18_
	,ATPPU1._PROV_UDF_19_ AS _ATP1_PROV_UDF_19_
	,ATPPU1._PROV_UDF_20_ AS _ATP1_PROV_UDF_20_
	  ,ATPP2.PROV_ID AS _ATP2_PROV_ID
	  ,ATPP2.PROV_LNAME AS _ATP2_PROV_LNAME
	  ,ATPP2.PROV_FNAME AS _ATP2_PROV_FNAME
	  ,ATP2SPEC.MI_PROV_SPEC AS _ATP2_SPECIALTY
	  ,ATP2LOC.PROV_ZIP AS _ATP2_ZIP
	  ,ATP2LOC.PROV_COUNTY AS _ATP2_COUNTY
	  ,ATP2LOC.PROV_STATE AS _ATP2_STATE
	  ,ATP2LOC.PROV_MSA_CODE AS _ATP2_MSA_CODE
	  ,ATP2LOC.PROV_MSA_NAME AS _ATP2_MSA_NAME
	,ATP2CL.PROV_CLINIC_ID AS _ATP2_PROV_CLINIC_ID
	,ATP2CL.PROV_CLINIC_NAME AS _ATP2_PROV_CLINIC_NAME
	,ATP2GRP.PROV_GRP_ID AS _ATP2_PCP_PROV_GRP_ID
	,ATP2GRP.PROV_GRP_NAME AS _ATP2_PROV_GRP_NAME
    ,ATPP2.PROV_GROUP_ACO_NAME AS _ATP2_PROV_GROUP_ACO_NAME
	  ,ATPP3.PROV_ID AS _ATP3_PROV_ID
	  ,ATPP3.PROV_LNAME AS _ATP3_PROV_LNAME
	  ,ATPP3.PROV_FNAME AS _ATP3_PROV_FNAME
	  ,ATP3SPEC.MI_PROV_SPEC AS _ATP3_SPECIALTY
	  ,ATP3LOC.PROV_ZIP AS _ATP3_ZIP
	  ,ATP3LOC.PROV_COUNTY AS _ATP3_COUNTY
	  ,ATP3LOC.PROV_STATE AS _ATP3_STATE
	  ,ATP3LOC.PROV_MSA_CODE AS _ATP3_MSA_CODE
	  ,ATP3LOC.PROV_MSA_NAME AS _ATP3_MSA_NAME
	,ATP3CL.PROV_CLINIC_ID AS _ATP3_PROV_CLINIC_ID
	,ATP3CL.PROV_CLINIC_NAME AS _ATP3_PROV_CLINIC_NAME
	,ATP3GRP.PROV_GRP_ID AS _ATP3_PCP_PROV_GRP_ID
	,ATP3GRP.PROV_GRP_NAME AS _ATP3_PROV_GRP_NAME
    ,ATPP3.PROV_GROUP_ACO_NAME AS _ATP3_PROV_GROUP_ACO_NAME
	  ,ATPP4.PROV_ID AS _ATP4_PROV_ID
	  ,ATPP4.PROV_LNAME AS _ATP4_PROV_LNAME
	  ,ATPP4.PROV_FNAME AS _ATP4_PROV_FNAME
	  ,ATP4SPEC.MI_PROV_SPEC AS _ATP4_SPECIALTY
	  ,ATP4LOC.PROV_ZIP AS _ATP4_ZIP
	  ,ATP4LOC.PROV_COUNTY AS _ATP4_COUNTY
	  ,ATP4LOC.PROV_STATE AS _ATP4_STATE
	  ,ATP4LOC.PROV_MSA_CODE AS _ATP4_MSA_CODE
	  ,ATP4LOC.PROV_MSA_NAME AS _ATP4_MSA_NAME
	,ATP4CL.PROV_CLINIC_ID AS _ATP4_PROV_CLINIC_ID
	,ATP4CL.PROV_CLINIC_NAME AS _ATP4_PROV_CLINIC_NAME
	,ATP4GRP.PROV_GRP_ID AS _ATP4_PCP_PROV_GRP_ID
	,ATP4GRP.PROV_GRP_NAME AS _ATP4_PROV_GRP_NAME
    ,ATPP4.PROV_GROUP_ACO_NAME AS _ATP4_PROV_GROUP_ACO_NAME
	  ,ATPP5.PROV_ID AS _ATP5_PROV_ID
	  ,ATPP5.PROV_LNAME AS _ATP5_PROV_LNAME
	  ,ATPP5.PROV_FNAME AS _ATP5_PROV_FNAME
	  ,ATP5SPEC.MI_PROV_SPEC AS _ATP5_SPECIALTY
	  ,ATP5LOC.PROV_ZIP AS _ATP5_ZIP
	  ,ATP5LOC.PROV_COUNTY AS _ATP5_COUNTY
	  ,ATP5LOC.PROV_STATE AS _ATP5_STATE
	  ,ATP5LOC.PROV_MSA_CODE AS _ATP5_MSA_CODE
	  ,ATP5LOC.PROV_MSA_NAME AS _ATP5_MSA_NAME
	,ATP5CL.PROV_CLINIC_ID AS _ATP5_PROV_CLINIC_ID
	,ATP5CL.PROV_CLINIC_NAME AS _ATP5_PROV_CLINIC_NAME
	,ATP5GRP.PROV_GRP_ID AS _ATP5_PCP_PROV_GRP_ID
	,ATP5GRP.PROV_GRP_NAME AS _ATP5_PROV_GRP_NAME
    ,ATPP5.PROV_GROUP_ACO_NAME AS _ATP5_PROV_GROUP_ACO_NAME
      ,ACO.ACO_ID 
      ,MH.MED_HOME_ID
      */
      ,'' AS [*=== COVERAGE ===*]
	  ,MM.HHS_PLAN_METAL_LEVEL
	  ,MM.HHS_CSR_VALUE AS HHS_CSR_LEVEL
	  ,CSR.CSR_Level AS HHS_CSR_LEVEL_DESC
      --,TIER.[TIER_KEY]
      --,CT.[CONTRACT]
	  --,BEN.BEN_PKG_ID AS BEN_PKG_ID
      ,[MM_UNITS]
      ,[RX_UNITS]
      ,[DN_UNITS]
      ,[VS_UNITS]
      --,[_USER_COVERAGE_IND_01_]
     -- ,[_USER_COVERAGE_IND_02_]
     --- ,[_USER_COVERAGE_IND_03_]
      --,[_USER_COVERAGE_IND_04_]
      ,CASE WHEN MM.MEMBER_KEY = MM.SUBSCRIBER_KEY OR REL.MI_RELATION = 'SUBSCRIBER' THEN [MM_UNITS] ELSE 0 END AS SUB_MM_UNITS
      ,CASE WHEN MM.MEMBER_KEY = MM.SUBSCRIBER_KEY OR REL.MI_RELATION = 'SUBSCRIBER' THEN [RX_UNITS] ELSE 0 END AS SUB_RX_UNITS
      ,CASE WHEN MM.MEMBER_KEY = MM.SUBSCRIBER_KEY OR REL.MI_RELATION = 'SUBSCRIBER' THEN [DN_UNITS] ELSE 0 END AS SUB_DN_UNITS
      ,CASE WHEN MM.MEMBER_KEY = MM.SUBSCRIBER_KEY OR REL.MI_RELATION = 'SUBSCRIBER' THEN [VS_UNITS] ELSE 0 END AS SUB_VS_UNITS
    --  ,CASE WHEN MM.MEMBER_KEY = MM.SUBSCRIBER_KEY THEN [_USER_COVERAGE_IND_01_] ELSE 0 END AS [SUB_USER_COVERAGE_IND_01_]
     -- ,CASE WHEN MM.MEMBER_KEY = MM.SUBSCRIBER_KEY THEN [_USER_COVERAGE_IND_02_] ELSE 0 END AS [SUB_USER_COVERAGE_IND_02_]
    --  ,CASE WHEN MM.MEMBER_KEY = MM.SUBSCRIBER_KEY THEN [_USER_COVERAGE_IND_03_] ELSE 0 END AS [SUB_USER_COVERAGE_IND_03_]
    --  ,CASE WHEN MM.MEMBER_KEY = MM.SUBSCRIBER_KEY THEN [_USER_COVERAGE_IND_04_] ELSE 0 END AS [SUB_USER_COVERAGE_IND_04_]
	  ,'' AS [*=== CLIENT BUSINESS DIMENSIONS ===*]
	,CASE WHEN MM._MI_USER_DIM_01_KEY=0 THEN NULL ELSE UD1._MI_USER_DIM_01_ END AS LOB
	,CASE WHEN MM._MI_USER_DIM_02_KEY=0 THEN NULL ELSE UD2._MI_USER_DIM_02_ END AS PRODUCT
	,CASE WHEN MM._MI_USER_DIM_03_KEY=0 THEN 'N' ELSE UD3._MI_USER_DIM_03_ END AS HCGINDICATOR
	,CASE WHEN MM._MI_USER_DIM_04_KEY=0 THEN NULL ELSE UD4._MI_USER_DIM_04_ END AS EXCLUSIONCODE
	,CASE WHEN MM._MI_USER_DIM_05_KEY=0 THEN NULL ELSE UD5._MI_USER_DIM_05_ END AS PARTIALYEARGROUP
	,CASE WHEN MM._MI_USER_DIM_06_KEY=0 THEN NULL ELSE UD6._MI_USER_DIM_06_ END AS DEMOGRAPHICGROUP
	,CASE WHEN MM._MI_USER_DIM_07_KEY=0 THEN NULL ELSE UD7._MI_USER_DIM_07_ END AS MEMBERAGEBAND
	,CASE WHEN MM._MI_USER_DIM_08_KEY=0 THEN NULL ELSE UD8._MI_USER_DIM_08_ END AS CONTRACTAGEBAND
	,CASE WHEN MM._MI_USER_DIM_09_KEY=0 THEN NULL ELSE UD9._MI_USER_DIM_09_ END AS HCGAGEBAND
	,CASE WHEN MM._MI_USER_DIM_10_KEY=0 THEN NULL ELSE UD10._MI_USER_DIM_10_ END AS CONTRIBUTORID
	/*
	,UD1._MI_USER_DIM_01_DESC AS _MI_USER_DIM_01_DESC
	,UD2._MI_USER_DIM_02_DESC AS _MI_USER_DIM_02_DESC
	,UD3._MI_USER_DIM_03_DESC AS _MI_USER_DIM_03_DESC
	,UD4._MI_USER_DIM_04_DESC AS _MI_USER_DIM_04_DESC
	,UD5._MI_USER_DIM_05_DESC AS _MI_USER_DIM_05_DESC
	,UD6._MI_USER_DIM_06_DESC AS _MI_USER_DIM_06_DESC
	,UD7._MI_USER_DIM_07_DESC AS _MI_USER_DIM_07_DESC
	,UD8._MI_USER_DIM_08_DESC AS _MI_USER_DIM_08_DESC
	,UD9._MI_USER_DIM_09_DESC AS _MI_USER_DIM_09_DESC
	,UD10._MI_USER_DIM_10_DESC AS _MI_USER_DIM_10_DESC
	,UD1._MI_USER_DIM_01_CODE_AND_DESC AS _MI_USER_DIM_01_CODE_AND_DESC
	,UD2._MI_USER_DIM_02_CODE_AND_DESC AS _MI_USER_DIM_02_CODE_AND_DESC
	,UD3._MI_USER_DIM_03_CODE_AND_DESC AS _MI_USER_DIM_03_CODE_AND_DESC
	,UD4._MI_USER_DIM_04_CODE_AND_DESC AS _MI_USER_DIM_04_CODE_AND_DESC
	,UD5._MI_USER_DIM_05_CODE_AND_DESC AS _MI_USER_DIM_05_CODE_AND_DESC
	,UD6._MI_USER_DIM_06_CODE_AND_DESC AS _MI_USER_DIM_06_CODE_AND_DESC
	,UD7._MI_USER_DIM_07_CODE_AND_DESC AS _MI_USER_DIM_07_CODE_AND_DESC
	,UD8._MI_USER_DIM_08_CODE_AND_DESC AS _MI_USER_DIM_08_CODE_AND_DESC
	,UD9._MI_USER_DIM_09_CODE_AND_DESC AS _MI_USER_DIM_09_CODE_AND_DESC
	,UD10._MI_USER_DIM_10_CODE_AND_DESC AS _MI_USER_DIM_10_CODE_AND_DESC
	*/
      ,DS.[DATA_SOURCE] AS DATA_SOURCE
      ,'' AS [*=== PREMIUM ===*]
      /*
      ,COALESCE(PX3.SETTING,'N/A') AS PREMIUM_GRAIN
      ,PREM.PREM_EMPLOYER_PAID AS PREMIUM_EMPLOYER_PAID
      ,PREM.PREM_EMPLOYEE_PAID AS PREMIUM_EMPLOYEE_PAID
      */
      ,'' AS [*=== CCHG ===*]
      
      ,CCHG.CCHG_CAT
	  ,CCHGR.CCHG_DESC AS CCHG_DESC
	  ,CCHGR.CCHG_CAT_CODE_AND_DESC AS CCHG_CAT_CODE_AND_DESC
	  
      ,'' AS [*=== MARA HCC ===*]
      
	  ,MARAHCC.ModelName AS MARAHHS_MODEL
	  ,MARAHCC.Final AS MARAHHS_FINAL
	  ,MARAHCC.Catastrophic AS MARAHHS_CATASTROPHIC
	  ,MARAHCC.Catastrophic_CSR AS MARAHHS_CATASTROPHIC_CSR
	  ,MARAHCC.Bronze AS MARAHHS_BRONZE
	  ,MARAHCC.Bronze_CSR AS MARAHHS_BRONZE_CSR
	  ,MARAHCC.Silver AS MARAHHS_SILVER
	  ,MARAHCC.Silver_CSR AS MARAHHS_SILVER_CSR
	  ,MARAHCC.Gold AS MARAHHS_GOLD
	  ,MARAHCC.Gold_CSR MARAHHS_GOLD_CSR
	  ,MARAHCC.Platinum AS MARAHHS_PLATINUM
	  ,MARAHCC.Platinum_CSR AS MARAHHS_PLATINUM_CSR
	  ,MARAHCC.HHSYEAR AS HHSYEAR
      ,'' AS [*=== MARA RISK ===*]
     
      ,MARAA.MARA_MODEL_ID AS MARA_AGESEX_MODEL
      ,MARA.AS_TOTAL AS MARA_AGESEX_TOTAL_RISK
      ,MARAC.MARA_MODEL_ID AS MARA_CONC_MODEL
      ,MARA.CON_TOTAL AS MARA_CONC_TOTAL_RISK
      ,MARA.CON_RX AS MARA_CONC_RX_RISK
      ,MARA.CON_MEDICAL AS MARA_CONC_MEDICAL_RISK
      ,MARA.CON_IP AS MARA_CONC_IP_RISK
      ,MARA.CON_OP AS MARA_CONC_OP_RISK
      ,MARA.CON_PHYSICIAN AS MARA_CONC_PHYSICIAN_RISK
	  ,MARA.CON_ER AS MARA_CONC_ER_RISK
	  ,MARA.CON_OTH AS MARA_CONC_OTH_RISK
      ,MARAP.MARA_MODEL_ID AS MARA_PROSP_MODEL
      ,MARA.PRO_TOTAL AS MARA_PROSP_TOTAL_RISK
      ,MARA.PRO_RX AS MARA_PROSP_RX_RISK
      ,MARA.PRO_MEDICAL AS MARA_PROSP_MEDICAL_RISK
      ,MARA.PRO_IP AS MARA_PROSP_IP_RISK
      ,MARA.PRO_OP AS MARA_PROSP_OP_RISK
      ,MARA.PRO_PHYSICIAN AS MARA_PROSP_PHYSICIAN_RISK
	  ,MARA.PRO_ER AS MARA_PROSP_ER_RISK
	  ,MARA.PRO_OTH AS MARA_PROSP_OTH_RISK
	 
      ,'' AS [*=== MARA PRIMARY RISK CONDITION ===*]
      /*
	,MARACC.[CLINICAL_LABEL] AS MARA_CONC_PRIMARY_RISK_CONDITION
	,MARACC.[C_CODE] + ' - ' + MARACC.[CLINICAL_LABEL] AS MARA_CONC_PRIMARY_RISK_CODE_AND_CONDITION
	,MARACC.MARA_SUMMARY_GROUP_DESCRIPTION AS MARA_CONC_SUMMARY_GROUP_DESCRIPTION
	,MARACC.MARA_AHRQ_CHRONIC AS MARA_CONC_AHRQ_CHRONIC
	,MARACC.MARA_AHRQ_COMMON_CHRONIC AS MARA_CONC_AHRQ_COMMON_CHRONIC
	,MARAPC.[CLINICAL_LABEL] AS MARA_PROSP_PRIMARY_RISK_CONDITION
	,MARAPC.[C_CODE] + ' - ' + MARAPC.[CLINICAL_LABEL] AS MARA_PROSP_PRIMARY_RISK_CODE_AND_CONDITION
	,MARAPC.MARA_SUMMARY_GROUP_DESCRIPTION AS MARA_PROSP_SUMMARY_GROUP_DESCRIPTION
	,MARAPC.MARA_AHRQ_CHRONIC AS MARA_PROSP_AHRQ_CHRONIC
	,MARAPC.MARA_AHRQ_COMMON_CHRONIC AS MARA_PROSP_AHRQ_COMMON_CHRONIC
	*/
      ,'' AS [*=== ERG RISK ===*]
      /*
	  ,ERG.ERG_PROSPECTIVE_RISK AS ERG_PROSPECTIVE_RISK
	  ,ERG.ERG_RETROSPECTIVE_RISK AS ERG_RETROSPECTIVE_RISK
	  ,ERG.ERG_DEMOGRAPHIC_RISK AS ERG_DEMOGRAPHIC_RISK
	  ,ERG.ERG_ACTUARIAL_PROSPECTIVE_RISK AS ERG_ACTUARIAL_PROSPECTIVE_RISK
	  ,ERG.ERG_PROSPECTIVE_RISK_CATEGORY AS ERG_PROSPECTIVE_RISK_CATEGORY
	  ,ERG.ERG_RETROSPECTIVE_RISK_CATEGORY AS ERG_RETROSPECTIVE_RISK_CATEGORY
	  ,ERG.ERG_ACTUARIAL_RISK_CATEGORY AS ERG_ACTUARIAL_RISK_CATEGORY
	  ,ERG.ERG_PARTIAL_ENROLLMENT AS ERG_PARTIAL_ENROLLMENT
	  */
      ,'' AS [*=== HCC RISK ===*]
      /*
      ,HCC_COMM.RISK_SCORE AS HCC_COMMUNITY_RISK
      ,HCC_INST.RISK_SCORE AS HCC_INSTITUTIONAL_RISK
      ,HCC_NEW.RISK_SCORE AS HCC_NEW_ENROLLEE_RISK
      ,HCC_SNEW.RISK_SCORE AS HCC_SNP_NEW_ENROLLEE_RISK
      */
      ,'' AS [*=== ADMIN ===*]
      /*
      ,ADM.ADMIN_TOTAL_COST
      */
	  ,'' AS [*=== CREDIBILITY FLAGS ===*]
	  /*
	  ,YL.MM_CREDIBLE
	  ,YL.INCUR_CREDIBLE
	  ,YL.PAID_CREDIBLE
	  ,YL.MONTH_CREDIBLE
	  */
      ,'' AS [*=== CLIENT USER FIELDS ===*]
      ,MMU._ENR_UDF_01_ AS srcLOB
      ,MMU._ENR_UDF_02_ AS srcProduct
      ,MMU._ENR_UDF_03_ AS MemberStatus
      ,MMU._ENR_UDF_04_ AS UserDefPop1
      ,MMU._ENR_UDF_05_ AS UserDefPop2
      ,MMU._ENR_UDF_06_ AS UserDefPop3
      ,MMU._ENR_UDF_07_ AS ManagedPopulation
      ,MMU._ENR_UDF_08_ AS Capitation
      ,MMU._ENR_UDF_09_ AS AgeSex
      ,MMU._ENR_UDF_10_ AS RiskScore
      ,MMU._ENR_UDF_11_ AS MedicareHIC
      ,MMU._ENR_UDF_12_ AS GroupType
      ,MMU._ENR_UDF_13_ AS Exchange
      ,MMU._ENR_UDF_14_ AS MedicaidPopulation
      ,MMU._ENR_UDF_15_ AS RateCellName
      ,MMU._ENR_UDF_16_ AS FullMedicaidBenefit
      ,MMU._ENR_UDF_17_ AS InstitutionalLOC
      ,MMU._ENR_UDF_18_ AS PolicyType
      ,MMU._ENR_UDF_19_ AS CountyFIPS
      /*
      ,MMU._ENR_UDF_20_  
      ,MMU._ENR_UDF_21_
      ,MMU._ENR_UDF_22_
      ,MMU._ENR_UDF_23_
      ,MMU._ENR_UDF_24_
      ,MMU._ENR_UDF_25_
      ,MMU._ENR_UDF_26_
      ,MMU._ENR_UDF_27_
      ,MMU._ENR_UDF_28_
      ,MMU._ENR_UDF_29_
      ,MMU._ENR_UDF_30_
      ,MMU._ENR_UDF_31_
      ,MMU._ENR_UDF_32_
      ,MMU._ENR_UDF_33_
      ,MMU._ENR_UDF_34_
      ,MMU._ENR_UDF_35_
      ,MMU._ENR_UDF_36_
      ,MMU._ENR_UDF_37_
      ,MMU._ENR_UDF_38_
      ,MMU._ENR_UDF_39_
      ,MMU._ENR_UDF_40_
      ,MMU._ENR_UDF_41_
      ,MMU._ENR_UDF_42_
      ,MMU._ENR_UDF_43_
      ,MMU._ENR_UDF_44_
      ,MMU._ENR_UDF_45_
      ,MMU._ENR_UDF_46_
      ,MMU._ENR_UDF_47_
      ,MMU._ENR_UDF_48_
      ,MMU._ENR_UDF_49_
      ,MMU._ENR_UDF_50_
      */
     ,'' AS [*=== SYSTEM ===*]
      ,MM.[ENROLLMENT_KEY]
      ,MM.[MEMBER_MONTH_KEY]
      ,MM.[BENCH_SLICE_KEY]
	  ,COALESCE(PX1.SETTING,0) AS PRIVATE_KEY
	  ,RSIG.Setting AS DB_SIG
  	  ,MIVER.Setting AS MI_VERSION
,'U' AS ROW_SECURITY  --rowcontrol2: do not edit or remove this comment--
--,CASE WHEN RCK.ROWCONTROL_KEY=-99 THEN 'U' ELSE 'R' END AS ROW_SECURITY  --rowcontrol: do not edit or remove this comment--
  
	  
FROM dbo.MEMBER_MONTH MM
LEFT JOIN dbo.MI_YEARMO_LIST YL
	ON  MM.MEMBER_MONTH_START_DATE = YL.FIRST_DATE_IN_MONTH
LEFT JOIN dbo.MEMBER_MONTH_UDF MMU
	ON  MM.MEMBER_MONTH_START_DATE = MMU.MEMBER_MONTH_START_DATE 
	AND MM.MEMBER_KEY = MMU.MEMBER_KEY
    AND MM.EFF_DATE = MMU.EFF_DATE
    AND MM.TERM_DATE = MMU.TERM_DATE 
    AND MM.PROD_TYPE_KEY = MMU.PROD_TYPE_KEY
    AND MM.MI_POST_DATE = MMU.MI_POST_DATE
LEFT JOIN dbo.MEMBER_MONTH_PREMIUM PREM
	ON  MM.MEMBER_MONTH_START_DATE = PREM.MEMBER_MONTH_START_DATE 
	AND MM.MEMBER_KEY = PREM.MEMBER_KEY
    AND MM.EFF_DATE = PREM.EFF_DATE
    AND MM.TERM_DATE = PREM.TERM_DATE 
    AND MM.PROD_TYPE_KEY = PREM.PROD_TYPE_KEY
    AND MM.MI_POST_DATE = PREM.MI_POST_DATE
LEFT JOIN dbo.VWI_MM_CCHG1 CCHG WITH (INDEX(PK),NOEXPAND)
	ON  MM.MEMBER_MONTH_START_DATE = CCHG.MEMBER_MONTH_START_DATE 
	AND MM.MEMBER_KEY = CCHG.MEMBER_KEY
    AND MM.EFF_DATE = CCHG.EFF_DATE
    AND MM.TERM_DATE = CCHG.TERM_DATE 
    AND MM.PROD_TYPE_KEY = CCHG.PROD_TYPE_KEY
    AND MM.MI_POST_DATE = CCHG.MI_POST_DATE
LEFT JOIN dbo.MEMBER_MONTH_ADMIN ADM
	ON  MM.MEMBER_MONTH_START_DATE = ADM.MEMBER_MONTH_START_DATE 
	AND MM.MEMBER_KEY = ADM.MEMBER_KEY
	AND MM.EFF_DATE = ADM.EFF_DATE
	AND MM.TERM_DATE = ADM.TERM_DATE 
	AND MM.PROD_TYPE_KEY = ADM.PROD_TYPE_KEY
	AND MM.MI_POST_DATE = ADM.MI_POST_DATE
LEFT JOIN MI.RFT_CCHG CCHGR ON CCHG.CCHG_CAT = CCHGR.CCHG_CAT
LEFT JOIN dbo.MEMBER M ON MM.MEMBER_KEY=M.MEMBER_KEY
LEFT JOIN dbo.VWI_MEM1 MEMLOC WITH (INDEX(UC),NOEXPAND)
	ON MM.MEMBER_KEY=MEMLOC.MEMBER_KEY
LEFT JOIN dbo.VWI_MEM2 MEMHH WITH (INDEX(UC),NOEXPAND)
	ON MM.MEMBER_KEY=MEMHH.MEMBER_KEY
LEFT JOIN dbo.MEMBER SUBSCR ON MM.SUBSCRIBER_KEY=SUBSCR.MEMBER_KEY
LEFT JOIN dbo.VWI_YEAR_MAP Y WITH (INDEX(UC),NOEXPAND) ON MM.MEMBER_MONTH_START_DATE=Y.FIRST_DATE_IN_MONTH
LEFT JOIN dbo.RFT_RELATION REL ON MM.RELATION_KEY=REL.RELATION_KEY
LEFT JOIN dbo.RFT_PROD_TYPE PT ON MM.PROD_TYPE_KEY = PT.PROD_TYPE_KEY
LEFT JOIN dbo.RFT_TERM_RSN TR ON MM.TERM_RSN_KEY = TR.TERM_RSN_KEY
LEFT JOIN MI.EMP_GROUP G ON MM.GRP_KEY=G.GRP_KEY
LEFT JOIN dbo.EMP_GROUP_UDF GU ON G.GRP_UDF_KEY=GU.GRP_UDF_KEY
LEFT JOIN dbo.EMP_GROUP_ROLLUP GR ON G.GRP_ROLLUP_KEY=GR.GRP_ROLLUP_KEY
LEFT JOIN dbo.RFT_SIC GS ON G.GRP_SIC=GS.SIC
LEFT JOIN dbo.RFT_NAICS GN ON G.GRP_NAICS=GN.NAICS
LEFT JOIN dbo.PROVIDER P ON MM.PCP_PROV_KEY = P.PROV_KEY
LEFT JOIN dbo.VWI_PROV1 PCPLOC WITH (INDEX(UC),NOEXPAND)
	ON MM.PCP_PROV_KEY=PCPLOC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_CLINIC PCPCL WITH (INDEX(UC),NOEXPAND)
	ON MM.PCP_PROV_KEY=PCPCL.PROV_KEY
LEFT JOIN dbo.VWI_PROV_GROUP PCPGRP WITH (INDEX(UC),NOEXPAND)
	ON MM.PCP_PROV_KEY=PCPGRP.PROV_KEY
LEFT JOIN dbo.PROVIDER_UDF PCPU ON P.PROV_UDF_KEY =PCPU.PROV_UDF_KEY

LEFT JOIN dbo.MI_PARMS PX4 ON PX4.PARM='DISPLAY AGE BAND'
LEFT JOIN dbo.RFT_AGE AB ON MM.AGE = AB.AGE AND MM.MONTHS = AB.MONTHS AND AB.AGE_BAND_TYPE=COALESCE(PX4.SETTING,'DEFAULT')
LEFT JOIN dbo.RFT_ACO_ID ACO ON MM.ACO_ID_KEY = ACO.ACO_ID_KEY
LEFT JOIN dbo.RFT_MED_HOME_ID MH ON MM.[MED_HOME_ID_KEY] = MH.[MED_HOME_ID_KEY]
LEFT JOIN dbo.RFT_TIER TIER ON MM.TIER_KEY = TIER.TIER_KEY
LEFT JOIN dbo.RFT_CONTRACT CT ON MM.CONTRACT_KEY = CT.CONTRACT_KEY
LEFT JOIN dbo.BENEFIT BEN ON MM.BEN_PKG_KEY = BEN.BEN_PKG_KEY
LEFT JOIN dbo.RFT_MEM_STAT MS ON MM.MEM_STAT_KEY = MS.MEM_STAT_KEY
LEFT JOIN dbo.RFT_PAYER_TYPE MMP ON MM.PAYER_TYPE_KEY = MMP.PAYER_TYPE_KEY
LEFT JOIN dbo.RFT_PAYER_LOB MMPL ON MMP.PAYER_LOB_KEY = MMPL.PAYER_LOB_KEY
LEFT JOIN dbo.RFT_DATA_SOURCE DS ON MM.DATA_SOURCE_KEY = DS.DATA_SOURCE_KEY
LEFT JOIN dbo.RFT_TIER TT ON MM.TIER_KEY = TT.TIER_KEY
LEFT JOIN MI.RFT_MI_USER_DIM_01_  UD1  ON MM._MI_USER_DIM_01_KEY =UD1._MI_USER_DIM_01_KEY
LEFT JOIN MI.RFT_MI_USER_DIM_02_  UD2  ON MM._MI_USER_DIM_02_KEY =UD2._MI_USER_DIM_02_KEY
LEFT JOIN MI.RFT_MI_USER_DIM_03_  UD3  ON MM._MI_USER_DIM_03_KEY =UD3._MI_USER_DIM_03_KEY
LEFT JOIN MI.RFT_MI_USER_DIM_04_  UD4  ON MM._MI_USER_DIM_04_KEY =UD4._MI_USER_DIM_04_KEY
LEFT JOIN MI.RFT_MI_USER_DIM_05_  UD5  ON MM._MI_USER_DIM_05_KEY =UD5._MI_USER_DIM_05_KEY
LEFT JOIN MI.RFT_MI_USER_DIM_06_  UD6  ON MM._MI_USER_DIM_06_KEY =UD6._MI_USER_DIM_06_KEY
LEFT JOIN MI.RFT_MI_USER_DIM_07_  UD7  ON MM._MI_USER_DIM_07_KEY =UD7._MI_USER_DIM_07_KEY
LEFT JOIN MI.RFT_MI_USER_DIM_08_  UD8  ON MM._MI_USER_DIM_08_KEY =UD8._MI_USER_DIM_08_KEY
LEFT JOIN MI.RFT_MI_USER_DIM_09_  UD9  ON MM._MI_USER_DIM_09_KEY =UD9._MI_USER_DIM_09_KEY
LEFT JOIN MI.RFT_MI_USER_DIM_10_ UD10 ON MM._MI_USER_DIM_10_KEY=UD10._MI_USER_DIM_10_KEY
LEFT JOIN MI.MEMBER_MONTH_ERG_RISK ERG ON 
		MM.MEMBER_MONTH_START_DATE = ERG.MEMBER_MONTH_START_DATE
		AND MM.MEMBER_KEY = ERG.MEMBER_KEY AND MM.PROD_TYPE_KEY = ERG.PROD_TYPE_KEY
LEFT JOIN MI_PARMS PX5 ON PX5.Parm = 'MARA HCC VIEW'
LEFT JOIN dbo.MEMBER_MONTH_MARA_RISK MARA 
		ON MM.MEMBER_MONTH_START_DATE = MARA.MEMBER_MONTH_START_DATE
		AND MM.MEMBER_KEY = MARA.MEMBER_KEY 
		AND MM.EFF_DATE = MARA.EFF_DATE
		AND MM.TERM_DATE = MARA.TERM_DATE
		AND MM.PROD_TYPE_KEY = MARA.PROD_TYPE_KEY
		AND MM.MI_POST_DATE = MARA.MI_POST_DATE
LEFT JOIN dbo.MEMBER_MONTH_MARA_HCC_RISK MARAHCC 
		ON MM.MEMBER_MONTH_START_DATE = MARAHCC.MEMBER_MONTH_START_DATE AND MARAHCC.HHSYEAR = PX5.Setting
		AND MM.MEMBER_KEY = MARAHCC.MEMBER_KEY 
		AND MM.EFF_DATE = MARAHCC.EFF_DATE
		AND MM.TERM_DATE = MARAHCC.TERM_DATE
		AND MM.PROD_TYPE_KEY = MARAHCC.PROD_TYPE_KEY
		AND MM.MI_POST_DATE = MARAHCC.MI_POST_DATE
LEFT JOIN dbo.RFT_MARA_HCC_CSR CSR ON MM.HHS_CSR_VALUE = CSR.RA_Software_Person_Level_Indicator AND CSR.HHSYEAR = PX5.SETTING
LEFT JOIN dbo.MI_MARA_MODELS MARAC ON MARA.CON_MARA_MODEL_KEY = MARAC.MARA_MODEL_KEY
LEFT JOIN dbo.MI_MARA_MODELS MARAP ON MARA.PRO_MARA_MODEL_KEY = MARAP.MARA_MODEL_KEY
LEFT JOIN dbo.MI_MARA_MODELS MARAA ON MARA.AS_MARA_MODEL_KEY = MARAA.MARA_MODEL_KEY
LEFT JOIN dbo.RFT_MARA_CLASS MARACC ON MARA.PRIMARY_CON_MARACLASS_KEY = MARACC.MARACLASS_KEY
LEFT JOIN dbo.RFT_MARA_CLASS MARAPC ON MARA.PRIMARY_PRO_MARACLASS_KEY = MARAPC.MARACLASS_KEY
LEFT JOIN dbo.MI_PARMS PX1 ON PX1.PARM='PRIVATE KEY'
LEFT JOIN dbo.MI_PARMS PX3 ON PX3.PARM='PREMIUM GRAIN'
LEFT JOIN dbo.MEMBER_MONTH_ATTRIB ATP1 ON ATP1.ATTRIBUTION_METHOD_KEY=1 AND
	MM.MEMBER_MONTH_START_DATE = ATP1.MEMBER_MONTH_START_DATE
	AND MM.MEMBER_KEY = ATP1.MEMBER_KEY
LEFT JOIN dbo.PROVIDER ATPP1 ON ATP1.PROV_KEY =ATPP1.PROV_KEY
LEFT JOIN dbo.VWI_PROV1 ATP1LOC WITH (INDEX(UC),NOEXPAND)
	ON ATP1.PROV_KEY=ATP1LOC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_SPEC ATP1SPEC WITH (INDEX(UC),NOEXPAND)
	ON ATP1.PROV_KEY=ATP1SPEC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_CLINIC ATP1CL WITH (INDEX(UC),NOEXPAND)
	ON ATP1.PROV_KEY=ATP1CL.PROV_KEY
LEFT JOIN dbo.VWI_PROV_GROUP ATP1GRP WITH (INDEX(UC),NOEXPAND)
	ON ATP1.PROV_KEY=ATP1GRP.PROV_KEY
LEFT JOIN dbo.PROVIDER_UDF ATPPU1 ON ATPP1.PROV_UDF_KEY = ATPPU1.PROV_UDF_KEY

LEFT JOIN dbo.MEMBER_MONTH_ATTRIB ATP2 ON ATP2.ATTRIBUTION_METHOD_KEY=2 AND
	MM.MEMBER_MONTH_START_DATE = ATP2.MEMBER_MONTH_START_DATE
	AND MM.MEMBER_KEY = ATP2.MEMBER_KEY
LEFT JOIN dbo.PROVIDER ATPP2 ON ATP2.PROV_KEY =ATPP2.PROV_KEY
LEFT JOIN dbo.VWI_PROV1 ATP2LOC WITH (INDEX(UC),NOEXPAND)
	ON ATP2.PROV_KEY=ATP2LOC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_SPEC ATP2SPEC WITH (INDEX(UC),NOEXPAND)
	ON ATP2.PROV_KEY=ATP2SPEC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_CLINIC ATP2CL WITH (INDEX(UC),NOEXPAND)
	ON ATP2.PROV_KEY=ATP2CL.PROV_KEY
LEFT JOIN dbo.VWI_PROV_GROUP ATP2GRP WITH (INDEX(UC),NOEXPAND)
	ON ATP2.PROV_KEY=ATP2GRP.PROV_KEY
LEFT JOIN dbo.MEMBER_MONTH_ATTRIB ATP3 ON ATP3.ATTRIBUTION_METHOD_KEY=3 AND
	MM.MEMBER_MONTH_START_DATE = ATP3.MEMBER_MONTH_START_DATE
	AND MM.MEMBER_KEY = ATP3.MEMBER_KEY
LEFT JOIN dbo.PROVIDER ATPP3 ON ATP3.PROV_KEY =ATPP3.PROV_KEY
LEFT JOIN dbo.VWI_PROV1 ATP3LOC WITH (INDEX(UC),NOEXPAND)
	ON ATP3.PROV_KEY=ATP3LOC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_SPEC ATP3SPEC WITH (INDEX(UC),NOEXPAND)
	ON ATP3.PROV_KEY=ATP3SPEC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_CLINIC ATP3CL WITH (INDEX(UC),NOEXPAND)
	ON ATP3.PROV_KEY=ATP3CL.PROV_KEY
LEFT JOIN dbo.VWI_PROV_GROUP ATP3GRP WITH (INDEX(UC),NOEXPAND)
	ON ATP3.PROV_KEY=ATP3GRP.PROV_KEY
LEFT JOIN dbo.MEMBER_MONTH_ATTRIB ATP4 ON ATP4.ATTRIBUTION_METHOD_KEY=4 AND
	MM.MEMBER_MONTH_START_DATE = ATP4.MEMBER_MONTH_START_DATE
	AND MM.MEMBER_KEY = ATP4.MEMBER_KEY
LEFT JOIN dbo.PROVIDER ATPP4 ON ATP4.PROV_KEY =ATPP4.PROV_KEY
LEFT JOIN dbo.VWI_PROV1 ATP4LOC WITH (INDEX(UC),NOEXPAND)
	ON ATP4.PROV_KEY=ATP4LOC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_SPEC ATP4SPEC WITH (INDEX(UC),NOEXPAND)
	ON ATP4.PROV_KEY=ATP4SPEC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_CLINIC ATP4CL WITH (INDEX(UC),NOEXPAND)
	ON ATP4.PROV_KEY=ATP4CL.PROV_KEY
LEFT JOIN dbo.VWI_PROV_GROUP ATP4GRP WITH (INDEX(UC),NOEXPAND)
	ON ATP4.PROV_KEY=ATP4GRP.PROV_KEY
LEFT JOIN dbo.MEMBER_MONTH_ATTRIB ATP5 ON ATP5.ATTRIBUTION_METHOD_KEY=5 AND
	MM.MEMBER_MONTH_START_DATE = ATP5.MEMBER_MONTH_START_DATE
	AND MM.MEMBER_KEY = ATP5.MEMBER_KEY
LEFT JOIN dbo.PROVIDER ATPP5 ON ATP5.PROV_KEY =ATPP5.PROV_KEY
LEFT JOIN dbo.VWI_PROV1 ATP5LOC WITH (INDEX(UC),NOEXPAND)
	ON ATP5.PROV_KEY=ATP5LOC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_SPEC ATP5SPEC WITH (INDEX(UC),NOEXPAND)
	ON ATP5.PROV_KEY=ATP5SPEC.PROV_KEY
LEFT JOIN dbo.VWI_PROV_CLINIC ATP5CL WITH (INDEX(UC),NOEXPAND)
	ON ATP5.PROV_KEY=ATP5CL.PROV_KEY
LEFT JOIN dbo.VWI_PROV_GROUP ATP5GRP WITH (INDEX(UC),NOEXPAND)
	ON ATP5.PROV_KEY=ATP5GRP.PROV_KEY
LEFT JOIN dbo.RFT_MEDICARE_BASIS MEL
	ON MM.MEDICARE_BASIS = MEL.MEDICARE_BASIS
LEFT JOIN dbo.RFT_HCC_MODEL HCC1 ON HCC1.HCC_MODEL = 'COMMUNITY'
LEFT JOIN dbo.MEMBER_MONTH_HCC_RISK HCC_COMM ON HCC_COMM.HCC_MODEL_KEY = HCC1.HCC_MODEL_KEY
		AND MM.MEMBER_MONTH_START_DATE = HCC_COMM.MEMBER_MONTH_START_DATE
		AND MM.MEMBER_KEY = HCC_COMM.MEMBER_KEY AND MM.PROD_TYPE_KEY = HCC_COMM.PROD_TYPE_KEY
LEFT JOIN dbo.RFT_HCC_MODEL HCC2 ON HCC2.HCC_MODEL = 'INSTITUTIONAL'
LEFT JOIN dbo.MEMBER_MONTH_HCC_RISK HCC_INST ON HCC_INST.HCC_MODEL_KEY = HCC2.HCC_MODEL_KEY
		AND MM.MEMBER_MONTH_START_DATE = HCC_INST.MEMBER_MONTH_START_DATE
		AND MM.MEMBER_KEY = HCC_INST.MEMBER_KEY AND MM.PROD_TYPE_KEY = HCC_INST.PROD_TYPE_KEY
LEFT JOIN dbo.RFT_HCC_MODEL HCC3 ON HCC3.HCC_MODEL = 'NEW ENROLLEE'
LEFT JOIN dbo.MEMBER_MONTH_HCC_RISK HCC_NEW ON HCC_NEW.HCC_MODEL_KEY = HCC3.HCC_MODEL_KEY
		AND MM.MEMBER_MONTH_START_DATE = HCC_NEW.MEMBER_MONTH_START_DATE
		AND MM.MEMBER_KEY = HCC_NEW.MEMBER_KEY AND MM.PROD_TYPE_KEY = HCC_NEW.PROD_TYPE_KEY
LEFT JOIN dbo.RFT_HCC_MODEL HCC4 ON HCC4.HCC_MODEL = 'SNP NEW ENROLLEE'
LEFT JOIN dbo.MEMBER_MONTH_HCC_RISK HCC_SNEW ON HCC_SNEW.HCC_MODEL_KEY = HCC4.HCC_MODEL_KEY
		AND MM.MEMBER_MONTH_START_DATE = HCC_SNEW.MEMBER_MONTH_START_DATE
		AND MM.MEMBER_KEY = HCC_SNEW.MEMBER_KEY AND MM.PROD_TYPE_KEY = HCC_SNEW.PROD_TYPE_KEY

LEFT JOIN dbo.MI_PARMS RSIG ON RSIG.PARM = 'RUN SIGNATURE'
LEFT JOIN dbo.MI_PARMS MIVER ON MIVER.PARM = 'MI VERSION'

--LEFT JOIN dbo.MI_ROWCONTROL_KEYS RCK  --rowcontrol: do not edit or remove this comment--
--ON SUSER_NAME() = RCK.ID AND (MM.ROWCONTROL_KEY=RCK.ROWCONTROL_KEY  OR RCK.ROWCONTROL_KEY=-99)  --rowcontrol: do not edit or remove this comment--
--WHERE RCK.ID IS NOT NULL  --rowcontrol: do not edit or remove this comment--


--select top 100 * from cst.VW_MEMBMTHS


--$LastChangedDate$
--$LastChangedRevision$
--$Author$
--$HeadURL$	




GO


