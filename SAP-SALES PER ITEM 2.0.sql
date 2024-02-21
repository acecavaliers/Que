



--  DECLARE @DATEFROM DATE ={?dateFrom}, @DATETO DATE ={?dateTo},
--  @DEPARTMENT VARCHAR(100)='{?Department}',@CATEGORY VARCHAR(100)='{?Category}',@ITEMNAME VARCHAR(200)='{?ItemName}',@STORE VARCHAR(10)='{?Whse}'

 DECLARE @DATEFROM DATE ='2023-01-01', @DATETO DATE ='2023-06-30',
 @DEPARTMENT VARCHAR(100)='',@CATEGORY VARCHAR(100)='',@ITEMNAME VARCHAR(200)='',@STORE VARCHAR(10)=''


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
--STANDARD AR
SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,'' AS 'DE-AP', '' AS 'TRANSTYPE',
T3.BPLID AS 'BRANCH ID',
'AR INVOICE' AS 'TYPE',
T1.U_Category AS 'Category',
T0.DocEntry AS 'Transaction#',T6.Number,
T3.DocDate AS 'Posting Date',
t3.U_DocSeries AS 'Invoice No.',
'' AS 'Reference',
'' AS 'ReferenceDate',
T3.CardName AS 'Customer',
T4.CardFName AS 'Foreign Name',
T3.Comments AS 'Comments',
T0.ocrcode AS 'Whse',
T0.ItemCode AS 'Item Code',
T0.unitMsr AS 'unit',
T0.Dscription AS 'Description',
T0.Quantity AS 'Quantity Sold',
T0.U_GPBD AS 'Price Before Discount',
T0.PriceAfVAT AS 'Price After Discount',
T0.INMPrice AS 'Price After Discount(VAT-Ex)',
T0.StockValue/T0.Quantity AS 'COST',

T0.INMPrice * T0.Quantity AS 'Total Sales'


FROM INV1 T0

INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode 
INNER JOIN OJDT T6 ON T0.DocEntry=T6.BaseRef AND T6.TransType =13


WHERE T3.DocType = 'I' 
AND T1.ItemType <> 'F'     
AND T3.TaxDate BETWEEN @DATEFROM AND  @DATETO
AND T3.CANCELED='N'
AND T3.isIns='N'
AND T3.U_BO_DRS ='N' AND T3.U_BO_DSDD ='N' AND T3.U_BO_DSDV ='N' AND T3.U_BO_DSPD ='N'

UNION ALL --AR RESERRVE
SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,'' AS 'DE-AP','' AS 'TRANSTYPE',
T3.BPLID AS 'BRANCH ID',
'AR RESERVE' AS 'TYPE',
T1.U_Category AS 'Category',
T0.DocEntry AS 'Transaction#',T6.Number,
T3.DocDate AS 'Posting Date',
t3.U_DocSeries AS 'Invoice No.',
'' AS 'Reference',
'' AS 'ReferenceDate',
T3.CardName AS 'Customer',
T4.CardFName AS 'Foreign Name',
T3.Comments AS 'Comments',
T0.ocrcode AS 'Whse',
T0.ItemCode AS 'Item Code',
T0.unitMsr AS 'unit',
T0.Dscription AS 'Description',
T0.Quantity-ISNULL(T7.QTY,0) AS 'Quantity Sold',
T0.U_GPBD AS 'Price Before Discount',
T0.PriceAfVAT AS 'Price After Discount',
T0.INMPrice AS 'Price After Discount(VAT-Ex)',
CASE WHEN T0.UOMCODE =T0.UOMCODE2 
THEN (SELECT AvgPrice FROM OITW WHERE ItemCode= T0.ItemCode AND WhsCode=T0.WhsCode) 
ELSE  (SELECT AvgPrice FROM OITW WHERE ItemCode= T0.ItemCode AND WhsCode=T0.WhsCode)*T0.NumPerMsr
END AS 'COST',

T0.INMPrice * (T0.Quantity-ISNULL(T7.QTY,0)) AS 'Total Sales'


FROM INV1 T0

INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode 
INNER JOIN OJDT T6 ON T0.DocEntry=T6.BaseRef AND T6.TransType =13
LEFT JOIN (SELECT SUM(Quantity)AS QTY,A0.BaseEntry,ITEMCODE FROM DLN1 A0 
			INNER JOIN ODLN A1 ON A0.DocEntry=A1.DocNum 
			WHERE CANCELED='N'
			GROUP BY  A0.BaseEntry ,ItemCode) AS T7 ON T0.DocEntry=T7.BaseEntry
			AND T7.ItemCode=T0.ItemCode

