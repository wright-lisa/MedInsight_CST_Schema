/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW CST.VW_OUTPHYSICIAN
AS 
Select

      [SERVICE_MONTH_START_DATE]
      ,[CLAIM_ID_KEY]
      ,[SERVICES_KEY]
	 -- ,MI_POST_DATE
	   ,[RVU_WORK_RVUS]
      ,[RVU_PRACTICE_RVUS]
      ,[RVU_MALPRACTICE_RVUS]
      ,[RVU_FINAL_RVUS]
     FROM [GRVU].[SERVICES_OUTPUT]
 
