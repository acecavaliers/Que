-- DECLARE @dfrom DATE ={?DateFrom},@dto date={?DateTo}
 DECLARE @dfrom DATE ='2021-01-01',@dto date='2023-12-20'


SELECT *,WTSum + ISNULL((SELECT ISNULL(sum(Credit),0) - ISNULL(sum(Debit),0) from JDT1 WHERE U_DocNum=TT.DocNum and U_BaseDocType=TT.ObjType and ShortName=TT.CardCode),0) AS WTSAM
FROM 
(
SELECT DISTINCT

T0.DocNum,T4.DOCENTRY,

'A/R Invoice' AS 'A/R Credit Memo',

IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
T5.CardCode,
T0.BPLName, 
T3.ObjType,
T0.DocDate, 
CASE WHEN T5.U_Collector=''
THEN T0.DocTotal
ELSE t4.SumApplied - t4.U_WTaxPay
END as 'DocTotal' ,
-- IIF(t4.U_WTaxPay >0,t4.SumApplied - t4.U_WTaxPay ,T0.DocTotal) as 'DocTotal' ,


CASE WHEN T5.U_Collector=''
THEN 
T0.WTSum
ELSE  
END as 'WTSum',
-- IIF(t4.U_WTaxPay >0,t4.U_WTaxPay,T0.WTSum) as 'WTSum',

IIF(T0.U_WTax <> 'Received',T5.U_WTax,T0.U_WTax) AS 'U_WTax',

REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 

(SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',

ISNULL(T0.U_wTaxComCode,T4.U_wTaxComCode) as 'U_wTaxComCode',

ISNULL(T0.U_WTAXRECBY,T5.U_WTAXRECBY) AS 'Received By',

ISNULL(t0.U_WTaxRecDate,T5.U_WTaxRecDate) AS 'Received Date'

FROM OINV T0 
INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
INNER JOIN INV5 T2 ON T0.DocNum = T2.AbsEntry 
INNER JOIN INV1 T3 ON T3.DocEntry = T0.DocEntry
INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
WHERE T0.CANCELED = 'N' 
AND cast(T0.DocDate as date) between @dfrom and @dto
AND T5.Canceled='N'

UNION ALL 

SELECT DISTINCT

T0.DocNum,null,

'A/R CM' AS 'A/R Credit Memo',

IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
T5.CardCode,
T0.BPLName, 
T3.ObjType,
T0.DocDate, 

T0.DocTotal * -1, 

T0.WTSum * -1, 

T0.U_WTax, 

REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 

(SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',

null as 'U_wTaxComCode',

T0.U_WTAXRECBY AS 'Received By',

t0.U_WTaxRecDate AS 'Received Date'

FROM ORIN T0 
INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
INNER JOIN RIN5 T2 ON T0.DocNum = T2.AbsEntry 
INNER JOIN RIN1 T3 ON T3.DocEntry = T0.DocEntry
INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
WHERE T0.CANCELED = 'N' 
AND cast(T0.DocDate as date) between @dfrom and @dto
AND T5.Canceled='N'

UNION ALL 

--ARDPI
SELECT DISTINCT

T0.DocNum,T4.DOCENTRY,

'A/R DPI' AS 'A/R Credit Memo',

IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
T5.CardCode,
T0.BPLName, 
T3.ObjType,
T0.DocDate,

CASE WHEN T5.U_Collector=''
THEN T0.DocTotal
ELSE t4.SumApplied - t4.U_WTaxPay
END as 'DocTotal' ,
-- IIF(t4.U_WTaxPay >0,t4.SumApplied - t4.U_WTaxPay ,T0.DocTotal) as 'DocTotal' ,
CASE WHEN T5.U_Collector=''
THEN T0.WTSum 
ELSE t4.U_WTaxPay 
END as 'WTSum',
-- IIF(t4.U_WTaxPay >0,t4.U_WTaxPay,T0.WTSum) as 'WTSum',

IIF(T0.U_WTax <> 'Received',T5.U_WTax,T0.U_WTax) AS 'U_WTax',

REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',

(SELECT DISTINCT WhsCode FROM DPI1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',

ISNULL(T0.U_wTaxComCode,T4.U_wTaxComCode) as 'U_wTaxComCode',

ISNULL(T0.U_WTAXRECBY,T5.U_WTAXRECBY) AS 'Received By',

ISNULL(t0.U_WTaxRecDate,T5.U_WTAXRECBY) AS 'Received Date'

FROM ODPI T0 
INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
INNER JOIN DPI5 T2 ON T0.DocNum = T2.AbsEntry 
INNER JOIN DPI1 T3 ON T3.DocEntry = T0.DocEntry
INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
WHERE T0.CANCELED = 'N' 
AND cast(T0.DocDate as date) between @dfrom and @dto
AND T5.Canceled='N'

UNION ALL
--JE
SELECT DISTINCT
T0.Number,
T4.DOCENTRY,
'JE' AS 'A/R Credit Memo',
T5.CardName AS 'CardName',
T5.CardCode,
T5.BPLName, 
T3.ObjType,
T0.TaxDate,
t4.SumApplied - t4.U_WTaxPay as 'DocTotal',
t4.U_WTaxPay as 'WTSum',
T5.U_WTax AS 'U_WTax',
REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',

T0.Ref3 AS 'Warehouse',

T4.U_wTaxComCode as 'U_wTaxComCode',

T5.U_WTAXRECBY AS 'Received By',

T5.U_WTaxRecDate AS 'Received Date'

FROM OJDT T0 
INNER JOIN JDT2 T2 ON T0.Number = T2.AbsEntry 
INNER JOIN JDT1 T3 ON T3.TransId = T0.Number
INNER JOIN OBPL T1 ON T3.BPLId = T1.[BPLId] 
INNER JOIN RCT2 T4 ON T4.DocEntry=T3.TransId AND T4.InvType=T0.ObjType
INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
WHERE T0.Memo NOT LIKE  'N' 
AND cast(T0.TaxDate as date) between @dfrom and @dto
AND T5.Canceled='N'

UNION ALL
--JE Adjustments AR/
SELECT DISTINCT
T0.Number AS DocNum,
T4.DocNum AS incoming#,
'JE- AR' AS 'A/R Credit Memo',
T5.CardName AS 'CardName',
NULL AS CardCode,
T5.BPLName, 
NULL AS ObjType,
T0.TaxDate,
T6.DocTotal 'DocTotal',
t4.U_WTaxPay  as 'WTSum',
T5.U_WTax AS 'U_WTax',
REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',

LEFT(T6.U_DocSeries,6)AS 'Warehouse',

T4.U_wTaxComCode as 'U_wTaxComCode',

T5.U_WTAXRECBY AS 'Received By',

T5.U_WTaxRecDate AS 'Received Date'

FROM OJDT T0 
INNER JOIN JDT1 T3 ON T3.TransId = T0.Number
INNER JOIN OBPL T1 ON T3.BPLId = T1.[BPLId] 
INNER JOIN RCT2 T4 ON T4.DocEntry=T3.TransId AND T4.InvType=T0.ObjType
INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
INNER JOIN OINV T6 ON T6.DocEntry=T3.U_DocNum AND T3.U_BaseDocType=13
WHERE T0.Memo NOT LIKE  'N' 
AND cast(T0.TaxDate as date) between @dfrom and @dto
AND T5.Canceled='N'
AND U_DocNum IS NOT NULL
AND U_BaseDocType IS NOT NULL
AND T6.DocNum NOT IN (SELECT AbsEntry FROM INV5 WHERE AbsEntry=T6.DocNum)

UNION ALL
--JE Adjustments ARDPI
SELECT DISTINCT
T0.Number AS DocNum,
T4.DocNum AS incoming#,
'JE- ARDPI' AS 'A/R Credit Memo',
T5.CardName AS 'CardName',
NULL AS CardCode,
T5.BPLName, 
NULL AS ObjType,
T0.TaxDate,
T6.DocTotal 'DocTotal',
t4.U_WTaxPay  as 'WTSum',
T5.U_WTax AS 'U_WTax',
REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',

LEFT(T6.U_DocSeries,6)AS 'Warehouse',

T4.U_wTaxComCode as 'U_wTaxComCode',

T5.U_WTAXRECBY AS 'Received By',

T5.U_WTaxRecDate AS 'Received Date'

FROM OJDT T0 
INNER JOIN JDT1 T3 ON T3.TransId = T0.Number
INNER JOIN OBPL T1 ON T3.BPLId = T1.[BPLId] 
INNER JOIN RCT2 T4 ON T4.DocEntry=T3.TransId AND T4.InvType=T0.ObjType
INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
INNER JOIN ODPI T6 ON T6.DocEntry=T3.U_DocNum AND T3.U_BaseDocType=203
WHERE T0.Memo NOT LIKE  'N' 
AND cast(T0.TaxDate as date) between @dfrom and @dto
AND T5.Canceled='N'
AND U_DocNum IS NOT NULL
AND U_BaseDocType IS NOT NULL
AND T6.DocNum NOT IN (SELECT AbsEntry FROM DPI5 WHERE AbsEntry=T6.DocNum)

UNION ALL
--JE Adjustments JE
SELECT DISTINCT
T0.Number AS DocNum,
T4.DocNum AS incoming#,
'JE- JE' AS 'A/R Credit Memo',
T5.CardName AS 'CardName',
NULL AS CardCode,
T5.BPLName, 
NULL AS ObjType,
T0.TaxDate,
t4.SumApplied - t4.U_WTaxPay 'DocTotal',
t4.U_WTaxPay  as 'WTSum',
T5.U_WTax AS 'U_WTax',
REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',

T0.Ref3 AS 'Warehouse',

T4.U_wTaxComCode as 'U_wTaxComCode',

T5.U_WTAXRECBY AS 'Received By',

T5.U_WTaxRecDate AS 'Received Date'

FROM OJDT T0 
INNER JOIN JDT1 T3 ON T3.TransId = T0.Number
INNER JOIN OBPL T1 ON T3.BPLId = T1.[BPLId] 
INNER JOIN RCT2 T4 ON T4.DocEntry=T3.TransId AND T4.InvType=T0.ObjType
INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
INNER JOIN OJDT T6 ON T6.Number=T3.U_DocNum AND T3.U_BaseDocType=30
WHERE T0.Memo NOT LIKE  'N' 
AND cast(T0.TaxDate as date) between @dfrom and @dto
AND T5.Canceled='N'
AND U_DocNum IS NOT NULL
AND U_BaseDocType IS NOT NULL
AND T6.NUMBER NOT IN (SELECT AbsEntry FROM DPI5 WHERE AbsEntry=T6.NUMBER)

) TT
 where WTSum >0
