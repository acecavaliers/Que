SELECT DOCNUM, DSCRIPTION,Quantity,T1.UomCode,T0.DocDate,'1' as 'ALt QTY',T4.UOMCODE,
concat((case when T4.UOMCODE ='KG' then cast(Altqty as INT) else cast(T3.BaseQty as INT) end),' ', 'KG') as 'Alt/BaseQty'  
FROM OINV T0
INNER JOIN INV1 T1 ON T0.DOCNUM=T1.DocEntry
INNER JOIN OITM T2 ON T1.ItemCode=T2.ItemCode
inner JOIN UGP1 T3 ON T2.UgpEntry=T3.UgpEntry
RIGHT JOIN OUOM T4 ON T3.UomEntry=T4.UomEntry
WHERE T1.Dscription LIKE '%TIE wire%'
AND T0.DocDate BETWEEN '2021-01-01' AND '2021-10-02'
AND T1.OcrCode ='KOR_STR2'