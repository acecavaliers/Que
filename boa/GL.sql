DECLARE @branch Varchar(50) =''
DECLARE @DateFrom Date = '2023-01-01'
DECLARE @DateTo Date = '2023-12-31'


set @branch = replace((@branch),'ALL BRANCH','')

IF (@BRANCH='')

BEGIN
    SELECT * FROM(
    SELECT 
    t1.REFDATE, t1.Transid, t1.Line_ID ,
    T0.Number as 'JE Entry',
    T0.REFDATE AS Date,
    CONCAT('JE ',T0.NUMBER, '  ',
        CASE 
            WHEN T0.TRANSTYPE = 69 THEN 'IF '
            WHEN T0.TransType = 15 THEN 'DN '
            WHEN T0.TransType = 310000001 then 'OB '
            WHEN T0.TransType = 67 then 'IM '
            WHEN T0.TransType = 21 then 'PR '
            WHEN T0.TransType = 18 then 'PU '
            WHEN T0.TransType = 19 then 'PC '
            WHEN T0.TransType = 13 then 'IN '
            WHEN T0.TransType = 162 then 'MR '
            WHEN T0.TransType = 59 then 'SI '
            WHEN T0.TransType = 60 then 'SO '
            WHEN T0.TransType = 20 then 'PD '
            WHEN T0.TransType = 14 then 'CN '
            WHEN T0.TransType = 30 then 'JE '
            WHEN T0.TransType = 24 then 'RC '
            WHEN T0.TransType = 25 then 'DP '
            WHEN T0.TransType = 46 then 'PS '
            WHEN T0.TransType = 203 then 'DT '
            WHEN T0.TransType = 204 then 'DT '
            WHEN T0.TransType = -2 then 'OB '
            WHEN T0.TransType = 1470000090 then 'FT '
            WHEN T0.TransType = 321 then 'JR '
            WHEN T0.TransType = 1470000049 then 'AC '
            WHEN T0.TransType = 1470000071 then 'DR '
            WHEN T0.TransType = 1470000075 then 'MD '
            WHEN T0.TransType = -4 then 'BN '
        END,
    CAST(T0.BaseRef AS varchar)) AS 'Base Reference',
    CASE 
        WHEN T0.MEMO <> T1.LINEMEMO THEN
        concat(t0.Memo,' : ', T1.LineMemo)
        ELSE t0.Memo
    END as 'Brief Description',
    T1.Account,
    T2.Acctname,   
       
    ISNULL((SELECT SUM(DEBIT)-SUM(CREDIT) FROM JDT1 WHERE  T1.Account=Account AND TaxDate <= DATEADD(DAY,-1,@DateFrom)) ,0)
    AS 'PHP Balance',

    T1.Debit AS 'PHP Debit',

    T1.Credit AS 'PHP Credit',    
    
    ISNULL((SELECT SUM(DEBIT)-SUM(CREDIT) FROM JDT1 WHERE  Account=T1.Account AND TaxDate <= DATEADD(DAY,-1,@DateFrom)),0)
    +
    SUM(isnull(T1.DEBIT,0) - isnull(T1.CREDIT,0)) OVER (PARTITION BY T1.ACCOUNT ORDER BY T1.ACCOUNT, T0.REFDATE, T1.Transid 
    ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) 
    AS PHPRunningBalance,
    T1.BPLName

    FROM OJDT t0 
    INNER JOIN JDT1 T1 ON T0.NUMBER = T1.TRANSID 
    INNER  JOIN OACT T2 ON T1.ACCOUNT = T2.AcctCode
    WHERE T1.BPLName like '%'+@Branch+'%'
    AND T0.TaxDate BETWEEN @DateFrom and @DateTo



    UNION ALL

    SELECT 
    REFDATE, 
    Transid, 
    Line_ID,
    '' as 'JE Entry',
    @DateFrom AS Date,
    '' as 'Base Reference',
    'PREVIOUS BALANCE' as 'Brief Description',
    Account,
    Acctname,
    ISNULL(SUM(DEBIT)-SUM(CREDIT),0) AS 'PHP Balance',
    0 AS 'PHP Debit',
    0 AS 'PHP Credit',
    ISNULL(SUM(DEBIT)-SUM(CREDIT) ,0) as 'PHPRunningBalance',
    BPLName
    FROM(

        SELECT
        t1.REFDATE, T1.Transid, T1.Line_ID ,
        T1.Account,
        T0.Acctname,
        SUM(T1.DEBIT) AS 'DEBIT',
        SUM(T1.CREDIT) AS 'CREDIT',
        T1.BPLName
        
        FROM OACT T0
        INNER JOIN JDT1 T1 ON T0.AcctCode=T1.Account AND T1.TaxDate<@DateFrom
        LEFT JOIN JDT1 T2 ON T2.Account=T0.AcctCode AND T2.TaxDate BETWEEN @DateFrom AND @DateTo
        WHERE 
        T2.Account IS NULL
        GROUP BY T1.Account ,T0.AcctName ,T1.BPLName,T1.REFDATE, T1.Transid, T1.Line_ID 

    )DD 
    GROUP BY Account ,AcctName ,BPLName,REFDATE, Transid, Line_ID 
    
    )xx
    -- where account='OP010-0100-0100'
    ORDER BY 
    ACCOUNT,
    REFDATE, 
    Transid, 
    Line_ID ASC


