
Declare @DateFrom date ={?dateFrom} , @DateTo Date={?dateTo} , @Store Varchar(20) ='{?Store}', @Branch Varchar(20) ='{?Branch}'
-- Declare @DateFrom date ='11-02-2022' , @DateTo Date='11-02-2022' , @Store Varchar(20) ='KOR_OST', @Branch Varchar(20) ='K'

SELECT DISTINCT  *  FROM
(SELECT DISTINCT
T0.taxdate AS 'TransDate',
t0.docentry as TNUM,
CASE WHEN T0.ISINS = 'Y' THEN 
CONCAT('RES-',T0.DocEntry) 
ELSE
CONCAT('IN-',T0.DocEntry) END AS 'TransNum',
T0.NumAtCard AS 'Refnum',
T2.OcrCode AS 'Store_Performance', 
T0.CardCode AS 'CardCode',
T0.CardName AS 'Customer',
T0.U_ADDRESS AS Address,
T3.ADDRESS AS ADDRS,
T1.LicTradNum AS 'TIN',
T0.max1099 / 1.12 AS 'VAT-Ex',
T0.max1099 - (Max1099/1.12) AS 'VAT',
T0.max1099 AS 'VAT-Inc',
CONCAT(T0.Comments,(SELECT TOP 1 CONCAT('(',U_ReasonCancelCode,')') FROM OINV T INNER JOIN INV1 Y ON Y.DocEntry=T.DocNum WHERE CANCELED='C' AND Y.BaseEntry=T0.DocNum)) AS 'Comments',
T0.U_DOCSeries AS 'DocSeries',
T1.GROUPCODE,
NULL  AS BaseEntry,
 T0.CANCELED,
IIF((select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode) IS NULL,T2.OcrCode,(select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode)) AS 'ZZ'
FROM OINV T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN INV1 T2 ON T0.DocNum = T2.DocEntry
INNER JOIN OBPL T3 ON T0.BPLID=T3.BPLID
WHERE T0.U_DocSeries NOT LIKE '%OB%' AND T0.CANCELED <> 'C'  
AND T0.taxdate >=@DateFrom AND T0.taxdate <= @DateTo
-- AND T2.OcrCode LIKE '%'+@Store+'%' 
AND T3.BPLName LIKE '%'+@Branch+'%' AND T3.BPLName NOT LIKE '%DC%'

UNION ALL
SELECT DISTINCT
T0.taxdate AS 'TransDate',
t0.docentry as TNUM,
CONCAT('CM-',T0.DocEntry)  AS 'TransNum',
T0.NumAtCard AS 'Refnum',
T2.OcrCode AS 'Store_Performance',
T0.CardCode AS 'CardCode',
T0.CardName AS 'Customer',
T0.U_ADDRESS AS Address,
T3.ADDRESS AS ADDRS,
T1.LicTradNum AS 'TIN',
(T0.Max1099 / 1.12) * -1 AS 'VAT-Ex',
(T0.max1099 - (T0.Max1099/1.12)) *-1 AS 'VAT',
T0.max1099 * -1 AS 'VAT-Inc',
CONCAT(T0.Comments,(SELECT TOP 1 CONCAT('(',U_ReasonCancelCode,')') FROM orin T INNER JOIN rin1 Y ON Y.DocEntry=T.DocNum WHERE CANCELED='C' AND Y.BaseEntry=T0.DocNum)) AS 'Comments',
T0.U_DOCSeries AS 'DocSeries',
T1.GROUPCODE,
T2.BaseEntry AS BaseEntry,
T0.CANCELED,
IIF((select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode) IS NULL,T2.OcrCode,(select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode)) AS 'ZZ'
FROM orin T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN RIN1 T2 ON T0.DocNum = T2.DocEntry
INNER JOIN OBPL T3 ON T0.BPLID=T3.BPLID
WHERE T0.U_DocSeries NOT LIKE '%OB%' AND T0.CANCELED <> 'C' 
AND T0.taxdate >=@DateFrom AND T0.taxdate <= @DateTo
-- AND T2.OcrCode LIKE '%'+@Store+'%'
AND T3.BPLName LIKE '%'+@Branch+'%' AND T3.BPLName NOT LIKE '%DC%' 
AND T2.BaseEntry NOT IN (SELECT DISTINCT DOCNUM FROM ODPI T INNER JOIN RIN1 TT ON T.DocNum=TT.BaseEntry)

) 
Esales
WHERE ZZ LIKE '%'+@Store+'%'
ORDER BY TNUM ASC

