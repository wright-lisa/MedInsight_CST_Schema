USE [MI_CHSD2016]
GO

/****** Object:  StoredProcedure [CST].[CONSOLIDATE_00_MASTER]    Script Date: 4/11/2018 1:12:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








ALTER PROCEDURE [CST].[CONSOLIDATE_00_MASTER] AS 


EXEC SP_MI_DROPTABLE '##TEMP_DBS'
SELECT CAST('MI_SH2016' AS VARCHAR(50)) AS DBS,'06' AS CID INTO ##TEMP_DBS
INSERT INTO ##TEMP_DBS SELECT 'MI_GEI2016','20' AS CID

/*
INSERT INTO ##TEMP_DBS SELECT 'MI_AET2016','30' AS CID  
INSERT INTO ##TEMP_DBS SELECT 'MI_BTN2016','11' AS CID
INSERT INTO ##TEMP_DBS SELECT 'MI_CBC2016','14' AS CID
INSERT INTO ##TEMP_DBS SELECT 'MI_CIG2016','12' AS CID
INSERT INTO ##TEMP_DBS SELECT 'MI_COV2016','18' AS CID
INSERT INTO ##TEMP_DBS SELECT 'MI_EXC2016','21' AS CID
INSERT INTO ##TEMP_DBS SELECT 'MI_MLT2016','32' AS CID 
INSERT INTO ##TEMP_DBS SELECT 'MI_GHC2016','17' AS CID
INSERT INTO ##TEMP_DBS SELECT 'MI_HMK2016','31' AS CID  
INSERT INTO ##TEMP_DBS SELECT 'MI_MED2016','19' AS CID
INSERT INTO ##TEMP_DBS SELECT 'MI_MMO2016','15' AS CID
INSERT INTO ##TEMP_DBS SELECT 'MI_NEB2016','33' AS CID --LW Added 4/13/17
INSERT INTO ##TEMP_DBS SELECT 'MI_REG2016','22' AS CID
INSERT INTO ##TEMP_DBS SELECT 'MI_WEL2016','13' AS CID
*/


CREATE UNIQUE CLUSTERED INDEX XPK ON ##TEMP_DBS(CID)

EXEC MI_0005_INDEX_MANAGEMENT 1

-- RUN CONSOLIDATING CODE --
EXEC CST.CONSOLIDATE_01_REFERENCES @TRUNCATE = 'Y'
EXEC CST.CONSOLIDATE_02_MEMBER_MONTH @TRUNCATE = 'Y',@INDEX = 'Y'
EXEC CST.CONSOLIDATE_03_SERVICES @TRUNCATE = 'Y',@INDEX = 'Y'
EXEC CST.CONSOLIDATE_04_EBMS @TRUNCATE = 'Y',@INDEX = 'Y'

EXEC DBO.MI_1000_INDEX_MANAGEMENT 1

EXEC ASRPT.MI_9200_INITIALIZE_ASRPT_METADATA 1
EXEC ASRPT.MI_9201_INITIALIZE_ASRPT_HELPER_TABLES 1
EXEC ASRPT.MI_9203_INITIALIZE_UDF_DIMENSIONS_FOR_CUBE 1





GO


