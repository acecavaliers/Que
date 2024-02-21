

DECLARE @DATEFROM DATE ='01-01-2021', @DATETO DATE ='12-31-2021',
@DEPARTMENT VARCHAR(100)='', @CATEGORY VARCHAR(100)='', @ITEMNAME VARCHAR(200)='', @STORE VARCHAR(10)=''

SELECT *,
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

SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,
T3.BPLID AS 'BRANCH ID',
CASE WHEN T3.isIns ='Y' THEN 'AR RESERVE' ELSE 'AR INVOICE' END AS 'TYPE',
T1.U_Category AS 'Category',
T0.DocEntry AS 'Transaction#',T6.Number,
T0.DocDate AS 'Posting Date',
t3.U_DocSeries AS 'Invoice No.',
CASE WHEN  T3.U_BO_DRS ='Y' --OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
THEN ISNULL((SELECT DISTINCT CONCAT('AP ',A3.DOCENTRY) FROM PRQ1 A0 
	INNER JOIN PQT1 A1 ON A0.DocEntry=A1.BaseEntry
	INNER JOIN POR1 A2 ON A1.DocEntry=A2.BaseEntry
	INNER JOIN PCH1 A3 ON A2.DocEntry=A3.BaseEntry
	WHERE A0.BaseEntry=T0.BaseEntry
	AND A3.BaseType=22 AND A3.ItemCode=T0.ItemCode AND A3.WhsCode=T0.WhsCode),
	'')
ELSE ''
END AS 'Reference',
CASE WHEN  T3.U_BO_DRS ='Y' --OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
THEN ISNULL(CONVERT(VARCHAR(20),(SELECT DISTINCT TAXDATE FROM PRQ1 A0 
	INNER JOIN PQT1 A1 ON A0.DocEntry=A1.BaseEntry
	INNER JOIN POR1 A2 ON A1.DocEntry=A2.BaseEntry
	INNER JOIN PCH1 A3 ON A2.DocEntry=A3.BaseEntry
	INNER JOIN OPCH A4 ON A4.DOCNUM=A3.DocEntry
	WHERE A0.BaseEntry=T0.BaseEntry
	AND A3.BaseType=22 AND A3.ItemCode=T0.ItemCode AND A3.WhsCode=T0.WhsCode)
	,101),'')
ELSE ''
END AS 'ReferenceDate',
T3.CardName AS 'Customer',
T4.CardFName AS 'Foreign Name',
T3.Comments AS 'Comments',
T0.ocrcode AS 'Whse',
T0.ItemCode AS 'Item Code',
T0.unitMsr AS 'unit',
T0.Dscription AS 'Description',
CASE WHEN (SELECT COUNT(DISTINCT DocEntry) FROM DLN1 WHERE BaseEntry =T0.DocEntry AND BaseType=13)>1
THEN  T0.Quantity-ISNULL(T5.QTY,0) 
ELSE  T0.Quantity-ISNULL(T8.QTY,0) 
END AS 'Quantity Sold',
T0.U_GPBD AS 'Price Before Discount',
T0.PriceAfVAT AS 'Price After Discount',
T0.INMPrice AS 'Price After Discount(VAT-Ex)',

CASE 
WHEN T3.isIns='Y' AND ISNULL((SELECT COUNT(BASEENTRY) FROM DLN1 WHERE BaseEntry=T0.DOCENTRY),0)>0
THEN CASE WHEN T0.OpenQty >0
	THEN  (SELECT AvgPrice FROM OITW WHERE ItemCode= T0.ItemCode AND WhsCode=T0.WhsCode)
	ELSE T0.StockValue/T0.Quantity END
WHEN T3.isIns='Y' AND ISNULL((SELECT COUNT(BASEENTRY) FROM DLN1 WHERE BaseEntry=T0.DOCENTRY),0)=0
THEN (SELECT AvgPrice FROM OITW WHERE ItemCode= T0.ItemCode AND WhsCode=T0.WhsCode)

