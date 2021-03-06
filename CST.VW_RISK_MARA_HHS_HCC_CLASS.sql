USE [MI_cbc2017]
GO

/****** Object:  View [CST].[VW_RISK_MARA_HHS_HCC_CLASS]    Script Date: 11/1/2018 3:37:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [CST].[VW_RISK_MARA_HHS_HCC_CLASS]
/* SVN Version #    */
/* SVN Version # 11269   */
AS
SELECT 
 
M.MI_PERSON_KEY,
M.MEMBER_ID,
M.MEMBER_ID_ENCRYPTED,
A.EFF_DATE,
A.TERM_DATE,
A.PROD_TYPE_KEY,
A.HHS_HCC_CLASS
--,A.MI_POST_DATE
--,RSIG.Setting AS DB_SIG
--,MIVER.Setting AS MI_VERSION

FROM dbo.MEMBER_MONTH_MARA_HCC_CLASS A
LEFT JOIN dbo.MEMBER M ON A.MEMBER_KEY = M.MEMBER_KEY
LEFT JOIN dbo.MI_PARMS PX ON PX.PARM='PRIVATE KEY'
LEFT JOIN dbo.MI_PARMS RSIG ON RSIG.PARM = 'RUN SIGNATURE'
LEFT JOIN dbo.MI_PARMS MIVER ON MIVER.PARM = 'MI VERSION'

WHERE A.PROD_TYPE_KEY <> 8 and A.HHS_HCC_CLASS is not Null




--$LastChangedDate$
--$LastChangedRevision$
--$Author$
--$HeadURL$	


GO


