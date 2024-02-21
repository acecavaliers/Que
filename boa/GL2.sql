DECLARE @Branch Varchar(50) ='ALL BRANCH'
DECLARE @DateFrom Date = '2023-01-01'
DECLARE @DateTo Date = '2023-12-31'


set @branch = replace((@branch),'ALL BRANCH','')


SELECT 
t1.REFDATE, t1.Transid, t1.Line_ID ,
T0.Number as 'JE Entry',


T0.REFDATE AS Date,
CONCAT('JE-',T0.NUMBER, '  ',
CASE WHEN T0.TRANSTYPE = 69 THEN 'IF-'
WHEN T0.TransType = 15 THEN 'DN-'
WHEN T0.TransType = 310000001 then 'OB-'
WHEN T0.TransType = 67 then 'IM-'
WHEN T0.TransType = 21 then 'PR-'
WHEN T0.TransType = 18 then 'PU-'
WHEN T0.TransType = 19 then 'PC-'
WHEN T0.TransType = 13 then 'IN-'
WHEN T0.TransType = 162 then 'MR-'
WHEN T0.TransType = 59 then 'SI-'
WHEN T0.TransType = 60 then 'SO-'
WHEN T0.TransType = 20 then 'PD-'
WHEN T0.TransType = 14 then 'CN-'
WHEN T0.TransType = 30 then 'JE-'
WHEN T0.TransType = 24 then 'RC-'
WHEN T0.TransType = 25 then 'DP-'
WHEN T0.TransType = 46 then 'PS-'
WHEN T0.TransType = 203 then 'DT-'
WHEN T0.TransType = 204 then 'DT-'
WHEN T0.TransType = -2 then 'OB-'
WHEN T0.TransType = 1470000090 then 'FT-'
WHEN T0.TransType = 321 then 'JR-'
WHEN T0.TransType = 1470000049 then 'AC-'
WHEN T0.TransType = 1470000071 then 'DR-'
WHEN T0.TransType = 1470000075 then 'MD-'
WHEN T0.TransType = -4 then 'BN-'
END,
REPLICATE('0', 7 - LEN(T0.BaseRef)) + CAST(T0.BaseRef AS varchar)  ) as 'Base Reference',
CASE WHEN T0.MEMO <> T1.LINEMEMO THEN
concat(t0.Memo,' : ', T1.LineMemo)
ELSE t0.Memo
END as 'Brief Description',
T1.Account,
T2.Acctname,




ISNULL((SELECT SUM(DEBIT)-SUM(CREDIT) FROM JDT1 WHERE T1.Account=Account AND TaxDate <= DATEADD(DAY,-1,@DateFrom)) ,0) as 'PHP Balance',


T1.Debit AS 'PHP Debit',

T1.Credit AS 'PHP Credit',

-- ISNULL((SELECT SUM(DEBIT)-SUM(CREDIT) FROM JDT1 WHERE T1.BPLId=BPLId AND T1.Account=Account AND TaxDate < @DateFrom),0)+

-- SUM(isnull(T1.DEBIT,0) - isnull(T1.CREDIT,0)) 
-- OVER (PARTITION BY T1.ACCOUNT ORDER BY T1.ACCOUNT, T0.taxdate, T1.Transid, T1.Line_ID ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) 
-- as PHPRunningBalanceRR,

ISNULL((SELECT SUM(DEBIT)-SUM(CREDIT) FROM JDT1 WHERE  Account=T1.Account AND TaxDate <= DATEADD(DAY,-1,@DateFrom)),0)+

SUM(isnull(T1.DEBIT,0) - isnull(T1.CREDIT,0)) OVER (PARTITION BY T1.ACCOUNT ORDER BY T1.ACCOUNT, T0.REFDATE, T1.Transid 
ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) as PHPRunningBalance,


T1.BPLName
FROM OJDT t0 
INNER JOIN JDT1 T1 ON T0.NUMBER = T1.TRANSID 
INNER  JOIN OACT T2 ON T1.ACCOUNT = T2.AcctCode
--WHERE T0.TransType = 1470000075
--WHERE T0.MEMO <> T1.LINEMEMO
--WHERE T1.Account = 'CA01010101'
WHERE T1.BPLName like '%'+@Branch+'%'
AND T0.TaxDate BETWEEN @DateFrom and @DateTo
and t1.account='OP010-0100-0100'
order BY
t1.REFDATE, 
t1.Transid, 
t1.Line_ID ASC
