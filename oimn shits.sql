



DECLARE @ITM VARCHAR(50)='',
@PERIODFROM DATE='2023-01-01',
@PERIODTO DATE='2023-08-29',
@STR VARCHAR(50)='KORATPGS'


select ItemCode,(SELECT TOP 1 ItemName FROM OITM WHERE ItemCode=XX.ItemCode) AS 'Description',SUM(InvoiceTotalQty) as 'Invoice Total Qty',
SUM(InvoiceTotalAmount) as 'Invoice Total Amount'



,ISNULL(ABS((select SUM(InQty)-SUM(OutQty) from(
select ItemCode,InQty,OutQty
from OINM where ItemCode=xx.ItemCode
and replace(Warehouse,'KORKM2GS','KOROSTGS') =@STR and TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) and DATEADD(DAY, -1, @PERIODFROM)
)dd WHERE ItemCode=XX.ItemCode GROUP BY ItemCode)),sum(OpeningQty)) 
as 'OpenQty'


,ISNULL((select top 1 Balance
from OINM 
where ItemCode=xx.ItemCode
and replace(Warehouse,'KORKM2GS','KOROSTGS') =@STR 
and TaxDate BETWEEN  DATEADD(YEAR, -1, @PERIODFROM) and DATEADD(DAY, -1, @PERIODFROM)
ORDER by TaxDate desc),sum(OpeningAmount)) 
as 'OpenAmount'
, 

ABS((select SUM(InQty)-SUM(OutQty) from(
select ItemCode,InQty,OutQty
from OINM where ItemCode=xx.ItemCode
and replace(Warehouse,'KORKM2GS','KOROSTGS') =@STR and TaxDate BETWEEN @PERIODFROM and @PERIODTO
)dd WHERE ItemCode=XX.ItemCode GROUP BY ItemCode) )
as 'ClosingQty',

(select top 1 Balance
from OINM 
where ItemCode=xx.ItemCode
and replace(Warehouse,'KORKM2GS','KOROSTGS') =@STR 
and TaxDate BETWEEN @PERIODFROM and @PERIODTO
ORDER by TaxDate desc) 
as 'ClosingAmount'

,SUM(InvoiceTotalQty) /
NULLIF((

(ISNULL(ABS((select SUM(InQty)-SUM(OutQty) from(
select ItemCode,InQty,OutQty
from OINM where ItemCode=xx.ItemCode
and replace(Warehouse,'KORKM2GS','KOROSTGS') =@STR and TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) and DATEADD(DAY, -1, @PERIODFROM)
)dd WHERE ItemCode=XX.ItemCode GROUP BY ItemCode)),sum(OpeningQty))
+
ABS((select SUM(InQty)-SUM(OutQty) from(
select ItemCode,InQty,OutQty
from OINM where ItemCode=xx.ItemCode
and replace(Warehouse,'KORKM2GS','KOROSTGS') =@STR and TaxDate BETWEEN @PERIODFROM and @PERIODTO
)dd WHERE ItemCode=XX.ItemCode GROUP BY ItemCode) )
  )/2) ,0)
AS'TurnOverQty'

,SUM(InvoiceTotalAmount)/
NULLIF(((ISNULL((select top 1 Balance
from OINM 
where ItemCode=xx.ItemCode
and replace(Warehouse,'KORKM2GS','KOROSTGS') =@STR 
and TaxDate BETWEEN  DATEADD(YEAR, -1, @PERIODFROM) and DATEADD(DAY, -1, @PERIODFROM)
ORDER by TaxDate desc),sum(OpeningAmount))+
(select top 1 Balance
from OINM 
where ItemCode=xx.ItemCode
and replace(Warehouse,'KORKM2GS','KOROSTGS') =@STR 
and TaxDate BETWEEN @PERIODFROM and @PERIODTO
ORDER by TaxDate desc)
  )/2),0)
AS'TurnOverAmount'

from(

select ItemCode,OutQty-(ISNULL((SELECT Quantity FROM RIN1 WHERE BASETYPE =OINM.TransType AND BASEENTRY=OINM.BASE_REF AND ItemCode=OINM.ItemCode),0)+
+
ISNULL((SELECT Quantity FROM INV1 A1 INNER JOIN OINV TT ON TT.DocNum=A1.DOCENTRY WHERE A1.BASETYPE =OINM.TransType AND A1.DocEntry=OINM.BASE_REF AND ItemCode=OINM.ItemCode AND TT.CANCELED<>'N'),0)
)  as 'InvoiceTotalQty'
,OutQty*Price as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount'
from OINM 
where ItemCode LIKE '%'+@ITM+'%'
and replace(Warehouse,'KORKM2GS','KOROSTGS') =@STR 
and TransType IN(13,15,60) and TaxDate BETWEEN @PERIODFROM and @PERIODTO

union all 

select ItemCode,0 as 'InvoiceTotalQty',0 as 'InvoiceTotalAmount',InQty as 'OpeningQty',Balance as  'OpeningAmount'
from OINM 
where ItemCode LIKE '%'+@ITM+'%'
and replace(Warehouse,'KORKM2GS','KOROSTGS') =@STR 
and TransType =310000001 and TaxDate BETWEEN DATEADD(YEAR,-1,@PERIODFROM) and @PERIODTO

union all 

select ItemCode,0 as 'InvoiceTotalQty',0 as 'InvoiceTotalAmount',0 as 'OpeningQty',0 as  'OpeningAmount'
from OINM 
where ItemCode LIKE '%'+@ITM+'%'
and Warehouse=@STR 
and TransType =20 and TaxDate BETWEEN DATEADD(YEAR,-1,@PERIODFROM) and @PERIODTO

)XX
GROUP BY ItemCode
