DECLARE  @qtr INT= 1, @grp int =0, @act1 varchar ='' , @APDODNUM INT = 0, @InvType int = 0,@DOCNUM INT =105
IF (@APDODNUM  =0)  AND (@InvType = 0)
SELECT *,
CASE WHEN ROW_NUMBER() OVER (ORDER BY (SELECT 1))>0 THEN ROW_NUMBER() OVER (ORDER BY (SELECT 1))-0 ELSE ROW_NUMBER() OVER (ORDER BY (SELECT 1)) END AS RNUM
FROM (
SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,
T0.TAXDATE, 
TaxbleAmnt,
T0.WTSum, T0.U_WTax,  WTAMNT, T3.U_GROSSAMT- T3.U_WTax AS 'DOCTOTAL'  , T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,
(SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) AS 'ATC', 
(SELECT TOP 1 concat(TI.U_ATCDesc,TI.U_EXTDesc)  FROM OWHT TI WHERE TI.WTCode = T1.WTCode ) AS 'ATC Description',

(SELECT COUNT(*) from VPM2 T6 WHERE T6.DOCNUM = @DOCNUM) AS 'ROWS'

FROM OPCH T0 INNER JOIN PCH5 T1 ON T0.DocNum = T1.AbsEntry 
INNER JOIN VPM2 T3 ON T0.Docentry = T3.Docentry 
WHERE T3.DocNum = @DOCNUM
AND (CASE
WHEN
month(t0.taxdate) = '1' OR month(t0.taxdate)= '2' OR month(t0.taxdate)= '3' THEN '1'
WHEN
month(t0.taxdate) = '4' OR month(t0.taxdate)= '5' OR month(t0.taxdate)= '6' THEN '2'
WHEN
month(t0.taxdate) = '7' OR month(t0.taxdate)= '8' OR month(t0.taxdate)= '9' THEN '3'
WHEN
month(t0.taxdate) = '10' OR month(t0.taxdate)= '11' OR month(t0.taxdate)= '12' THEN '4'
ELSE 'N/A'
END)=1
AND (SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) LIKE '%%' 



UNION ALL 


SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,
T0.TAXDATE, 
TaxbleAmnt,
T0.WTSum, T0.U_WTax, WTAMNT, T3.U_GROSSAMT- T3.U_WTax AS 'DOCTOTAL' , T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,
(SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) AS 'ATC', 
(SELECT TOP 1 concat(TI.U_ATCDesc,TI.U_EXTDesc)  FROM OWHT TI WHERE TI.WTCode = T1.WTCode ) AS 'ATC Description',

(SELECT COUNT(*) from VPM2 T6 WHERE T6.DOCNUM = @DOCNUM) AS 'ROWS'

FROM ODPO T0 INNER JOIN DPO5 T1 ON T0.DocNum = T1.AbsEntry 
INNER JOIN VPM2 T3 ON T0.Docentry = T3.Docentry
WHERE  T3.DocNum = @DOCNUM
AND (CASE
WHEN
month(t0.taxdate) = '1' OR month(t0.taxdate)= '2' OR month(t0.taxdate)= '3' THEN '1'
WHEN
month(t0.taxdate) = '4' OR month(t0.taxdate)= '5' OR month(t0.taxdate)= '6' THEN '2'
WHEN
month(t0.taxdate) = '7' OR month(t0.taxdate)= '8' OR month(t0.taxdate)= '9' THEN '3'
WHEN
month(t0.taxdate) = '10' OR month(t0.taxdate)= '11' OR month(t0.taxdate)= '12' THEN '4'
ELSE 'N/A'
END)=1
AND (SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) LIKE '%%' 

UNION ALL
--CM
SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,
T0.TAXDATE, 
TaxbleAmnt,
T0.WTSum, T0.U_WTax,  WTAMNT,T3.U_GROSSAMT- T3.U_WTax AS 'DOCTOTAL' , T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,
(SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) AS 'ATC', 
(SELECT TOP 1 concat(TI.U_ATCDesc,TI.U_EXTDesc)  FROM OWHT TI WHERE TI.WTCode = T1.WTCode ) AS 'ATC Description',

(SELECT COUNT(*) from VPM2 T6 WHERE T6.DOCNUM = @DOCNUM) AS 'ROWS'

FROM ORPC T0 INNER JOIN RPC5 T1 ON T0.DocNum = T1.AbsEntry 
INNER JOIN VPM2 T3 ON T0.Docentry = T3.Docentry 
WHERE T3.DocNum = @DOCNUM
AND T0.DOCNUM IN (SELECT DocEntry FROM VPM2 WHERE InvType=19 AND DocNum=@DOCNUM)
AND (CASE
WHEN
month(t0.taxdate) = '1' OR month(t0.taxdate)= '2' OR month(t0.taxdate)= '3' THEN '1'
WHEN
month(t0.taxdate) = '4' OR month(t0.taxdate)= '5' OR month(t0.taxdate)= '6' THEN '2'
WHEN
month(t0.taxdate) = '7' OR month(t0.taxdate)= '8' OR month(t0.taxdate)= '9' THEN '3'
WHEN
month(t0.taxdate) = '10' OR month(t0.taxdate)= '11' OR month(t0.taxdate)= '12' THEN '4'
ELSE 'N/A'
END)=1
AND (SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) LIKE '%%' 

UNION ALL 
--JE
SELECT
T2.CardName AS 'N1',T2.CardName AS 'CARDNAME',
NULL,
T0.TAXDATE, 
NULL,
CASE WHEN DEBIT =0 THEN CREDIT ELSE DEBIT END AS 'WTSUM', NULL,
CASE WHEN DEBIT =0 THEN CREDIT ELSE DEBIT END AS 'WTAMNT',T3.U_GROSSAMT- T3.U_WTax AS 'DOCTOTAL' , T3.SUMAPPLIED,
CASE WHEN DEBIT =0 THEN CREDIT ELSE DEBIT END AS 'BASEAMNT',u_wtaxpay,T3.U_GROSSAMT,
U_ATCcode AS 'ATC', 
U_ATCName AS 'ATC Description',

(SELECT COUNT(*) from VPM2 T6 WHERE T6.DOCNUM = @DOCNUM) AS 'ROWS'

FROM JDT1 T0 
INNER JOIN OCRD T2 ON T0.ShortName=T2.CardCode 
INNER JOIN VPM2 T3 ON T0.TransId = T3.Docentry 
WHERE T3.DocNum = @DOCNUM
AND T0.U_ATCcode IS NOT NULL
AND T0.TransId IN (SELECT DocEntry FROM VPM2 WHERE InvType=30 AND DocNum=@DOCNUM) 
AND (CASE
WHEN
month(t0.taxdate) = '1' OR month(t0.taxdate)= '2' OR month(t0.taxdate)= '3' THEN '1'
WHEN
month(t0.taxdate) = '4' OR month(t0.taxdate)= '5' OR month(t0.taxdate)= '6' THEN '2'
WHEN
month(t0.taxdate) = '7' OR month(t0.taxdate)= '8' OR month(t0.taxdate)= '9' THEN '3'
WHEN
month(t0.taxdate) = '10' OR month(t0.taxdate)= '11' OR month(t0.taxdate)= '12' THEN '4'
ELSE 'N/A'
END)=1
AND U_ATCcode LIKE '%%' 


) EWTCERTIFICATE
/* WHERE ATC NOT LIKE  '%WV%'
and ATC NOT LIKE  '%WB%'
AND N1=CardName */
ORDER BY TAXDATE
OFFSET 0 ROWS FETCH NEXT 15 ROWS ONLY