END

IF (@BRANCH<>'')

BEGIN
  SELECT * FROM(
    SELECT 
    
    t1.REFDATE, t1.Transid, t1.Line_ID ,
    T0.Number as 'JE Entry',
    T0.REFDATE AS Date,
    CONCAT('JE ',T0.NUMBER, '  ',
        CASE 
            WHEN T0.TRANSTYPE = 69 THEN 'IF '
            WHEN T0.TransType = 15 THEN 'DN '
            WHEN T0.TransType = 310000001 then 'OB '
            WHEN T0.TransType = 67 then 'IM '
            WHEN T0.TransType = 21 then 'PR '
            WHEN T0.TransType = 18 then 'PU '
            WHEN T0.TransType = 19 then 'PC '
            WHEN T0.TransType = 13 then 'IN '
            WHEN T0.TransType = 162 then 'MR '
            WHEN T0.TransType = 59 then 'SI '
            WHEN T0.TransType = 60 then 'SO '
            WHEN T0.TransType = 20 then 'PD '
            WHEN T0.TransType = 14 then 'CN '
            WHEN T0.TransType = 30 then 'JE '
            WHEN T0.TransType = 24 then 'RC '
            WHEN T0.TransType = 25 then 'DP '
            WHEN T0.TransType = 46 then 'PS '
            WHEN T0.TransType = 203 then 'DT '
            WHEN T0.TransType = 204 then 'DT '
            WHEN T0.TransType = -2 then 'OB '
            WHEN T0.TransType = 1470000090 then 'FT '
            WHEN T0.TransType = 321 then 'JR '
            WHEN T0.TransType = 1470000049 then 'AC '
            WHEN T0.TransType = 1470000071 then 'DR '
            WHEN T0.TransType = 1470000075 then 'MD '
            WHEN T0.TransType = -4 then 'BN '
        END,
    CAST(T0.BaseRef AS varchar)) AS 'Base Reference',
    CASE 
        WHEN T0.MEMO <> T1.LINEMEMO THEN
        concat(t0.Memo,' : ', T1.LineMemo)
        ELSE t0.Memo
    END as 'Brief Description',
    T1.Account,
    T2.Acctname,   
       
    ISNULL((SELECT SUM(DEBIT)-SUM(CREDIT) FROM JDT1 WHERE T1.BPLId=BPLId AND T1.Account=Account AND TaxDate <= DATEADD(DAY,-1,@DateFrom)) ,0)
    AS 'PHP Balance',

    T1.Debit AS 'PHP Debit',

    T1.Credit AS 'PHP Credit',    
    
    ISNULL((SELECT SUM(DEBIT)-SUM(CREDIT) FROM JDT1 WHERE T1.BPLId=BPLId AND Account=T1.Account AND TaxDate <= DATEADD(DAY,-1,@DateFrom)),0)
    +
    SUM(isnull(T1.DEBIT,0) - isnull(T1.CREDIT,0)) OVER (PARTITION BY T1.ACCOUNT ORDER BY T1.ACCOUNT, T0.REFDATE, T1.Transid 
    ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) 
    AS PHPRunningBalance,
    T1.BPLName
    
    FROM OJDT t0 
    INNER JOIN JDT1 T1 ON T0.NUMBER = T1.TRANSID 
    INNER  JOIN OACT T2 ON T1.ACCOUNT = T2.AcctCode
    WHERE T1.BPLName like '%'+@Branch+'%'
    AND T0.TaxDate BETWEEN @DateFrom and @DateTo



    UNION ALL

    SELECT 
   
    REFDATE, 
    Transid, 
    Line_ID,
    '' as 'JE Entry',
    @DateFrom AS Date,
    '' as 'Base Reference',
    'PREVIOUS BALANCE' as 'Brief Description',
    Account,
    Acctname,
    ISNULL(SUM(DEBIT)-SUM(CREDIT),0) AS 'PHP Balance',
    0 AS 'PHP Debit',
    0 AS 'PHP Credit',
    ISNULL(SUM(DEBIT)-SUM(CREDIT) ,0) as 'PHPRunningBalance',
    BPLName
    FROM(

        SELECT
        t1.REFDATE, T1.Transid, T1.Line_ID ,
        T1.Account,
        T0.Acctname,
        SUM(T1.DEBIT) AS 'DEBIT',
        SUM(T1.CREDIT) AS 'CREDIT',
        T1.BPLName
        
        FROM OACT T0
        INNER JOIN JDT1 T1 ON T0.AcctCode=T1.Account AND T1.TaxDate<@DateFrom
        LEFT JOIN JDT1 T2 ON T2.Account=T0.AcctCode AND T2.TaxDate BETWEEN @DateFrom AND @DateTo
        WHERE 
        T2.Account IS NULL
        AND T1.BPLName like '%'+@Branch+'%'
        GROUP BY T1.Account ,T0.AcctName ,T1.BPLName,T1.REFDATE, T1.Transid, T1.Line_ID 

    )DD 
    
        GROUP BY Account ,AcctName ,BPLName,REFDATE, Transid, Line_ID 
    )xx
    -- WHERE TransType=-4
    ORDER BY 
    ACCOUNT,
    REFDATE, 
    Transid, 
    Line_ID ASC

END


