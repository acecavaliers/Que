



 

DECLARE @QTR INT= 1 ,@GRP INT =0, @ATC varchar= '' , @APDODNUM  INT = 0, @InvType Int =0, @DOCNUM INT =116
IF (@APDODNUM  = 0) AND (@InvType =0)

SELECT T.*,
CASE 
    WHEN T.WTAmnt IS NULL 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T.U_wTaxComCode 
    ),'')
    ELSE 
    T.WTAmnt + ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T.DocNum 
    AND A0.U_ATCcode IS NOT NULL 
    AND A1.InvType=30  
    AND A1.U_wTaxComCode=T.U_wTaxComCode 
    AND A0.U_ATCcode=T.ATC 
),0)
END AS 'wtax',
CASE 
    WHEN ROW_NUMBER() OVER (ORDER BY (SELECT 1))>@GRP THEN ROW_NUMBER() OVER (ORDER BY (SELECT 1))-@GRP 
    ELSE ROW_NUMBER() OVER (ORDER BY (SELECT 1)) 
    END AS 'RNUM'
FROM(
--APINV
SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,T3.U_wTaxComCode,T3.DocNum,
T0.TAXDATE, 

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

T0.WTSum, T0.U_WTax , 
T3.U_GROSSAMT- 
CASE WHEN T3.U_GROSSAMT- T3.U_WTax=T3.U_GROSSAMT 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
    ),'')
    ELSE T3.U_WTax     
 END AS  'DOCTOTAL'  ,
 T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,

ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

ISNULL((SELECT TOP 1 CONCAT(TI.U_ATCDesc,TI.U_EXTDESC ) FROM OWHT TI 
 WHERE  T1.AbsEntry =T0.DocNum AND TI.WTCode = T1.WTCode),
ISNULL((SELECT A0.U_ATCNAME FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
 ),'')) AS 'ATC Description',

CASE
WHEN
month(t0.taxdate) = '1' OR month(t0.taxdate)= '2' OR month(t0.taxdate)= '3' THEN '1'
WHEN
month(t0.taxdate) = '4' OR month(t0.taxdate)= '5' OR month(t0.taxdate)= '6' THEN '2'
WHEN
month(t0.taxdate) = '7' OR month(t0.taxdate)= '8' OR month(t0.taxdate)= '9' THEN '3'
WHEN
month(t0.taxdate) = '10' OR month(t0.taxdate)= '11' OR month(t0.taxdate)= '12' THEN '4'
ELSE 'N/A'
END AS 'QTR',

(SELECT COUNT(*) from VPM2 T6 WHERE T6.DOCNUM = @DocNum) AS 'ROWS'

FROM OPCH T0 
LEFT JOIN PCH5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN VPM2 T3 ON T0.Docentry = T3.Docentry
INNER JOIN PCH1 T5 ON T5.DocEntry=T0.DocNum
WHERE T3.DocNum = @DOCNUM
AND T0.CANCELED='N'

UNION ALL 
--APDPI 
SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,T3.U_wTaxComCode,T3.DocNum,
T0.TAXDATE, 

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

T0.WTSum, T0.U_WTax,
T3.U_GROSSAMT- 
CASE WHEN T3.U_GROSSAMT- T3.U_WTax=T3.U_GROSSAMT 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
    ),'')
    ELSE T3.U_WTax     
 END AS  'DOCTOTAL'  ,
T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,

ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

ISNULL((SELECT TOP 1 CONCAT(TI.U_ATCDesc,TI.U_EXTDESC ) FROM OWHT TI 
 WHERE  T1.AbsEntry =T0.DocNum AND TI.WTCode = T1.WTCode),
ISNULL((SELECT A0.U_ATCNAME FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
 ),'')) AS 'ATC Description',

CASE
WHEN
month(t0.taxdate) = '1' OR month(t0.taxdate)= '2' OR month(t0.taxdate)= '3' THEN '1'
WHEN
month(t0.taxdate) = '4' OR month(t0.taxdate)= '5' OR month(t0.taxdate)= '6' THEN '2'
WHEN
month(t0.taxdate) = '7' OR month(t0.taxdate)= '8' OR month(t0.taxdate)= '9' THEN '3'
WHEN
month(t0.taxdate) = '10' OR month(t0.taxdate)= '11' OR month(t0.taxdate)= '12' THEN '4'
ELSE 'N/A'
END AS 'QTR',

