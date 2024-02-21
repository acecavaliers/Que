

DECLARE @dt as varchar(1) ='D'
DECLARE @Branch Varchar(50) = 'ALL BRANCH'
DECLARE @RESULT Varchar(100) = ''
DECLARE @DateFrom Date ='2023-01-01'
DECLARE @DateTo Date = '2023-12-31'

set @branch = replace((@branch),'ALL BRANCH','')


SELECT DISTINCT
T0.DOCNUM,
T0.ObjType,
ISNULL(TT.ProfitCode,T2.OcrCode) AS STR, 
T0.DOCDATE AS 'Posting Date',
T0.TAXDATE AS 'Document Date',
T1.LicTradNum AS 'Customer TIN',
T0.CARDCODE AS 'Customer Code',
T0.CARDNAME AS 'Customer Name',
T0.Comments as 'Description/Particular',
T0.DOCNUM AS 'Credit Memo #',

IIF(T0.CANCELED <>'C',T0.DocTotal,T0.DocTotal*-1) AS 'PHP Amount',
IIF(T0.CANCELED <>'C',T0.WTSUM,T0.WTSUM*-1) AS 'PHP WTax Amount',
IIF(T0.CANCELED <>'C',T0.VATSUM,T0.VATSUM*-1) AS 'PHP VAT Amount',
IIF(T0.CANCELED <>'C',T0.DiscSum,T0.DiscSum*-1) AS 'PHP Discount',
IIF(T0.CANCELED <>'C',(T0.DocTotal+t0.WTSum)-T0.VATSUM,((T0.DocTotal+t0.WTSum)-T0.VATSUM)*-1) AS 'PHP Net Amount',

T2.BASETYPE,
T0.BPLNAME
,T0.CtlAccount
,T3.AcctName
FROM ORIN T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE 
INNER JOIN RIN1 T2 ON T0.DOCNUM = T2.DOCENTRY
INNER JOIN JDT1 TT ON  TT.BaseRef = T0.DocEntry AND TransType = 14 AND Account='RV010-0200-0000'
INNER JOIN OACT T3 ON T3.AcctCode=T0.CtlAccount
WHERE 
-- T2.BASETYPE IN  (13, -1)
-- AND 
T0.DOCTYPE = 'I'
AND 
CASE WHEN @Branch LIKE '%BRANCH%' THEN T0.BPLName ELSE ISNULL(TT.ProfitCode,T2.OcrCode) END LIKE '%'+@RESULT+'%'
-- AND ISNULL(T2.OcrCode,(SELECT PROFITCODE FROM JDT1 WHERE BaseRef=T0.DocNum AND TranType=T0.ObjType AND Account='RV010-0200-0000')) LIKE  '%'+@STR+'%'
AND T0.TaxDate between @DateFrom and @DateTo
-- AND T0.DocNum=490

ORDER BY T0.DOCNUM ASC




