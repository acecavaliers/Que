



DECLARE @BRANCH Varchar(20)='{?brachID}', 
@STR Varchar(20)='{?Store}', 
@DATETO DATE ={?DateTo}, 
@DATETOPREV DATE = {?DateToPrev}


-- DECLARE @BRANCH Varchar(20)='koronadal', 
-- @STR Varchar(20)='All', 
-- @DATETO DATE ='2023-12-31', 
-- @DATETOPREV DATE = '2022-12-31'

SET @BRANCH = REPLACE(@BRANCH,'All Branch','')
SET @STR = REPLACE(@STR,'All','')
BEGIN
IF (@STR='')
    BEGIN
        --INCOME
        SELECT '0'as 'GROUP',0 AS GroupMask,
        '0' AS AcctCode,
        'INCOME' AS AcctName,
        SUM(L7) AS L7 ,
        SUM(P7)  AS P7
         FROM (
            SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS L7,0 AS P7
            FROM OACT T0
            LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
            WHERE T0.GROUPMASK BETWEEN 4 AND 7 AND Levels >=3
            AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate <= @DATETO
            GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

            UNION ALL 

            SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS L7,0 AS P7
            FROM OACT T0
            INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
            WHERE T0.GROUPMASK = 8 AND Levels =2
            AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate <= @DATETO
            GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode 

            UNION ALL 
            --PREV
            SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
            FROM OACT T0
            LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
            WHERE T0.GROUPMASK BETWEEN 4 AND 7 AND Levels >=3
            AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate <= @DATETOPREV
            GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

            UNION ALL 

            SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
            FROM OACT T0
            INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
            WHERE T0.GROUPMASK = 8 AND Levels =2
            AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate <= @DATETOPREV
            GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode     
            --END PREV
         )DD

        UNION ALL 
        --DATA FP
        SELECT concat(T.AcctCode,' - ', T.AcctName)as 'GROUP',T.GroupMask,T.AcctCode,T.AcctName
        ,ISNULL(SUM(L7),0) AS L7
        ,ISNULL(SUM(P7),0) AS P7
        
        FROM OACT T 
        LEFT JOIN

                (
                --CURRENT
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS L7,0 AS P7
                FROM OACT T0
                LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK BETWEEN 1 AND 3 AND Levels >=3
                AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate  <= @DATETO
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode
 
                --END CURRENT
                UNION ALL 
                --PREV
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
                FROM OACT T0
                LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK BETWEEN 1 AND 3 AND Levels >=3
                AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate  <= @DATETOPREV
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

                   
                --END PREV          
                )

        L7 ON LEFT(T.AcctCode,5)=LEFT(L7.AcctCode,5)

        WHERE T.LEVELS=3 AND T.GROUPMASK BETWEEN 1 AND 3
        GROUP BY T.GroupMask,T.AcctCode,T.AcctName
        ORDER BY GroupMask
    END
   
END

BEGIN
IF (@STR<>'')
    BEGIN
         --INCOME
        SELECT 0 as 'GROUP',0 AS GroupMask,
        '0' AS AcctCode,
        'INCOME' AS AcctName,
        SUM(L7) AS L7 ,
        SUM(P7)  AS P7
        FROM(
            SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS L7,0 AS P7
            FROM OACT T0
            LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
            WHERE T0.GROUPMASK BETWEEN 4 AND 7 AND Levels >=3
            AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate <= @DATETO
            GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

            UNION ALL 

            SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS L7,0 AS P7
            FROM OACT T0
            INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
            WHERE T0.GROUPMASK = 8 AND Levels =2
            AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate <= @DATETO
            GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode  
            --END CURRENT
            UNION ALL 
            
            --PREV
            SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
            FROM OACT T0
            LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
            WHERE T0.GROUPMASK BETWEEN 4 AND 7 AND Levels >=3
            AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate <= @DATETOPREV
            GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

            UNION ALL 

            SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
            FROM OACT T0
            INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
            WHERE T0.GROUPMASK = 8 AND Levels =2
            AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate <= @DATETOPREV
            GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode 
        )DD

        UNION ALL 
        SELECT concat(T.AcctCode,' - ', T.AcctName)as 'GROUP',T.GroupMask,T.AcctCode,T.AcctName
        ,ISNULL(SUM(L7),0) AS L7
        ,ISNULL(SUM(P7),0) AS P7
        
        FROM OACT T 
        LEFT JOIN

                (
                --CURRENT
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS L7,0 AS P7
                FROM OACT T0
                LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK BETWEEN 1 AND 3 AND Levels >=3
                AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate  <= @DATETO
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode
                

                --END CURRENT
                UNION ALL 
                
                --PREV
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,0 AS L7,SUM(T1.Debit-T1.Credit ) AS P7
                FROM OACT T0
                LEFT JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK BETWEEN 1 AND 3 AND Levels >=3
                AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate  <= @DATETOPREV
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode

                       
                )

        L7 ON LEFT(T.AcctCode,5)=LEFT(L7.AcctCode,5)

        WHERE T.LEVELS=3 AND T.GROUPMASK BETWEEN 1 AND 3
        GROUP BY T.GroupMask,T.AcctCode,T.AcctName
        ORDER BY GroupMask
    END
   
END