(SELECT COUNT(*) from VPM2 T6 WHERE T6.DOCNUM = @DocNum) AS 'ROWS'

FROM ODPO T0 
LEFT JOIN DPO5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN VPM2 T3 ON T0.Docentry = T3.Docentry
INNER JOIN DPO1 T5 ON T5.DocEntry=T0.DocNum
WHERE T3.DocNum = @DOCNUM
AND T0.CANCELED='N'

UNION ALL
--CM
SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,T3.U_wTaxComCode,T3.DocNum,
T0.TAXDATE, 

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

T0.WTSum, T0.U_WTax ,
T3.U_GROSSAMT- 
CASE WHEN T3.U_GROSSAMT- T3.U_WTax=T3.U_GROSSAMT 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
    ),'')
    ELSE T3.U_WTax     
 END AS  'DOCTOTAL'  ,
T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,

ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

ISNULL((SELECT TOP 1 CONCAT(TI.U_ATCDesc,TI.U_EXTDESC ) FROM OWHT TI 
 WHERE  T1.AbsEntry =T0.DocNum AND TI.WTCode = T1.WTCode),
ISNULL((SELECT A0.U_ATCNAME FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
 ),'')) AS 'ATC Description',

CASE
WHEN
month(t0.taxdate) = '1' OR month(t0.taxdate)= '2' OR month(t0.taxdate)= '3' THEN '1'
WHEN
month(t0.taxdate) = '4' OR month(t0.taxdate)= '5' OR month(t0.taxdate)= '6' THEN '2'
WHEN
month(t0.taxdate) = '7' OR month(t0.taxdate)= '8' OR month(t0.taxdate)= '9' THEN '3'
WHEN
month(t0.taxdate) = '10' OR month(t0.taxdate)= '11' OR month(t0.taxdate)= '12' THEN '4'
ELSE 'N/A'
END AS 'QTR',
(SELECT COUNT(*) from VPM2 T6 WHERE T6.DOCNUM = @DocNum) AS 'ROWS'

FROM ORPC T0 
LEFT JOIN RPC5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN VPM2 T3 ON T0.Docentry = T3.Docentry
INNER JOIN RPC1 T5 ON T5.DocEntry=T0.DocNum
WHERE T3.DocNum = @DOCNUM
AND T0.CANCELED='N'

 )T
WHERE ATC LIKE '%'+@ATC+'%'
AND QTR =@QTR
AND T.[ATC] IS NOT NULL
ORDER BY TaxDate
OFFSET @GRP ROWS FETCH NEXT 15 ROWS ONLY

ELSE IF (@APDODNUM  > 0) AND (@InvType =1)

SELECT T.*,
CASE 
    WHEN T.WTAmnt IS NULL 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T.U_wTaxComCode 
    ),'')
    ELSE 
    T.WTAmnt + ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T.DocNum 
    AND A0.U_ATCcode IS NOT NULL 
    AND A1.InvType=30  
    AND A1.U_wTaxComCode=T.U_wTaxComCode 
    AND A0.U_ATCcode=T.ATC 
),0)
END AS 'wtax',
CASE 
    WHEN ROW_NUMBER() OVER (ORDER BY (SELECT 1))>@GRP THEN ROW_NUMBER() OVER (ORDER BY (SELECT 1))-@GRP 
    ELSE ROW_NUMBER() OVER (ORDER BY (SELECT 1)) 
    END AS 'RNUM'
FROM(
--APINV
SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,T3.U_wTaxComCode,T3.DocNum,
T0.TAXDATE, 

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

T0.WTSum, T0.U_WTax ,
T3.U_GROSSAMT- 
CASE WHEN T3.U_GROSSAMT- T3.U_WTax=T3.U_GROSSAMT 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
    ),'')
    ELSE T3.U_WTax     
 END AS  'DOCTOTAL'  ,
T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,

ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

ISNULL((SELECT TOP 1 CONCAT(TI.U_ATCDesc,TI.U_EXTDESC ) FROM OWHT TI 
 WHERE  T1.AbsEntry =T0.DocNum AND TI.WTCode = T1.WTCode),
ISNULL((SELECT A0.U_ATCNAME FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
 ),'')) AS 'ATC Description',