--ELSE 
--	CASE WHEN T0.GrossBuyPr=0 
--		THEN (SELECT DISTINCT AvgPrice FROM OITW WHERE ItemCode= T0.ItemCode AND WhsCode=T0.WhsCode) 
--		ELSE T0.StockValue/T0.Quantity
--	END
WHEN T3.isIns='N'
THEN  
	 T0.StockValue/T0.Quantity
END AS 'COST',

T0.INMPrice * (T0.Quantity-ISNULL(T5.QTY,0)) AS 'Total Sales'


FROM INV1 T0

INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
LEFT JOIN (SELECT DISTINCT SUM(A0.Quantity) AS 'QTY', A0.BaseEntry , A0.ItemCode,A0.WHSCODE 
		FROM DLN1 A0
		GROUP BY  A0.BaseEntry ,A0.ItemCode,A0.WHSCODE) AS T5  
		ON T5.BaseEntry =T0.DocEntry AND T5.ItemCode=T0.ItemCode AND T5.WHSCODE=T0.WHSCODE  
INNER JOIN OJDT T6 ON T0.DocEntry=T6.BaseRef AND T6.TransType =13
LEFT JOIN (SELECT GrossBuyPr,BaseEntry,ItemCode FROM RIN1) AS T7
		ON T7.BaseEntry=T0.DocEntry AND T7.ItemCode=T0.ItemCode
LEFT JOIN (SELECT DISTINCT A0.Quantity AS 'QTY', A0.BaseEntry , A0.ItemCode,A0.WHSCODE 
		FROM DLN1 A0) AS T8
		ON T8.BaseEntry =T0.DocEntry AND T8.ItemCode=T0.ItemCode AND T8.WHSCODE=T0.WHSCODE

WHERE T3.DocType = 'I' 
AND T1.ItemType='I'
AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
AND T3.CANCELED='N'
AND T3.U_BO_DRS ='N' --AND T3.U_BO_DSDD ='N' AND T3.U_BO_DSDV ='N' AND T3.U_BO_DSPD ='N'


UNION ALL --DROPSHIP

SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,
T3.BPLID AS 'BRANCH ID',
CASE WHEN T3.isIns ='Y' THEN 'AR RES' ELSE 'AR INV' END AS 'TYPE',
T1.U_Category AS 'Category',
T0.DocEntry AS 'Transaction#',T8.Number,
T0.DocDate AS 'Posting Date',
t3.U_DocSeries AS 'Invoice No.',
CASE WHEN  T9.REFDOCNUM IS NULL AND T7.RTYPE ='AP'
THEN CONCAT('AP ',T7.DocEntry)
WHEN T7.RTYPE='PO' AND T9.RefDocNum IS NOT NULL
THEN CONCAT('AP ',T9.REFDOCNUM)
ELSE ''
END AS 'Reference',
CASE WHEN T7.RTYPE ='AP' AND T9.ISSUEDATE IS NULL
THEN CONVERT(VARCHAR(20),T7.TAXDATE,101)
WHEN T7.RTYPE='PO' AND T9.ISSUEDATE IS NOT NULL
THEN CONVERT(VARCHAR(20),T9.ISSUEDATE,101)
ELSE ''
END AS 'ReferenceDate',
T3.CardName AS 'Customer',
T4.CardFName AS 'Foreign Name',
T3.Comments AS 'Comments',
T0.ocrcode AS 'Whse',
T0.ItemCode AS 'Item Code',
T0.unitMsr AS 'unit',
T0.Dscription AS 'Description',
CASE WHEN 
(SELECT COUNT(Quantity)FROM POR1 WHERE DocEntry=T7.DocEntry AND ItemCode=T7.ItemCode AND ObjType=T7.ObjType 
AND DOCENTRY NOT IN (SELECT BASEENTRY FROM PCH1 WHERE BaseType=22 AND ITEMCODE IS NOT NULL)) +
(SELECT COUNT(Quantity)FROM PCH1 WHERE DocEntry=T7.DocEntry AND ItemCode=T7.ItemCode AND ObjType=T7.ObjType )+
(SELECT COUNT(Quantity)FROM POR1 WHERE DocEntry=T9.DocEntry AND ItemCode=T9.ItemCode AND ObjType=T9.ObjType 
AND DOCENTRY NOT IN (SELECT BASEENTRY FROM PCH1 WHERE BaseType=22 AND ITEMCODE IS NOT NULL)) +
(SELECT COUNT(Quantity)FROM PCH1 WHERE DocEntry=T9.DocEntry AND ItemCode=T9.ItemCode AND ObjType=T9.ObjType ) >1
THEN T7.Quantity - ISNULL((SELECT DISTINCT A1.QUANTITY FROM IGE21 A0
			INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY
			WHERE A0.REFOBJTYPE =13 AND REFDOCNUM=T0.DOCENTRY AND ITEMCODE=T0.ITEMCODE),0)
