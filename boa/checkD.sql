

DECLARE @dt as varchar(1) =''
DECLARE @Branch Varchar(50) = ''
DECLARE @DateFrom  Date = '2023-01-01'
DECLARE @DateTo  Date = '2023-12-31'
DECLARE @AccountCode VarChar(50) = ''

set @branch = replace((@branch),'ALL BRANCH','')

SELECT DISTINCT * FROM (

SELECT 
T0.TaxDate AS 'Posting Date',
T0.TAXDATE AS 'Document Date',
T0.DOCNUM AS 'Payment Voucher #',
T0.CounterRef AS 'Reference #',
T0.CARDCODE AS 'Vendor Code',
T0.CARDNAME AS 'Vendor Name',
T1.LICTRADNUM AS 'Vendor TIN',
T3.Account AS 'Account Code',
T4.AcctName AS 'Account Name',
T3.DEBIT AS 'PHP Debit',
T3.CREDIT AS 'PHP Credit',

CONCAT(T2.Memo, ' ' ,
CASE WHEN T0.DocCurr = 'PHP' THEN '' ELSE
CONCAT( T0.DOCCURR, ': ' , FORMAT(T0.DocTotalFC, 'N')   )END,' ',
cASE WHEN ('Rate: '+(cast(cast(t0.DocRate as decimal(16,2)) as varchar))) = 'Rate: 0.00' THEN
''
else
('Rate: '+(cast(cast(t0.DocRate as decimal(16,2)) as varchar)))end) AS 'Remarks',

'APV #' AS 'APV #',
T0.BPLNAME, T3.TransId
--t3.CheckAbs,
--t1.U_DC,
FROM OVPM T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN OJDT T2 ON T0.TRANSID = T2.NUMBER 
INNER JOIN JDT1 T3 ON T2.NUMBER = T3.TRANSID 
INNER JOIN OACT T4 ON T3.ACCOUNT = T4.AcctCode
WHERE T0.DOCTYPE <> 'A' 
AND T3.TRANSID NOT IN (SELECT T5.TRANSID FROM JDT1 T5 INNER JOIN OACT T6 ON T5.Account = T6.AcctCode WHERE T6.ACCTNAME LIKE '%REVOLV%' )
AND T3.TRANSID NOT IN (SELECT T7.TRANSID FROM JDT1 T7 INNER JOIN OACT T8 ON T7.Account = T8.AcctCode WHERE T8.DETAILS LIKE '%Merchant%' ) 
and t0.CheckSum > 0 
and t3.CheckAbs is not null AND T1.U_DC IS NULL 
AND T0.CardCode  NOT IN (SELECT CARDCODE FROM OCRD WHERE CARDTYPE='S' AND U_TaxPayerClass='Y' )
AND T3.BPLName like  '%'+@Branch+'%'
And T0.TaxDate between @DateFrom and @DateTo
--AND T3.Account LIKE '%'+@AccountCode+'%'
UNION ALL


SELECT 
T0.TaxDate AS 'Posting Date',
T0.TAXDATE AS 'Document Date',
T0.DOCNUM AS 'Payment Voucher #',
T0.CounterRef AS 'Reference #',
T0.CARDCODE AS 'Vendor Code',
T0.CARDNAME AS 'Vendor Name',
T1.LICTRADNUM AS 'Vendor TIN',
T3.Account AS 'Account Code',
T4.AcctName AS 'Account Name',
T3.DEBIT AS 'PHP Debit',
T3.CREDIT AS 'PHP Credit',

CONCAT(T2.Memo, ' ' ,
CASE WHEN T0.DocCurr = 'PHP' THEN '' ELSE
CONCAT( T0.DOCCURR, ': ' , FORMAT(T0.DocTotalFC, 'N')   )END,' ',
cASE WHEN ('Rate: '+(cast(cast(t0.DocRate as decimal(16,2)) as varchar))) = 'Rate: 0.00' THEN
''
else
('Rate: '+(cast(cast(t0.DocRate as decimal(16,2)) as varchar)))end) AS 'Remarks',

'APV #' AS 'APV #',
T0.BPLNAME, T3.TransId
--t3.CheckAbs,
--t1.U_DC,
FROM OVPM T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN OJDT T2 ON T0.TRANSID = T2.StornoToTr 
INNER JOIN JDT1 T3 ON T2.NUMBER = T3.TRANSID 
INNER JOIN OACT T4 ON T3.ACCOUNT = T4.AcctCode
WHERE T0.DOCTYPE <> 'A' 
AND T3.TRANSID NOT IN (SELECT T5.TRANSID FROM JDT1 T5 INNER JOIN OACT T6 ON T5.Account = T6.AcctCode WHERE T6.ACCTNAME LIKE '%REVOLV%' )
AND T3.TRANSID NOT IN (SELECT T7.TRANSID FROM JDT1 T7 INNER JOIN OACT T8 ON T7.Account = T8.AcctCode WHERE T8.DETAILS LIKE '%Merchant%' ) 
and t0.CheckSum > 0 
and t3.CheckAbs is not null AND T1.U_DC IS NULL 
AND T0.CardCode  NOT IN (SELECT CARDCODE FROM OCRD WHERE CARDTYPE='S' AND U_TaxPayerClass='Y' )
AND T3.BPLName like  '%'+@Branch+'%'
--AND T3.Account LIKE '%'+@AccountCode+'%'
And T0.TaxDate between @DateFrom and @DateTo
) X
WHERE [Account Code] LIKE '%'+@AccountCode+'%'
ORDER BY X.[Payment Voucher #] ASC