WHERE T3.DocType = 'I' 
AND T1.ItemType <> 'F'
AND T3.TaxDate BETWEEN @DATEFROM AND  @DATETO
AND T3.CANCELED='N'
AND T3.isIns='Y'
AND T3.U_BO_DRS ='N' AND T3.U_BO_DSDD ='N' AND T3.U_BO_DSDV ='N' AND T3.U_BO_DSPD ='N'
AND T0.Quantity-ISNULL(T7.QTY,0)>0

UNION ALL --DELIVERIES


SELECT 
T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,T0.DocEntry AS 'DE-AP', 15 AS 'TRANSTYPE',
T3.BPLID AS 'BRANCH ID',
'DELIVERY' AS 'TYPE',
T1.U_Category AS 'Category',
T0.BaseEntry AS 'Transaction#',T6.Number,

T7.TaxDate AS 'Posting Date',
T7.U_DocSeries AS 'Invoice No.',
CONCAT('DN ',T0.DocEntry) AS 'Reference',
CONVERT(VARCHAR(20),T3.TAXDATE,101) AS 'ReferenceDate',
T7.CardName AS 'Customer',
T4.CardFName AS 'Foreign Name',
T7.Comments AS 'Comments',
T0.ocrcode AS 'Whse',
T0.ItemCode AS 'Item Code',
T0.unitMsr AS 'unit',
T0.Dscription AS 'Description',
T0.Quantity AS 'Quantity Sold',
T0.U_GPBD AS 'Price Before Discount',
T0.PriceAfVAT AS 'Price After Discount',
T0.INMPrice AS 'Price After Discount(VAT-Ex)',
T0.StockValue/T0.Quantity AS 'COST',
T0.INMPrice * T0.Quantity AS 'Total Sales'


FROM DLN1 T0

INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode AND T1.ItemType<>'F'
INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
INNER JOIN ODLN T3 ON T0.DocEntry = T3.DocNum
INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
INNER JOIN OJDT T6 ON T0.BaseEntry=T6.BaseRef AND T6.TransType =13 
LEFT JOIN OINV T7 ON T0.BaseEntry=T7.DocNum


WHERE T3.DocType = 'I' 
AND T1.ItemType <> 'F'
AND T7.TaxDate BETWEEN @DATEFROM AND  @DATETO
AND T3.CANCELED='N'
--AND T3.isIns='Y'

UNION ALL --DROPSHIP--DROPSHIP

SELECT DISTINCT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,
CASE WHEN T5.RTYPE IS NOT NULL
THEN T5.DocEntry
WHEN T6.RTYPE IS NOT NULL 
THEN T6.DOCENTRY

END AS 'DE-AP',
CASE WHEN ISNULL(T5.INMPrice,T6.INMPrice) IS NOT NULL THEN 18 ELSE 0 END AS 'TRANSTYPE',
T3.BPLID AS 'BRANCH ID',
CASE 
	WHEN T3.isIns ='Y' 
	THEN 'AR RESERVE' 
	ELSE 'AR INVOICE' 
END AS 'TYPE',
T1.U_Category AS 'Category',
T0.DocEntry AS 'Transaction#',T10.Number,
T3.DocDate AS 'Posting Date',
t3.U_DocSeries AS 'Invoice No.',
CASE 
    WHEN  T5.DocEntry IS NOT NULL 
	THEN CONCAT('PO ',T5.DocNum)
    WHEN T6.RTYPE  IS NOT NULL
	THEN CONCAT('AP ',T6.DocNum)

	-- WHEN  T5.DocEntry IS NOT NULL AND T5.RTYPE ='AP'
	-- THEN CONCAT('AP ',T5.DocEntry)
	-- WHEN T6.RTYPE='AP' AND T6.RefDocNum IS NOT NULL
	-- THEN CONCAT('AP ',T6.REFDOCNUM)
	-- WHEN T8.DocEntry IS NOT NULL 
	-- THEN CONCAT('AP ',T8.DocEntry)
	-- WHEN T7.DocEntry IS NOT NULL AND T7.RTYPE='AP'
	-- THEN CONCAT('AP ',T7.DocEntry)
	ELSE ''
