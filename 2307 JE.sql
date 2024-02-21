DECLARE @QTR INT=4 ,@GRP INT =0, @ATC varchar= '' , @WTCOMCODE varchar(50)='C00004920221117-1'
SELECT  
ISNULL(T0.U_wTaxComCode,T3.U_wTaxComCode) AS 'U_wTaxComCode',
T3.DOCNUM,'01' as WTaxDayFrom,
'n/A' AS 'U_WTax',
T0.TaxDate, 
0 AS 'DocTotal', (Select CompnyName from OADM) AS 'Payor',
ProfitCode AS 'ocrcode',
CASE
    WHEN  month(t0.taxdate) IN (1,2,3) THEN '01'
    WHEN  month(t0.taxdate) IN (4,5,6) THEN '04'
    WHEN  month(t0.taxdate) IN (7,8,9) THEN '07'
    WHEN  month(t0.taxdate) IN (10,11,12) THEN '10'
    ELSE 'N/A' END AS WtaxMonthFrom,
CONVERT(varchar(10), year(T0.taxdate))  as 'WtaxYearFrom',
CASE
    WHEN  month(t0.taxdate) IN (1,2,3) THEN '03'
    WHEN  month(t0.taxdate) IN (4,5,6) THEN '06'
    WHEN   month(t0.taxdate) IN (7,8,9) THEN '09'
    WHEN  month(t0.taxdate) IN (10,11,12) THEN '12'
    ELSE 'N/A'  END AS WtaxMonthTo,
CONVERT(varchar(10), DAY(EOMONTH(
CASE
    WHEN  month(t0.taxdate) IN (1,2,3) THEN '2020-03-20 00:00:00.000'
    WHEN  month(t0.taxdate) IN (4,5,6) THEN '2020-06-20 00:00:00.000'
    WHEN  month(t0.taxdate) IN (7,8,9) THEN '2020-09-20 00:00:00.000'
    WHEN  month(t0.taxdate) IN (10,11,12) THEN '2020-12-20 00:00:00.000'
    ELSE 'N/A' END))) as WTaxDayTo,

CONVERT(varchar(10), year(t0.taxdate))  as 'WtaxYearTo',
T4.CardName,
LEFT(T4.LicTradNum, 3)
 As 'P1stTIN',
SUBSTRING(T4.LicTradNum,5,3)  
 As 'P2ndTIN',
SUBSTRING(T4.LicTradNum,9,3) 
 As 'P3rdTIN',
SUBSTRING(T4.LicTradNum,13,3) 
 As 'P4thTIN',
    UPPER((SELECT DISTINCT CONCAT(CAST(Building AS varchar(max)),
    (CASE WHEN Building IS NULL THEN '' ELSE ', ' END),Address2,(CASE WHEN Address2 IS NULL THEN '' ELSE ', ' END),Address3,(CASE WHEN Address3 IS NULL THEN '' ELSE ', ' END), 
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END), StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],
    (CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) 
    FROM CRD1 WHERE CardCode = t4.CardCode AND AdresType = 'B')) 
AS 'Payee Address',
(SELECT DISTINCT ZipCode FROM CRD1 WHERE CardCode = T4.CardCode AND AdresType = 'B') 
AS 'PayeeZipCode',
T2.TaxbleAmnt AS 'TaxbleAmnt',
T2.WTAmnt AS 'WTAmnt',
(Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=T0.ProfitCode) AS 'PY1stTIN',
(Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=T0.ProfitCode) AS 'PY2ndTIN',
(Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=T0.ProfitCode) AS 'PY3ndTIN',
(Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=T0.ProfitCode) AS 'PY4thTIN',
ISNULL ((select TOP 1 
UPPER( CONCAT(CAST(Building AS varchar(max)),iif(Building IS NULL ,'',', '),
Street,iif(Street IS NULL ,'',', '),StreetNo,iif(StreetNo IS NULL ,'',', '),
[Block],iif([Block] IS NULL ,'',', '), City,iif(City IS NULL ,'',' ')) )
from owhs INNER JOIN PCH1 ON PCH1.WhsCode=OWHS.U_WhseExt AND PCH1.DocEntry=T0.DocNum ), 
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),iif(Building IS NULL ,'',', '),
        Street,iif(Street IS NULL ,'',', '),StreetNo,iif(StreetNo IS NULL ,'',', '),
        [Block],iif([Block] IS NULL ,'',', '), City,iif(City IS NULL ,'',' ')) 
        FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum) )) )
AS 'PayorAddress',
(SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=T0.ProfitCode)
    AS 'PayorZipCode',
(SELECT TI.U_ATC FROM OWHT TI WHERE  TI.WTCode = T2.WTCode ) AS 'ATC',

(SELECT COUNT(DocNum) FROM  RCT2 A0 WHERE DocNum = T3.DOCNUM) AS 'ROWS'


FROM JDT1 T0 
INNER JOIN JDT2 T2 ON T0.TransId=T2.AbsEntry
INNER JOIN RCT2 T3 ON T0.TransId= T3.Docentry AND T3.InvType=30
INNER JOIN OCRD T4 ON T0.ContraAct=T4.CardCode
where
ISNULL(T0.U_wTaxComCode,T3.U_wTaxComCode)=@WTCOMCODE



-- SELECT * FROM JDT2 WHERE Account= 'CA060-1000-0000' AND TaxbleAmnt = 3185
-- SELECT * FROM JDT1 WHERE TransId = 4664