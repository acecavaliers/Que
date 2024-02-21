


DECLARE @QTR INT= 1 ,@GRP INT =0, @ATC varchar= '' , @INVnum  INT = 0, @INV Int =0, @DOCNUM INT =384
--DECLARE @QTR INT={?Pm-?quarter} ,@GRP INT ={?Pm-?Group}, @ATC varchar= '{?ATC}' , @INVnum  INT = {?Pm-?ApDocnum}, @INV Int ={?InvType}, @DOCNUM INT ={?Pm-?Docnum}
IF (@INVnum  = 0) AND (@INV =0)

SELECT *,
CASE 
    WHEN T.WTAmnt IS NULL 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T.U_wTaxComCode 
    ),'')
    ELSE 
    T.WTAmnt + ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
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
    WHEN (SELECT COUNT(RATE) FROM INV5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN (SELECT MAX(TaxbleAmnt) FROM INV5 WHERE AbsEntry=T3.DocEntry)
    ELSE ISNULL(TaxbleAmnt,T0.DocTotal-T0.VatSum)
END AS 'TaxbleAmnt',
CASE 
    WHEN (SELECT COUNT(RATE) FROM INV5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN ((T3.SUMAPPLIED/T0.DOCTOTAL)*(SELECT MAX(TaxbleAmnt) FROM INV5 WHERE AbsEntry=T3.DocEntry)) *(T1.RATE/100)
    ELSE T3.U_WtaxPay
END  AS 'WTAmnt',

T0.WTSum, T0.U_WTax , 
T3.U_GROSSAMT- 
CASE WHEN T3.U_GROSSAMT- T3.U_WTax=T3.U_GROSSAMT 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
    ),'')
    ELSE T3.U_WTax     
 END AS  'DOCTOTAL'  ,
 T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,

ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

