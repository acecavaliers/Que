
DECLARE @QTR INT= 4 ,@GRP INT =0, @ATC varchar= '' , @APnum  INT = 0, @INV Int =0, @DOCNUM INT =13
-- DECLARE @QTR INT= {?quarter} ,@GRP INT ={?Group}, @ATC varchar(9)= '{?ATC}' , @APnum  INT = {?ApDocNum}, @INV Int ={?InvType}, @DOCNUM INT ={?DocNum}

IF (@APnum  = 0) AND (@INV =0)

SELECT *
from(
--APINV
SELECT 
T3.U_wTaxComCode,T3.DOCNUM,'01' as WTaxDayFrom,
T0.U_WTax,T0.TaxDate, T0.DocTotal, (Select CompnyName from OADM) AS 'Payor',
CASE 
    WHEN T0.DOCTYPE = 'I' THEN (SELECT TOP 1 WhsCode FROM PCH1 WHERE DOCENTRY=T0.DocNum )
    WHEN T0.DOCTYPE = 'S' THEN (SELECT TOP 1 ocrcode FROM PCH1 WHERE DOCENTRY=T0.DocNum )
END AS 'ocrcode',

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

CASE 
    WHEN T0.U_ALIAS_VENDOR IS NULL THEN T0.CardName
    ELSE T0.U_ALIAS_VENDOR
END AS 'Payee',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN LEFT(T0.U_TIN,3)
    ELSE (SELECT LEFT(LicTradNum, 3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P1stTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,5,3)
    ELSE (SELECT SUBSTRING(LicTradNum,5,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode)     
END As 'P2ndTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,9,3)
    ELSE (SELECT SUBSTRING(LicTradNum,9,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P3rdTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,13,3)
    ELSE (SELECT SUBSTRING(LicTradNum,13,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P4thTIN',  
CASE 
    WHEN T0.U_ADDRESS IS NOT NULL THEN T0.U_ADDRESS
    ELSE
    UPPER((SELECT DISTINCT CONCAT(CAST(Building AS varchar(max)),
    (CASE WHEN Building IS NULL THEN '' ELSE ' ' END),Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END), StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],
    (CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) 
    FROM CRD1 WHERE CardCode = t0.CardCode AND AdresType = 'B')) 
END AS 'Payee Address',
CASE 
    WHEN T0.U_ADDRESS IS NOT NULL THEN T0.U_ZIPCODE
    ELSE
    (SELECT DISTINCT ZipCode FROM CRD1 WHERE CardCode = T0.CardCode AND AdresType = 'B') 
END AS 'PayeeZipCode',


CASE 
    WHEN (SELECT COUNT(RATE) FROM PCH5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN (SELECT MAX(TaxbleAmnt) FROM PCH5 WHERE AbsEntry=T3.DocEntry)
    ELSE ISNULL(TaxbleAmnt,T0.DocTotal-T0.VatSum)
END AS 'TaxbleAmnt',

CASE 
    WHEN (SELECT COUNT(RATE) FROM PCH5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN ((T3.SUMAPPLIED/T0.DOCTOTAL)*(SELECT MAX(TaxbleAmnt) FROM PCH5 WHERE AbsEntry=T3.DocEntry)) *(T1.RATE/100)
    ELSE T3.U_WtaxPay
END  AS 'WTAmnt',





CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 Left(FedTaxID,3)
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OWNERCODE)
    ELSE 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                 INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
END AS 'PY1stTIN',

CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 SUBSTRING(FedTaxID,5,3)
        FROM  OWHS A0 
        inner join oudg  A1 on A0.WhsCode=A1.Warehouse
        inner join OUSR A2 on A1.Code=A2.DfltsGroup
        inner join ohem A3 on A2.USERID  =A3.userId
        WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END  AS 'PY2ndTIN',


CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN  (Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 SUBSTRING(FedTaxID,9,3)
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN  (Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END  AS 'PY3ndTIN',


CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN
    (Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN
    (Select TOP 1 SUBSTRING(FedTaxId,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
    INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL THEN 
    (SELECT  TOP 1 SUBSTRING(FedTaxID,13,3)
    FROM  OWHS A0 
    inner join oudg  A1 on A0.WhsCode=A1.Warehouse
    inner join OUSR A2 on A1.Code=A2.DfltsGroup
    inner join ohem A3 on A2.USERID  =A3.userId
    WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN
    (Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN
    (Select TOP 1 SUBSTRING(FedTaxId,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
    INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END AS 'PY4thTIN',



CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum) )) 
    WHEN T0.DOCTYPE = 'S' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(
    SELECT TOP 1 OOCR.U_Whse FROM PCH1 
    INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum) )) END IS NULL 
    THEN

    (SELECT  CONCAT( 
    CASE WHEN  Building IS NULL THEN '' ELSE CONCAT(Building, ', ')  END,
    CASE WHEN  StreetNo IS NULL THEN '' ELSE StreetNo +', ' END,
    CASE WHEN  Block IS NULL THEN '' ELSE Block +', '  END,
    CASE WHEN  City IS NULL THEN '' ELSE City +', '  END,
    CASE WHEN  County IS NULL THEN '' ELSE County +', '  END, 'PHILIPPINES')
    FROM  OWHS A0 
    inner join oudg  A1 on A0.WhsCode=A1.Warehouse
    inner join OUSR A2 on A1.Code=A2.DfltsGroup
    inner join ohem A3 on A2.USERID  =A3.userId
    WHERE A3.code=T0.OwnerCode)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum) )) 
    WHEN T0.DOCTYPE = 'S' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(
    SELECT TOP 1 OOCR.U_Whse FROM PCH1 
    INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum) )) END 
 END AS 'PayorAddress',

CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN  (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT  TOP 1  OOCR.U_Whse FROM PCH1 INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  ZipCode
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OwnerCode)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN   (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN  (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT  TOP 1  OOCR.U_Whse FROM PCH1 
                                 INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) 
    END
END AS 'PayorZipCode',

CASE
    WHEN   month(t0.taxdate) IN (1,2,3) THEN '1'
    WHEN   month(t0.taxdate) IN (4,5,6) THEN '2'
    WHEN   month(t0.taxdate) IN (7,8,9) THEN '3'
    WHEN   month(t0.taxdate) IN (10,11,12) THEN '4'
    ELSE 'N/A'
END AS 'QTR',
t0.docentry as doc,
ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

(SELECT COUNT(A0.DocNum) FROM OPCH A0 
INNER JOIN VPM2 A1 ON A0.Docentry = A1.Docentry
WHERE A1.DocNum = @DOCNUM
AND A0.WTSum>0
AND
(CASE
WHEN month(A0.taxdate) IN (1,2,3) THEN '1'
WHEN month(A0.taxdate) IN (4,5,6) THEN '2'
WHEN month(A0.taxdate) IN (7,8,9) THEN '3'
WHEN month(A0.taxdate) IN (10,11,12) THEN '4'
ELSE 'N/A' END)=@QTR) AS 'ROWS'

FROM OPCH T0 
LEFT JOIN PCH5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN VPM2 T3 ON T0.DOCNUM= T3.Docentry AND T3.InvType=18

WHERE T3.DocNum = @DOCNUM
AND T0.CANCELED='N'

UNION ALL 
--APDPI 


SELECT 
T3.U_wTaxComCode,T3.DOCNUM,'01' as WTaxDayFrom,
T0.U_WTax,T0.TaxDate, T0.DocTotal, (Select CompnyName from OADM) AS 'Payor',
CASE 
    WHEN T0.DOCTYPE = 'I' THEN (SELECT TOP 1 WhsCode FROM PCH1 WHERE DOCENTRY=T0.DocNum )
    WHEN T0.DOCTYPE = 'S' THEN (SELECT TOP 1 OCRCODE FROM PCH1 WHERE DOCENTRY=T0.DocNum )
END AS 'ocrcode',

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

CASE 
    WHEN T0.U_ALIAS_VENDOR IS NULL THEN T0.CardName
    ELSE T0.U_ALIAS_VENDOR
END AS 'Payee',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN LEFT(T0.U_TIN,3)
    ELSE (SELECT LEFT(LicTradNum, 3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P1stTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,5,3)
    ELSE (SELECT SUBSTRING(LicTradNum,5,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode)     
END As 'P2ndTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,9,3)
    ELSE (SELECT SUBSTRING(LicTradNum,9,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P3rdTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,13,3)
    ELSE (SELECT SUBSTRING(LicTradNum,13,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P4thTIN',  
CASE 
    WHEN T0.U_ADDRESS IS NOT NULL THEN T0.U_ADDRESS
    ELSE
    UPPER((SELECT DISTINCT CONCAT(CAST(Building AS varchar(max)),
    (CASE WHEN Building IS NULL THEN '' ELSE ' ' END),Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END), StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],
    (CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) 
    FROM CRD1 WHERE CardCode = t0.CardCode AND AdresType = 'B')) 
END AS 'Payee Address',
CASE 
    WHEN T0.U_ADDRESS IS NOT NULL THEN T0.U_ZIPCODE
    ELSE
    (SELECT DISTINCT ZipCode FROM CRD1 WHERE CardCode = T0.CardCode AND AdresType = 'B') 
END AS 'PayeeZipCode',


CASE 
    WHEN (SELECT COUNT(RATE) FROM DPO5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN (SELECT MAX(TaxbleAmnt) FROM DPO5 WHERE AbsEntry=T3.DocEntry)
    ELSE ISNULL(TaxbleAmnt,T0.DocTotal-T0.VatSum)
END AS 'TaxbleAmnt',

CASE 
    WHEN (SELECT COUNT(RATE) FROM DPO5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN ((T3.SUMAPPLIED/T0.DOCTOTAL)*(SELECT MAX(TaxbleAmnt) FROM DPO5 WHERE AbsEntry=T3.DocEntry)) *(T1.RATE/100)
    ELSE T3.U_WtaxPay
END  AS 'WTAmnt',





CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 Left(FedTaxID,3)
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OWNERCODE)
    ELSE 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                 INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
END AS 'PY1stTIN',

CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 SUBSTRING(FedTaxID,5,3)
        FROM  OWHS A0 
        inner join oudg  A1 on A0.WhsCode=A1.Warehouse
        inner join OUSR A2 on A1.Code=A2.DfltsGroup
        inner join ohem A3 on A2.USERID  =A3.userId
        WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END  AS 'PY2ndTIN',


CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN  (Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 SUBSTRING(FedTaxID,9,3)
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN  (Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END  AS 'PY3ndTIN',


CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN
    (Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN
    (Select TOP 1 SUBSTRING(FedTaxId,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
    INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL THEN 
    (SELECT  TOP 1 SUBSTRING(FedTaxID,13,3)
    FROM  OWHS A0 
    inner join oudg  A1 on A0.WhsCode=A1.Warehouse
    inner join OUSR A2 on A1.Code=A2.DfltsGroup
    inner join ohem A3 on A2.USERID  =A3.userId
    WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN
    (Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN
    (Select TOP 1 SUBSTRING(FedTaxId,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
    INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END AS 'PY4thTIN',



CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum) )) 
    WHEN T0.DOCTYPE = 'S' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(
    SELECT TOP 1 OOCR.U_Whse FROM DPO1 
    INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum) )) END IS NULL 
    THEN

    (SELECT  CONCAT( 
    CASE WHEN  Building IS NULL THEN '' ELSE CONCAT(Building, ', ')  END,
    CASE WHEN  StreetNo IS NULL THEN '' ELSE StreetNo +', ' END,
    CASE WHEN  Block IS NULL THEN '' ELSE Block +', '  END,
    CASE WHEN  City IS NULL THEN '' ELSE City +', '  END,
    CASE WHEN  County IS NULL THEN '' ELSE County +', '  END, 'PHILIPPINES')
    FROM  OWHS A0 
    inner join oudg  A1 on A0.WhsCode=A1.Warehouse
    inner join OUSR A2 on A1.Code=A2.DfltsGroup
    inner join ohem A3 on A2.USERID  =A3.userId
    WHERE A3.code=T0.OwnerCode)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum) )) 
    WHEN T0.DOCTYPE = 'S' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(
    SELECT TOP 1 OOCR.U_Whse FROM DPO1 
    INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum) )) END 
 END AS 'PayorAddress',

CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN  (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT  TOP 1  OOCR.U_Whse FROM DPO1 INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  ZipCode
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OwnerCode)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN   (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN  (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT  TOP 1  OOCR.U_Whse FROM DPO1 
                                 INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) 
    END
END AS 'PayorZipCode',

CASE
    WHEN   month(t0.taxdate) IN (1,2,3) THEN '1'
    WHEN   month(t0.taxdate) IN (4,5,6) THEN '2'
    WHEN   month(t0.taxdate) IN (7,8,9) THEN '3'
    WHEN   month(t0.taxdate) IN (10,11,12) THEN '4'
    ELSE 'N/A'
END AS 'QTR',
t0.docentry as doc,
ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

(SELECT COUNT(A0.DocNum) FROM ODPO A0 
INNER JOIN VPM2 A1 ON A0.Docentry = A1.Docentry
WHERE A1.DocNum = @DOCNUM
AND A0.WTSum>0
AND
(CASE
WHEN month(A0.taxdate) IN (1,2,3) THEN '1'
WHEN month(A0.taxdate) IN (4,5,6) THEN '2'
WHEN month(A0.taxdate) IN (7,8,9) THEN '3'
WHEN month(A0.taxdate) IN (10,11,12) THEN '4'
ELSE 'N/A' END)=@QTR) AS 'ROWS'

FROM ODPO T0 
LEFT JOIN DPO5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN VPM2 T3 ON T0.DOCNUM= T3.Docentry AND T3.InvType=204

WHERE T3.DocNum = @DOCNUM
AND T0.CANCELED='N'

UNION ALL 
--APCM


SELECT 
T3.U_wTaxComCode,T3.DOCNUM,'01' as WTaxDayFrom,
T0.U_WTax,T0.TaxDate, T0.DocTotal, (Select CompnyName from OADM) AS 'Payor',
CASE 
    WHEN T0.DOCTYPE = 'I' THEN (SELECT TOP 1 WhsCode FROM PCH1 WHERE DOCENTRY=T0.DocNum )
    WHEN T0.DOCTYPE = 'S' THEN (SELECT TOP 1 ocrcode FROM PCH1 WHERE DOCENTRY=T0.DocNum )
END AS 'ocrcode',

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

CASE 
    WHEN T0.U_ALIAS_VENDOR IS NULL THEN T0.CardName
    ELSE T0.U_ALIAS_VENDOR
END AS 'Payee',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN LEFT(T0.U_TIN,3)
    ELSE (SELECT LEFT(LicTradNum, 3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P1stTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,5,3)
    ELSE (SELECT SUBSTRING(LicTradNum,5,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode)     
END As 'P2ndTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,9,3)
    ELSE (SELECT SUBSTRING(LicTradNum,9,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P3rdTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,13,3)
    ELSE (SELECT SUBSTRING(LicTradNum,13,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P4thTIN',  
CASE 
    WHEN T0.U_ADDRESS IS NOT NULL THEN T0.U_ADDRESS
    ELSE
    UPPER((SELECT DISTINCT CONCAT(CAST(Building AS varchar(max)),
    (CASE WHEN Building IS NULL THEN '' ELSE ' ' END),Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END), StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],
    (CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) 
    FROM CRD1 WHERE CardCode = t0.CardCode AND AdresType = 'B')) 
END AS 'Payee Address',
CASE 
    WHEN T0.U_ADDRESS IS NOT NULL THEN T0.U_ZIPCODE
    ELSE
    (SELECT DISTINCT ZipCode FROM CRD1 WHERE CardCode = T0.CardCode AND AdresType = 'B') 
END AS 'PayeeZipCode',


CASE 
    WHEN (SELECT COUNT(RATE) FROM RPC5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN (SELECT MAX(TaxbleAmnt) FROM RPC5 WHERE AbsEntry=T3.DocEntry)
    ELSE ISNULL(TaxbleAmnt,T0.DocTotal-T0.VatSum)
END AS 'TaxbleAmnt',

CASE 
    WHEN (SELECT COUNT(RATE) FROM RPC5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN ((T3.SUMAPPLIED/T0.DOCTOTAL)*(SELECT MAX(TaxbleAmnt) FROM RPC5 WHERE AbsEntry=T3.DocEntry)) *(T1.RATE/100)
    ELSE T3.U_WtaxPay
END  AS 'WTAmnt',





CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM RPC1 
                                INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 Left(FedTaxID,3)
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OWNERCODE)
    ELSE 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM RPC1 
                                 INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
END AS 'PY1stTIN',

CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM RPC1 
                                INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 SUBSTRING(FedTaxID,5,3)
        FROM  OWHS A0 
        inner join oudg  A1 on A0.WhsCode=A1.Warehouse
        inner join OUSR A2 on A1.Code=A2.DfltsGroup
        inner join ohem A3 on A2.USERID  =A3.userId
        WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM RPC1 
                                INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END  AS 'PY2ndTIN',


CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN  (Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM RPC1 
                                INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 SUBSTRING(FedTaxID,9,3)
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN  (Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM RPC1 
                                INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END  AS 'PY3ndTIN',


CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN
    (Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN
    (Select TOP 1 SUBSTRING(FedTaxId,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM RPC1 
    INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL THEN 
    (SELECT  TOP 1 SUBSTRING(FedTaxID,13,3)
    FROM  OWHS A0 
    inner join oudg  A1 on A0.WhsCode=A1.Warehouse
    inner join OUSR A2 on A1.Code=A2.DfltsGroup
    inner join ohem A3 on A2.USERID  =A3.userId
    WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN
    (Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN
    (Select TOP 1 SUBSTRING(FedTaxId,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM RPC1 
    INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END AS 'PY4thTIN',



CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum) )) 
    WHEN T0.DOCTYPE = 'S' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(
    SELECT TOP 1 OOCR.U_Whse FROM RPC1 
    INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum) )) END IS NULL 
    THEN

    (SELECT  CONCAT( 
    CASE WHEN  Building IS NULL THEN '' ELSE CONCAT(Building, ', ')  END,
    CASE WHEN  StreetNo IS NULL THEN '' ELSE StreetNo +', ' END,
    CASE WHEN  Block IS NULL THEN '' ELSE Block +', '  END,
    CASE WHEN  City IS NULL THEN '' ELSE City +', '  END,
    CASE WHEN  County IS NULL THEN '' ELSE County +', '  END, 'PHILIPPINES')
    FROM  OWHS A0 
    inner join oudg  A1 on A0.WhsCode=A1.Warehouse
    inner join OUSR A2 on A1.Code=A2.DfltsGroup
    inner join ohem A3 on A2.USERID  =A3.userId
    WHERE A3.code=T0.OwnerCode)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum) )) 
    WHEN T0.DOCTYPE = 'S' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(
    SELECT TOP 1 OOCR.U_Whse FROM RPC1 
    INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum) )) END 
 END AS 'PayorAddress',

CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN  (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT  TOP 1  OOCR.U_Whse FROM RPC1 INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  ZipCode
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OwnerCode)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN   (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM RPC1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN  (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT  TOP 1  OOCR.U_Whse FROM RPC1 
                                 INNER JOIN OOCR ON RPC1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) 
    END
END AS 'PayorZipCode',

CASE
    WHEN   month(t0.taxdate) IN (1,2,3) THEN '1'
    WHEN   month(t0.taxdate) IN (4,5,6) THEN '2'
    WHEN   month(t0.taxdate) IN (7,8,9) THEN '3'
    WHEN   month(t0.taxdate) IN (10,11,12) THEN '4'
    ELSE 'N/A'
END AS 'QTR',
t0.docentry as doc,
ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

(SELECT COUNT(A0.DocNum) FROM ORPC A0 
INNER JOIN VPM2 A1 ON A0.Docentry = A1.Docentry
WHERE A1.DocNum = @DOCNUM
AND A0.WTSum>0
AND
(CASE
WHEN month(A0.taxdate) IN (1,2,3) THEN '1'
WHEN month(A0.taxdate) IN (4,5,6) THEN '2'
WHEN month(A0.taxdate) IN (7,8,9) THEN '3'
WHEN month(A0.taxdate) IN (10,11,12) THEN '4'
ELSE 'N/A' END)=@QTR) AS 'ROWS'

FROM ORPC T0 
LEFT JOIN RPC5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN VPM2 T3 ON T0.DOCNUM= T3.Docentry AND T3.InvType=19

WHERE T3.DocNum = @DOCNUM
AND T0.CANCELED='N'

 )T
WHERE ATC LIKE '%'+@ATC+'%'
AND QTR =@QTR AND T.[ATC] IS NOT NULL
ORDER BY TaxDate
OFFSET @GRP ROWS FETCH NEXT 15 ROWS ONLY

IF (@APnum  > 0) AND (@INV =1)

SELECT *
from(
--APINV
SELECT 
T3.U_wTaxComCode,T3.DOCNUM,'01' as WTaxDayFrom,
T0.U_WTax,T0.TaxDate, T0.DocTotal, (Select CompnyName from OADM) AS 'Payor',
CASE 
    WHEN T0.DOCTYPE = 'I' THEN (SELECT TOP 1 WhsCode FROM PCH1 WHERE DOCENTRY=T0.DocNum )
    WHEN T0.DOCTYPE = 'S' THEN (SELECT TOP 1 ocrcode FROM PCH1 WHERE DOCENTRY=T0.DocNum )
END AS 'ocrcode',

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

CASE 
    WHEN T0.U_ALIAS_VENDOR IS NULL THEN T0.CardName
    ELSE T0.U_ALIAS_VENDOR
END AS 'Payee',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN LEFT(T0.U_TIN,3)
    ELSE (SELECT LEFT(LicTradNum, 3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P1stTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,5,3)
    ELSE (SELECT SUBSTRING(LicTradNum,5,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode)     
END As 'P2ndTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,9,3)
    ELSE (SELECT SUBSTRING(LicTradNum,9,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P3rdTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,13,3)
    ELSE (SELECT SUBSTRING(LicTradNum,13,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P4thTIN',  
CASE 
    WHEN T0.U_ADDRESS IS NOT NULL THEN T0.U_ADDRESS
    ELSE
    UPPER((SELECT DISTINCT CONCAT(CAST(Building AS varchar(max)),
    (CASE WHEN Building IS NULL THEN '' ELSE ' ' END),Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END), StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],
    (CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) 
    FROM CRD1 WHERE CardCode = t0.CardCode AND AdresType = 'B')) 
END AS 'Payee Address',
CASE 
    WHEN T0.U_ADDRESS IS NOT NULL THEN T0.U_ZIPCODE
    ELSE
    (SELECT DISTINCT ZipCode FROM CRD1 WHERE CardCode = T0.CardCode AND AdresType = 'B') 
END AS 'PayeeZipCode',


CASE 
    WHEN (SELECT COUNT(RATE) FROM PCH5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN (SELECT MAX(TaxbleAmnt) FROM PCH5 WHERE AbsEntry=T3.DocEntry)
    ELSE ISNULL(TaxbleAmnt,T0.DocTotal-T0.VatSum)
END AS 'TaxbleAmnt',

CASE 
    WHEN (SELECT COUNT(RATE) FROM PCH5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN ((T3.SUMAPPLIED/T0.DOCTOTAL)*(SELECT MAX(TaxbleAmnt) FROM PCH5 WHERE AbsEntry=T3.DocEntry)) *(T1.RATE/100)
    ELSE T3.U_WtaxPay
END  AS 'WTAmnt',





CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 Left(FedTaxID,3)
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OWNERCODE)
    ELSE 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                 INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
END AS 'PY1stTIN',

CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 SUBSTRING(FedTaxID,5,3)
        FROM  OWHS A0 
        inner join oudg  A1 on A0.WhsCode=A1.Warehouse
        inner join OUSR A2 on A1.Code=A2.DfltsGroup
        inner join ohem A3 on A2.USERID  =A3.userId
        WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END  AS 'PY2ndTIN',


CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN  (Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 SUBSTRING(FedTaxID,9,3)
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN  (Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
                                INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END  AS 'PY3ndTIN',


CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN
    (Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN
    (Select TOP 1 SUBSTRING(FedTaxId,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
    INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL THEN 
    (SELECT  TOP 1 SUBSTRING(FedTaxID,13,3)
    FROM  OWHS A0 
    inner join oudg  A1 on A0.WhsCode=A1.Warehouse
    inner join OUSR A2 on A1.Code=A2.DfltsGroup
    inner join ohem A3 on A2.USERID  =A3.userId
    WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN
    (Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN
    (Select TOP 1 SUBSTRING(FedTaxId,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM PCH1 
    INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END AS 'PY4thTIN',



CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum) )) 
    WHEN T0.DOCTYPE = 'S' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(
    SELECT TOP 1 OOCR.U_Whse FROM PCH1 
    INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum) )) END IS NULL 
    THEN

    (SELECT  CONCAT( 
    CASE WHEN  Building IS NULL THEN '' ELSE CONCAT(Building, ', ')  END,
    CASE WHEN  StreetNo IS NULL THEN '' ELSE StreetNo +', ' END,
    CASE WHEN  Block IS NULL THEN '' ELSE Block +', '  END,
    CASE WHEN  City IS NULL THEN '' ELSE City +', '  END,
    CASE WHEN  County IS NULL THEN '' ELSE County +', '  END, 'PHILIPPINES')
    FROM  OWHS A0 
    inner join oudg  A1 on A0.WhsCode=A1.Warehouse
    inner join OUSR A2 on A1.Code=A2.DfltsGroup
    inner join ohem A3 on A2.USERID  =A3.userId
    WHERE A3.code=T0.OwnerCode)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum) )) 
    WHEN T0.DOCTYPE = 'S' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(
    SELECT TOP 1 OOCR.U_Whse FROM PCH1 
    INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum) )) END 
 END AS 'PayorAddress',

CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN  (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT  TOP 1  OOCR.U_Whse FROM PCH1 INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  ZipCode
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OwnerCode)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN   (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM PCH1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN  (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT  TOP 1  OOCR.U_Whse FROM PCH1 
                                 INNER JOIN OOCR ON PCH1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) 
    END
END AS 'PayorZipCode',

CASE
    WHEN   month(t0.taxdate) IN (1,2,3) THEN '1'
    WHEN   month(t0.taxdate) IN (4,5,6) THEN '2'
    WHEN   month(t0.taxdate) IN (7,8,9) THEN '3'
    WHEN   month(t0.taxdate) IN (10,11,12) THEN '4'
    ELSE 'N/A'
END AS 'QTR',
t0.docentry as doc,
ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

(SELECT COUNT(A0.DocNum) FROM OPCH A0 
INNER JOIN VPM2 A1 ON A0.Docentry = A1.Docentry
WHERE A1.DocNum = @DOCNUM
AND A0.WTSum>0
AND
(CASE
WHEN month(A0.taxdate) IN (1,2,3) THEN '1'
WHEN month(A0.taxdate) IN (4,5,6) THEN '2'
WHEN month(A0.taxdate) IN (7,8,9) THEN '3'
WHEN month(A0.taxdate) IN (10,11,12) THEN '4'
ELSE 'N/A' END)=@QTR) AS 'ROWS'

FROM OPCH T0 
LEFT JOIN PCH5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN VPM2 T3 ON T0.DOCNUM= T3.Docentry

WHERE T3.DocNum = @DOCNUM AND T0.DocNum=@APnum
AND T0.CANCELED='N' 
AND T3.InvType=18
 )T
WHERE ATC LIKE '%'+@ATC+'%'
AND QTR =@QTR AND T.[ATC] IS NOT NULL

IF (@APnum  > 0) AND (@INV =2)

SELECT *
from(
SELECT 
T3.U_wTaxComCode,T3.DOCNUM,'01' as WTaxDayFrom,
T0.U_WTax,T0.TaxDate, T0.DocTotal, (Select CompnyName from OADM) AS 'Payor',
CASE 
    WHEN T0.DOCTYPE = 'I' THEN (SELECT TOP 1 WhsCode FROM PCH1 WHERE DOCENTRY=T0.DocNum )
    WHEN T0.DOCTYPE = 'S' THEN (SELECT TOP 1 ocrcode FROM PCH1 WHERE DOCENTRY=T0.DocNum )
END AS 'ocrcode',

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

CASE 
    WHEN T0.U_ALIAS_VENDOR IS NULL THEN T0.CardName
    ELSE T0.U_ALIAS_VENDOR
END AS 'Payee',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN LEFT(T0.U_TIN,3)
    ELSE (SELECT LEFT(LicTradNum, 3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P1stTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,5,3)
    ELSE (SELECT SUBSTRING(LicTradNum,5,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode)     
END As 'P2ndTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,9,3)
    ELSE (SELECT SUBSTRING(LicTradNum,9,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P3rdTIN',
CASE 
    WHEN T0.U_TIN IS NOT NULL THEN SUBSTRING(T0.U_TIN,13,3)
    ELSE (SELECT SUBSTRING(LicTradNum,13,3) FROM OCRD TT WHERE TT.CardCode = T0.CardCode) 
END As 'P4thTIN',  
CASE 
    WHEN T0.U_ADDRESS IS NOT NULL THEN T0.U_ADDRESS
    ELSE
    UPPER((SELECT DISTINCT CONCAT(CAST(Building AS varchar(max)),
    (CASE WHEN Building IS NULL THEN '' ELSE ' ' END),Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END), StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],
    (CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) 
    FROM CRD1 WHERE CardCode = t0.CardCode AND AdresType = 'B')) 
END AS 'Payee Address',
CASE 
    WHEN T0.U_ADDRESS IS NOT NULL THEN T0.U_ZIPCODE
    ELSE
    (SELECT DISTINCT ZipCode FROM CRD1 WHERE CardCode = T0.CardCode AND AdresType = 'B') 
END AS 'PayeeZipCode',


CASE 
    WHEN (SELECT COUNT(RATE) FROM DPO5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN (SELECT MAX(TaxbleAmnt) FROM DPO5 WHERE AbsEntry=T3.DocEntry)
    ELSE ISNULL(TaxbleAmnt,T0.DocTotal-T0.VatSum)
END AS 'TaxbleAmnt',

CASE 
    WHEN (SELECT COUNT(RATE) FROM DPO5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN ((T3.SUMAPPLIED/T0.DOCTOTAL)*(SELECT MAX(TaxbleAmnt) FROM DPO5 WHERE AbsEntry=T3.DocEntry)) *(T1.RATE/100)
    ELSE T3.U_WtaxPay
END  AS 'WTAmnt',





CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 Left(FedTaxID,3)
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OWNERCODE)
    ELSE 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 Left(FedTaxID,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                 INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
END AS 'PY1stTIN',

CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 SUBSTRING(FedTaxID,5,3)
        FROM  OWHS A0 
        inner join oudg  A1 on A0.WhsCode=A1.Warehouse
        inner join OUSR A2 on A1.Code=A2.DfltsGroup
        inner join ohem A3 on A2.USERID  =A3.userId
        WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN (Select TOP 1 SUBSTRING(FedTaxID,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,5,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END  AS 'PY2ndTIN',


CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN  (Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  TOP 1 SUBSTRING(FedTaxID,9,3)
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN  (Select TOP 1 SUBSTRING(FedTaxID,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (Select TOP 1 SUBSTRING(FedTaxId,9,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
                                INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END  AS 'PY3ndTIN',


CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN
    (Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN
    (Select TOP 1 SUBSTRING(FedTaxId,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
    INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL THEN 
    (SELECT  TOP 1 SUBSTRING(FedTaxID,13,3)
    FROM  OWHS A0 
    inner join oudg  A1 on A0.WhsCode=A1.Warehouse
    inner join OUSR A2 on A1.Code=A2.DfltsGroup
    inner join ohem A3 on A2.USERID  =A3.userId
    WHERE A3.code=T0.OWNERCODE)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN
    (Select TOP 1 SUBSTRING(FedTaxID,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN
    (Select TOP 1 SUBSTRING(FedTaxId,13,3) FROM OWHS WHERE WhsCode=(SELECT TOP 1 OOCR.U_Whse FROM DPO1 
    INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END
 END AS 'PY4thTIN',



CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum) )) 
    WHEN T0.DOCTYPE = 'S' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(
    SELECT TOP 1 OOCR.U_Whse FROM DPO1 
    INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum) )) END IS NULL 
    THEN

    (SELECT  CONCAT( 
    CASE WHEN  Building IS NULL THEN '' ELSE CONCAT(Building, ', ')  END,
    CASE WHEN  StreetNo IS NULL THEN '' ELSE StreetNo +', ' END,
    CASE WHEN  Block IS NULL THEN '' ELSE Block +', '  END,
    CASE WHEN  City IS NULL THEN '' ELSE City +', '  END,
    CASE WHEN  County IS NULL THEN '' ELSE County +', '  END, 'PHILIPPINES')
    FROM  OWHS A0 
    inner join oudg  A1 on A0.WhsCode=A1.Warehouse
    inner join OUSR A2 on A1.Code=A2.DfltsGroup
    inner join ohem A3 on A2.USERID  =A3.userId
    WHERE A3.code=T0.OwnerCode)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum) )) 
    WHEN T0.DOCTYPE = 'S' THEN
    UPPER((SELECT TOP 1 CONCAT(CAST(Building AS varchar(max)),(CASE WHEN Building IS NULL THEN '' ELSE ', ' END),
    Street,(CASE WHEN Street IS NULL THEN '' ELSE ', ' END),StreetNo,(CASE WHEN StreetNo IS NULL THEN '' ELSE ', ' END),[Block],(CASE WHEN [Block] IS NULL THEN '' ELSE ', ' END),
    City,(CASE WHEN City IS NULL THEN '' ELSE ' ' END)) FROM owhs  WHERE WhsCode=(
    SELECT TOP 1 OOCR.U_Whse FROM DPO1 
    INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum) )) END 
 END AS 'PayorAddress',

CASE WHEN 
    CASE WHEN T0.DOCTYPE = 'I' THEN  (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT  TOP 1  OOCR.U_Whse FROM DPO1 INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) END IS NULL 
    THEN (SELECT  ZipCode
            FROM  OWHS A0 
            inner join oudg  A1 on A0.WhsCode=A1.Warehouse
            inner join OUSR A2 on A1.Code=A2.DfltsGroup
            inner join ohem A3 on A2.USERID  =A3.userId
            WHERE A3.code=T0.OwnerCode)
    ELSE
    CASE WHEN T0.DOCTYPE = 'I' THEN   (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT TOP 1 WhsCode FROM DPO1 WHERE DocEntry=T0.DocNum))
    WHEN T0.DOCTYPE = 'S' THEN  (SELECT TOP 1 ZipCode FROM owhs  WHERE WhsCode=(SELECT  TOP 1  OOCR.U_Whse FROM DPO1 
                                 INNER JOIN OOCR ON DPO1.OCRCODE = OOCR.OCRCODE WHERE DocEntry=T0.DocNum)) 
    END
END AS 'PayorZipCode',

CASE
    WHEN   month(t0.taxdate) IN (1,2,3) THEN '1'
    WHEN   month(t0.taxdate) IN (4,5,6) THEN '2'
    WHEN   month(t0.taxdate) IN (7,8,9) THEN '3'
    WHEN   month(t0.taxdate) IN (10,11,12) THEN '4'
    ELSE 'N/A'
END AS 'QTR',
t0.docentry as doc,
ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

(SELECT COUNT(A0.DocNum) FROM ODPO A0 
INNER JOIN VPM2 A1 ON A0.Docentry = A1.Docentry
WHERE A1.DocNum = @DOCNUM
AND A0.WTSum>0
AND
(CASE
WHEN month(A0.taxdate) IN (1,2,3) THEN '1'
WHEN month(A0.taxdate) IN (4,5,6) THEN '2'
WHEN month(A0.taxdate) IN (7,8,9) THEN '3'
WHEN month(A0.taxdate) IN (10,11,12) THEN '4'
ELSE 'N/A' END)=@QTR) AS 'ROWS'

FROM ODPO T0 
LEFT JOIN DPO5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN VPM2 T3 ON T0.DOCNUM= T3.Docentry

WHERE T3.DocNum = @DOCNUM AND T0.DocNum=@APnum
AND T0.CANCELED='N' 
AND T3.InvType=204

 )T
WHERE ATC LIKE '%'+@ATC+'%'
AND QTR =@QTR AND T.[ATC] IS NOT NULL