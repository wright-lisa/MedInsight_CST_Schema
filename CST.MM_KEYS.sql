CREATE TABLE [CST].[MM_KEYS](
	[MEMBER_KEY] [int] NOT NULL,
	[MI_PERSON_KEY] [int] NOT NULL,
	[EFF_DATE] [date] NOT NULL,
	[MEDICAL] [numeric](38, 2) NULL
) ON [PRIMARY]

GO
--$LastChangedDate: 2017-07-07 21:18:51 -0500 (Fri, 07 Jul 2017) $
--$LastChangedRevision: 32289 $
--$Author: WrightL $
--$HeadURL: https://topsvcs.medinsight.milliman.com/svn/MedInsight/branches/Database/MI_11/HRT/Core/Scripts/Post-Deployment/Update01/CST.MM_KEYS.sql $	
