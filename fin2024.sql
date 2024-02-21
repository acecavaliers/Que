

-- DECLARE @BRANCH Varchar(20)='', 
-- @STR Varchar(20)='OST', 
-- @DATEFROM DATE ='2023-1-1',
-- @DATETO DATE ='2023-12-31', 
-- @DATEFROMPREV  DATE = '2022-01-01', 
-- @DATETOPREV DATE = '2022-12-31'
DECLARE @BRANCH Varchar(20)='{?brachID}', 
@DATEFROM DATE ={?DateFrom} ,
@DATETO DATE ={?DateTo} , 
@DATEFROMPREV  DATE = {?DateFromPrev},
@DATETOPREV DATE ={?DateToPrev},
@STR VARCHAR(50)='{?Store}'

SET @BRANCH = REPLACE(@BRANCH,'All Branch','')
SET @STR = REPLACE(@STR,'All','')


BEGIN
IF (@STR='')
    BEGIN
        SELECT concat(TT.AcctCode,' - ', TT.AcctName) as 'GROUP',T.GroupMask,T.AcctCode,T.AcctName
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
                LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK BETWEEN 4 AND 7 AND Levels >=3
                AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate BETWEEN @DATEFROM AND @DATETO
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

                UNION ALL 

                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS L7,0 AS P7
                FROM OACT T0
                INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK = 8 AND Levels =2
                AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate BETWEEN @DATEFROM AND @DATETO
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode  
                --END CURRENT
                UNION ALL 
                --PREV
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
                FROM OACT T0
                LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK BETWEEN 4 AND 7 AND Levels >=3
                AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate BETWEEN @DATEFROMPREV AND @DATETOPREV
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

                UNION ALL 

                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
                FROM OACT T0
                INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK = 8 AND Levels =2
                AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate BETWEEN @DATEFROMPREV AND @DATETOPREV
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode     
                --END PREV          
                )

        L7 ON LEFT(T.AcctCode,5)=LEFT(L7.AcctCode,5)
        INNER JOIN OACT TT ON TT.AcctCode=T.FatherNum
        WHERE T.LEVELS=2 AND T.GROUPMASK BETWEEN 4 AND 8
        GROUP BY T.GroupMask,T.AcctCode,T.AcctName,TT.AcctCode,TT.AcctName
        ORDER BY T.GroupMask
    END
   
END

