


DECLARE @PeriodFrom as Date = '2023-04-01'
,@PeriodTo as Date = '2023-04-06'
,@TOP AS Integer = 1
,@GroupByStore as bit = 1
,@Store VARCHAR =''
,@Department VARCHAR = ''
,@SortBy VARCHAR(100)='QUANTITY'

-- DECLARE @PeriodFrom as Date = {?PeriodFrom}
-- ,@PeriodTo as Date = {?PeriodTo}
-- ,@TOP AS Integer = {?TOP}
-- ,@GroupByStore as bit = {?GroupBy}
-- ,@Store VARCHAR =''
-- ,@Department VARCHAR = '{?Department}'
SELECT * FROM(
SELECT
    OrderCode
	Itemcode,
	ItemName,
    UomCode,
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
	SELECT	
		T1.UomCode,
		CASE 
			WHEN T0.ISINS = 'Y' 
			THEN CONCAT('RES ', T0.DOCNUM)
			WHEN t0.U_BO_DRS = 'Y' 
			THEN CONCAT('IN ', T0.DOCNUM) 
			ELSE CONCAT('IN ', T0.DOCNUM) 
		END AS Type,

		T2.Itemcode as ItemCode,
		T2.ItemName as ItemName,
		CASE 
			WHEN T0.ISINS = 'Y' 
			THEN 'AR Reserve'
			WHEN t0.U_BO_DRS = 'Y' 
			THEN 'Dropship' 
			ELSE 'Standard'
		END AS TransType,

		CASE
			WHEN t0.discsum > 0 
			THEN T1.StockSum
			ELSE T1.LineTotal
		END AS Sales,

		CASE 
			WHEN T0.ISINS = 'Y' 
			THEN 0
			WHEN t0.U_BO_DRS = 'Y' 
			THEN 0
			ELSE T1.STOCKVALUE
		END AS Cost,

		CASE 
			WHEN t0.discsum > 0
			THEN T1.StockSum - CASE WHEN T0.ISINS = 'Y' THEN 0 WHEN t0.U_BO_DRS = 'Y' THEN 0 ELSE T1.STOCKVALUE END
			ELSE T1.LineTotal- CASE WHEN T0.ISINS = 'Y' THEN 0 WHEN t0.U_BO_DRS = 'Y' THEN 0 ELSE	T1.STOCKVALUE END
		end as GrossProfit,
		t1.OcrCode,
		CASE 
			WHEN T1.Dscription LIKE '%Delivery Charge%' 
			THEN 2
			ELSE 1 
		END AS OrderCode,
		T1.Quantity as Quantity,
		t1.UomCode as UOM,
		T1.OcrCode as Store,
		T3.ItmsGrpNam as ItemGroup,
		T2.U_Category as Category,
		T1.WhsCode

	FROM OINV T0
	INNER JOIN INV1 T1 ON T0.DOCNUM = T1.DOCENTRY
	INNER JOIN OITM T2 ON T1.ITEMCODE = T2.ITEMCODE
	INNER JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
	WHERE T0.DOCTYPE = 'I' AND T0.CANCELED = 'N'
	AND  T0.TaxDate BETWEEN @PeriodFrom AND @PeriodTo

	UNION ALL

	SELECT 	
		T1.UomCode,
		CONCAT('DN ' , t0.DocNum) as Type,
		T2.ItemCode as ItemCode,
		T2.ItemName as ItemName,
		'Delivery' as TransType,

		0 as Sales,
		T1.StockValue as Cost,
		0 - T1.StockValue  as GrossProfit,
		t1.OcrCode,
		CASE 
			WHEN T1.Dscription LIKE '%Delivery Charge%' 
			THEN 2
			ELSE 1 
		END AS OrderCode,
		T1.Quantity as Quantity,
		t1.UomCode as UOM,
		T1.OcrCode as Store,
		T3.ItmsGrpNam as ItemGroup,
		T2.U_Category as Category,
		T1.WhsCode

	FROM ODLN T0
	INNER JOIN DLN1 T1 ON T1.Docentry = T0.Docnum
	INNER JOIN OITM T2 ON T1.ItemCode = T2.Itemcode
	INNER JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
	WHERE T0.CANCELED = 'N'
	AND T0.TaxDate BETWEEN @PeriodFrom AND @PeriodTo

	UNION ALL

	SELECT 	
		T1.UomCode,
		CONCAT('CN ' , t0.DocNum) as Type,
		T2.ItemCode,
		T2.ItemName,
		'Credit Memo' as TransType,
		T1.LineTotal * -1 AS Sales,
		T1.StockValue * -1  AS Cost,
		(T1.LineTotal - T1.StockValue) * -1 as GrossProfit,
		t1.OcrCode,
		CASE 
			WHEN T1.Dscription LIKE '%Delivery Charge%' 
			THEN 2
			ELSE 1 
		END AS OrderCode,
		T1.Quantity * -1  as Quantity,
		t1.UomCode as UOM,
		T1.OcrCode as Store,
		T3.ItmsGrpNam as ItemGroup,
		T2.U_Category,
		T1.WhsCode

	FROM ORIN T0
	INNER JOIN RIN1 T1 ON T1.Docentry = T0.Docnum
	INNER JOIN OITM T2 ON T1.ItemCode = T2.Itemcode
	INNER JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
	WHERE T0.CANCELED = 'N' AND T1.BASETYPE <> 203
	AND T0.TaxDate BETWEEN @PeriodFrom AND @PeriodTo

	UNION ALL 

	SELECT 	
		T1.UomCode,
		CONCAT('CN ' , t0.DocNum) as Type,
		T2.ItemCode,
		T2.ItemName,
		'AP Invoice' as TransType,
		0 AS Sales,
		T1.LineTotal AS Cost,
		(T1.LineTotal - T1.StockValue) as GrossProfit,
		t1.OcrCode,
		CASE 
			WHEN T1.Dscription LIKE '%Delivery Charge%' 
			THEN 2
			ELSE 1 
		END AS OrderCode,
		T1.Quantity as Quantity,
		t1.UomCode as UOM,
		T1.OcrCode as Store,
		T3.ItmsGrpNam as ItemGroup,
		T2.U_Category as Category,
		T1.WhsCode

	FROM OPCH T0
	INNER JOIN PCH1 T1 ON T1.Docentry = T0.Docnum
	INNER JOIN OITM T2 ON T1.ItemCode = T2.Itemcode
	INNER JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
	WHERE T0.CANCELED = 'N' AND T1.WhsCode LIKE '%DS%'
	AND T0.TaxDate BETWEEN @PeriodFrom AND @PeriodTo

) as TP
WHERE Store LIKE '%'+@Store+'%'
AND ItemGroup  LIKE  '%'+@Department+'%'
GROUP BY ITEMCODE, ITEMNAME, OrderCode, ItemGroup, Category,Store ,UomCode
-- ORDER BY 
-- case when @SortBy='Gross Profit Percentage' then   CAST ( (SUM(Sales) - SUM(Cost)) / nullif( SUM(Sales), 0 ) * 100 as MONEY ) 
-- when @SortBy = 'Quantity' then SUM(Quantity) 
-- when @SortBy ='Total Sales' then CAST(SUM(Sales) AS FLOAT) 
-- END DESC
)DD

ORDER BY 
case when @SortBy='Gross Profit Percentage' then  [Gross Profit Percentage]
when @SortBy = 'Total Quantity' then [Total Quantity Sold]
when @SortBy ='Total Sales' then [Total Sales]
END DESC

		