ELSE T0.Quantity - ISNULL((SELECT DISTINCT A1.QUANTITY FROM IGE21 A0
			INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY
			WHERE A0.REFOBJTYPE =13 AND REFDOCNUM=T0.DOCENTRY AND ITEMCODE=T0.ITEMCODE),0)

END AS 'Quantity Sold',
--T0.Quantity-ISNULL(T5.QTY,0) AS 'Quantity Sold',
T0.U_GPBD AS 'Price Before Discount',
T0.PriceAfVAT AS 'Price After Discount',
T0.INMPrice AS 'Price After Discount(VAT-Ex)',
ISNULL(T7.INMPrice,T9.INMPrice)	AS 'COST',

T0.INMPrice * CASE WHEN 
(SELECT COUNT(Quantity)FROM POR1 WHERE DocEntry=T7.DocEntry AND ItemCode=T7.ItemCode AND ObjType=T7.ObjType 
AND DOCENTRY NOT IN (SELECT BASEENTRY FROM PCH1 WHERE BaseType=22 AND ITEMCODE IS NOT NULL)) +
(SELECT COUNT(Quantity)FROM PCH1 WHERE DocEntry=T7.DocEntry AND ItemCode=T7.ItemCode AND ObjType=T7.ObjType )+
(SELECT COUNT(Quantity)FROM POR1 WHERE DocEntry=T9.DocEntry AND ItemCode=T9.ItemCode AND ObjType=T9.ObjType 
AND DOCENTRY NOT IN (SELECT BASEENTRY FROM PCH1 WHERE BaseType=22 AND ITEMCODE IS NOT NULL)) +
(SELECT COUNT(Quantity)FROM PCH1 WHERE DocEntry=T9.DocEntry AND ItemCode=T9.ItemCode AND ObjType=T9.ObjType ) >1
THEN T7.Quantity
ELSE T0.Quantity - ISNULL((SELECT A1.QUANTITY FROM IGE21 A0
			INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY
			WHERE A0.REFOBJTYPE =13 AND REFDOCNUM=T0.DOCENTRY AND ITEMCODE=T0.ITEMCODE),0)

END AS 'Total Sales'

FROM INV1 T0

INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
--LEFT JOIN (SELECT SUM(Quantity) AS 'QTY', BaseEntry , ItemCode,WHSCODE 
--		FROM DLN1 
--		GROUP BY  BaseEntry ,ItemCode,WHSCODE) AS T5  
--		ON T5.BaseEntry =T0.DocEntry AND T5.ItemCode=T0.ItemCode AND T5.WHSCODE=T0.WHSCODE  
LEFT JOIN (	SELECT DISTINCT A3.INMPrice,A3.DocEntry,A0.BaseEntry,A3.Quantity,A3.ItemCode,A3.WhsCode,A3.ObjType,A4.TAXDATE, 'AP'AS 'RTYPE' FROM POR1 A0 
			INNER JOIN PCH1 A3 ON A0.DocEntry=A3.BaseEntry
			INNER JOIN OPCH A4 ON A3.DocEntry=A4.DocNum
			WHERE A3.BaseType=22  AND A4.CANCELED='N'
			AND A3.ITEMCODE IS NOT NULL
			UNION ALL
			SELECT DISTINCT A2.INMPrice,A2.DocEntry,A2.BaseEntry,A2.Quantity,A2.ItemCode,A2.WhsCode,A2.ObjType,A3.TAXDATE,'PO'AS 'RTYPE' FROM POR1 A2
			INNER JOIN OPOR A3 ON A2.DocEntry=A3.DocNum
			WHERE A2.BaseType=540000006  AND A3.CANCELED='N'
			AND A2.ITEMCODE IS NOT NULL
			AND A2.DOCENTRY NOT IN (SELECT BASEENTRY FROM PCH1 WHERE BaseType=22 AND ITEMCODE IS NOT NULL)) 
			AS T7
			ON T7.BaseEntry=T0.BaseEntry
			AND T7.ItemCode=T0.ItemCode AND T7.WhsCode=T0.WhsCode