END AS 'Reference',
CASE 
	WHEN  T5.TAXDATE IS NOT NULL
	THEN CONVERT(VARCHAR(20),T5.TAXDATE,101)
	WHEN T6.TAXDATE IS NOT NULL
	THEN CONVERT(VARCHAR(20),T6.TAXDATE,101)
	-- WHEN T8.TaxDate IS NOT NULL 
	-- THEN CONVERT(VARCHAR(20),T8.TAXDATE,101)
	-- WHEN T7.IssueDate IS NOT NULL AND T7.RTYPE='AP'
	-- THEN CONVERT(VARCHAR(20),T7.IssueDate,101)
	ELSE ''
END AS 'ReferenceDate',
T3.CardName AS 'Customer',
T4.CardFName AS 'Foreign Name',
CASE 
	WHEN T9.Number IS NULL 
	THEN T3.Comments
	ELSE
	CONCAT(T3.Comments,' ; LC: ',T9.Number) 
END AS 'Comments',
T0.ocrcode AS 'Whse',
T0.ItemCode AS 'Item Code',
T0.unitMsr AS 'unit',
T0.Dscription AS 'Description',
(T0.Quantity - ISNULL(T11.Quantity,0))
-- *(IIF(ISNULL(T5.NumPerMsr,T6.NumPerMsr)>T0.NumPerMsr,ISNULL(T5.NumPerMsr,T6.NumPerMsr),T0.NumPerMsr))

AS 'Quantity Sold',   
T0.U_GPBD AS 'Price Before Discount',
T0.PriceAfVAT AS 'Price After Discount',
T0.INMPrice AS 'Price After Discount(VAT-Ex)',
CASE 
    WHEN T5.INMPrice IS NULL
    THEN IIF(T6.NumPerMsr>T0.NumPerMsr,(T6.INMPrice/T6.NumPerMsr),T6.INMPrice) + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])*T6.[LANDEDCOST])/T0.Quantity - ISNULL(T11.Quantity,0),0)    
	ELSE IIF(T5.NumPerMsr>T0.NumPerMsr,(T5.INMPrice/T5.NumPerMsr),T5.INMPrice) + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])*T5.[LANDEDCOST])/T0.Quantity - ISNULL(T11.Quantity,0),0)
    END AS 'COST',
-- CASE 
    
-- 	WHEN T5.INMPrice IS NULL AND T6.INMPrice IS NOT NULL AND T7.INMPrice IS NULL AND T8.INMPrice IS NULL
-- 	THEN T6.INMPrice + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])*T6.[LANDEDCOST])/T0.Quantity - ISNULL(T11.Quantity,0),0)
-- 	WHEN T5.INMPrice IS NULL AND T6.INMPrice IS  NULL AND T7.INMPrice IS NOT NULL AND T8.INMPrice IS NULL
-- 	THEN T7.INMPrice + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])*T7.[LANDEDCOST])/T0.Quantity - ISNULL(T11.Quantity,0),0)
-- 	WHEN T5.INMPrice IS NULL AND T6.INMPrice IS  NULL AND T7.INMPrice IS NULL AND T8.INMPrice IS NOT NULL
-- 	THEN T8.INMPrice + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])*T9.[LANDEDCOST])/T0.Quantity - ISNULL(T11.Quantity,0),0)
-- 	ELSE T5.INMPrice + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])*T5.[LANDEDCOST])/T0.Quantity - ISNULL(T11.Quantity,0),0)
-- END AS 'COST',
 
T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))
AS 'Total Sales'

FROM INV1 T0
INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
--VIA PO
LEFT JOIN (	
			SELECT TB.NumPerMsr,TA.DocEntry,TC.DocNum,TB.BaseEntry,TC.TaxDate ,TB.Quantity,TB.ItemCode,TB.WhsCode,TB.INMPRICE,TB.DocEntry AS 'PO_#','PO'AS 'RTYPE'
            , TC.U_ARRASTRE+TC.U_BROKERAGE_FEE+TC.U_DOC_STAMP+TC.U_FREIGHT+TC.U_LABOR+TC.U_INSURANCE+TC.U_TRUCKING+TC.U_WHARFAGE+TC.U_OTHERS AS 'LANDEDCOST'
            FROM INV21 TA
            INNER JOIN POR1 TB ON TA.RefDocNum=TB.DocEntry 
            INNER JOIN OPOR TC ON TB.DocEntry=TC.DocNum
            WHERE 
            TA.RefObjType=22
            AND TC.CANCELED='N'
            AND TB.TrgetEntry=0
			)AS T5
			ON T5.DocEntry=T0.DocEntry
			AND T5.ItemCode=T0.ItemCode 
            -- AND T5.WhsCode=T0.WhsCode
