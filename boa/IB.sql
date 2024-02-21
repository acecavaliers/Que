

DECLARE
@PERIODFROM DATE='2023-01-01', 
@PERIODTO DATE='2023-12-31',
@ITEM VARCHAR(100)='',
@Warehouse VARCHAR(50)='ALL WAREHOUSE'


SET @Warehouse = replace((@Warehouse),'ALL WAREHOUSE','')

-- SELECT SUM([PHP Amount])
-- FROM (
SELECT 

Transseq,
T0.TRANSTYPE AS TransactionCode,

CASE WHEN T0.TRANSTYPE = 69 THEN 'Landed Costs'
WHEN T0.TransType = 15 THEN 'Delivery'
WHEN T0.TransType = 310000001 then 'Inventory Opening Balance'
WHEN T0.TransType = 67 then 'Inventory Transfer'
WHEN T0.TransType = 21 then 'Goods Return'
WHEN T0.TransType = 18 then 'A/P Invoice'
WHEN T0.TransType = 19 then 'A/P Credit Memo'
WHEN T0.TransType = 13 then 'A/R Invoice'
WHEN T0.TransType = 162 then 'Inventory Reevaluation'
WHEN T0.TransType = 59 then 'Goods Receipt'
WHEN T0.TransType = 60 then 'Goods Issue'
WHEN T0.TransType = 20 then 'GRPO'
WHEN T0.TransType = 14 then 'A/R Credit Memo'
END AS TransactionType,
T0.BASE_REF AS BaseDocument,
T0.DocLineNum,
-- SUM(isnull(T0.sumStock,0)) OVER (PARTITION BY T1.ITEMCODE ORDER BY T1.ITEMNAME, t0.TransSeq, T0.LocCode, T0.DocDate ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )  as BalancePHP,
-- T0.SumStock,

T0.DOCDATE AS Date,
T0.Itemcode as 'Product Code',
T1.ItemName as 'Product Name',
CASE WHEN EvalSystem='A' THEN 'Moving Average'
    WHEN EvalSystem='S' THEN 'Standard'
    WHEN EvalSystem='F' THEN 'FIFO'
END
AS EvalSystem,
T0.Comments as Description,
CONCAT(
CASE WHEN T0.TRANSTYPE = 69 THEN 'IF-'
WHEN T0.TransType = 15 THEN 'DN-'
WHEN T0.TransType = 310000001 then 'OB-'
WHEN T0.TransType = 67 then 'IM-'
WHEN T0.TransType = 21 then 'PR-'
WHEN T0.TransType = 18 then 'PU-'
WHEN T0.TransType = 19 then 'PC-'
WHEN T0.TransType = 13 then 'IN-'
WHEN T0.TransType = 162 then 'MR-'
WHEN T0.TransType = 59 then 'SI-'
WHEN T0.TransType = 60 then 'SO-'
WHEN T0.TransType = 20 then 'PD-'
WHEN T0.TransType = 14 then 'CN-' end
,
REPLICATE('0', 7 - LEN(T0.BASE_REF)) + CAST(T0.BASE_REF AS varchar) ) AS Reference,


T0.Warehouse AS Warehouse,
CASE WHEN T0.InQty > 0 THEN
T0.InQty
ELSE
T0.OutQty * -1
END AS Quantity,

T2.UomCode,
CAST(T0.CalcPrice AS MONEY) as 'PHP Unit Price',

TRANSVALUE as 'PHP Amount',

CASE WHEN @Warehouse='' 
    THEN
        ISNULL((SELECT SUM(isnull(InQty,0)) - SUM(isnull(outQty,0))  
        FROM OINM WHERE ItemCode=T0.ItemCode  AND TaxDate<=DATEADD(DAY, -1, @PERIODFROM) )
        ,0)
        +
        SUM(isnull(t0.InQty,0) - isnull(t0.outQty,0)) OVER 
        (PARTITION BY T1.ITEMCODE ORDER BY T1.ITEMNAME,  t0.TransSeq, T0.TAXDATE ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )   
    ELSE 
        ISNULL((SELECT SUM(isnull(InQty,0)) - SUM(isnull(outQty,0))  
        FROM OINM WHERE ItemCode=T0.ItemCode AND Warehouse=T0.Warehouse AND TaxDate<=DATEADD(DAY, -1, @PERIODFROM) )
        ,0)
        +
        SUM(isnull(t0.InQty,0) - isnull(t0.outQty,0)) OVER 
        (PARTITION BY T1.ITEMCODE ORDER BY T1.ITEMNAME,  t0.TransSeq, T0.WAREHOUSE, T0.TAXDATE ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)   
END 
AS 'Balance Quantity',

-- TransValue,

-- (SELECT (sum(TransValue))
-- FROM OINM A where A.ItemCode=T0.ItemCode and Warehouse=T0.Warehouse and A.TaxDate <=T0.TaxDate) AS PREVAL,

-- SUM(TRANSVALUE) OVER (PARTITION BY T1.ITEMCODE ORDER BY T1.ITEMNAME,  t0.TransSeq, T0.WAREHOUSE, T0.TAXDATE ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) 
-- AS BALNOW,

CASE WHEN @Warehouse='' 
    THEN
        ISNULL((SELECT (sum(TransValue))
        FROM OINM A where A.ItemCode=T0.ItemCode and A.TaxDate <@PERIODFROM),0)
        +
        SUM(TRANSVALUE) OVER (PARTITION BY T1.ITEMCODE ORDER BY T1.ITEMNAME,  t0.TransSeq, T0.TAXDATE ASC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) 

    ELSE 
        ISNULL((SELECT (sum(TransValue))
        FROM OINM A where A.ItemCode=T0.ItemCode and Warehouse=T0.Warehouse and A.TaxDate <@PERIODFROM),0)
        +
        (SELECT SUM(TRANSVALUE) FROM OINM B WHERE B.ITEMCODE=T0.ITEMCODE AND B.TAXDATE BETWEEN @PERIODFROM AND T0.TaxDate)
        -- SUM(TRANSVALUE) OVER (PARTITION BY T1.ITEMCODE ORDER BY T1.ITEMNAME,  t0.TransSeq, T0.WAREHOUSE, T0.TAXDATE ASC 
        -- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) 
        
END 
AS 'Balance Amount'


FROM OINM T0
INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
INNER JOIN OUOM T2 ON T1.InvntryUom = T2.UomName
-- INNER JOIN OITB T3 ON T3.ItmsGrpCod=t1.ItmsGrpCod
WHERE T1.ItemCode LIKE '%'+@ITEM+'%'
AND T0.TaxDate BETWEEN @PERIODFROM AND @PERIODTO
-- AND REPLACE(T0.Warehouse,'KORKM2','KOROST') LIKE '%'+@Warehouse+'%'
AND T0.Warehouse LIKE '%'+@Warehouse+'%'
AND T1.InvntItem='Y'

AND t0.TransValue <>0


ORDER by Warehouse,T0.ItemCode,T0.TaxDate ,TransSeq

