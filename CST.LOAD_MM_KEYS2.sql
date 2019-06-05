USE [MI_CBC2017]
GO

/****** Object:  StoredProcedure [CST].[LOAD_MM_KEYS2]    Script Date: 11/1/2018 2:29:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [CST].[LOAD_MM_KEYS2]
AS
INSERT INTO CST.MM_KEYS2
( MEMBER_KEY, MI_PERSON_KEY, EFF_DATE, MEMBER_ID)
SELECT 
 a.MEMBER_KEY, a.MI_PERSON_KEY, a.EFF_DATE,b.MEMBER_ID 
  from CST.MM_KEYS a LEFT JOIN DBO.MEMBER b on a.MI_PERSON_KEY=b.MI_PERSON_KEY
and a.MEMBER_KEY = b.MEMBER_KEY

--$LastChangedDate: 2017-07-07 17:01:54 -0700 (Fri, 07 Jul 2017) $
--$LastChangedRevision: 32284 $
--$Author: WrightL $
--$HeadURL: https://topsvcs.medinsight.milliman.com/svn/MedInsight/branches/Database/MI_11/HRT/Core/Schemas/cst/Procedures/CST.LOAD_MM_KEYS2.sql $	

GO