-- --VIA AP
LEFT JOIN (
		SELECT TC.NumPerMsr, TA.DocEntry,TD.DocNum,TD.TaxDate ,TC.Quantity,TC.ItemCode,TC.WhsCode,TC.INMPRICE        ,TC.DocEntry AS 'PO_#','AP'AS 'RTYPE'
        , TD.U_ARRASTRE+TD.U_BROKERAGE_FEE+TD.U_DOC_STAMP+TD.U_FREIGHT+TD.U_LABOR+TD.U_INSURANCE+TD.U_TRUCKING+TD.U_WHARFAGE+TD.U_OTHERS AS 'LANDEDCOST'
        FROM INV21 TA
        INNER JOIN POR1 TB ON TA.RefDocNum=TB.DocEntry  
        INNER JOIN PCH1 TC ON TB.DocEntry=TC.BaseEntry
        INNER JOIN OPCH TD ON TC.DocEntry=TD.DocNum
        WHERE 
        TA.RefObjType=22
        AND TD.CANCELED='N'
        ) 
		AS T6
		ON T6.DocEntry=T0.DocEntry
        AND T6.ItemCode=T0.ItemCode

--LANDED COST
LEFT JOIN (SELECT  A0.DOCENTRY,A1.REFDOCNUM,A0.DocTotal-ISNULL(SUM(A3.DocTotal),0) AS 'LANDEDCOST',A2.Number FROM OPCH A0
		INNER JOIN PCH21 A1 ON A0.DOCNUM=A1.DocEntry
		INNER JOIN OJDT A2 ON A0.DocNum=A2.BaseRef AND TransType=18
		LEFT JOIN (SELECT TT.BaseEntry,DocTotal
			FROM ORPC T INNER JOIN RPC1 TT ON T.DocNum=TT.DocEntry 
			WHERE TT.BaseType=18
			)AS A3 ON A0.DocNum=A3.BaseEntry
		WHERE A1.RefObjType=13 AND A0.CANCELED='N' AND A0.DocType='S'
		GROUP BY A0.DOCENTRY,A1.RefObjType,A1.REFDOCNUM,A1.DOCENTRY,A0.DocTotal,A2.Number) 
		AS T9
		ON T0.DocEntry=T9.REFDOCNUM 
--JE
INNER JOIN OJDT T10 ON T0.DocEntry=T10.BaseRef AND T10.TransType =13
LEFT JOIN (SELECT A1.QUANTITY,A1.ITEMCODE,A0.RefDocNum FROM IGE21 A0
		INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY
		WHERE A0.REFOBJTYPE =13) 
		AS T11 ON T11.REFDOCNUM=T0.DOCENTRY AND T11.ITEMCODE=T0.ITEMCODE
INNER JOIN (SELECT  DOCENTRY,SUM(A2.INMPrice*(A2.Quantity-ISNULL(A3.Quantity,0))) AS 'SALES SUM' FROM INV1 A2 
		LEFT JOIN (SELECT B1.QUANTITY,REFDOCNUM,B1.ItemCode FROM IGE21 B0
					INNER JOIN IGE1 B1 ON B0.DOCENTRY=B1.DOCENTRY
					WHERE B0.REFOBJTYPE =13)
					AS A3 ON A2.DocEntry=A3.REFDOCNUM AND A2.ItemCode=A3.ItemCode
		GROUP BY DOCENTRY)
		AS T12 ON T0.DocEntry=T12.DocEntry

WHERE T3.DocType = 'I' 
AND T1.ItemType <> 'F'
AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
AND T3.CANCELED='N'
AND T3.ISINS='N'
AND  T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y'  

UNION ALL --GOODS ISSUE

SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,'' AS 'DE-AP','' AS 'TRANSTYPE',
T3.BPLID AS 'BRANCH ID',
CASE WHEN T3.isIns ='Y' THEN 'AR RESERVE' ELSE 'AR INVOICE' END AS 'TYPE',
T1.U_Category AS 'Category',
T0.DocEntry AS 'Transaction#',T9.Number,
T3.DocDate AS 'Posting Date',
t3.U_DocSeries AS 'Invoice No.',
CASE WHEN  T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
THEN CONCAT('GI ',T8.DocEntry)

