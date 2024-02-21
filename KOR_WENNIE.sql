

-- SELECT DISTINCT A2.INMPrice,A2.DocEntry,A0.BaseEntry,A2.Quantity,A2.ItemCode,A2.WhsCode,A2.ObjType,'PO'AS 'RTYPE',a2.DocEntry AS 'PO_#'
-- 	 FROM PRQ1 A0 
-- 			INNER JOIN PQT1 A1 ON A0.DocEntry=A1.BaseEntry
-- 			INNER JOIN POR1 A2 ON A1.DocEntry=A2.BaseEntry
-- 			-- INNER JOIN OPOR A3 ON A2.DocEntry=A3.DocNum
-- 			WHERE A2.BaseType=540000006  --AND A3.CANCELED='N'
-- 			AND A2.ITEMCODE IS NOT NULL
-- 			AND A2.DOCENTRY NOT IN (SELECT T.BASEENTRY FROM PCH1 T INNER JOIN OPCH TT ON T.DocEntry=TT.DOCNUM WHERE T.BaseType=22 AND CANCELED='N' AND ITEMCODE IS NOT NULL)
--             and a0.BaseEntry=6375



-- select * FROM pqt1 where DocEntry=640
-- select T1.Quantity,* FROM prq1 T0
-- INNER JOIN PQT1 T1 ON T0.DocEntry=T1.BaseEntry
--  where T0.DocEntry=642



--//INVNTORY
-- SELECT T0.WhsCode, T0.ItemCode, T1.ItemName, InvntryUom, T0.OnHand,t0.AvgPrice
-- FROM OITW T0 
-- INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode 
-- WHERE WhsCode LIKE '%KOROSTBS%'
-- AND T0.OnHand <>0

--//PARENT CHILD
-- SELECT UgpCode,UgpName,UomName,BaseQty
--  FROM OUGP t0 
-- inner join ugp1 t1 ON T0.UgpEntry=T1.UgpEntry
-- INNER JOIN OUOM T2 ON T1.UomEntry=T2.UomEntry
-- WHERE  (select count(UgpEntry) from UGP1 where UgpEntry=t0.UgpEntry)>1
-- ORDER BY  T0.UgpCode

--//ITEM SERIALLIZATON
-- SELECT T0.ItemCode,T0.ItemName,T1.Quantity,T1.IntrSerial, T0.InvntryUom
-- FROM OITM T0 
-- INNER JOIN OSRI T1 ON T1.ItemCode=T0.ItemCode
-- WHERE WhsCode LIKE'%KOROST%' 




SELECT * FROM OSRI WHERE ItemCode='0007222PWGDR'

SELECT ItemCode,ItemName,Quantity,IntrSerial,InvntryUom,* FROM OSRI WHERE WhsCode LIKE'%KOROST%' 


SELECT T0.ItemCode,T0.ItemName,T1.Quantity,T1.IntrSerial, T0.InvntryUom
FROM OITM T0 
INNER JOIN OSRI T1 ON T1.ItemCode=T0.ItemCode
WHERE WhsCode LIKE'%KOROST%' 
ORDER BY T0.ItemCode


