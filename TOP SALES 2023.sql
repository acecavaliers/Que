

-- DECLARE @PeriodFrom as Date = {?PeriodFrom}
-- ,@PeriodTo as Date = {?PeriodTo}

-- ,@GroupByStore as bit = {?GroupBy}
-- ,@Store VARCHAR ='{?Store}'
-- ,@Department VARCHAR = '{?Department}'
-- ,@SortBy VARCHAR(100)='{?SortBy}'


DECLARE 
@PeriodFrom as Date = '2023-06-01'
,@PeriodTo as Date = '2023-06-10'

,@Store VARCHAR ='DCC'
,@Department VARCHAR = ''
,@SortBy VARCHAR(100)='Gross Profit Percentage'

SELECT * 
FROM(
	SELECT
    OrderCode
	Itemcode,
	ItemName,
    UomCode2,
	SUM(Quantity) as 'Total Quantity Sold',
	CAST(SUM(Sales) AS FLOAT) AS 'Total Sales',
	CAST(SUM(Cost) AS FLOAT) AS Cost,
	CAST(SUM(Sales) AS FLOAT) - CAST(SUM(Cost) AS FLOAT) as 'Gross Profit',
	CASE 
		WHEN (SUM(Sales) - SUM(Cost)) / nullif( SUM(Sales) , 0 ) > 0 
		THEN isnull((SUM(Sales) - SUM(Cost)) / nullif( SUM(Sales) , 0 ) * 100, 0 )
		ELSE isnull((SUM(Sales) - SUM(Cost)) / nullif( SUM(Sales) , 0 ) , 0 ) 
	END as 'Gross Profit Percentage',
	Store,
	ItemGroup as Department, 
	Category,
	max(replace(left(WhsCode,6),'KORKM2','KOROST')) AS WhsCode

FROM(    
	SELECT	--/// Standar Invoice
	t0.TaxDate,
	T0.DocNum,
	T1.UomCode2,
	CASE 
	WHEN T0.ISINS = 'Y' 
	THEN CONCAT('RES ', T0.DOCNUM)
	WHEN t0.U_BO_DRS = 'Y' 
	THEN CONCAT('IN ', T0.DOCNUM) 
	ELSE CONCAT('IN ', T0.DOCNUM) 
	END AS Type,
	T2.Itemcode as 'ItemCode',
	T2.ItemName as 'ItemName',			
	'Standard' AS 'TransType',
	CASE
	WHEN t0.discsum > 0 
	THEN T1.StockSum
	ELSE T1.LineTotal
	END AS 'Sales',
	T1.StockValue as 'Cost',
	CASE 
	WHEN t0.discsum > 0
	THEN T1.StockSum - CASE WHEN T0.ISINS = 'Y' THEN 0 WHEN t0.U_BO_DRS = 'Y' THEN 0 ELSE T1.STOCKVALUE END
	ELSE T1.LineTotal- CASE WHEN T0.ISINS = 'Y' THEN 0 WHEN t0.U_BO_DRS = 'Y' THEN 0 ELSE	T1.STOCKVALUE END
	End as 'GrossProfit',
	t1.OcrCode,
	CASE 
	WHEN T1.Dscription LIKE '%Delivery Charge%' 
	THEN 2
	ELSE 1 
	END AS 'OrderCode',
	t1.NumPerMsr*t1.Quantity as 'Quantity',
	t1.UomCode2 as 'UOM',
	T1.OcrCode as 'Store',
	T3.ItmsGrpNam as 'ItemGroup',
	T2.U_Category as 'Category',
	T1.WhsCode

	FROM OINV T0
	INNER JOIN INV1 T1 ON T0.DOCNUM = T1.DOCENTRY
	INNER JOIN OITM T2 ON T1.ITEMCODE = T2.ITEMCODE
	INNER JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
	WHERE T0.DocType = 'I' 
	AND T0.CANCELED = 'N'    
	AND T2.ItemType <> 'F'
	AND  T0.TaxDate BETWEEN @PeriodFrom AND @PeriodTo
	AND T0.isIns='N'
	AND T0.U_BO_DRS ='N' AND T0.U_BO_DSDD ='N' AND T0.U_BO_DSDV ='N' AND T0.U_BO_DSPD ='N'

UNION ALL ----/// AR RESERVE

		
	SELECT	
	t0.TaxDate,
	T0.DocNum,
	T1.UomCode2,
	CASE 
	WHEN T0.ISINS = 'Y' 
	THEN CONCAT('RES ', T0.DOCNUM)
	WHEN t0.U_BO_DRS = 'Y' 
	THEN CONCAT('IN ', T0.DOCNUM) 
	ELSE CONCAT('IN ', T0.DOCNUM) 
	END AS Type,
	T2.Itemcode as 'ItemCode',
	T2.ItemName as 'ItemName',		
	'AR Reserve' AS 'TransType',
	CASE
	WHEN t0.discsum > 0 
	THEN T1.StockSum
	ELSE T1.LineTotal
	END AS 'Sales',

	CASE WHEN T1.UOMCODE =T1.UOMCODE2 
	THEN (SELECT AvgPrice FROM OITW WHERE ItemCode= T1.ItemCode AND WhsCode=T1.WhsCode) 
	ELSE  (SELECT AvgPrice FROM OITW WHERE ItemCode= T1.ItemCode AND WhsCode=T1.WhsCode)*(T1.NumPerMsr*T1.Quantity)
	END AS 'COST',

	CASE 
	WHEN t0.discsum > 0
	THEN T1.StockSum - CASE WHEN T0.ISINS = 'Y' THEN 0 WHEN t0.U_BO_DRS = 'Y' THEN 0 ELSE T1.STOCKVALUE END
	ELSE T1.LineTotal- CASE WHEN T0.ISINS = 'Y' THEN 0 WHEN t0.U_BO_DRS = 'Y' THEN 0 ELSE	T1.STOCKVALUE END
	end as 'GrossProfit',
	t1.OcrCode,
	CASE 
	WHEN T1.Dscription LIKE '%Delivery Charge%' 
	THEN 2
	ELSE 1 
	END AS 'OrderCode',
	t1.NumPerMsr*t1.Quantity as 'Quantity',
	t1.UomCode2 as 'UOM',
	T1.OcrCode as 'Store',
	T3.ItmsGrpNam as 'ItemGroup',
	T2.U_Category as 'Category',
	T1.WhsCode

	FROM OINV T0
	INNER JOIN INV1 T1 ON T0.DOCNUM = T1.DOCENTRY
	INNER JOIN OITM T2 ON T1.ITEMCODE = T2.ITEMCODE
	INNER JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
	LEFT JOIN 
		(SELECT SUM(Quantity)AS QTY,A0.BaseEntry,ITEMCODE FROM DLN1 A0 
		INNER JOIN ODLN A1 ON A0.DocEntry=A1.DocNum 
		WHERE CANCELED='N'
		GROUP BY  A0.BaseEntry ,ItemCode) AS T7 ON T1.DocEntry=T7.BaseEntry
		AND T7.ItemCode=T1.ItemCode

	WHERE T0.DocType = 'I' 
	AND T0.CANCELED = 'N'    
	AND T2.ItemType <> 'F'
	AND  T0.TaxDate BETWEEN @PeriodFrom AND @PeriodTo
	AND T0.isIns='Y'
	AND T0.U_BO_DRS ='N' AND T0.U_BO_DSDD ='N' AND T0.U_BO_DSDV ='N' AND T0.U_BO_DSPD ='N'
	AND T1.Quantity-ISNULL(T7.QTY,0)>0


UNION ALL --//DropShip

	SELECT
	t0.TaxDate,
	T0.DocNum,
	T1.UomCode2,
	CASE 
	WHEN T0.ISINS = 'Y' 
	THEN CONCAT('RES ', T0.DOCNUM)
	WHEN t0.U_BO_DRS = 'Y' 
	THEN CONCAT('IN ', T0.DOCNUM) 
	ELSE CONCAT('IN ', T0.DOCNUM) 
	END AS Type,

	T2.Itemcode as 'ItemCode',
	T2.ItemName as 'ItemName',	
	'DropShip' AS 'TransType',

	CASE
	WHEN t0.discsum > 0 
	THEN T1.StockSum
	ELSE T1.LineTotal
	END AS 'Sales',

	CASE 
	WHEN T6.STOCKVALUE IS NULL
	THEN T5.STOCKVALUE   
	ELSE T6.STOCKVALUE
	END  AS 'COST',
		-- T1.INMPrice as Cost,
	CASE 
	WHEN t0.discsum > 0
	THEN T1.StockSum - CASE WHEN T0.ISINS = 'Y' THEN 0 WHEN t0.U_BO_DRS = 'Y' THEN 0 ELSE T1.STOCKVALUE END
	ELSE T1.LineTotal- CASE WHEN T0.ISINS = 'Y' THEN 0 WHEN t0.U_BO_DRS = 'Y' THEN 0 ELSE	T1.STOCKVALUE END
	end as 'GrossProfit',
	t1.OcrCode,
	CASE 
	WHEN T1.Dscription LIKE '%Delivery Charge%' 
	THEN 2
	ELSE 1 
	END AS 'OrderCode',
	t1.NumPerMsr*t1.Quantity as 'Quantity',
	t1.UomCode2 as 'UOM',
	T1.OcrCode as 'Store',
	T3.ItmsGrpNam as 'ItemGroup',
	T2.U_Category as 'Category',
	T1.WhsCode

	FROM OINV T0
	INNER JOIN INV1 T1 ON T0.DOCNUM = T1.DOCENTRY
	INNER JOIN OITM T2 ON T1.ITEMCODE = T2.ITEMCODE
	INNER JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
		-- --VIA PO
	INNER JOIN 
		(SELECT TB.NumPerMsr,TA.DocEntry,TC.DocNum,TB.BaseEntry,TC.TaxDate ,TB.Quantity,TB.ItemCode,TB.WhsCode,TB.INMPRICE,TB.DocEntry AS 'PO_#','PO'AS 'RTYPE'
		,TB.StockValue
		FROM INV21 TA
		INNER JOIN POR1 TB ON TA.RefDocNum=TB.DocEntry 
		INNER JOIN OPOR TC ON TB.DocEntry=TC.DocNum
		WHERE 
		TA.RefObjType=22
		AND TC.CANCELED='N'
		AND TB.TrgetEntry=0
		)AS T5
		ON T5.DocEntry=T0.DocNum
		AND T5.ItemCode=T1.ItemCode 

		-- --VIA AP
	LEFT JOIN 
		(SELECT TC.NumPerMsr, TA.DocEntry,TD.DocNum,TD.TaxDate ,TC.Quantity,TC.ItemCode,TC.WhsCode,TC.INMPRICE        ,TC.DocEntry AS 'PO_#','AP'AS 'RTYPE'
		,TC.StockValue
		FROM INV21 TA
		INNER JOIN POR1 TB ON TA.RefDocNum=TB.DocEntry  
		INNER JOIN PCH1 TC ON TB.DocEntry=TC.BaseEntry
		INNER JOIN OPCH TD ON TC.DocEntry=TD.DocNum
		WHERE 
		TA.RefObjType=22
		AND TD.CANCELED='N') AS T6
		ON T6.DocEntry=T0.DOCNUM 
		AND T6.ItemCode=T1.ItemCode

	WHERE T0.DocType = 'I' 
	AND T0.CANCELED = 'N'    
	AND T2.ItemType <> 'F'
	AND T0.TaxDate BETWEEN @PeriodFrom AND @PeriodTo
	AND T0.isIns='N'
	AND T0.U_BO_DRS ='Y' OR T0.U_BO_DSDD ='Y' OR T0.U_BO_DSDV ='Y' OR T0.U_BO_DSPD ='Y'
		

) as TP
WHERE Store LIKE '%'+@Store+'%'
AND ItemGroup  LIKE  '%'+@Department+'%'
AND  TaxDate BETWEEN @PeriodFrom AND @PeriodTo
AND ItemName NOT LIKE '%DELIVERY CHARGE%'
GROUP BY ITEMCODE, ITEMNAME, OrderCode, ItemGroup, Category,Store,UomCode2


)DD

ORDER BY 
case when @SortBy='Gross Profit Percentage' then  [Gross Profit Percentage]
when @SortBy = 'Total Quantity' then [Total Quantity Sold]
when @SortBy ='Total Sales' then [Total Sales]
END DESC