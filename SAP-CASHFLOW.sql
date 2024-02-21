DECLARE @BRANCH Varchar(5)='3', @DATEFROM DATE ='02-01-2022' ,@DATETO DATE ='12-31-2022' , @DATEFROMPREV  DATE = '01-01-2021', @DATETOPREV DATE ='01-31-2022'


SET @BRANCH = REPLACE(@BRANCH,'0','')

    SELECT AcctCode,AcctName,Levels,FatherNum,
    CASE WHEN AcctCode IN ('NA010-0000-0000','NA020-0000-0000') THEN 2 ELSE 1 END as 'NO',
    CASE WHEN ACCTCODE='CA030-0000-0000'THEN 3 WHEN ACCTCODE = 'CA040-0000-0000' THEN 4 WHEN ACCTCODE = 'NA010-0000-0000' THEN 7 
    WHEN ACCTCODE='CA060-0000-0000' THEN 4 ELSE 8 END AS 'LINE NO',
    CASE
        WHEN ACCTCODE ='NA020-0000-0000'
        THEN  
                (
                (
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%OP170%'
                    and TAXDATE <=@DATETO),0)
                    -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%OP170%'
                    and TAXDATE <=@DATETOPREV),0)
                )
                +
                (
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETO),0)
                    -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETOPREV),0)
                )
                - 
                (
                    CASE WHEN (SELECT MIN(TaxDate) FROM JDT1) BETWEEN @DATEFROM AND @DATETO THEN  
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROM AND @DATETO ),0)
                   -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROM AND @DATETO),0)
                    ELSE 
                    0
                    END 
                )
                )*-1
        WHEN ACCTCODE ='NA010-0000-0000'
        THEN 
                (
                (
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%OP160%'
                    and TAXDATE <=@DATETO),0)
                    -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%OP160%'
                    and TAXDATE <=@DATETOPREV),0)
                )
                +
                (
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETO),0)
                    -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETOPREV),0)
                )
                - 
                (
                    CASE WHEN (SELECT MIN(TaxDate) FROM JDT1) BETWEEN @DATEFROM AND @DATETO THEN  
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                     AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROM AND @DATETO ),0)
                   -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROM AND @DATETO),0)
                    ELSE 
                    0
                    END 
                )
                )*-1
        WHEN ACCTCODE='CA030-0000-0000' 
        THEN
            (
                (
                    (
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                        and TAXDATE <=@DATETO),0)
                        +
                        ISNULL((select sum(A1.Debit)-sum(A1.Credit) as t from oact A0
                        left join jdt1  A1 on A0.AcctCode=A1.Account
                        where levels =5 and GroupMask=3 AND AcctCode like '%EQ010-0500%' AND A1.BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE BETWEEN @DATEFROM AND @DATETO),0)
                    )
                    -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETOPREV),0)
                )                 
               - 
                    CASE WHEN (SELECT MIN(TaxDate) FROM JDT1) BETWEEN @DATEFROM AND @DATETO THEN  
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROM AND @DATETO ),0)
                    -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROM AND @DATETO),0) 
                    ELSE 
                    0
                    END
                
            )*-1
        
        ELSE 
            (
                (
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETO),0)
                    -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETOPREV),0)
                )
                - 
                (
                    CASE WHEN ACCTCODE='CA040-0000-0000'
                    THEN 
                        (
                            ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                            AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROM AND @DATETO ),0)
                        -
                            ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                             AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROM AND @DATETO),0)

                        )*-1
                     ELSE
                    CASE WHEN (SELECT MIN(TaxDate) FROM JDT1) BETWEEN @DATEFROM AND @DATETO THEN  
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE BETWEEN @DATEFROM AND @DATETO ),0)
                   -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE BETWEEN @DATEFROM AND @DATETO),0)
                    ELSE 
                    0
                    END END
                )
            )*-1
        
    END AS 'Current', 

    --Previous Year  End
    CASE
        WHEN ACCTCODE ='NA020-0000-0000'
        THEN 
                (
                    --OP170-0000-0000 - Amortization Expense 
                (
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%OP170%' 
                        and TAXDATE <=@DATETOPREV),0)
                    -
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%OP170%'
                        and TAXDATE <=@DATEFROMPREV),0)
                )
                    + 
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%OP170%'
                        AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0) 
                
                +
                (    
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETOPREV),0)
                -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATEFROMPREV),0)
                )
                - 
                (
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0)
                    - 
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0)
                )
                )*-1

        WHEN ACCTCODE ='NA010-0000-0000'
        THEN 
                (
                    --OP160-0000-0000 - Depreciation Expense
                (
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%OP160%'
                        and TAXDATE <=@DATETOPREV),0)
                    -
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%OP160%'
                        and TAXDATE <=@DATEFROMPREV),0)
                )
                    + 
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%OP160%'
                        AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0) 
                
                +
                (    
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETOPREV),0)
                -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATEFROMPREV),0)
                )
                - 
                (
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0)
                    - 
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0)
                )
                )*-1

        WHEN ACCTCODE='CA030-0000-0000' 
        THEN 
            (
                
                (
                        (
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                        and TAXDATE <=@DATETOPREV),0)
                        +
                        CASE WHEN (SELECT MIN(TaxDate) FROM JDT1) BETWEEN @DATEFROMPREV AND @DATETOPREV THEN   0
                        ELSE
                        ISNULL((select sum(A1.Debit)-sum(A1.Credit) as t from oact A0
                        left join jdt1  A1 on A0.AcctCode=A1.Account
                        where levels =5 and GroupMask=3 AND AcctCode like '%EQ010-0500%' AND A1.BPLID LIKE '%'+@BRANCH+'%' AND  TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV ),0)
                        END
                    )
                    -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATEFROMPREV),0)
                )
               - 
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    /* */ AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV ),0)
                    - 
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0) 
            )*-1
        
        ELSE 
            (
                (    
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETOPREV),0)
                -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATEFROMPREV),0)
                )
                - 
                  
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                     AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0)
                    - 
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0) 
                   
            
                    
                
            )*-1
        
    END AS 'Previous'

    FROM OACT T0
    WHERE LEVELS=3 AND GROUPMASK = 1  AND AcctCode IN ('CA030-0000-0000','CA040-0000-0000','NA010-0000-0000','NA020-0000-0000','CA060-0000-0000')

