 SELECT  ItemCode,(SELECT TOP 1 ItemName FROM OITM WHERE ItemCode=X.ITEMCODE) AS 'DESCRIPTION',[SMALLEST UNIT],

 sum(Quantity) as 'QTY',sum(Quantity)/7 AS 'AVG SOLD',(SELECT FACTOR FROM ITM1 WHERE PriceList=12 AND ItemCode=X.ItemCode) AS 'FACTOR'
 --,MONTH(TaxDate) AS 'MONTH',YEAR(TaxDate) AS 'YEAR'
,
-- COUNT( format(TaxDate,'yyyy-MM')) as 'NO. of MONTHS',
 'MONTHS SOLD' = STUFF((
        SELECT 
	 	 ',',month(TaxDate)
	 	 FROM OINM T1
WHERE T1.ItemCode =x.ItemCode
-- AND format(TaxDate,'yyyy-MM')=XXX.MMS
AND Cast(Docdate as Date) between '2022-01-01' AND '2022-12-31'
AND (TransType=13 OR TransType=15)
GROUp by year(TaxDate), month(TaxDate) --format(TaxDate,'yyyy-MM')
           FOR XML PATH('')
        ), 1, 1, '')
FROM(
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=01
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=02
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=03
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=04
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=05
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=06
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=07
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=08
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=09
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=10
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=11
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'
UNION ALL
SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
FROM INV1 T1
INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
AND T2.TaxDate LIKE '%2022%'
AND MONTH(TAXDATE)=12
and WhsCode like '%GSCNAP%'
and WhsCode not like '%DS%'

-- UNION ALL

-- SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
-- ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
-- FROM INV1 T1
-- INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
-- WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
-- AND T2.TaxDate LIKE '%2022%'
-- AND MONTH(TAXDATE)=01
-- and WhsCode like '%GSCNAP%'
-- and WhsCode not like '%DS%'
-- UNION ALL
-- SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
-- ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
-- FROM INV1 T1
-- INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
-- WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
-- AND T2.TaxDate LIKE '%2022%'
-- AND MONTH(TAXDATE)=02
-- and WhsCode like '%GSCNAP%'
-- and WhsCode not like '%DS%'
-- UNION ALL
-- SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
-- ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
-- FROM INV1 T1
-- INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
-- WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
-- AND T2.TaxDate LIKE '%2022%'
-- AND MONTH(TAXDATE)=03
-- and WhsCode like '%GSCNAP%'
-- and WhsCode not like '%DS%'
-- UNION ALL
-- SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
-- ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
-- FROM INV1 T1
-- INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
-- WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
-- AND T2.TaxDate LIKE '%2022%'
-- AND MONTH(TAXDATE)=04
-- and WhsCode like '%GSCNAP%'
-- and WhsCode not like '%DS%'
-- UNION ALL
-- SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
-- ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
-- FROM INV1 T1
-- INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
-- WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
-- AND T2.TaxDate LIKE '%2022%'
-- AND MONTH(TAXDATE)=05
-- and WhsCode like '%GSCNAP%'
-- and WhsCode not like '%DS%'
-- UNION ALL
-- SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
-- ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
-- FROM INV1 T1
-- INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
-- WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
-- AND T2.TaxDate LIKE '%2022%'
-- AND MONTH(TAXDATE)=06
-- and WhsCode like '%GSCNAP%'
-- and WhsCode not like '%DS%'
-- UNION ALL
-- SELECT T2.DOCNUM, ItemCode,unitMsr2 AS 'SMALLEST UNIT',Quantity*NumPerMsr AS 'Quantity',TAXDATE,
-- ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY Quantity DESC) rank,WhsCode
-- FROM INV1 T1
-- INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum
-- WHERE ItemCode IS NOT NULL AND T2.CANCELED ='N'
-- AND T2.TaxDate LIKE '%2022%'
-- AND MONTH(TAXDATE)=07
-- and WhsCode like '%GSCNAP%'
-- and WhsCode not like '%DS%'

) X
WHERE X.rank = 1 
AND ITEMCODE NOT LIKE '%SVSVS%'
AND (SELECT 'MONTHS SOLD' = STUFF((SELECT ',',month(TaxDate) FROM OINM T1 
                                        WHERE T1.ItemCode =x.ItemCode AND Cast(Docdate as Date) between '2022-01-01' AND '2022-12-31'
                                        AND (TransType=13 OR TransType=15)
                                        GROUp by year(TaxDate), month(TaxDate)FOR XML PATH('')), 1, 1, '')) in ('7,8,9,10,11,12','8,9,10,11,12')--,'9,10,11,12','7,8,9,10,11','7,8,9,10','10,11,12','8,9,10,11,12','8,9,10,11','8,9,10')
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=1 AND T2.TaxDate LIKE '%2022%' AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=2 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=3 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=4 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=5 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=6 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=7 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)

-- -- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=1 AND T2.TaxDate LIKE '%2022%' AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=2 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=3 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=4 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=5 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=6 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=7 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)

-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=8 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=9 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=10 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=11 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)
-- AND ItemCode IN (SELECT ItemCode FROM INV1 T1 INNER JOIN OINV T2 ON T1.DocEntry=T2.DocNum AND T2.CANCELED='N'WHERE  MONTH(TaxDate)=12 AND T2.TaxDate LIKE '%2022%'AND ItemCode=X.ItemCode)

GROUP by ItemCode ,[SMALLEST UNIT]--,--MONTH(TaxDate),YEAR(TaxDate)


ORDER BY COUNT( format(TaxDate,'yyyy-MM')) DESC,ItemCode--,[YEAR],[MONTH]


-- select * from inv1 where ItemCode='0006006ELSP3' and Quantity=1368