ISNULL((SELECT TOP 1 CONCAT(TI.U_ATCDesc,TI.U_EXTDESC ) FROM OWHT TI 
 WHERE  T1.AbsEntry =T0.DocNum AND TI.WTCode = T1.WTCode),
ISNULL((SELECT A0.U_ATCNAME FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
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

(SELECT COUNT(*) from RCT2 T6 WHERE T6.DOCNUM = @DocNum) AS 'ROWS'

FROM OINV T0 
LEFT JOIN INV5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN RCT2 T3 ON T0.DOCNUM = T3.Docentry AND T3.InvType=13

WHERE T3.DocNum = @DOCNUM
AND T0.CANCELED='N'

UNION ALL 
--APDPI 
SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,T3.U_wTaxComCode,T3.DocNum,
T0.TAXDATE, 

CASE 
    WHEN (SELECT COUNT(RATE) FROM DPI5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN (SELECT MAX(TaxbleAmnt) FROM DPI5 WHERE AbsEntry=T3.DocEntry)
    ELSE ISNULL(TaxbleAmnt,T0.DocTotal-T0.VatSum)
END AS 'TaxbleAmnt',
CASE 
    WHEN (SELECT COUNT(RATE) FROM DPI5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN ((T3.SUMAPPLIED/T0.DOCTOTAL)*(SELECT MAX(TaxbleAmnt) FROM DPI5 WHERE AbsEntry=T3.DocEntry)) *(T1.RATE/100)
    ELSE T3.U_WtaxPay
END  AS 'WTAmnt',

T0.WTSum, T0.U_WTax,
T3.U_GROSSAMT- 
CASE WHEN T3.U_GROSSAMT- T3.U_WTax=T3.U_GROSSAMT 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
    ),'')
    ELSE T3.U_WTax     
 END AS  'DOCTOTAL'  ,
T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,

ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

ISNULL((SELECT TOP 1 CONCAT(TI.U_ATCDesc,TI.U_EXTDESC ) FROM OWHT TI 
 WHERE  T1.AbsEntry =T0.DocNum AND TI.WTCode = T1.WTCode),
ISNULL((SELECT A0.U_ATCNAME FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
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

(SELECT COUNT(*) from RCT2 T6 WHERE T6.DOCNUM = @DocNum) AS 'ROWS'

FROM ODPI T0 
LEFT JOIN DPI5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN RCT2 T3 ON T0.DOCNUM = T3.Docentry  AND T3.InvType=203

WHERE T3.DocNum = @DOCNUM
AND T0.CANCELED='N'

UNION ALL
--CM
SELECT
CASE WHEN U_ALIAS_VENDOR IS NULL THEN CardName ELSE U_ALIAS_VENDOR END AS N1,CardName,
T0.VatPaid,T3.U_wTaxComCode,T3.DocNum,
T0.TAXDATE, 

CASE 
    WHEN (SELECT COUNT(RATE) FROM RIN5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN (SELECT MAX(TaxbleAmnt) FROM RIN5 WHERE AbsEntry=T3.DocEntry)
    ELSE ISNULL(TaxbleAmnt,T0.DocTotal-T0.VatSum)
END AS 'TaxbleAmnt',
CASE 
    WHEN (SELECT COUNT(RATE) FROM RIN5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN ((T3.SUMAPPLIED/T0.DOCTOTAL)*(SELECT MAX(TaxbleAmnt) FROM RIN5 WHERE AbsEntry=T3.DocEntry)) *(T1.RATE/100)
    ELSE T3.U_WtaxPay
END  AS 'WTAmnt',

T0.WTSum, T0.U_WTax ,
T3.U_GROSSAMT- 
CASE WHEN T3.U_GROSSAMT- T3.U_WTax=T3.U_GROSSAMT 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
    ),'')
    ELSE T3.U_WTax     
 END AS  'DOCTOTAL'  ,
T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,

ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

ISNULL((SELECT TOP 1 CONCAT(TI.U_ATCDesc,TI.U_EXTDESC ) FROM OWHT TI 
 WHERE  T1.AbsEntry =T0.DocNum AND TI.WTCode = T1.WTCode),
ISNULL((SELECT A0.U_ATCNAME FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
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
(SELECT COUNT(*) from RCT2 T6 WHERE T6.DOCNUM = @DocNum) AS 'ROWS'

FROM ORIN T0 
LEFT JOIN RIN5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN RCT2 T3 ON T0.DOCNUM = T3.Docentry  AND T3.InvType=14

WHERE T3.DocNum = @DOCNUM
AND T0.CANCELED='N'

 )T
WHERE ATC LIKE '%'+@ATC+'%'
AND ATC NOT LIKE '%WB%'
AND ATC NOT LIKE '%WV%'
AND QTR =@QTR
AND T.[ATC] IS NOT NULL
ORDER BY TaxDate
OFFSET @GRP ROWS FETCH NEXT 15 ROWS ONLY

ELSE IF (@INVnum  > 0) AND (@INV =1)

SELECT *,
CASE 
    WHEN T.WTAmnt IS NULL 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T.U_wTaxComCode 
    ),'')
    ELSE 
    T.WTAmnt + ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
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
    WHEN (SELECT COUNT(RATE) FROM INV5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN (SELECT MAX(TaxbleAmnt) FROM INV5 WHERE AbsEntry=T3.DocEntry)
    ELSE ISNULL(TaxbleAmnt,T0.DocTotal-T0.VatSum)
END AS 'TaxbleAmnt',
CASE 
    WHEN (SELECT COUNT(RATE) FROM INV5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN ((T3.SUMAPPLIED/T0.DOCTOTAL)*(SELECT MAX(TaxbleAmnt) FROM INV5 WHERE AbsEntry=T3.DocEntry)) *(T1.RATE/100)
    ELSE T3.U_WtaxPay
END  AS 'WTAmnt',

T0.WTSum, T0.U_WTax ,
T3.U_GROSSAMT- 
CASE WHEN T3.U_GROSSAMT- T3.U_WTax=T3.U_GROSSAMT 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
    ),'')
    ELSE T3.U_WTax     
 END AS  'DOCTOTAL'  ,
T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,

ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

ISNULL((SELECT TOP 1 CONCAT(TI.U_ATCDesc,TI.U_EXTDESC ) FROM OWHT TI 
 WHERE  T1.AbsEntry =T0.DocNum AND TI.WTCode = T1.WTCode),
ISNULL((SELECT A0.U_ATCNAME FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
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

(SELECT COUNT(*) from RCT2 T6 WHERE T6.DOCNUM = @DocNum) AS 'ROWS'

FROM OINV T0 
LEFT JOIN INV5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN RCT2 T3 ON T0.DOCNUM= T3.Docentry

WHERE T3.DocNum = @DOCNUM AND T0.DocNum=@INVnum
AND T0.CANCELED='N'
AND T3.InvType=18

 )T
WHERE ATC LIKE '%'+@ATC+'%'
AND ATC NOT LIKE '%WB%'
AND ATC NOT LIKE '%WV%'
AND QTR =@QTR
AND T.[ATC] IS NOT NULL
ORDER BY TaxDate

ELSE IF (@INVnum  > 0) AND (@INV =2)
--APDPI
SELECT *,
CASE 
    WHEN T.WTAmnt IS NULL 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T.U_wTaxComCode 
    ),'')
    ELSE 
    T.WTAmnt + ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
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
    WHEN (SELECT COUNT(RATE) FROM DPI5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN (SELECT MAX(TaxbleAmnt) FROM DPI5 WHERE AbsEntry=T3.DocEntry)
    ELSE ISNULL(TaxbleAmnt,T0.DocTotal-T0.VatSum)
END AS 'TaxbleAmnt',
CASE 
    WHEN (SELECT COUNT(RATE) FROM DPI5 WHERE AbsEntry=T3.DocEntry)>1 
    THEN ((T3.SUMAPPLIED/T0.DOCTOTAL)*(SELECT MAX(TaxbleAmnt) FROM DPI5 WHERE AbsEntry=T3.DocEntry)) *(T1.RATE/100)
    ELSE T3.U_WtaxPay
END  AS 'WTAmnt',

T0.WTSum, T0.U_WTax,
T3.U_GROSSAMT- 
CASE WHEN T3.U_GROSSAMT- T3.U_WTax=T3.U_GROSSAMT 
    THEN ISNULL((SELECT A1.U_WtaxPay FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
    ),'')
    ELSE T3.U_WTax     
 END AS  'DOCTOTAL'  ,
T3.SUMAPPLIED,BASEAMNT,u_wtaxpay,T3.U_GROSSAMT,

ISNULL((SELECT TI.U_ATC FROM OWHT TI
WHERE T1.AbsEntry=T0.DocNum AND TI.WTCode = T1.WTCode ),
ISNULL((SELECT A0.U_ATCCODE FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
    WHERE A1.DocNum=T3.DocNum  AND A0.U_ATCcode IS NOT NULL  AND A1.InvType=30  AND A1.U_wTaxComCode=T3.U_wTaxComCode 
),'')) AS 'ATC',

ISNULL((SELECT TOP 1 CONCAT(TI.U_ATCDesc,TI.U_EXTDESC ) FROM OWHT TI 
 WHERE  T1.AbsEntry =T0.DocNum AND TI.WTCode = T1.WTCode),
ISNULL((SELECT A0.U_ATCNAME FROM JDT1 A0 INNER JOIN RCT2 A1 ON A0.TransId=A1.DocEntry 
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

(SELECT COUNT(*) from RCT2 T6 WHERE T6.DOCNUM = @DocNum) AS 'ROWS'

FROM ODPI T0 
LEFT JOIN DPI5 T1 ON T1.AbsEntry=T0.DocNum
INNER JOIN RCT2 T3 ON T0.DOCNUM= T3.Docentry

WHERE T3.DocNum = @DOCNUM AND T0.DocNum=@INVnum
AND T0.CANCELED='N'
AND T3.InvType=204

 )T
WHERE ATC LIKE '%'+@ATC+'%'
AND ATC NOT LIKE '%WB%'
AND ATC NOT LIKE '%WV%'
AND QTR =@QTR
AND T.[ATC] IS NOT NULL
ORDER BY TaxDate
