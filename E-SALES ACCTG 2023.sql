




Declare  @DateFrom date={?dateFrom}, @DateTo date={?dateTo}

-- Declare  @Store Varchar(20) ='DCC', @DateFrom date='2023-05-01', @DateTo date='2023-07-07'
SELECT * FROM
(SELECT DISTINCT
T0.ObjType,
T0.DocNum,
T0.taxdate AS 'TransDate',
t0.docentry as TNUM,
CASE WHEN T0.ISINS = 'Y' THEN 
CONCAT('RES-',T0.DocEntry) 
ELSE
CONCAT('IN-',T0.DocEntry) END AS 'TransNum',
--(SELECT CASE WHEN (T0.NumAtCard) IS NULL THEN T0.U_DocSeries END) AS 'Refnum',
T0.U_DocSeries AS 'Refnum',
T2.OcrCode AS 'Store Performance',
T0.CardCode AS 'CardCode',
t0.CardName AS Customer,
T0.U_Customer as UCustomer,
(Select case when (t0.Address) is null THEN T3.Address else t0.Address end ) as Address,
T1.LicTradNum AS 'TIN',
T0.max1099 / 1.12 AS 'VAT-Ex',
T0.max1099 - (Max1099/1.12) AS 'VAT',
T0.max1099 AS 'VAT-Inc',
CONCAT(T0.Comments,(SELECT TOP 1 CONCAT('(',U_ReasonCancelCode,')') FROM OINV T INNER JOIN INV1 Y ON Y.DocEntry=T.DocNum WHERE CANCELED='C' AND Y.BaseEntry=T0.DocNum)) AS 'Comments',
IIF((select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode) IS NULL,T2.OcrCode,(select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode)) AS 'ZZ',
T0.U_DOCSeries AS 'DocSeries',
T0.CANCELED,
T2.OcrCode
FROM OINV T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN INV1 T2 ON T0.DocNum = T2.DocEntry
INNER JOIN OBPL T3 ON T3.BPLId = T0.BPLId
WHERE T0.U_DocSeries NOT LIKE '%OB%' AND T0.CANCELED <> 'C' AND cast(T0.taxdate as date)  between @DateFrom AND  @DateTo
-- AND T2.OcrCode LIKE '%{?Store}%'

UNION ALL

SELECT DISTINCT
T0.ObjType,
T0.DocNum,
T0.taxdate AS 'TransDate',
t0.docentry as TNUM,
CONCAT('CM-',T0.DocEntry)  AS 'TransNum',
(SELECT CASE WHEN (T0.NumAtCard) IS NULL THEN T0.U_DocSeries END) AS 'Refnum',
T2.OcrCode AS 'Store Performance',
T0.CardCode AS 'CardCode',
t0.CardName AS Customer,
T0.U_Customer as UCustomer,
(Select case when (t0.Address) is null THEN T3.Address else t0.Address end ) as Address,
T1.LicTradNum AS 'TIN',
(T0.Max1099 / 1.12) * -1 AS 'VAT-Ex',
(T0.max1099 - (Max1099/1.12)) *-1 AS 'VAT',
T0.max1099 * -1 AS 'VAT-Inc',
CONCAT(T0.Comments,(SELECT TOP 1 CONCAT('(',U_ReasonCancelCode,')') FROM ORIN T INNER JOIN RIN1 Y ON Y.DocEntry=T.DocNum WHERE CANCELED='C' AND Y.BaseEntry=T0.DocNum)) AS 'Comments',
IIF((select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode) IS NULL,T2.OcrCode,(select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode)) AS 'ZZ',
T0.U_DOCSeries AS 'DocSeries',
T0.CANCELED,
T2.OcrCode
FROM orin T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN RIN1 T2 ON T0.DocNum = T2.DocEntry
INNER JOIN OBPL T3 ON T3.BPLId = T0.BPLId
WHERE T0.U_DocSeries NOT LIKE '%OB%' AND T0.CANCELED <> 'C' AND cast(T0.taxdate as date)  between @DateFrom AND @DateTo
AND T2.BaseEntry NOT IN (SELECT DISTINCT DOCNUM FROM ODPI T INNER JOIN RIN1 TT ON T.DocNum=TT.BaseEntry and TT.BaseType=203)
-- AND T2.OcrCode LIKE '%{?Store}%'

-- UNION ALL --ardpi

-- SELECT DISTINCT
-- T0.ObjType,
-- T0.DocNum,
-- T0.taxdate AS 'TransDate',
-- t0.docentry as TNUM,
-- CONCAT('ARDPI-',T0.DocEntry) AS 'TransNum',
-- (SELECT CASE WHEN (T0.NumAtCard) IS NULL THEN T0.U_DocSeries END) AS 'Refnum',
-- T2.OcrCode AS 'Store Performance',
-- T0.CardCode AS 'CardCode',
-- t0.CardName AS Customer,
-- T0.U_Customer as UCustomer,
-- (Select case when (t0.Address) is null THEN T3.Address else t0.Address end ) as Address,
-- T1.LicTradNum AS 'TIN',
-- (T0.Max1099 / 1.12) * -1 AS 'VAT-Ex',
-- (T0.max1099 - (Max1099/1.12)) *-1 AS 'VAT',
-- T0.max1099 * -1 AS 'VAT-Inc',
-- CONCAT(T0.Comments,(SELECT TOP 1 CONCAT('(',U_ReasonCancelCode,')') FROM ODPI T INNER JOIN DPI1 Y ON Y.DocEntry=T.DocNum WHERE CANCELED='C' AND Y.BaseEntry=T0.DocNum)) AS 'Comments',
-- IIF((select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode) IS NULL,T2.OcrCode,(select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode)) AS 'ZZ',
-- T0.U_DOCSeries AS 'DocSeries',
-- T0.CANCELED,
-- T2.OcrCode
-- FROM ODPI T0
-- INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
-- INNER JOIN DPI1 T2 ON T0.DocNum = T2.DocEntry
-- INNER JOIN OBPL T3 ON T3.BPLId = T0.BPLId
-- WHERE T0.U_DocSeries NOT LIKE '%OB%' AND T0.CANCELED <> 'C' AND cast(T0.taxdate as date)  between @DateFrom AND @DateTo
-- -- AND T2.OcrCode LIKE '%{?Store}%'

) 
Esales
-- WHERE ZZ LIKE '%'+@Store+'%'
-- AND U_ReasonCancelCode IS NOT NULL
ORDER BY TNUM ASC