CASE
WHEN
month(t0.taxdate) = '1' OR month(t0.taxdate)= '2' OR month(t0.taxdate)= '3' THEN '1'
WHEN
month(t0.taxdate) = '4' OR month(t0.taxdate)= '5' OR month(t0.taxdate)= '6' THEN '2'
WHEN
month(t0.taxdate) = '7' OR month(t0.taxdate)= '8' OR month(t0.taxdate)= '9' THEN '3'
WHEN
month(t0.taxdate) = '10' OR month(t0.taxdate)= '11' OR month(t0.taxdate)= '12' THEN '4'
ELSE 'N/A'
END AS 'QTR',

(SELECT COUNT(*) from VPM2 T6 WHERE T6.DOCNUM = @DocNum) AS 'ROWS'

FROM OPCH T0 
LEFT JOIN PCH5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN VPM2 T3 ON T0.Docentry = T3.Docentry
INNER JOIN PCH1 T5 ON T5.DocEntry=T0.DocNum
WHERE T3.DocNum = @DOCNUM AND T0.DocNum=@APDODNUM
AND T0.CANCELED='N'
AND T3.InvType=18

 )T
WHERE ATC LIKE '%'+@ATC+'%'
AND QTR =@QTR
AND T.[ATC] IS NOT NULL
ORDER BY TaxDate

ELSE IF (@APDODNUM  > 0) AND (@InvType =2)
--APDPI
SELECT T.*,
CASE 
    WHEN T.WTAmnt IS NULL 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T.U_wTaxComCode 
    ),'')
    ELSE 
    T.WTAmnt + ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T.DocNum 
    AND A0.U_ATCcode IS NOT NULL 
    AND A1.InvType=30  
    AND A1.U_wTaxComCode=T.U_wTaxComCode 
    AND A0.U_ATCcode=T.ATC 
),0)
END AS 'wtax',
CASE 
    WHEN ROW_NUMBER() OVER (ORDER BY (SELECT 1))>@GRP THEN ROW_NUMBER() OVER (ORDER BY (SELECT 1))-@GRP 
    ELSE ROW_NUMBER() OVER (ORDER BY (SELECT 1)) 
    END AS 'RNUM'
FROM(
SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,T3.U_wTaxComCode,T3.DocNum,
T0.TAXDATE, 

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

T0.WTSum, T0.U_WTax,
T3.U_GROSSAMT- 
CASE WHEN T3.U_GROSSAMT- T3.U_WTax=T3.U_GROSSAMT 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
    ),'')
    ELSE T3.U_WTax     
 END AS  'DOCTOTAL'  ,
T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,

ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

ISNULL((SELECT TOP 1 CONCAT(TI.U_ATCDesc,TI.U_EXTDESC ) FROM OWHT TI 
 WHERE  T1.AbsEntry =T0.DocNum AND TI.WTCode = T1.WTCode),
ISNULL((SELECT A0.U_ATCNAME FROM JDT1 A0 INNER JOIN VPM2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
 ),'')) AS 'ATC Description',

CASE
WHEN
month(t0.taxdate) = '1' OR month(t0.taxdate)= '2' OR month(t0.taxdate)= '3' THEN '1'
WHEN
month(t0.taxdate) = '4' OR month(t0.taxdate)= '5' OR month(t0.taxdate)= '6' THEN '2'
WHEN
month(t0.taxdate) = '7' OR month(t0.taxdate)= '8' OR month(t0.taxdate)= '9' THEN '3'
WHEN
month(t0.taxdate) = '10' OR month(t0.taxdate)= '11' OR month(t0.taxdate)= '12' THEN '4'
ELSE 'N/A'
END AS 'QTR',

(SELECT COUNT(*) from VPM2 T6 WHERE T6.DOCNUM = @DocNum) AS 'ROWS'

FROM ODPO T0 
LEFT JOIN DPO5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN VPM2 T3 ON T0.Docentry = T3.Docentry
INNER JOIN DPO1 T5 ON T5.DocEntry=T0.DocNum
WHERE T3.DocNum = @DOCNUM AND T0.DocNum=@APDODNUM
AND T0.CANCELED='N'
AND T3.InvType=204

 )T
WHERE ATC LIKE '%'+@ATC+'%'
AND QTR =@QTR
AND T.[ATC] IS NOT NULL
ORDER BY TaxDate
