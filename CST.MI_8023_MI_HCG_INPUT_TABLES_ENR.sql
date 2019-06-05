

/****** Object:  StoredProcedure [dbo].[MI_8023_MI_HCG_INPUT_TABLES_ENR]    Script Date: 7/30/2018 11:09:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [CST].[MI_8023_MI_HCG_INPUT_TABLES_ENR]
AS
BEGIN

	DECLARE @DB_ID INT = DB_ID()
	,@LOGID INT = 0
	,@PROC VARCHAR(500)=OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	,@PERF_START datetime
	,@PERF_DURATION int
	,@PERF_ROW INT
	,@RC INT
	,@MSG VARCHAR(1000);

	EXEC dbo.SP_MI_UTIL_LOG_EVENT @@PROCID, @DB_ID, @LOG2ID=@LOGID OUT;
	DECLARE @MI_POST_DATE DATE=COALESCE(DBO.FN_GETMIPARM('MI POST DATE'),'TRAP');

	DECLARE @ETG_LAST_DATE DATE=(SELECT MAX(LAST_DATE_IN_MONTH) FROM DBO.MI_YEARMO_LIST)
	
	--Inserting data for MemberMonth claims. 
	SET @PERF_START = GETDATE();
		
	TRUNCATE TABLE [DBO].[WORK_HCG_MEMBER_MONTHS_INPUT]

	INSERT INTO [DBO].[WORK_HCG_MEMBER_MONTHS_INPUT] WITH (TABLOCK) 
			(
					MemberID,	MedicareHIC,	ContractID,	YearMo,	DepCode,	DateOfBirth,	Gender,	SourceLOB,	LOB,	srcProduct,	Product,	GroupID,	Zip,	County,	Industry,	Medical
					,Dental,	Rx,	Vision,	Capitation,	Capitation1,	Capitation2,	Capitation3,	Capitation4,	Capitation5,	Premium,	PremiumMedical,	PremiumDrug,	PremiumVision
					,PremiumDental,	Expense,	Expense1,	Expense2,	Expense3,	Expense4,	Expense5,	AgeSex,	PCP,	ManagedPopulation,	RiskScore,	MemberStatus
					,UserDefPop1,	UserDefPop2,	UserDefPop3,	MemberMonthKey
			)

	select 
				MM.MI_PERSON_KEY AS MemberId	
				,max(m.MEM_MEDICARE) as MedicareHIC
				,CASE WHEN SKL.PROXY_SUBSCRIBER_KEY IS NOT NULL AND SKL.PROXY_SUBSCRIBER_KEY <> 0 THEN 'S' ELSE 'M' END + right(replicate('0',19) + CAST(CASE WHEN SKL.PROXY_SUBSCRIBER_KEY IS NOT NULL AND SKL.PROXY_SUBSCRIBER_KEY <> 0  THEN SKL.PROXY_SUBSCRIBER_KEY ELSE MM.MI_PERSON_KEY END AS VARCHAR),19)  AS CONTRACTID
				,convert(char(6), mm.MEMBER_MONTH_START_DATE, 112) as YearMo
				,max(case when r.RELATION = '0' or r.RELATION = '1' then r.RELATION else '2' end) as DepCode
				,convert(char(10), max(m.MEM_DOB), 101) as DateOfBirth
				,convert(CHAR(1), max(MM.GENDER)) AS [Gender]
				,NULL as SourceLOB
				,_MI_USER_DIM_01_ AS LOB
				,NULL as SrcProduct
				,_MI_USER_DIM_02_ AS PRODUCT
				,NULL as GroupId		
				,convert(char(5), max(m.mem_zip)) as Zip		
				,convert(char(5), max(m.mem_county)) as County	
				,null as Industry  --outstanding question on this
				,max(case when mm.MM_UNITS <> 0 then 1 else 0 end) as Medical
				,max(case when mm.DN_UNITS <> 0 then 1 else 0 end) as Dental
				,max(case when mm.RX_UNITS <> 0 then 1 else 0 end) as Rx
				,max(case when mm.VS_UNITS <> 0 then 1 else 0 end) as Vision	
				,null as Capitation	
				,null as Capitation1
				,null as Capitation2
				,null as Capitation3
				,null as Capitation4
				,null as Capitation5	
				,null as Premium
				,null as PremiumMedical
				,null as PremiumDrug
				,null as PremiumVision
				,null as PremiumDental	
				,null as Expense
				,null as Expense1
				,null as Expense2
				,null as Expense3
				,null as Expense4
				,null as Expense5
				,null as AgeSex
				,null as PCP
				,null as ManagedPopulation
				,null as RiskScore
				,null as MemberStatus
				,NULL as UserDefPop1
				,NULL as UserDefPop2
				,NULL as UserDefPop3
				,max(mm.MEMBER_MONTH_KEY) as MemberMonthKey
	from 		dbo.MEMBER_MONTH MM
	LEFT JOIN	DBO.HCG_PERSON_KEY_PROXY_SUBSCRIBER_KEY_LOOKUP SKL ON MM.MEMBER_KEY = SKL.MEMBER_KEY
	left join	dbo.MEMBER M ON MM.MEMBER_KEY = M.MEMBER_KEY
	left join	dbo.RFT_RELATION r on mm.RELATION_KEY = r.RELATION_KEY		
	left join	dbo.RFT_MI_USER_DIM_01_ U1 ON mm._MI_USER_DIM_01_KEY = U1._MI_USER_DIM_01_KEY
	left join	dbo.RFT_MI_USER_DIM_02_ U2 ON mm._MI_USER_DIM_02_KEY = U2._MI_USER_DIM_02_KEY
	where 
		--MM_UNITS > 0
		--AND 
		M.MEM_DOB <= @ETG_LAST_DATE
		AND CONVERT(INT, DATEDIFF(D, M.MEM_DOB, @ETG_LAST_DATE)/365.25) < 120
	group by
		CASE WHEN SKL.PROXY_SUBSCRIBER_KEY IS NOT NULL AND SKL.PROXY_SUBSCRIBER_KEY <> 0 THEN 'S' ELSE 'M' END + right(replicate('0',19) + CAST(CASE WHEN SKL.PROXY_SUBSCRIBER_KEY IS NOT NULL AND SKL.PROXY_SUBSCRIBER_KEY <> 0  THEN SKL.PROXY_SUBSCRIBER_KEY ELSE MM.MI_PERSON_KEY END AS VARCHAR),19) 
		,mm.MI_PERSON_KEY
		,convert(char(6), mm.MEMBER_MONTH_START_DATE, 112) 
		,mm.RELATION_KEY
		,_MI_USER_DIM_01_
		,_MI_USER_DIM_02_
	SET @PERF_ROW=@@ROWCOUNT;
	SET @PERF_DURATION = DATEDIFF(minute,@PERF_START,GETDATE())
	EXEC dbo.SP_MI_UTIL_LOG_EVENT @@PROCID, @DB_ID, '[DBO].[WORK_HCG_MEMBER_MONTHS_INPUT] LOADED', @PERF_ROW, @DURATION_IN_MIN=@PERF_DURATION, @LOG2ID=@LOGID;

		
	EXEC dbo.SP_MI_UTIL_LOG_EVENT @@PROCID, @DB_ID, @LOG2ID=@LOGID,@END_FLAG=1;		


END


--$LastChangedDate: 2018-05-23 12:46:20 -0700 (Wed, 23 May 2018) $

--$LastChangedRevision: 41904 $

--$Author: schulb $

--$HeadURL: https://topsvcs.medinsight.milliman.com/svn/MedInsight/branches/Database/MI_12/MI/Schema%20Objects/Schemas/dbo/Programmability/Stored%20Procedures/MI_8023_MI_HCG_INPUT_TABLES_ENR.sql $


GO


