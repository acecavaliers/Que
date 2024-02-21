DECLARE @dfrom DATE ='2022-01-01',@dto date='2023-06-30'



SELECT * FROM 
(
SELECT DISTINCT
T0.DocNum,T4.DOCENTRY,
'A/R Invoice' AS 'A/R Credit Memo',
T0.CardName,
T0.BPLName, 
T0.DocDate, 
-- T0.DocTotal, 
-- T0.WTSum, 
IIF(t4.U_WTaxPay >0,t4.SumApplied - t4.U_WTaxPay ,T0.DocTotal) as 'DocTotal' ,
IIF(t4.U_WTaxPay >0,t4.U_WTaxPay,T0.WTSum) as 'WTSum' ,
T0.U_WTax, 
REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
(SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',
ISNULL(T0.U_wTaxComCode,T4.U_wTaxComCode) as 'U_wTaxComCode',
T0.U_WTAXRECBY AS 'Received By',
t0.U_WTaxRecDate AS 'Received Date'

FROM OINV T0 
INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
INNER JOIN INV5 T2 ON T0.DocNum = T2.AbsEntry 
INNER JOIN INV1 T3 ON T3.DocEntry = T0.DocEntry
INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
WHERE T0.CANCELED = 'N' 
AND cast(T0.DocDate as date) between @dfrom and @dto

UNION ALL 

SELECT DISTINCT
T0.DocNum,null,
'A/R Credit Memo' AS 'A/R Credit Memo',
T0.CardName,
T0.BPLName, 
T0.DocDate, 
T0.DocTotal * -1, 
T0.WTSum * -1, 
-- 0 ,
-- 0,
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
-- INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
WHERE T0.CANCELED = 'N' 
AND cast(T0.DocDate as date) between @dfrom and @dto

) STATUSREPORT




