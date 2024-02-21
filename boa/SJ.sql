

DECLARE @dt as varchar(1)='d'
DECLARE @Branch Varchar(50) = 'ALL BRANCH'
DECLARE @RESULT VARCHAR(20) = ''
DECLARE @df date = '2023-01-01'
DECLARE @dto date = '2023-12-31'



set @RESULT = @branch
set @RESULT = replace((@Branch),'ALL BRANCH','')







SELECT DISTINCT
T2.TransId,
t0.docnum,
t0.docdate as 'Posting Date',
t0.taxdate as 'Document Date',
t0.LicTradNum as 'Vendor TIN',
t0.cardcode as 'Vendor Code',
t0.cardname as 'Vendor Name',
ISNULL(REPLACE(REPLACE(t0.[Address],char(13),' '),char(10),' '),(select DISTINCT Replace(concat(city,Country),'PH',' PHILIPPINES') From OWHS where owhs.WhsCode = t1.WhsCode)) as 'Address',
t0.Comments as 'Description/Particulars',
t0.docnum as 'Reference #',
t0.NumAtCard as 'Vendor Reference #',
t0.U_SCPWD as Discount,

T0.BPLName
,ISNULL(T2.ProfitCode,T1.OcrCode) AS STR
,IIF(T0.CANCELED <>'C',T0.WTSum,T0.WTSum*-1) AS WtaxAmount
,IIF(T0.CANCELED <>'C',T0.VatSum,T0.VatSum*-1) AS VatAmount
,IIF(T0.CANCELED <>'C',T0.DocTotal,T0.DocTotal*-1) AS Amount
,IIF(T0.CANCELED <>'C',
                IIF(T0.DpmAmnt>0,((T0.DpmAmnt-t0.VatSum)+t0.DocTotal),((T0.DOCTOTAL+T0.WTSum)-T0.VATSUM) ),
                (IIF(T0.DpmAmnt>0,((T0.DpmAmnt-t0.VatSum)+t0.DocTotal),((T0.DOCTOTAL+T0.WTSum)-T0.VATSUM) ))*-1
    ) AS 'Net Puchases'
,IIF(T0.CANCELED <>'C',T0.DiscSum,T0.DiscSum*-1) AS Discount
,T0.CtlAccount
,T3.AcctName
FROM OINV T0
INNER JOIN INV1 T1 ON T0.DOCNUM = T1.DOCENTRY
INNER JOIN JDT1 T2 ON  T2.BaseRef = T0.DocEntry AND TransType = 13 AND Account='RV010-0100-0000'
INNER JOIN OACT T3 ON T3.AcctCode=T0.CtlAccount
WHERE 
-- T0.BPLName LIKE '%'+@Branch+'%'
-- AND 
CASE WHEN @Branch LIKE '%BRANCH%' THEN T2.BPLName ELSE ISNULL(T2.ProfitCode,T1.OcrCode) END LIKE '%'+@RESULT+'%'
AND
CASE WHEN @dt = 'D' THEN T0.TaxDate ELSE T0.DocDate END BETWEEN @df AND @dto
-- AND T2.TransId=16757
-- AND T0.DocNum=33583
-- AND ISNULL(T2.ProfitCode,T1.OcrCode)
ORDER BY T0.docnum



