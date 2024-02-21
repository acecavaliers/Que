


SELECT ItemCode,(SELECT TOP 1 ItemName FROM OITM WHERE ItemCode=X.ITEMCODE) AS 'DESCRIPTION',SUM([TOTAL QTY])as 'TOTAL QTY',SUM([ITEM COUNT]) AS 'ITEM COUNT',SUM([TOTAL QTY])/SUM([ITEM COUNT]) AS 'AVG SOLD',(SELECT FACTOR FROM ITM1 WHERE PriceList=12 AND ItemCode=X.ItemCode) AS 'FACTOR' FROM(

SELECT T1.DOCENTRY,T1.ItemCode,t1.unitMsr2 as 'Smallest Unit',SUM(T1.Quantity)*NumPerMsr as 'TOTAL QTY',
COUNT(DISTINCT T1.ItemCode) AS 'ITEM COUNT',NumPerMsr,
(SUM(T1.Quantity)*NumPerMsr )/(COUNT(T1.ItemCode)) AS 'AVG SOLD'
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum

WHERE  
 CANCELED='N' AND T2.TaxDate LIKE '%2021%' --AND ItemCode='0002051sbdfb' or ItemCode='0005544sbdfb'
 --AND T2.U_BO_DRS='Y'
 and t1.DocEntry not in (select t.BaseEntry from rin1 t inner join orin tt on t.DocEntry=tt.DocNum where CANCELED='n' and t.itemcode=t1.itemcode and t.basetype =13 and t.Quantity = t1.Quantity ) 

AND T2.BPLId=3
GROUP BY T1.ItemCode,t1.unitMsr2,NumPerMsr,T1.DOCENTRY


UNION ALL
SELECT T1.DOCENTRY,T1.ItemCode,t1.unitMsr2 as 'Smallest Unit',
-- CASE WHEN (SELECT SUM(Quantity) FROM INV1 WHERE DocEntry=T1.BaseEntry AND T1.BaseType=13 AND ItemCode=T1.ItemCode)=SUM(T1.Quantity)
-- then 0
-- else (SUM(T1.Quantity)*NumPerMsr)*-1  end as 'TOTAL QTY',
(SUM(T1.Quantity)*NumPerMsr)*-1  as 'TOTAL QTY',
--CASE WHEN (SELECT SUM(Quantity) FROM INV1 WHERE DocEntry=T1.BaseEntry AND T1.BaseType=13 AND ItemCode=T1.ItemCode)=SUM(T1.Quantity)
--THEN COUNT(DISTINCT T1.ItemCode)*-1 ELSE 
--0 END AS 'ITEM COUNT',
0  AS 'ITEM COUNT',
NumPerMsr,
--(SUM(T1.Quantity)*NumPerMsr )/(COUNT(T1.ItemCode))*-1 AS 'AVG SOLD'
0 AS 'AVG SOLD'
FROM RIN1 T1
INNER JOIN ORIN T2 ON T1.DocEntry=T2.DocNum
INNER JOIN OINV T3 ON T1.BaseEntry=T3.DocNum 
WHERE 
 T2.CANCELED='N'AND T2.TaxDate LIKE '%2021%' --AND ItemCode='0006395HWAC4'
AND T2.BPLId=3 
AND T3.U_BO_DRS='Y'

GROUP BY T1.ItemCode,t1.unitMsr2,NumPerMsr,T1.DOCENTRY,T1.BaseEntry,T1.BaseType,Quantity
)X 
where [TOTAL QTY]>0 --AND ItemCode='0003510ELAC3'
GROUP BY ItemCode
order by [ITEM COUNT]

--SELECT ITEMNAME FROM OITM T INNER JOIN INV1 A ON T.ITEMCODE=A.ITEMCODE