BEGIN
IF (@STR<>'')
    BEGIN
        SELECT concat(TT.AcctCode,' - ', TT.AcctName) as 'GROUP',T.GroupMask,T.AcctCode,T.AcctName
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
                LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK BETWEEN 4 AND 7 AND Levels >=3
                AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate BETWEEN @DATEFROM AND @DATETO
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

                UNION ALL 

                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS L7,0 AS P7
                FROM OACT T0
                INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK = 8 AND Levels =2
                AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate BETWEEN @DATEFROM AND @DATETO
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode  

                -- UNION ALL 
                -- --HO ACCTG
                -- SELECT GROUPMASK,FatherNum,AcctCode,SUM(L7) AS L7,SUM(P7) AS P7 
                -- FROM(
                -- SELECT T0.GROUPMASK,T0.FatherNum,AcctCode
                -- ,(T1.Debit-T1.Credit)*(SELECT PrcAmount/100 from OCR1 where PrcCode like '%'+@STR+'%' and OcrCode='HO_ACCTG' AND TaxDate BETWEEN ValidFrom AND ISNULL(ValidTo,GETDATE())) 
                -- AS L7
                -- ,0 AS P7
                -- FROM OACT T0
                -- LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode      
                -- WHERE T0.GROUPMASK BETWEEN 4 AND 7 AND Levels >=3
                -- AND T1.ProfitCode ='HO_ACCTG'  AND T1.TaxDate BETWEEN @DATEFROM AND @DATETO
                -- )DD
                -- GROUP BY GROUPMASK,FatherNum,AcctCode

                -- UNION ALL 

                -- SELECT GROUPMASK,FatherNum,AcctCode,SUM(L7) AS L7,SUM(P7) AS P7 
                -- FROM(
                -- SELECT T0.GROUPMASK,T0.FatherNum,AcctCode
                -- ,(T1.Debit-T1.Credit)*(SELECT PrcAmount/100 from OCR1 where PrcCode like '%'+@STR+'%' and OcrCode='HO_ACCTG' AND TaxDate BETWEEN ValidFrom AND ISNULL(ValidTo,GETDATE())) 
                -- AS L7
                -- ,0 AS P7
                -- FROM OACT T0
                -- LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode      
                -- WHERE T0.GROUPMASK = 8 AND Levels >=3
                -- AND T1.ProfitCode ='HO_ACCTG'  AND T1.TaxDate BETWEEN @DATEFROMPREV AND @DATETOPREV
                -- )DD
                -- GROUP BY GROUPMASK,FatherNum,AcctCode 

                --END CURRENT
                UNION ALL 
                
                --PREV
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
                FROM OACT T0
                LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK BETWEEN 4 AND 7 AND Levels >=3
                AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate BETWEEN @DATEFROMPREV AND @DATETOPREV
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

                UNION ALL 

                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
                FROM OACT T0
                INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK = 8 AND Levels =2
                AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate BETWEEN @DATEFROMPREV AND @DATETOPREV
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode 

                -- UNION ALL 
                
                -- --PREV HO ACCTG
                -- SELECT GROUPMASK,FatherNum,AcctCode,SUM(L7) AS L7,SUM(P7) AS P7 
                -- FROM(
                -- SELECT T0.GROUPMASK,T0.FatherNum,AcctCode
                -- ,0 AS L7
                -- ,(T1.Debit-T1.Credit)*(SELECT PrcAmount/100 from OCR1 where PrcCode like '%'+@STR+'%' and OcrCode='HO_ACCTG' AND TaxDate BETWEEN ValidFrom AND ISNULL(ValidTo,GETDATE())) 
                -- AS P7
                -- FROM OACT T0
                -- LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode      
                -- WHERE T0.GROUPMASK BETWEEN 4 AND 7 AND Levels >=3
                -- AND T1.ProfitCode ='HO_ACCTG'  AND T1.TaxDate BETWEEN @DATEFROMPREV AND @DATETOPREV
                -- )DD
                -- GROUP BY GROUPMASK,FatherNum,AcctCode

                -- UNION ALL 

                -- SELECT GROUPMASK,FatherNum,AcctCode,SUM(L7) AS L7,SUM(P7) AS P7 
                -- FROM(
                -- SELECT T0.GROUPMASK,T0.FatherNum,AcctCode
                -- ,0 AS L7
                -- ,(T1.Debit-T1.Credit)*(SELECT PrcAmount/100 from OCR1 where PrcCode like '%'+@STR+'%' and OcrCode='HO_ACCTG' AND TaxDate BETWEEN ValidFrom AND ISNULL(ValidTo,GETDATE()))
                -- AS P7
                -- FROM OACT T0
                -- LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode      
                -- WHERE T0.GROUPMASK = 8 AND Levels >=3
                -- AND T1.ProfitCode ='HO_ACCTG'  AND T1.TaxDate BETWEEN @DATEFROMPREV AND @DATETOPREV
                -- )DD
                -- GROUP BY GROUPMASK,FatherNum,AcctCode     
                --END PREV          
                )

        L7 ON LEFT(T.AcctCode,5)=LEFT(L7.AcctCode,5)
        INNER JOIN OACT TT ON TT.AcctCode=T.FatherNum
        WHERE T.LEVELS=2 AND T.GROUPMASK BETWEEN 4 AND 8
        GROUP BY T.GroupMask,T.AcctCode,T.AcctName,TT.AcctCode,TT.AcctName
        ORDER BY T.GroupMask
    END
   
END