ELSE ''
END AS 'Reference',
CASE WHEN  T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
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
LEFT JOIN (SELECT SUM(Quantity) AS 'QTY', A0.BaseEntry , ItemCode,WHSCODE 
		FROM DLN1 A0 INNER JOIN ODLN A1 ON A0.DOCENTRY=A1.DOCNUM
		WHERE CANCELED = 'N'
		GROUP BY  A0.BaseEntry ,ItemCode,WHSCODE) AS T5  
		ON T5.BaseEntry =T0.DocEntry AND T5.ItemCode=T0.ItemCode AND T5.WHSCODE=T0.WHSCODE  

INNER JOIN (SELECT A1.DOCENTRY,REFDOCNUM, A1.QUANTITY,A1.LINETOTAL/A1.QUANTITY AS 'PRICE',A0.IssueDate FROM IGE21 A0
		INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY AND A1.AcctCode LIKE '%CS010%'
		WHERE A0.REFOBJTYPE =13) AS T8
		ON T8.REFDOCNUM=T0.DOCENTRY 
INNER JOIN OJDT T9 ON T8.DOCENTRY=T9.BaseRef AND T9.TransType =60

WHERE T3.DocType = 'I' 
AND T1.ItemType <> 'F'
AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
AND T3.CANCELED='N'
AND  T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 

UNION ALL  --AR CM

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
THEN ISNULL(T7.INMPrice,T8.INMPrice)
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

INNER JOIN OJDT T6 ON T0.DocEntry=T6.BaseRef AND T6.TransType =14
LEFT JOIN (SELECT DISTINCT A3.INMPrice ,A0.DOCENTRY,A3.ItemCode
		FROM INV1 A0
		INNER JOIN  PRQ1 A1 ON A0.BaseEntry=A1.BaseEntry
		INNER JOIN PQT1 A2 ON A1.DocEntry=A2.BaseEntry
		INNER JOIN POR1 A3 ON A2.DocEntry=A3.BaseEntry
		WHERE A3.BaseType=540000006 AND A3.DocEntry NOT IN (SELECT T.BaseEntry FROM PCH1 T INNER JOIN OPCH TT ON T.DocEntry=TT.DocNum WHERE T.BASETYPE=22 AND TT.DocType='I' AND CANCELED='N')
		)AS T7 
		ON T7.DOCENTRY=T0.BaseEntry AND T7.ItemCode=T0.ItemCode
