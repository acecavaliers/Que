
DECLARE @ITM VARCHAR(50)='',
@PERIODFROM DATE='2023-01-01',
@PERIODTO DATE='2023-08-31',
@STR VARCHAR(50)='KOROSTGS'

SELECT *
    ,(SELECT dbo.udf_stockTurnoverOpenAmnt(DD.ItemCode,@PERIODFROM,DD.Warehouse)) as AA
    ,(SELECT dbo.udf_stockTurnoverCloseAmnt(DD.ItemCode,@PERIODFROM,@PERIODTO,DD.Warehouse)) as CC


FROM(

SELECT T0.ITEMCODE,ITEMNAME,Warehouse,SUM(InvoiceTotalAmount) as 'invAmt'


FROM OITM T0
INNER JOIN (
        SELECT ItemCode,Warehouse,OutQty-ISNULL((SELECT Quantity FROM RIN1 WHERE BASETYPE =OINM.TransType AND BASEENTRY=OINM.BASE_REF AND ItemCode=OINM.ItemCode),0)
        as 'InvoiceTotalQty'
        ,COGSVAL as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where TransType=13 and TaxDate BETWEEN @PERIODFROM and @PERIODTO
        AND BASE_REF NOT IN 
        (SELECT DocNum FROM INV1 A1 INNER JOIN OINV TT ON TT.DocNum=A1.DOCENTRY WHERE TT.ObjType =OINM.TransType AND A1.DocEntry=OINM.BASE_REF AND ItemCode=OINM.ItemCode AND TT.CANCELED <>'N')
        AND REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR

        union all 

        SELECT ItemCode,Warehouse,0 as 'InvoiceTotalQty'
        ,COGSVAL as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where TransType=14 and TaxDate BETWEEN @PERIODFROM and @PERIODTO    
        AND REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR

        union all 

        SELECT ItemCode,Warehouse,OutQty-ISNULL((SELECT Quantity FROM RIN1 WHERE BASETYPE =OINM.TransType AND BASEENTRY=OINM.BASE_REF AND ItemCode=OINM.ItemCode),0)
        as 'InvoiceTotalQty'
        ,COGSVAL as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where TransType =15 and TaxDate BETWEEN @PERIODFROM and @PERIODTO
        AND REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR

        union all 

        SELECT ItemCode,Warehouse,OutQty-ISNULL((SELECT Quantity FROM RIN1 WHERE BASETYPE =OINM.TransType AND BASEENTRY=OINM.BASE_REF AND ItemCode=OINM.ItemCode),0)
        as 'InvoiceTotalQty'
        ,COGSVAL as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where TransType =60   
        and CardName like'%Cost of sales%' 
        and TaxDate BETWEEN @PERIODFROM and @PERIODTO
        AND REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR

        union all 

        SELECT ItemCode,Warehouse,OutQty-ISNULL((SELECT Quantity FROM RIN1 WHERE BASETYPE =OINM.TransType AND BASEENTRY=OINM.BASE_REF AND ItemCode=OINM.ItemCode),0)
        as 'InvoiceTotalQty'
        ,COGSVAL as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where TransType =59  
        and CardName like'%Cost of sales%'
        and TaxDate BETWEEN @PERIODFROM and @PERIODTO
        AND REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR

        union all 

        SELECT ItemCode,Warehouse,0 as 'InvoiceTotalQty',0 as 'InvoiceTotalAmount',InQty as 'OpeningQty',Balance as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where TransType =310000001 and TaxDate BETWEEN @PERIODFROM and @PERIODTO
        AND REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR

        union all 

        SELECT ItemCode,Warehouse,0 as 'InvoiceTotalQty',0 as 'InvoiceTotalAmount',InQty as 'OpeningQty',Balance as  'OpeningAmount',0 as clsqty,Balance as clsamt
        from OINM A0
        where TransType =310000001 and TaxDate BETWEEN DATEADD(YEAR,-1,@PERIODFROM) and DATEADD(DAY,-1,@PERIODFROM)  
        AND REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR  

        union all 

        SELECT ItemCode,Warehouse,0 as 'InvoiceTotalQty',0 as 'InvoiceTotalAmount',0 as 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where TransType IN (20,67,69) and  TaxDate BETWEEN DATEADD(YEAR,-1,@PERIODFROM) and @PERIODTO 
        AND REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
        
        union all 

        SELECT ItemCode,Warehouse,0 as 'InvoiceTotalQty',0 as 'InvoiceTotalAmount',0 as 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where TransType =10000071 and TransValue <>0 and  TaxDate BETWEEN DATEADD(YEAR,-1,@PERIODFROM) and @PERIODTO 
        AND REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
)T1 ON T1.ItemCode=T0.ItemCode
WHERE InvntItem ='Y' AND ItemType='I'
GROUP BY T0.ItemCode,T0.ItemName,Warehouse
)DD
-- PIVOT
-- (
--     SUM(invAmt) FOR Warehouse IN (KOROSTGS,KORATPGS,GSNAPGS,GSCDCCGS)
-- ) AS p

-- GROUP BY ItemCode