ELSE IF (@APDODNUM  > 0) AND (@InvType =1)


SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,
T0.Docdate AS 'Document Date',
T0.TAXDATE,
T0.CardCode ,T0.CardName, T0.DocDate , 
T3.U_GROSSAMT- T3.U_WTax AS 'DOCTOTAL' , T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,
TaxbleAmnt,
T0.WTSum, T0.U_WTax, WTAMNT,(SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) AS 'ATC', 
(SELECT TI.U_ATCDesc FROM OWHT TI WHERE TI.WTCode = T1.WTCode) AS 'ATC Description', 

1 AS 'ROWS',
ROW_NUMBER() OVER (ORDER BY (SELECT 1))  AS RNUM

FROM OPCH T0 INNER JOIN PCH5 T1 ON T0.DocNum = T1.AbsEntry 
INNER JOIN VPM2 T3 ON T0.Docentry = T3.Docentry 
WHERE  T0.DocNum  = 0
AND T3.docnum =@DOCNUM
AND (SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) NOT LIKE  '%WV%'
AND (SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) NOT LIKE  '%WB%'
AND T3.InvType=18

ELSE

SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,
T0.Docdate AS 'Document Date',
T0.TAXDATE,
T0.CardCode ,T0.CardName, T0.DocDate , 
T3.U_GROSSAMT- T3.U_WTax AS 'DOCTOTAL' , T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,
TaxbleAmnt,
T0.WTSum, T0.U_WTax, WTAMNT,(SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) AS 'ATC', 
(SELECT TI.U_ATCDesc FROM OWHT TI WHERE TI.WTCode = T1.WTCode) AS 'ATC Description', 

1 AS 'ROWS',
ROW_NUMBER() OVER (ORDER BY (SELECT 1))  AS RNUM

FROM ODPO T0 INNER JOIN DPO5 T1 ON T0.DocNum = T1.AbsEntry 
INNER JOIN VPM2 T3 ON T0.Docentry = T3.Docentry 
WHERE  T0.DocNum  = 0
AND T3.docnum =@DOCNUM
AND (SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) NOT LIKE  '%WV%'
AND (SELECT TI.U_ATC FROM OWHT TI WHERE TI.WTCode = T1.WTCode) NOT LIKE  '%WB%'
AND T3.InvType=204

