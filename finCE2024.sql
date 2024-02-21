

DECLARE @BRANCH Varchar(20)='', 
@STR Varchar(20)='', 
-- @DATEFROM DATE ='2023-1-1',
@DATETO DATE ='2023-12-31', 
-- @DATEFROMPREV  DATE = '2022-01-01', 
@DATETOPREV DATE = '2022-12-31'
-- DECLARE @BRANCH Varchar(20)='{?brachID}', 
-- @DATEFROM DATE ={?DateFrom} ,
-- @DATETO DATE ={?DateTo} , 
-- @DATEFROMPREV  DATE = {?DateFromPrev},
-- @DATETOPREV DATE ={?DateToPrev},
-- @STR VARCHAR(50)='{?Store}'

SET @BRANCH = REPLACE(@BRANCH,'All Branch','')
SET @STR = REPLACE(@STR,'All','')


BEGIN
IF (@STR='')
    BEGIN
        SELECT T.LEVELS, concat(TT.AcctCode,' - ', TT.AcctName) as 'GROUP',T.GroupMask,T.AcctCode,T.AcctName
        ,ISNULL(SUM(L7),0) AS L7
        ,ISNULL(SUM(P7),0) AS P7
        ,0 AS 'InventoryShortage'
        ,0 AS 'InventoryShortagePrev'
        FROM OACT T 
        LEFT JOIN

                (
                --CURRENT
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS L7,0 AS P7
                FROM OACT T0
                LEFT JOIN JDT1 T1 ON T1.Account like '%'+ LEFT(AcctCode,10) +'%'       
                WHERE T0.GROUPMASK =3 AND T0.AcctCode IN ('EQ010-0100-0000','EQ010-0200-0000','EQ010-0300-0000','EQ010-0400-0000','EQ010-0500-0000','EQ010-0600-0000','EQ010-0700-0000')
                AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TAXDATE <  YEAR(@DATETO)
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

                --END CURRENT
                UNION ALL 
                --PREV
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
                FROM OACT T0
                LEFT JOIN JDT1 T1 ON T1.Account like '%'+ LEFT(AcctCode,10) +'%'           
                WHERE T0.GROUPMASK =3 AND T0.AcctCode IN ('EQ010-0100-0000','EQ010-0200-0000','EQ010-0300-0000','EQ010-0400-0000','EQ010-0500-0000','EQ010-0600-0000','EQ010-0700-0000')
                AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate <  YEAR(@DATETOPREV)
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

                 
                --END PREV          
                )

        L7 ON LEFT(T.AcctCode,5)=LEFT(L7.AcctCode,5)
        INNER JOIN OACT TT ON TT.AcctCode=T.AcctCode
        WHERE T.GROUPMASK = 3 AND T.AcctCode IN ('EQ010-0100-0000','EQ010-0200-0000','EQ010-0300-0000','EQ010-0400-0000','EQ010-0500-0000','EQ010-0600-0000','EQ010-0700-0000')
        GROUP BY T.GroupMask,T.AcctCode,T.AcctName,TT.AcctCode,TT.AcctName,T.Levels
        ORDER BY T.GroupMask
    END
   
END
  



