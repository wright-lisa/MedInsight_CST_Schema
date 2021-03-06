USE [MI_CBC2017]
GO

/****** Object:  View [CST].[SERVICES_2_HRT]    Script Date: 11/1/2018 3:19:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [CST].[SERVICES_2_HRT]
/* SVN Version #    */
	AS SELECT 
	 CLAIM_ID_KEY
	,SERVICES_KEY
	,RVU_MI_BILLED	
	,RVU_MI_ALLOWED		
	,RVU_MI_CURRENT_ALLOWED		
	,RVU_DEFAULT_BASIS		
	,RVU_FINAL_STEP		
	,RVU_FINAL		
	,RVU_CONVERSION_FACTOR		
	,RVU_CF_INCLUDE		
	,RVU_ADJUSTED_UNITS		
	,MEDICARE_INCLUDE		
	,MEDICARE_ADJUDICATED		
	,MEDICARE_ALLOWED_BASE_NTNWD		
	,MEDICARE_ALLOWED_BASE		
	,MEDICARE_OUTLIER		
	,MEDICARE_DSH_UCP		
	,MEDICARE_CAP_IME		
	,MEDICARE_OP_IME		
	,MEDICARE_ADJUSTED_UNITS		
	,MEDICARE_FEE_SCHEDULE		
	,MEDICARE_APC_DRG_HCPCS		
	,MEDICARE_STATUS_LOOKUP
	,[AMT_PAID_BASIS]
      ,[AMT_ALLOWED_BASIS]
      ,[AMT_BILLED_BASIS]
FROM DBO.SERVICES_2

GO


