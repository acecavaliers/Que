

DECLARE @DATEFROM AS DATE ='01-01-2021', @DATETO  AS DATE ='12-31-2021',
@DEPARTMENT VARCHAR(100)='', @CATEGORY VARCHAR(100)='', @ITEMNAME VARCHAR(200)='', @STORE VARCHAR(10)=''


SELECT D.*,
CASE WHEN D.[DE-AP]<>0 
THEN convert(varchar(20),OJDT.Number)
WHEN TYPE='AR RESERVE' AND (SELECT COUNT(BASEENTRY) FROM DLN1 WHERE BaseEntry=D.Transaction# AND DLN1.ItemCode=D.[Item Code])=0
THEN CONCAT('AR - ',D.Transaction# )
ELSE convert(varchar(20),D.Number)
END AS 'JE-COST',

CASE WHEN D.TYPE='AR Credit Memo' 
	THEN (D.COST*D.[Quantity Sold])*-1 
	ELSE D.COST*D.[Quantity Sold] 
END  AS 'Total Cost',

CASE WHEN D.SWW='FREEBIES' AND D.[Total Sales]=0 
	THEN 0 
	ELSE 
		CASE WHEN D.TYPE='AR Credit Memo' 
		THEN D.[Total Sales]-((D.COST*D.[Quantity Sold])*-1)
		ELSE D.[Total Sales]-(D.COST*D.[Quantity Sold]) 
		END
END AS 'Gross Profit',

CASE WHEN D.SWW='FREEBIES' AND D.[Total Sales]=0 
	THEN 0 
	ELSE 
		CASE WHEN D.TYPE='AR Credit Memo' 
		THEN (((D.[Total Sales]-((D.COST*D.[Quantity Sold])*-1))/NULLIF(D.[Total Sales], 0))*100)*-1 
		ELSE ((D.[Total Sales]-(D.COST*D.[Quantity Sold]))/NULLIF(D.[Total Sales], 0))*100 
		END 
END AS 'Profit Margin' 


FROM(


SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,'' AS 'DE-AP','' AS 'TRANSTYPE',
T3.BPLID AS 'BRANCH ID',
'AR Credit Memo' AS 'TYPE',
T1.U_Category AS 'Category',
T0.DocEntry AS 'Transaction#',T6.Number,
T3.DocDate AS 'Posting Date',
T3.U_DocSeries AS 'Invoice No.',
'' AS 'Reference',
'' AS 'ReferenceDate',
T3.CardName AS 'Customer',
T4.CardFName AS 'Foreign Name',
T3.Comments AS 'Comments',
T0.ocrcode AS 'Whse',
T0.ItemCode AS 'Item Code',
T0.unitMsr AS 'unit',
T0.Dscription AS 'Description',
T0.Quantity * -1 AS 'Quantity Sold',
T0.U_GPBD AS 'Price Before Discount',
T0.PriceAfVAT * -1 AS 'Price After Discount',
T0.INMPrice * -1 AS 'Price After Discount(VAT-Ex)',
CASE 
WHEN   T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
THEN ISNULL(T5.INMPrice,ISNULL(T7.INMPrice,T8.INMPrice))
WHEN (SELECT isIns FROM OINV WHERE DOCNUM=T0.BaseEntry AND CANCELED='N')='Y'
	THEN 
	CASE WHEN T0.ITEMCODE IN ((SELECT ITEMCODE FROM DLN1 A0 INNER JOIN ODLN A1 ON A0.DOCENTRY=A1.DOCNUM WHERE A0.BaseEntry=T0.BaseEntry AND CANCELED='N'))
			THEN (SELECT TOP 1 StockValue/Quantity AS 'PRICE' FROM DLN1 WHERE BaseEntry=T0.BaseEntry AND ItemCode=T0.ItemCode)
			ELSE (SELECT AvgPrice FROM OITW WHERE ItemCode= T0.ItemCode AND WhsCode=T0.WhsCode)
			END
WHEN T0.BASETYPE=203
THEN (SELECT DISTINCT A1.StockValue/A1.Quantity FROM DPI1 A0 INNER JOIN INV1 A1 ON A0.BaseEntry=A1.BaseEntry WHERE A0.DocEntry=T0.BaseEntry AND A1.ItemCode=T0.ItemCode)
WHEN T0.BaseType=13
THEN (SELECT TOP 1 StockValue/Quantity FROM INV1 WHERE DocEntry=T0.BaseEntry AND ItemCode=T0.ItemCode AND ObjType=T0.BaseType)
				
			
END *-1 AS 'Cost',
(T0.INMPrice * T0.Quantity) * -1 AS 'Total Sales'


from RIN1 T0

INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode 
INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
INNER JOIN ORIN T3 ON T0.DocEntry = T3.DocNum
INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
LEFT JOIN (SELECT DISTINCT A0.DocEntry,A5.INMPrice,A5.ItemCode,A5.WhsCode
		FROM RIN1 A0
		INNER JOIN INV1 A1 ON A0.BaseEntry=A1.DocEntry
		INNER JOIN PRQ1 A2 ON A1.BaseEntry=A2.BaseEntry
		INNER JOIN PQT1 A3 ON A2.DocEntry=A3.BaseEntry
		INNER JOIN POR1 A4 ON A3.DocEntry=A4.BaseEntry
		INNER JOIN PCH1 A5 ON A4.DocEntry=A5.BaseEntry
		INNER JOIN OPCH A6 ON A5.DocEntry=A6.DocNum		
		WHERE A0.BaseType=13 AND A5.BaseType=22
		AND A6.CANCELED='N'
		UNION ALL
		SELECT DISTINCT A0.DocEntry,A5.INMPrice,A5.ItemCode,A5.WhsCode
		FROM RIN1 A0
		INNER JOIN DPI1 A1 ON A0.BaseEntry=A1.DocEntry
		INNER JOIN PRQ1 A2 ON A1.BaseEntry=A2.BaseEntry
		INNER JOIN PQT1 A3 ON A2.DocEntry=A3.BaseEntry
		INNER JOIN POR1 A4 ON A3.DocEntry=A4.BaseEntry
		INNER JOIN PCH1 A5 ON A4.DocEntry=A5.BaseEntry
		INNER JOIN OPCH A6 ON A5.DocEntry=A6.DocNum
		WHERE A0.BaseType=203 AND A5.BaseType=22
		AND A6.CANCELED='N'
		) AS T5
		ON T5.DocEntry =T0.DocEntry		
		AND T5.ItemCode=T0.ItemCode AND T5.WhsCode=T0.WhsCode
INNER JOIN OJDT T6 ON T0.DocEntry=T6.BaseRef AND T6.TransType =14
LEFT JOIN (SELECT DISTINCT A3.INMPrice ,A0.DOCENTRY,A3.ItemCode
		FROM INV1 A0
		INNER JOIN  PRQ1 A1 ON A0.BaseEntry=A1.BaseEntry
		INNER JOIN PQT1 A2 ON A1.DocEntry=A2.BaseEntry
		INNER JOIN POR1 A3 ON A2.DocEntry=A3.BaseEntry
		WHERE A3.BaseType=540000006 AND A3.DocEntry NOT IN (SELECT T.BaseEntry FROM PCH1 T INNER JOIN OPCH TT ON T.DocEntry=TT.DocNum WHERE T.BASETYPE=22 AND CANCELED='N')
		)AS T7 
		ON T7.DOCENTRY=T0.BaseEntry AND T7.ItemCode=T0.ItemCode
LEFT JOIN (SELECT A3.INMPrice,A0.DocEntry,A3.ItemCode FROM INV1 A0
		INNER JOIN RDR21 A1 ON A0.BaseEntry=A1.DocEntry
		INNER JOIN POR1 A2 ON A1.RefDocNum=A2.DOCENTRY
		INNER JOIN PCH1 A3 ON A2.DocEntry=A3.BaseEntry
		WHERE A3.ItemCode IS NOT NULL
		UNION ALL 
		SELECT A2.INMPrice,A0.DocEntry,A2.ItemCode FROM INV1 A0
		INNER JOIN RDR21 A1 ON A0.BaseEntry=A1.DocEntry
		INNER JOIN POR1 A2 ON A1.RefDocNum=A2.DOCENTRY
		WHERE A2.ITEMCODE IS NOT NULL AND A2.DocEntry NOT IN (SELECT T.BaseEntry FROM PCH1 T INNER JOIN OPCH TT ON T.DocEntry=TT.DocNum WHERE T.BASETYPE=22 AND CANCELED='N')
		)AS T8
		ON T8.DocEntry=T0.BASEENTRY AND T8.ItemCode=T0.ItemCode

WHERE T3.DocType = 'I' 
AND T1.ItemType <> 'F'
AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
AND T3.CANCELED='N'
AND T0.BaseType<>203
) D
LEFT JOIN OJDT ON OJDT.BaseRef=D.[DE-AP] AND OJDT.TransType = D.TRANSTYPE
WHERE D.[Quantity Sold]<>0
AND D.[BRANCH ID] NOT IN (SELECT BPLId FROM OBPL WHERE U_isDC='Y')
AND D.Department LIKE '%'+@DEPARTMENT+'%' 
AND D.Category LIKE '%'+@CATEGORY+'%'
AND D.Description LIKE '%'+@ITEMNAME+'%'
AND D.Whse LIKE '%'+@STORE+'%'
AND D.CANCELED='N'
ORDER BY 'Transaction#' ASC

