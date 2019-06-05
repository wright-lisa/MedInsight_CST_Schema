USE [MI_CBC2017]
GO

/****** Object:  StoredProcedure [CST].[LOAD_MM_KEYS]    Script Date: 11/1/2018 2:21:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [CST].[LOAD_MM_KEYS]
	
AS
	 
INSERT INTO [CST].[MM_KEYS] 
( MEMBER_KEY, MI_PERSON_KEY, EFF_DATE, MEDICAL)
SELECT 
    MEMBER_KEY, MI_PERSON_KEY, EFF_DATE, sum(MM_UNITS) as medical from dbo.member_month
      group by member_key, Mi_person_Key, eff_date  

--$LastChangedDate: 2017-07-07 18:11:13 -0700 (Fri, 07 Jul 2017) $
--$LastChangedRevision: 32285 $
--$Author: WrightL $
--$HeadURL: https://topsvcs.medinsight.milliman.com/svn/MedInsight/branches/Database/MI_11/HRT/Core/Schemas/cst/Procedures/CST.LOAD_MM_KEYS.sql $	



GO