--COST DROPSHIP
LEFT JOIN (SELECT  A6.DocNum AS 'DocEntry',A0.INMPrice +ISNULL((((A7.INMPrice*(A7.Quantity - ISNULL(A8.Quantity,0))/A10.[SALES SUM])*A9.LANDEDCOST)/A7.Quantity - ISNULL(A8.Quantity,0)),0)AS 'INMPrice' ,A0.ItemCode
		FROM PCH1 A0
		INNER JOIN PCH21 A4 ON A0.DocEntry=A4.DocEntry AND A4.RefObjType=13  
		INNER JOIN OPCH A5 ON A5.DOCNUM=A0.DOCENTRY AND A5.CANCELED='N' AND A5.DocType='I'
		INNER JOIN OINV A6 ON A4.RefDocNum=A6.DocNum AND A6.CANCELED='N'
		INNER JOIN INV1 A7 ON A6.DocNum=A7.DocEntry AND A7.ItemCode=A0.ItemCode
		LEFT JOIN (SELECT A1.QUANTITY,A1.ITEMCODE,A0.RefDocNum FROM IGE21 A0
		INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY
		WHERE A0.REFOBJTYPE =13) 
		AS A8 ON A8.REFDOCNUM=A7.DOCENTRY AND A8.ITEMCODE=A7.ITEMCODE
		--LANDED COST
		LEFT JOIN (SELECT  A0.DOCENTRY,A1.REFDOCNUM,A0.DocTotal-ISNULL(SUM(A3.DocTotal),0) AS 'LANDEDCOST',A2.Number,A1.RefObjType FROM OPCH A0
					INNER JOIN PCH21 A1 ON A0.DOCNUM=A1.DocEntry
					INNER JOIN OJDT A2 ON A0.DocNum=A2.BaseRef AND TransType=18
					LEFT JOIN (SELECT TT.BaseEntry,DocTotal
							FROM ORPC T INNER JOIN RPC1 TT ON T.DocNum=TT.DocEntry 
							WHERE TT.BaseType=18
							)AS A3 ON A0.DocNum=A3.BaseEntry
		WHERE A1.RefObjType=13 AND A0.CANCELED='N' AND A0.DocType='S'
		GROUP BY A0.DOCENTRY,A1.RefObjType,A1.REFDOCNUM,A1.DOCENTRY,A0.DocTotal,A2.Number) 
		AS A9
		ON A6.DOCNUM=A9.REFDOCNUM AND A9.RefObjType=A6.ObjType
		INNER JOIN (SELECT  DOCENTRY,SUM(A2.INMPrice*(A2.Quantity-ISNULL(A3.Quantity,0))) AS 'SALES SUM' FROM INV1 A2 
		--GOODS ISUE
		LEFT JOIN (SELECT B1.QUANTITY,REFDOCNUM,B1.ItemCode FROM IGE21 B0
					INNER JOIN IGE1 B1 ON B0.DOCENTRY=B1.DOCENTRY
					WHERE B0.REFOBJTYPE =13)
					AS A3 ON A2.DocEntry=A3.REFDOCNUM AND A2.ItemCode=A3.ItemCode
		GROUP BY DOCENTRY)
		AS A10 ON A7.DocEntry=A10.DocEntry
		WHERE A6.U_BO_DRS ='Y' OR A6.U_BO_DSDD ='Y' OR A6.U_BO_DSDV ='Y' OR A6.U_BO_DSPD ='Y'		
		UNION ALL
		--FROM PO COST
		SELECT DISTINCT A2.INMPrice,A4.DocEntry,A2.ItemCode --,U_ARRASTRE+U_BROKERAGE_FEE+U_DOC_STAMP+U_FREIGHT+U_LABOR+U_INSURANCE+U_TRUCKING+U_WHARFAGE+U_OTHERS AS 'LANDEDCOST' 
			FROM POR1 A2
			INNER JOIN OPOR A3 ON A2.DocEntry=A3.DocNum
			INNER JOIN INV1 A4 ON A2.BaseEntry=A4.BaseEntry AND A2.BaseType=A4.BaseType
			WHERE A2.BaseType=540000006  AND A3.CANCELED='N'
			AND A2.ITEMCODE IS NOT NULL
			AND A2.DOCENTRY NOT IN (SELECT T.BASEENTRY FROM PCH1 T INNER JOIN OPCH TT ON T.DocEntry=TT.DOCNUM WHERE T.BaseType=22 AND CANCELED='N' AND ITEMCODE IS NOT NULL)
		UNION ALL
		SELECT DISTINCT A2.INMPrice,A4.DocEntry,A2.ItemCode --,U_ARRASTRE+U_BROKERAGE_FEE+U_DOC_STAMP+U_FREIGHT+U_LABOR+U_INSURANCE+U_TRUCKING+U_WHARFAGE+U_OTHERS AS 'LANDEDCOST' 
			FROM PRQ1 A0 
			INNER JOIN PQT1 A1 ON A0.DocEntry=A1.BaseEntry
			INNER JOIN POR1 A2 ON A1.DocEntry=A2.BaseEntry
			INNER JOIN OPOR A3 ON A2.DocEntry=A3.DocNum
			INNER JOIN INV1 A4 ON A0.BaseEntry=A4.BaseEntry AND A0.BaseType=A4.BaseType
			WHERE A2.BaseType=540000006  AND A3.CANCELED='N'
			AND A2.ITEMCODE IS NOT NULL
			AND A2.DOCENTRY NOT IN (SELECT T.BASEENTRY FROM PCH1 T INNER JOIN OPCH TT ON T.DocEntry=TT.DOCNUM WHERE T.BaseType=22 AND CANCELED='N' AND ITEMCODE IS NOT NULL)
		)AS T8
		ON T8.DocEntry=T0.BASEENTRY AND T8.ItemCode=T0.ItemCode
		--END COST DROP SHIP


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
AND D.[Posting Date] BETWEEN @DATEFROM AND  @DATETO
AND D.CANCELED='N'
and D.[Item Code] NOT LIKE '%SVSVS%'
AND COST is NULL

ORDER BY 'Transaction#' ASC






