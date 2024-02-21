
-- No 1  Open Sales Order
SELECT  T0.DocDate,DocNum,CardName,DocTotal,DocStatus,T1.OCRCODE 
FROM ORDR T0
INNER JOIN RDR1 T1 ON T0.DOCNUM=T1.DocEntry
where DocStatus <>'c'
GROUP BY T0.DocDate,DocNum,CardName,DocTotal,DocStatus,T1.OCRCODE 

-- ==== QUERY #2 AR Invoice Without Base Doc. from Sales Order
SELECT T0.DocDate,DocNum,CardName,DocTotal,DocStatus,T2.OCRCODE from oinv t0
INNER JOIN INV1 T2 ON T2.DocEntry=T0.DOCNUM
LEFT JOIN inv21 t1 on t0.docnum=t1.docentry AND T1.RefObjType =17
WHERE t1.docentry is NULL
GROUP BY T0.DocDate,DocNum,CardName,DocTotal,DocStatus,T2.OCRCODE
-- ==== END QUERY 

-- NO.3  Drop Ship (Sales Order) Without Base Doc. From Purchase Request
SELECT T0.DocDate,DocNum,CardName,DocTotal,DocStatus,T1.OCRCODE FROM ORDR T0
INNER JOIN RDR1 T1 ON T0.DOCNUM=T1.DocEntry
LEFT JOIN PRQ1 T2 ON T0.DOCNUM=T2.BASEREF AND T2.BASETYPE =17
WHERE  U_BO_DSDV<>'N' AND T2.BASEREF IS NULL
GROUP BY T0.DocDate,DocNum,CardName,DocTotal,DocStatus,T1.OCRCODE

-- No.4 Drop Ship (Sales Order) Without AR Down Payment Invoice
SELECT T0.DocDate,DocNum,CardName,DocTotal,DocStatus,T1.OCRCODE FROM ORDR T0
INNER JOIN RDR1 T1 ON T0.DOCNUM=T1.DocEntry
LEFT JOIN DPI1 T2 ON T0.DOCNUM=T2.BASEREF AND T2.BASETYPE =17
WHERE  U_BO_DSDV<>'N' --AND T2.BASEREF IS NULL
AND (U_SO_Cash='Y' OR U_SO_PDC='Y' OR U_BO_Cash='Y' OR U_BO_PDC='Y')
GROUP BY T0.DocDate,DocNum,CardName,DocTotal,DocStatus,T1.OCRCODE


-- No. 5 Picked Up/Delivered Goods without AR Invoice
SELECT T0.DocDate,DocNum,CardName,DocTotal,DocStatus,T1.OCRCODE,T1.U_PickUpLoc
FROM ODPI T0
INNER JOIN DPI1 T1 ON T0.DocNum=T1.DocEntry
LEFT JOIN INV9 T2 ON T2.BaseAbs=T0.DocNum 
WHERE T2.BaseAbs IS NULL
GROUP BY T0.DocDate,DocNum,CardName,DocTotal,DocStatus,T1.OCRCODE,T1.U_PickUpLoc


-- No. 6 Sales Return (Credit Memo) without Base Doc. from AR Invoice
SELECT T0.DocDate,DocNum,CardName,DocTotal,T1.OCRCODE
FROM ORIN T0
INNER JOIN RIN1 T1 ON T0.DocNum=T1.DocEntry
LEFT JOIN RIN21 T2 ON T0.DocNUM=T2.DocEntry --AND T2. RefObjType=13
WHERE (T2.RefObjType<>13 OR T2.RefObjType IS NULL)
GROUP BY T0.DocDate,DocNum,CardName,DocTotal,T1.OCRCODE

-- No. 7  Sales Order (Due to Customer and Sales Order) without AR CM Referenced Doc
SELECT T0.DocDate,DocNum,CardName,DocTotal,T1.OCRCODE
FROM ORDR T0
INNER JOIN RDR1 T1 ON T0.DocNum=T1.DocEntry
LEFT JOIN RDR21 T2 ON T0.DocNum=T2.DocEntry
WHERE (T2.RefObjType<>13 OR T2.RefObjType IS NULL)
AND (U_SO_DTC='Y' OR U_SO_CM='Y')
AND  (T2.RefObjType<>14 OR T2.RefObjType IS NULL)
GROUP BY T0.DocDate,DocNum,CardName,DocTotal,T1.OCRCODE

-- No.8  Goods Receipt PO without  Base Doc. from Purchase Order
SELECT T0.DocDate,DocNum,CardName,DocTotal,T1.OCRCODE
FROM OPDN T0
INNER JOIN PDN1 T1 ON  T0.DocNum=T1.DocEntry
LEFT JOIN PDN21 T2 ON T0.DocNum=T2.DocEntry
WHERE (T2.RefObjType<>22 OR T2.RefObjType IS NULL)
GROUP BY T0.DocDate,DocNum,CardName,DocTotal,T1.OCRCODE



SELECT * FROM PDN21 WHERE DocEntry=534

 -- DocDate	DocNum	Customer 	DocTotal	Store
 