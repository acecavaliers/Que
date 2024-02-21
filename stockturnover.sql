



-- DECLARE @ITM VARCHAR(50)='',
-- @PERIODFROM DATE={?DATEFROM},
-- @PERIODTO DATE={?DATETO},
-- @STR VARCHAR(50)='{?Str}'



DECLARE @ITM VARCHAR(50)='',
@PERIODFROM DATE='2023-01-01',
@PERIODTO DATE='2023-08-31',
@STR VARCHAR(50)='KOROSTGS'


SELECT DD.ItemCode,TT.ItemName,REPLACE(WSH,'KORKM2GS','KOROSTGS') AS WSH, SUM(invQty) as 'Invoice Total Qty',SUM(invAmt) as 'Invoice Total Amount',SUM(OpenQty) as 'OpenQty',SUM(OpenAmount) as 'OpenAmount',
SUM(ClosingQty) as 'ClosingQty',SUM(ClosingAmount) as 'ClosingAmount'
FROM(
    SELECT ItemCode,REPLACE(Warehouse,'KORKM2GS','KOROSTGS') AS WSH,SUM(InvoiceTotalQty) as 'invQty',
    SUM(InvoiceTotalAmount) as 'invAmt'

    ,ISNULL(
        ABS(
            (
                SELECT SUM(InQty) - SUM(OutQty)
                FROM (
                    SELECT ItemCode, InQty, OutQty
                    FROM OINM
                    WHERE ItemCode = xx.ItemCode
                        AND Warehouse = XX.Warehouse
                        AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND DATEADD(DAY, -1, @PERIODFROM)
                ) dd
                WHERE ItemCode = XX.ItemCode
                GROUP BY ItemCode
            )
        ),
        SUM(OpeningQty)
    ) AS 'OpenQty'


    ,ISNULL((SELECT
            CASE
                WHEN YEAR(TAXDATE) <> YEAR(createDate) THEN 
                    TransValue +
                    (
                        SELECT Balance
                        FROM OINM
                        WHERE ItemCode = xx.ItemCode
                        AND Warehouse = XX.Warehouse
                        AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND DATEADD(DAY, -1, @PERIODFROM)
                        AND TransType <> 18
                        ORDER BY TaxDate DESC,TransSeq DESC
                        OFFSET 1 ROW FETCH NEXT 1 ROW ONLY
                    )
                ELSE
                    Balance + ISNULL(
                        (
                            SELECT SUM(TransValue)
                            FROM OINM
                            WHERE ItemCode = xx.ItemCode
                            AND Warehouse = XX.Warehouse
                            AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND DATEADD(DAY, -1, @PERIODFROM)
                            AND TransType IN (60, 59)
                            AND YEAR(CreateDate) > YEAR(TaxDate)
                        ),
                        0
                    )
            END
        FROM OINM
        WHERE ItemCode = xx.ItemCode
        AND Warehouse = XX.Warehouse
        AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND DATEADD(DAY, -1, @PERIODFROM)
        AND TransType <> 18
        ORDER BY  TaxDate DESC,TransSeq DESC
        OFFSET 0 ROW FETCH NEXT 1 ROW ONLY 
    ),0) AS 'OpenAmount'


    ,ABS(
        (
            SELECT SUM(InQty) - SUM(OutQty)
            FROM (
                SELECT ItemCode, InQty, OutQty
                FROM OINM
                WHERE ItemCode = xx.ItemCode
                AND Warehouse = XX.Warehouse
                AND TaxDate BETWEEN @PERIODFROM AND @PERIODTO
            ) dd
            WHERE ItemCode = XX.ItemCode
            GROUP BY ItemCode
        )
        +
        IIF(
            SUM(OpeningQty) > 0,
            SUM(OpeningQty),
            (
                SELECT SUM(InQty) - SUM(OutQty)
                FROM (
                    SELECT ItemCode, InQty, OutQty
                    FROM OINM
                    WHERE ItemCode = xx.ItemCode
                    AND Warehouse = XX.Warehouse
                    AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND DATEADD(DAY, -1, @PERIODFROM)
                ) dd
                WHERE ItemCode = XX.ItemCode
                GROUP BY ItemCode
            )
        )
    ) AS 'ClosingQty'

    ,ISNULL(IIF(
        (SELECT Balance FROM oinm
            WHERE TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND DATEADD(DAY, -1, @PERIODFROM)
            AND ItemCode = XX.itemcode
            ORDER BY  createDate DESC,TransSeq DESC
            OFFSET 0 ROW FETCH NEXT 1 ROW ONLY) = 0
        AND
        (SELECT Balance FROM oinm
            WHERE TaxDate BETWEEN @PERIODFROM AND @PERIODTO
            AND ItemCode = XX.itemcode
            ORDER BY  createDate DESC,TransSeq DESC
            OFFSET 0 ROW FETCH NEXT 1 ROW ONLY) IS NULL,
        0,
        ISNULL(
            (SELECT
                CASE WHEN TRANSTYPE=20 AND (SELECT U_APCPRICEAP FROM OPCH P1 INNER JOIN PCH1 PP ON P1.DOCNUM=PP.DOCENTRY 
                    WHERE CANCELED='N' AND PP.BaseEntry=AAA.BASE_REF AND PP.BASETYPE=20 AND ItemCode=AAA.ItemCode)='Y' THEN 
                    (SELECT BALANCE FROM OINM WHERE TRANSTYPE=18 AND BASE_REF=(SELECT TrgetEntry FROM PDN1 WHERE DOCENTRY=AAA.BASE_REF AND ItemCode=AAA.ItemCode) AND ItemCode=AAA.ItemCode)
                
                ELSE Balance  END
            
            FROM OINM AAA
                WHERE ItemCode = xx.ItemCode
                AND Warehouse = XX.Warehouse
                AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM)  AND @PERIODTO
                AND TransValue<>0
                -- AND TransType <> 18
                ORDER BY createDate DESC,TransSeq DESC
                OFFSET 0 ROW FETCH NEXT 1 ROW ONLY),
            IIF(
                (SELECT COUNT(ItemCode) FROM OINM A0
                    WHERE ItemCode = XX.itemcode
                    AND Warehouse = XX.Warehouse
                    AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND @PERIODTO) = 1,
                (SELECT Balance FROM OINM A0
                    WHERE ItemCode = XX.itemcode
                    AND Warehouse = XX.Warehouse
                    AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND @PERIODTO),
                0
            )
        )
    ),0) AS 'ClosingAmount'

    FROM(

        SELECT ItemCode,Warehouse,OutQty-ISNULL((SELECT Quantity FROM RIN1 WHERE BASETYPE =OINM.TransType AND BASEENTRY=OINM.BASE_REF AND ItemCode=OINM.ItemCode),0)
        as 'InvoiceTotalQty'
        ,COGSVAL as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
        and TransType=13 and TaxDate BETWEEN @PERIODFROM and @PERIODTO
        AND BASE_REF NOT IN 
        (SELECT DocNum FROM INV1 A1 INNER JOIN OINV TT ON TT.DocNum=A1.DOCENTRY WHERE TT.ObjType =OINM.TransType AND A1.DocEntry=OINM.BASE_REF AND ItemCode=OINM.ItemCode AND TT.CANCELED <>'N')

        union all 

        SELECT ItemCode,Warehouse,0 as 'InvoiceTotalQty'
        ,COGSVAL as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
        and TransType=14 and TaxDate BETWEEN @PERIODFROM and @PERIODTO    

        union all 

        SELECT ItemCode,Warehouse,OutQty-ISNULL((SELECT Quantity FROM RIN1 WHERE BASETYPE =OINM.TransType AND BASEENTRY=OINM.BASE_REF AND ItemCode=OINM.ItemCode),0)
        as 'InvoiceTotalQty'
        ,COGSVAL as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
        and TransType =15 and TaxDate BETWEEN @PERIODFROM and @PERIODTO

        union all 

        SELECT ItemCode,Warehouse,OutQty-ISNULL((SELECT Quantity FROM RIN1 WHERE BASETYPE =OINM.TransType AND BASEENTRY=OINM.BASE_REF AND ItemCode=OINM.ItemCode),0)
        as 'InvoiceTotalQty'
        ,COGSVAL as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
        and TransType =60   
        and CardName like'%Cost of sales%' 
        and TaxDate BETWEEN @PERIODFROM and @PERIODTO

        union all 

        SELECT ItemCode,Warehouse,OutQty-ISNULL((SELECT Quantity FROM RIN1 WHERE BASETYPE =OINM.TransType AND BASEENTRY=OINM.BASE_REF AND ItemCode=OINM.ItemCode),0)
        as 'InvoiceTotalQty'
        ,COGSVAL as 'InvoiceTotalAmount' ,0 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
        and TransType =59  
        and CardName like'%Cost of sales%'
        and TaxDate BETWEEN @PERIODFROM and @PERIODTO

        union all 

        SELECT ItemCode,Warehouse,0 as 'InvoiceTotalQty',0 as 'InvoiceTotalAmount',InQty as 'OpeningQty',Balance as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
        and TransType =310000001 and TaxDate BETWEEN @PERIODFROM and @PERIODTO

        union all 

        SELECT ItemCode,Warehouse,0 as 'InvoiceTotalQty',0 as 'InvoiceTotalAmount',InQty as 'OpeningQty',Balance as  'OpeningAmount',0 as clsqty,Balance as clsamt
        from OINM A0
        where REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
        -- and ItemCode not in('0005705PTWRB','0004227ETPMP','0005605ELAC3','0006008PTWRB') 
        and TransType =310000001 and TaxDate BETWEEN DATEADD(YEAR,-1,@PERIODFROM) and DATEADD(DAY,-1,@PERIODFROM)    

        union all 

        SELECT ItemCode,Warehouse,0 as 'InvoiceTotalQty',0 as 'InvoiceTotalAmount',0 as 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
        and TransType IN (20,67,69) and  TaxDate BETWEEN DATEADD(YEAR,-1,@PERIODFROM) and @PERIODTO 
        
        union all 

        SELECT ItemCode,Warehouse,0 as 'InvoiceTotalQty',0 as 'InvoiceTotalAmount',0 as 'OpeningQty',0 as  'OpeningAmount',0 as clsqty,0 as clsamt
        from OINM 
        where REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
        and TransType =10000071 and TransValue <>0 and  TaxDate BETWEEN DATEADD(YEAR,-1,@PERIODFROM) and @PERIODTO  

    )XX

    GROUP BY ItemCode,Warehouse
)DD
INNER JOIN OITM TT ON DD.ItemCode=TT.ItemCode AND InvntItem ='Y'
where TT.ItemName LIKE '%'+@ITM+'%'
GROUP BY DD.ItemCode,TT.ItemName,WSH
