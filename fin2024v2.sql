
DECLARE @BRANCH Varchar(20)='koronadal', 
@STR Varchar(20)='', 
@DATEFROM DATE ='2023-1-1',
@DATETO DATE ='2023-12-31', 
@DATEFROMPREV  DATE = '2023-01-01', 
@DATETOPREV DATE = '2023-12-31'

BEGIN
IF (@STR='')
    BEGIN
        SELECT T.GroupMask,T.AcctCode,T.AcctName,
        ISNULL(SUM(T3.AMT),ISNULL(SUM(T4.AMT),0)) 
        
        FROM OACT T 
        LEFT JOIN

                (
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS AMT
                FROM OACT T0
                INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK BETWEEN 4 AND 8 AND Levels >=3
                AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate BETWEEN @DATEFROM AND @DATETO
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode
                )

        T3 ON LEFT(T.AcctCode,5)=LEFT(T3.AcctCode,5)

        LEFT JOIN

                (
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS AMT
                FROM OACT T0
                INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK = 8 AND Levels =2
                AND T1.BPLName LIKE '%'+@BRANCH+'%' AND T1.TaxDate BETWEEN @DATEFROM AND @DATETO
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode
                )

        T4 ON LEFT(T.AcctCode,5)=LEFT(T4.AcctCode,5)
        WHERE T.LEVELS=2 AND T.GROUPMASK BETWEEN 4 AND 8
        GROUP BY T.GroupMask,T.AcctCode,T.AcctName
        ORDER BY T.GroupMask
    END

IF (@STR<>'')
    BEGIN
        SELECT T.GroupMask,T.AcctCode,T.AcctName,
        ISNULL(SUM(T3.AMT),ISNULL(SUM(T4.AMT),0)) 
        
        FROM OACT T 
        LEFT JOIN

                (
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS AMT
                FROM OACT T0
                INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK BETWEEN 4 AND 8 AND Levels >=3
                AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate BETWEEN @DATEFROM AND @DATETO
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode
                )

        T3 ON LEFT(T.AcctCode,5)=LEFT(T3.AcctCode,5)
        
        LEFT JOIN

                (
                SELECT T0.GROUPMASK,T0.FatherNum,AcctCode,SUM(T1.Debit-T1.Credit ) AS AMT
                FROM OACT T0
                INNER JOIN JDT1 T1 ON T1.Account=T0.AcctCode        
                WHERE T0.GROUPMASK = 8 AND Levels =2
                AND T1.ProfitCode LIKE '%'+@STR+'%' AND T1.TaxDate BETWEEN @DATEFROM AND @DATETO
                GROUP BY T0.GROUPMASK,T0.FatherNum,AcctCode
                )

        T4 ON LEFT(T.AcctCode,5)=LEFT(T4.AcctCode,5)
        WHERE T.LEVELS=2 AND T.GROUPMASK BETWEEN 4 AND 8
        GROUP BY T.GroupMask,T.AcctCode,T.AcctName
        ORDER BY T.GroupMask
    END


END





