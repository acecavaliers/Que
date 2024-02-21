





DECLARE 
 @dt as varchar(1) ='D'
,@DateFrom DATE='2023-01-01'
,@Dateto date= '2023-12-31'
,@Branch Varchar(50) = 'ALL BRANCH'
,@STR Varchar(10) = ''

set @branch = replace((@branch),'ALL BRANCH','')



SELECT X.*,ACCTNAME FROM (
SELECT DISTINCT
WhsCode,
T0.DOCDATE AS 'Posting Date',
T0.TAXDATE AS 'Document Date',
T1.LicTradNum AS 'Vendor TIN',
T0.CARDCODE AS 'Vendor Code',
T0.CARDNAME AS 'Vendor Name',
T0.Comments as 'Description/Particular',
T0.DOCNUM AS 'Reference #', 
IIF(T0.CANCELED<>'C',T0.DocTotal,T0.DocTotal*-1) as 'PHP Amount',
IIF(T0.CANCELED<>'C',T0.WTSUM,T0.WTSUM*-1) as 'PHP WTax Amount',
IIF(T0.CANCELED<>'C',T0.VATSUM,T0.VATSUM*-1) as 'PHP VAT Amount',
IIF(T0.CANCELED<>'C',T0.DiscSum,T0.DiscSum*-1) as 'PHP Discount',
IIF(T0.CANCELED<>'C',T0.DocTotal-T0.VATSUM + T0.WTSUM,(T0.DocTotal-T0.VATSUM + T0.WTSUM)*-1) as 'PHP Purchases',
-- T0.WTSUM AS '',
-- T0.VATSUM AS 'PHP ',
-- T0.DiscSum AS 'PHP ',
-- T0.DocTotal-T0.VATSUM + T0.WTSUM AS 'PHP ',
T2.BASETYPE,
T0.BPLNAME,
T0.CtlAccount,
T2.VatGroup
FROM ORPC T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE 
INNER JOIN RPC1 T2 ON T0.DOCNUM = T2.DOCENTRY 
INNER JOIN OITM A1 ON T2.ItemCode=A1.ItemCode
INNER JOIN OITB A2 ON A2.ItmsGrpCod=A1.ItmsGrpCod
WHERE  
T0.DocType='I'
AND A1.ItmsGrpCod NOT IN(100,123,125,126,127,129)
AND T0.BPLName like  '%'+@Branch+'%'
-- AND T2.WhsCode like  '%'+@STR+'%'
) x
INNER JOIN OACT T5 ON T5.AcctCode=x.ctlaccount
WHERE 
case when @dt='d'
then x.[Document Date] 
WHEN @dt ='p'
then x.[Posting Date]
END BETWEEN @DateFrom AND @Dateto

ORDER BY 
case when @dt='d'
then x.[Document Date] 
WHEN @dt ='p'
then x.[Posting Date]
END  ASC