INNER JOIN OJDT T8 ON T0.DocEntry=T8.BaseRef AND T8.TransType =13
LEFT JOIN (SELECT DISTINCT A0.DOCENTRY,A4.RefObjType,A4.REFDOCNUM,A4.DOCENTRY AS 'REF_ENTRY',A4.ISSUEDATE,A0.INMPrice,A0.ItemCode,A0.ObjType,A0.Quantity FROM PCH1 A0
		INNER JOIN POR1 A1 ON A0.BaseEntry=A1.DocEntry
		INNER JOIN PQT1 A2 ON A1.BaseEntry=A2.DocEntry
		INNER JOIN PRQ1 A3 ON A2.BaseEntry=A3.DocEntry
		INNER JOIN RDR21 A4 ON A3.DocEntry=A4.RefDocNum
		INNER JOIN OPCH A5 ON A5.DOCNUM=A0.DOCENTRY
		WHERE A4.RefObjType=1470000113 AND A5.CANCELED='N'
		UNION ALL
		SELECT DISTINCT A0.DOCENTRY,A3.RefObjType,A3.REFDOCNUM,A3.DOCENTRY AS 'REF_ENTRY',A3.ISSUEDATE,A0.INMPrice,A0.ItemCode,A0.ObjType,A0.Quantity FROM POR1 A0
		INNER JOIN PQT1 A1 ON A0.BaseEntry=A1.DocEntry
		INNER JOIN PRQ1 A2 ON A1.BaseEntry=A2.DocEntry
		INNER JOIN RDR21 A3 ON A2.DocEntry=A3.RefDocNum
		INNER JOIN OPOR A4 ON A3.DOCENTRY=A4.DOCNUM
		WHERE A3.RefObjType=1470000113 AND A4.CANCELED='N') 
		AS T9
		ON T0.BaseEntry=T9.REF_ENTRY


WHERE T3.DocType = 'I' 
AND T1.ItemType='I'
AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
AND T3.CANCELED='N'
AND  T3.U_BO_DRS ='Y' --OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 

UNION ALL --DELIVERIES

SELECT 
T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,
T3.BPLID AS 'BRANCH ID',
'DELIVERY' AS 'TYPE',
T1.U_Category AS 'Category',
T0.DocEntry AS 'Transaction#',T6.Number,
T0.DocDate AS 'Posting Date',
t3.U_DocSeries AS 'Invoice No.',
CONCAT('DN ',T5.DocEntry) AS 'Reference',
CONVERT(VARCHAR(20),(SELECT TAXDATE FROM ODLN WHERE DOCNUM=T5.DOCENTRY),101) AS 'ReferenceDate',
T3.CardName AS 'Customer',
T4.CardFName AS 'Foreign Name',
T3.Comments AS 'Comments',
T0.ocrcode AS 'Whse',
T0.ItemCode AS 'Item Code',
T0.unitMsr AS 'unit',
T0.Dscription AS 'Description',
T5.Quantity AS 'Quantity Sold',
T0.U_GPBD AS 'Price Before Discount',
T0.PriceAfVAT AS 'Price After Discount',
T0.INMPrice AS 'Price After Discount(VAT-Ex)',
T5.PRICE AS 'COST',
T0.INMPrice * T5.Quantity AS 'Total Sales'


FROM INV1 T0

INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
INNER JOIN (SELECT DISTINCT StockValue/Quantity AS 'PRICE',DocEntry,Quantity, BaseEntry , ItemCode,WHSCODE FROM DLN1)  AS T5  ON T5.BaseEntry =T0.DocEntry AND T5.ItemCode=T0.ItemCode AND T5.WHSCODE=T0.WHSCODE 
--INNER JOIN OJDT T6 ON T5.DocEntry=T6.BaseRef AND T6.TransType =15
INNER JOIN OJDT T6 ON T0.DocEntry=T6.BaseRef AND T6.TransType =13

WHERE T3.DocType = 'I' 
AND T1.ItemType='I'
AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
AND T3.CANCELED='N'


UNION ALL --GOODS ISSUE

SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,
T3.BPLID AS 'BRANCH ID',
CASE WHEN T3.isIns ='Y' THEN 'AR RESERVE' ELSE 'AR INVOICE' END AS 'TYPE',
T1.U_Category AS 'Category',
T0.DocEntry AS 'Transaction#',T9.Number,
T0.DocDate AS 'Posting Date',
t3.U_DocSeries AS 'Invoice No.',
CASE WHEN  T3.U_BO_DRS ='Y' --OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
THEN CONCAT('GI ',T8.DocEntry)
ELSE ''
END AS 'Reference',
CASE WHEN  T3.U_BO_DRS ='Y' --OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
THEN CONVERT(VARCHAR(20),T8.IssueDate,101)
ELSE ''
END AS 'ReferenceDate',
T3.CardName AS 'Customer',
T4.CardFName AS 'Foreign Name',
T3.Comments AS 'Comments',
T0.ocrcode AS 'Whse',
T0.ItemCode AS 'Item Code',
T0.unitMsr AS 'unit',
T0.Dscription AS 'Description',
--T0.Quantity AS 'Quantity Sold',
T8.Quantity 
	AS 'Quantity Sold',
--T0.Quantity-ISNULL(T5.QTY,0) AS 'Quantity Sold',
T0.U_GPBD AS 'Price Before Discount',
T0.PriceAfVAT AS 'Price After Discount',
T0.INMPrice AS 'Price After Discount(VAT-Ex)',
T8.PRICE AS 'COST',

T0.INMPrice * T8.Quantity AS 'Total Sales'

FROM INV1 T0

INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
LEFT JOIN (SELECT SUM(Quantity) AS 'QTY', BaseEntry , ItemCode,WHSCODE 
		FROM DLN1 
		GROUP BY  BaseEntry ,ItemCode,WHSCODE) AS T5  
		ON T5.BaseEntry =T0.DocEntry AND T5.ItemCode=T0.ItemCode AND T5.WHSCODE=T0.WHSCODE  

INNER JOIN (SELECT A1.DOCENTRY,REFDOCNUM, A1.QUANTITY,A1.LINETOTAL/A1.QUANTITY AS 'PRICE',A0.IssueDate FROM IGE21 A0
		INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY
		WHERE A0.REFOBJTYPE =13) AS T8
		ON T8.REFDOCNUM=T0.DOCENTRY 
INNER JOIN OJDT T9 ON T8.DOCENTRY=T9.BaseRef AND T9.TransType =60

WHERE T3.DocType = 'I' 
AND T1.ItemType='I'
AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
AND T3.CANCELED='N'
AND  T3.U_BO_DRS ='Y' --OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 


UNION ALL  --AR CM

SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,
T3.BPLID AS 'BRANCH ID',
'AR Credit Memo' AS 'TYPE',
T1.U_Category AS 'Category',
T0.DocEntry AS 'Transaction#',T6.Number,
T0.DocDate AS 'Posting Date',
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
CASE WHEN   T3.U_BO_DRS ='Y' --OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
THEN ISNULL(T5.INMPrice*-1,ISNULL((SELECT DISTINCT A3.INMPrice 
							FROM INV1 A0
							INNER JOIN  PRQ1 A1 ON A0.BaseEntry=A1.BaseEntry
							INNER JOIN PQT1 A2 ON A1.DocEntry=A2.BaseEntry
							INNER JOIN POR1 A3 ON A2.DocEntry=A3.BaseEntry
							WHERE A0.DOCENTRY=T0.BaseEntry
							AND A3.BaseType=540000006 AND A3.ItemCode=T0.ItemCode AND A2.WhsCode=T0.WhsCode),
							(SELECT A3.INMPrice FROM INV1 A0
							INNER JOIN RDR21 A1 ON A0.BaseEntry=A1.DocEntry
							INNER JOIN POR1 A2 ON A1.RefDocNum=A2.DOCENTRY
							INNER JOIN PCH1 A3 ON A2.DocEntry=A3.BaseEntry
							WHERE A0.DocEntry=T0.BASEENTRY AND A3.ItemCode=T0.ItemCode
							UNION ALL 
							SELECT A2.INMPrice FROM INV1 A0
							INNER JOIN RDR21 A1 ON A0.BaseEntry=A1.DocEntry
							INNER JOIN POR1 A2 ON A1.RefDocNum=A2.DOCENTRY
							WHERE A0.DocEntry=T0.BASEENTRY AND A2.ItemCode=T0.ItemCode
							AND A2.DocEntry NOT IN (SELECT BaseEntry FROM PCH1 WHERE BASETYPE=22))))
WHEN (SELECT isIns FROM OINV WHERE DOCNUM=T0.BaseEntry)='Y'
	THEN CASE WHEN T0.ITEMCODE IN ((SELECT ITEMCODE FROM DLN1 WHERE BaseEntry=T0.BaseEntry))
			THEN (SELECT DISTINCT StockValue/Quantity AS 'PRICE' FROM DLN1 WHERE BaseEntry=T0.BaseEntry AND ItemCode=T0.ItemCode)
			ELSE (SELECT AvgPrice FROM OITW WHERE ItemCode= T0.ItemCode AND WhsCode=T0.WhsCode)
			END
ELSE 
			CASE WHEN T0.BASETYPE=203
			THEN (SELECT DISTINCT A1.StockValue/A1.Quantity FROM DPI1 A0
				INNER JOIN INV1 A1 ON A0.BaseEntry=A1.BaseEntry
				WHERE A0.DocEntry=T0.BaseEntry AND A1.ItemCode=T0.ItemCode)
			WHEN T0.BaseType=13
			THEN (SELECT TOP 1 StockValue/Quantity FROM INV1 WHERE DocEntry=T0.BaseEntry AND ItemCode=T0.ItemCode AND ObjType=T0.BaseType)
			END		
			
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
		WHERE A0.BaseType=13 AND A5.BaseType=22
		UNION ALL
		SELECT DISTINCT A0.DocEntry,A5.INMPrice,A5.ItemCode,A5.WhsCode
		FROM RIN1 A0
		INNER JOIN DPI1 A1 ON A0.BaseEntry=A1.DocEntry
		INNER JOIN PRQ1 A2 ON A1.BaseEntry=A2.BaseEntry
		INNER JOIN PQT1 A3 ON A2.DocEntry=A3.BaseEntry
		INNER JOIN POR1 A4 ON A3.DocEntry=A4.BaseEntry
		INNER JOIN PCH1 A5 ON A4.DocEntry=A5.BaseEntry
		WHERE A0.BaseType=203 AND A5.BaseType=22
		) AS T5
		ON T5.DocEntry =T0.DocEntry		
		AND T5.ItemCode=T0.ItemCode AND T5.WhsCode=T0.WhsCode
INNER JOIN OJDT T6 ON T0.DocEntry=T6.BaseRef AND T6.TransType =14


WHERE T3.DocType = 'I' 
AND T1.ItemType='I'
AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
AND T3.CANCELED='N'


) D
WHERE D.[Quantity Sold]<>0
--AND D.[BRANCH ID] NOT IN (SELECT BPLId FROM OBPL WHERE U_isDC='Y')
AND D.Department LIKE '%'+@DEPARTMENT+'%' 
AND D.Category LIKE '%'+@CATEGORY+'%'
AND D.Description LIKE '%'+@ITEMNAME+'%'
AND D.Whse LIKE '%'+@STORE+'%'
AND D.CANCELED='N'

ORDER BY 'Transaction#' ASC


