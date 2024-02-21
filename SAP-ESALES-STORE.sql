
-- Declare @DateFrom date ='11-01-2021' , @DateTo Date='12-31-2022'  , @Store Varchar(20) ='{?Store}', @Branch Varchar(20) ='{?Branch}'

Declare @DateFrom date ={?dateFrom} , @DateTo Date={?dateTo} , @Store Varchar(20) ='', @Branch Varchar(20) ='',@S1 VARCHAR (10)='{?Store}',

 @USER VARCHAR(50), @IP VARCHAR(50)=(select CAST(CONNECTIONPROPERTY('client_net_address') AS VARCHAR(50)))

SET @USER =(SELECT top 1 UserCode FROM USR5 Where ClientIP = @IP order by [Date] desc, [Time] DESC)
set @Store= 
    CASE WHEN RIGHT(@USER,2) like '%SS%' THEN 
    (SELECT TOP 1 Address3 FROM OWHS WHERE WhsCode LIKE ''+ left(@USER,6)+'%')
    else @S1 END
SET @Branch= 
    CASE WHEN RIGHT(@USER,2) like '%BM%' AND @S1='' THEN 
    (SELECT TOP 1 concat(BPLid,'') FROM OWHS WHERE WhsCode LIKE ''+ left(@USER,3)+'%')
    else '' END 


SELECT DISTINCT  * FROM
(SELECT DISTINCT
T0.DocDate AS 'TransDate',
t0.docentry as TNUM,
CASE WHEN T0.ISINS = 'Y' THEN 
CONCAT('RES-',T0.DocEntry) 
ELSE
CONCAT('IN-',T0.DocEntry) END AS 'TransNum',
T0.NumAtCard AS 'Refnum',
T2.OcrCode AS 'Store Performance',
T0.CardCode AS 'CardCode',
T0.CardName AS 'Customer',
T0.U_ADDRESS AS Address,
T3.ADDRESS AS ADDRS,
T1.LicTradNum AS 'TIN',
T0.max1099 / 1.12 AS 'VAT-Ex',
T0.max1099 - (Max1099/1.12) AS 'VAT',
T0.max1099 AS 'VAT-Inc',
T0.Comments AS 'Comments',
T0.U_DOCSeries AS 'DocSeries',
T1.GROUPCODE,
NULL  AS BaseEntry
FROM OINV T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN INV1 T2 ON T0.DocNum = T2.DocEntry
INNER JOIN OBPL T3 ON T0.BPLID=T3.BPLID
WHERE T0.U_DocSeries NOT LIKE '%OB%' AND T0.CANCELED = 'N'  
AND T0.DocDate >=@DateFrom AND T0.DocDate <= @DateTo
AND T2.OcrCode LIKE '%'+@Store+'%' AND T3.BPLId LIKE '%'+@Branch+'%' AND T3.BPLName NOT LIKE '%DC%'

UNION ALL
SELECT DISTINCT
T0.DocDate AS 'TransDate',
t0.docentry as TNUM,
CONCAT('CM-',T0.DocEntry)  AS 'TransNum',
T0.NumAtCard AS 'Refnum',
T2.OcrCode AS 'Store Performance',
T0.CardCode AS 'CardCode',
T0.CardName AS 'Customer',
T0.U_ADDRESS AS Address,
T3.ADDRESS AS ADDRS,
T1.LicTradNum AS 'TIN',
(T0.Max1099 / 1.12) * -1 AS 'VAT-Ex',
(T0.max1099 - (T0.Max1099/1.12)) *-1 AS 'VAT',
T0.max1099 * -1 AS 'VAT-Inc',
T0.Comments AS 'Comments',
T0.U_DOCSeries AS 'DocSeries',
T1.GROUPCODE,
T2.BaseEntry AS BaseEntry
FROM orin T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN RIN1 T2 ON T0.DocNum = T2.DocEntry
INNER JOIN OBPL T3 ON T0.BPLID=T3.BPLID
WHERE T0.U_DocSeries NOT LIKE '%OB%' AND T0.CANCELED = 'N' 
AND T0.DocDate >=@DateFrom AND T0.DocDate <= @DateTo
AND T2.OcrCode LIKE '%'+@Store+'%' AND T3.BPLID LIKE '%'+@Branch+'%' AND T3.BPLName NOT LIKE '%DC%' 
AND T2.BaseEntry NOT IN (SELECT DISTINCT DOCNUM FROM ODPI T INNER JOIN RIN1 TT ON T.DocNum=TT.BaseEntry)

-- UNION ALL 

-- SELECT DISTINCT
-- T0.DocDate AS 'TransDate',
-- t0.docentry as TNUM,
-- CONCAT('CM-',T0.DocEntry) AS 'TransNum',
-- T0.NumAtCard AS 'Refnum',
-- T2.OcrCode AS 'Store Performance',
-- T0.CardCode AS 'CardCode',
-- T0.CardName AS 'Customer',
-- T0.U_ADDRESS AS Address,
-- T3.ADDRESS AS ADDRS,
-- T1.LicTradNum AS 'TIN',
-- (T0.Max1099 / 1.12) * -1 AS 'VAT-Ex',
-- (T0.max1099 - (Max1099/1.12)) *-1 AS 'VAT',
-- T0.max1099 * -1 AS 'VAT-Inc',
-- T0.Comments AS 'Comments',
-- T0.U_DOCSeries AS 'DocSeries',
-- T1.GROUPCODE,
-- NULL  AS BaseEntry
-- FROM orin T0
-- INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
-- INNER JOIN DPI1 T2 ON T0.DocNum = T2.DocEntry
-- INNER JOIN OBPL T3 ON T0.BPLID=T3.BPLID
-- WHERE T0.U_DocSeries NOT LIKE '%OB%' AND T0.CANCELED = 'N'  
-- AND T0.DocDate >=@DateFrom AND T0.DocDate <= @DateTo
-- AND T2.OcrCode LIKE '%'+@Store+'%' AND T3.BPLName LIKE '%'+@Branch+'%' AND T3.BPLName NOT LIKE '%DC%'

) 
Esales

ORDER BY TNUM ASC