UNION ALL
    --//DOUBTFUL & DEPRECIATION
    SELECT AcctCode,AcctName,Levels,FatherNum,0 AS 'NO',CASE WHEN ACCTCODE='OP160-0000-0000' THEN 1 ELSE 2 END AS 'LINE NO',
    --Current Year End
            
                ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                and TAXDATE <=@DATETO),0)
                -
                ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                and TAXDATE <=@DATETOPREV),0)
            
        
        AS 'CURR',

    --Previous Year  End
            
                (
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETOPREV),0)
                -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATEFROMPREV),0)
                )
                + 
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0)
            
        AS 'PPREV'

    FROM OACT T0
    WHERE LEVELS=2 AND GROUPMASK = 6  AND AcctCode in ('OP160-0000-0000','OP150-0000-0000')

UNION ALL
--EXPENSES & PAYABLES
    SELECT AcctCode,AcctName,Levels,FatherNum,1 AS 'NO',CASE WHEN ACCTCODE='CL010-0000-0000' THEN 5 ELSE 6 END AS 'LINE NO',
                (   
                    (
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                        and TAXDATE <=@DATETO),0)
                        -
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                        and TAXDATE <=@DATETOPREV),0)
                    )
                    - 
                    CASE WHEN (SELECT MIN(TaxDate) FROM JDT1) BETWEEN @DATEFROM AND @DATETO THEN  
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROM AND @DATETO ),0)
                   -
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROM AND @DATETO),0) 
                    ELSE
                    0
                    END
                )*-1
            
            AS 'CURR',

        --Previous Year  End
                (
                    (
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                        and TAXDATE <=@DATETOPREV),0)
                    -
                        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                        and TAXDATE <=@DATEFROMPREV),0)
                    )
                    -                 
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransCode='OBB' AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0)
                    - 
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=310000001 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <> @DATEFROMPREV AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0) 
                )*-1
            AS 'PPREV'

    FROM OACT T0
    WHERE LEVELS=3 AND GROUPMASK = 2  AND AcctCode IN ('CL010-0000-0000','CL020-0000-0000')

UNION ALL
--//CASH OPENING
    SELECT AcctCode,AcctName,Levels,FatherNum,3 as 'NO',9 as 'Line No',
    --Current Year Beginning
                CASE WHEN (SELECT MIN(TaxDate) FROM JDT1) BETWEEN @DATEFROM AND @DATETO THEN   
                ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=-2 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                AND TAXDATE BETWEEN @DATEFROM AND @DATETO),0)
                ELSE 
                ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                AND TAXDATE <=@DATETOPREV),0)
                END AS 'Current',
    --Previous Year  Beginning

                CASE WHEN (SELECT MIN(TaxDate) FROM JDT1) BETWEEN @DATEFROMPREV AND @DATETOPREV THEN  
                ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE TransType=-2 AND BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                AND TAXDATE <> @DATEFROM AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0)
                ELSE 
                ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                and TAXDATE <=@DATEFROMPREV),0)               
                END AS 'Previous'

    FROM OACT T0
    WHERE LEVELS=3 AND GROUPMASK = 1  AND AcctCode ='CA010-0000-0000'

UNION ALL
--//CASH CLOSING
    SELECT AcctCode,AcctName,Levels,FatherNum,4 as 'NO',10 as 'Line No',
        --Current Year Beginning
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETO),0)
                    AS 'Current',
        --Previous Year  Beginning
                    ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    and TAXDATE <=@DATETOPREV),0)
                    AS 'Previous' 

    FROM OACT T0
    WHERE LEVELS=3 AND GROUPMASK = 1  AND AcctCode ='CA010-0000-0000'

UNION ALL 
--//NET SALES
    SELECT '0' AS 'ACCTCODE','NET PROFIT' AS 'AcctName',0,'0',0 AS 'NO',0 AS 'LINE NO',SUM(CURR),SUM(PREVIOUS) FROM(
    SELECT 

            (
                ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                AND TAXDATE BETWEEN @DATEFROM AND @DATETO),0)
                -
                ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE  TransType=-3 and  BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                AND TAXDATE BETWEEN @DATEFROM AND @DATETO AND AcctCode ='OP190-1400-0000'),0)
            )*-1
            AS 'CURR',
            --Previous Year  Beginning
            (
                ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV),0)
                -
                ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE  TransType=-3 and  BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                AND TAXDATE BETWEEN @DATEFROMPREV AND @DATETOPREV AND AcctCode ='OP190-1400-0000'),0)
            )*-1
            AS 'Previous'

    FROM OACT T0
    WHERE LEVELS=2 AND GROUPMASK BETWEEN 4 AND 8)D

ORDER BY NO, [LINE NO] 