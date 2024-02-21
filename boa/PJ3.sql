


DECLARE @Branch Varchar(10) = 'ALL BRANCH'
DECLARE @DateFrom Date = '2022-10-01'
DECLARE @DateTo Date = '2022-12-31'

set @branch = replace((@branch),'ALL BRANCH','')

SELECT DD.*,T5.ACCTNAME 
FROM(
SELECT 
DISTINCT
T4.Number,
T0.DocEntry,
T0.DocNum,
T0.DocCur,
T0.docdate AS 'Posting Date',
T0.taxdate AS 'Document Date',
T0.LicTradNum AS 'Vendor TIN',
T0.cardcode AS 'Vendor Code',
T0.cardname AS 'Vendor Name',
ISNULL(REPLACE(REPLACE(T3.[Address], CHAR(13), ' '), CHAR(10), ' '), '') AS 'Address',
CONCAT(T0.Comments, ' ',
CASE
WHEN T0.DocCur <> 'PHP' THEN CONCAT(T0.DOCCUR, ': ', CONVERT(MONEY, T0.DocTotalFC))
ELSE ''
END) AS 'Description/Particulars',
ISNULL(T0.NumAtCard, '-') AS 'Vendor Reference #',
T0.BPLName,
IIF(T0.CANCELED <>'C',T0.DocTotal,T0.DocTotal*-1) AS  Amount,
IIF(T0.CANCELED <>'C',T0.DiscSum,T0.DiscSum*-1) AS Discount,
IIF(T0.CANCELED <>'C',T0.WTSum,T0.WTSum*-1) AS WtaxAmount,
IIF(T0.CANCELED <>'C',T0.VatSum,T0.VatSum*-1) AS VatAmount,
IIF(T0.CANCELED <>'C', IIF(T0.DpmAmnt>0,((T0.DpmAmnt-t0.VatSum)+t0.DocTotal),((T0.DOCTOTAL+T0.WTSum)-T0.VATSUM) ),
                    (IIF(T0.DpmAmnt>0,((T0.DpmAmnt-t0.VatSum)+t0.DocTotal),((T0.DOCTOTAL+T0.WTSum)-T0.VATSUM) ))*-1
) AS 'Net Puchases',
CASE
    WHEN T1.BaseType = 20 THEN CONCAT('PD ', '', (T1.BaseRef))
    WHEN T1.BaseType = 22 THEN CONCAT('PO ', '', (T1.BaseRef))
    ELSE 
        CASE 
        WHEN (SELECT TOP 1 BaseType FROM PCH1 WHERE DOCENTRY= T1.BaseRef and BaseRef IS NOT NULL)=20
            THEN CONCAT('PD ', '', (SELECT TOP 1 BaseRef FROM PCH1 WHERE DOCENTRY= T1.BaseRef and BaseType=20))        
        WHEN (SELECT TOP 1 BaseType FROM PCH1 WHERE DOCENTRY= T1.BaseRef and BaseRef IS NOT NULL)=22
            THEN CONCAT('PO ', '', (SELECT TOP 1 BaseRef FROM PCH1 WHERE DOCENTRY= T1.BaseRef and BaseType=22))

        END
    
    -- 1 = 18 THEN CONCAT('PD ', '', (SELECT TOP 1 BaseRef FROM PCH1 WHERE DOCENTRY= T1.BaseRef and BaseRef in(20,22)))
END AS Reference# ,
T0.CANCELED,
T1.WhsCode,
T0.CtlAccount
,T1.VatGroup
-- T5.ACCTNAME


FROM OPCH T0
INNER JOIN PCH1 T1 ON T1.DocEntry = T0.DocEntry
-- INNER JOIN OITM T2 ON T2.ItemCode = T1.ItemCode
INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode
INNER JOIN OJDT T4 ON T4.BASEREF=T0.DOCNUM AND T4.TRANSTYPE=T0.OBJTYPE
LEFT JOIN (
            SELECT DISTINCT A1.DocEntry FROM PCH1 A1
            INNER JOIN OITM A2 ON A2.ItemCode = A1.ItemCode
            INNER JOIN OPCH A3 ON A3.DocNum=A1.DocEntry
            WHERE A2.ItmsGrpCod IN (100,125,123,127,126,129)
            AND A3.BPLName LIKE '%' + @Branch + '%'
            AND A3.DocDate BETWEEN @DateFrom AND @DateTo

)TTT ON TTT.DocEntry=T0.DocNum

WHERE 
T0.DocType = 'I'
AND T0.BPLName LIKE '%' + @Branch + '%'
AND T0.DocDate BETWEEN @DateFrom AND @DateTo
AND TTT.DocEntry IS NULL
-- AND T2.ItmsGrpCod NOT IN (100,125,123,127,126,129)

 

UNION ALL
-- AP LANDED COST

SELECT 
DISTINCT
T4.Number,
T0.DocEntry,
T0.DocNum,
T0.DocCur,
T0.docdate AS 'Posting Date',
T0.taxdate AS 'Document Date',
T0.LicTradNum AS 'Vendor TIN',
T0.cardcode AS 'Vendor Code',
T0.cardname AS 'Vendor Name',
ISNULL(REPLACE(REPLACE(T3.[Address], CHAR(13), ' '), CHAR(10), ' '), '') AS 'Address',
CONCAT(T0.Comments, ' ',
CASE
WHEN T0.DocCur <> 'PHP' THEN CONCAT(T0.DOCCUR, ': ', CONVERT(MONEY, T0.DocTotalFC))
ELSE ''
END) AS 'Description/Particulars',
ISNULL(T0.NumAtCard, '-') AS 'Vendor Reference #',
T0.BPLName,
IIF(T0.CANCELED <>'C',T0.DocTotal,T0.DocTotal*-1) AS  Amount,
IIF(T0.CANCELED <>'C',T0.DiscSum,T0.DiscSum*-1) AS Discount,
IIF(T0.CANCELED <>'C',T0.WTSum,T0.WTSum*-1) AS WtaxAmount,
IIF(T0.CANCELED <>'C',T0.VatSum,T0.VatSum*-1) AS VatAmount,
IIF(T0.CANCELED <>'C', IIF(T0.DpmAmnt>0,((T0.DpmAmnt-t0.VatSum)+t0.DocTotal),((T0.DOCTOTAL+T0.WTSum)-T0.VATSUM) ),
                    (IIF(T0.DpmAmnt>0,((T0.DpmAmnt-t0.VatSum)+t0.DocTotal),((T0.DOCTOTAL+T0.WTSum)-T0.VATSUM) ))*-1
) AS 'Net Puchases',
CASE
    WHEN TT.ST=22 THEN CONCAT('PO ', '', (TT.SB))
    WHEN TT.ST=69 THEN CONCAT('IF ', '', (TT.SB))
END AS Reference#,
T0.CANCELED,
replace(t1.OcrCode,'_','') as WhsCode,
T0.CtlAccount
,T1.VatGroup


FROM OPCH T0
INNER JOIN PCH1 T1 ON T1.DocEntry = T0.DocEntry
INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode
INNER JOIN OJDT T4 ON T4.BASEREF=T0.DOCNUM AND T4.TRANSTYPE=T0.OBJTYPE
-- 
INNER JOIN (
            SELECT DISTINCT 
                IIF(ISNULL(T1.BaseType,TT.BaseType)=18,TTT.BASEREF,ISNULL(T1.BaseRef,TT.BaseRef)) AS SB,
                IIF(ISNULL(T1.BaseType,TT.BaseType)=18,TTT.BaseType,IIF(T1.BaseType=-1,TT.BaseType,T1.BASETYPE)) AS ST
                ,DocNum,
                T2.ObjType 
                ,ISNULL(T1.BaseRef,TT.BaseRef) as aaa
                ,IIF(T1.BaseType=-1,TT.BaseType,T1.BASETYPE) as ddd
            FROM PCH1 T1
            INNER JOIN OPCH T2 ON T1.DocEntry=T2.DocNum
            LEFT JOIN (
                SELECT DISTINCT DocEntry, BaseRef,BaseType FROM PCH1 WHERE BaseRef IS NOT NULL
            )TT ON T1.DocEntry=TT.DocEntry
            LEFT JOIN (        
                SELECT DISTINCT TrgetEntry,BaseRef,BaseType  FROM PCH1 WHERE TargetType=18 AND BaseRef IS NOT NULL
            )TTT ON T1.DocEntry=TTT.TrgetEntry
            WHERE T2.DocType='S'
            AND AcctCode IN ('CL020-2700-0000','CS010-0500-0000')
            AND IIF(ISNULL(T1.BaseRef,TT.BaseRef)=18,TTT.BASEREF,ISNULL(T1.BaseRef,TT.BaseRef)) IS NOT NULL
            
            

)TT ON TT.DOCNUM=T0.DOCNUM AND T0.ObjType=TT.ObjType
WHERE 
T0.BPLName LIKE '%' + @Branch + '%'
AND T0.DocDate BETWEEN @DateFrom AND @DateTo
AND t1.baseref not in  (SELECT DocEntry FROM  PCH1 B WHERE BaseType=-1 and TargetType=18 and TrgetEntry =t0.DocNum)

)DD
INNER JOIN OACT T5 ON T5.AcctCode=DD.ctlaccount
-- where Number=62581
ORDER BY DocNum




-- select top 100 * from PCH1 where BaseEntry IS NULL and AcctCode in ('CL020-2700-0000')