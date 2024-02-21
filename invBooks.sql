
DECLARE
@PERIODFROM DATE='2023-06-01', 
@PERIODTO DATE='2023-12-31',
@ITEM VARCHAR(100)='',
@Warehouse VARCHAR(50)='GSCDCCGS'


SET @Warehouse = replace((@Warehouse),'ALL WAREHOUSE','')

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


(SELECT SUM(isnull(InQty,0)) - SUM(isnull(outQty,0))  FROM OINM WHERE ItemCode=T0.ItemCode AND Warehouse=T0.Warehouse AND TaxDate<=DATEADD(DAY, -1, @PERIODFROM) )

+
SUM(isnull(t0.InQty,0) - isnull(t0.outQty,0)) OVER (PARTITION BY T1.ITEMCODE ORDER BY T1.ITEMNAME,  t0.TransSeq, T0.WAREHOUSE, T0.TAXDATE ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )   
as 'Balance Quantity',

((SELECT SUM(isnull(InQty,0)) - SUM(isnull(outQty,0))  FROM OINM WHERE ItemCode=T0.ItemCode AND Warehouse=T0.Warehouse AND TaxDate<=DATEADD(DAY, -1, @PERIODFROM) )

+
SUM(isnull(t0.InQty,0) - isnull(t0.outQty,0)) OVER (PARTITION BY T1.ITEMCODE ORDER BY T1.ITEMNAME,  t0.TransSeq, T0.WAREHOUSE, T0.TAXDATE ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) )*  T0.CalcPrice
as 'Balance Amount'


FROM OINM T0
INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
INNER JOIN OUOM T2 ON T1.InvntryUom = T2.UomName
WHERE T1.ItemName LIKE '%'+@ITEM+'%'
AND T0.TaxDate BETWEEN @PERIODFROM AND @PERIODTO
AND T0.Warehouse=@Warehouse

-- SELECT * FROM OINM WHERE ItemCode='0000157SBAGB' AND Warehouse='GSCDCCGS' AND TaxDate BETWEEN '2023-01-01' AND '2023-12-31'

-- SELECT * FROM OIVL WHERE ItemCode='0006697HWFAN'