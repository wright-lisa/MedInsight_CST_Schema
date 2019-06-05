USE [MI_CBC2017]
GO

/****** Object:  View [CST].[VWI_MEM1]    Script Date: 11/1/2018 3:37:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [CST].[VWI_MEM1]
/* SVN Version #    */
	AS SELECT 
	 M.MEMBER_KEY
     ,M.MEM_DOB
	 ,M.MEM_GENDER
	, M.MI_PERSON_KEY
	,M.MEMBER_ID
	,M.MEMBER_ID_ENCRYPTED
	,Z.ZIP5 AS MEM_ZIP
	,Z.ST AS MEM_STATE
	,Z.MSACODE AS MEM_MSA_CODE
FROM 
DBO.MEMBER M 
LEFT JOIN DBO.RFT_ZIP Z
ON M.MEM_ZIP = Z.ZIP5

--$LastChangedDate: 2017-07-11 14:37:58 -0700 (Tue, 11 Jul 2017) $
--$LastChangedRevision: 32330 $
--$Author: WrightL $
--$HeadURL: https://topsvcs.medinsight.milliman.com/svn/MedInsight/branches/Database/MI_11/HRT/Core/Schemas/cst/Views/CST.VWI_MEM1.sql $	




GO


