

-- DECLARE @DATEFROM DATE ={?PeriodFrom}, 
-- @DATETO DATE = {?PeriodTo},
-- @DEPARTMENT VARCHAR(100)='{?Department}',
-- @CATEGORY VARCHAR(100)='',
-- @STORE VARCHAR(50)='{?Store}',
-- @SortBy VARCHAR(100)='{?SortBy}'



 DECLARE 
 @DATEFROM DATE ='2023-01-01', 
 @DATETO DATE ='2023-12-31',
 @DEPARTMENT VARCHAR(100)='',
 @CATEGORY VARCHAR(100)='',
 @ITEMNAME VARCHAR(200)='',
 @STORE VARCHAR(50)='gsc_dcc',
 @SortBy VARCHAR(100)='Total Quantity'
  

SET @STORE=REPLACE(REPLACE(@STORE,'ALL (Top from all Store)',''),'ALL (Top per Store)','')

SELECT * from(
select 
[Item Code] as 'Itemcode',
DESCRPTN as 'ItemName',
Department,
Category,
Store,
unit as 'UomCode',
SUM(TOTALQTY) as 'Total Quantity Sold',
SUM(TOTALCOST) as 'Cost',
SUM(TOTALSALES) as 'Total Sales',
CAST(SUM(TOTALSALES) AS FLOAT) - CAST(SUM(TOTALCOST) AS FLOAT) as 'Gross Profit',
CASE 
		WHEN (SUM(TOTALSALES) - SUM(TOTALCOST)) / nullif( SUM(TOTALSALES) , 0 ) > 0 
		THEN isnull((SUM(TOTALSALES) - SUM(TOTALCOST)) / nullif( SUM(TOTALSALES) , 0 ) * 100, 0 )
		ELSE isnull((SUM(TOTALSALES) - SUM(TOTALCOST)) / nullif( SUM(TOTALSALES) , 0 ) , 0 ) 
	END as 'Gross Profit Percentage'

from(
SELECT 
XX.Transaction#,
XX.[Item Code],
XX.DESCRPTN,
Department,
Category,
Store,
unit,
XX.[Quantity Sold] AS TOTALQTY,
XX.COST*XX.[Quantity Sold] AS TOTALCOST,
XX.TotalSales*XX.[Quantity Sold] AS TOTALSALES,
Whse
-- max(replace(left(Whse,6),'KORKM2','KOROST')) AS WhsCode

-- CAST((SUM(TotalSales)*SUM(XX.[Quantity Sold])) AS FLOAT) - CAST((SUM(Cost)*SUM(XX.[Quantity Sold])) AS FLOAT) as 'Gross Profit',
-- CASE 
-- 	WHEN ((SUM(TotalSales)*SUM(XX.[Quantity Sold])) - (SUM(Cost))*SUM(XX.[Quantity Sold])) / nullif( (SUM(TotalSales)*SUM(XX.[Quantity Sold])) , 0 ) > 0 
-- 	THEN isnull(((SUM(TotalSales)*SUM(XX.[Quantity Sold])) - (SUM(Cost)*SUM(XX.[Quantity Sold]))) / nullif( (SUM(TotalSales)*SUM(XX.[Quantity Sold])) , 0 ) * 100, 0 )
-- 	ELSE isnull(((SUM(TotalSales)*SUM(XX.[Quantity Sold])) - (SUM(Cost)*SUM(XX.[Quantity Sold]))) / nullif( (SUM(TotalSales)*SUM(XX.[Quantity Sold])) , 0 ) , 0 ) 
-- END as 'Gross Profit Percentage'

FROM(

--STANDARD AR
SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,'' AS 'DE-AP', '' AS 'TRANSTYPE',
    T3.BPLID AS 'BRANCH ID',
    'AR INVOICE' AS 'TYPE',
    T1.U_Category AS 'Category',
    T0.DocEntry AS 'Transaction#',T6.Number,
    T3.TaxDate AS 'Posting Date',
    t3.U_DocSeries AS 'Invoice No.',
    '' AS 'Reference',
    '' AS 'ReferenceDate',
    T3.CardName AS 'Customer',
    T4.CardFName AS 'Foreign Name',
    T3.Comments AS 'Comments',
    T0.WhsCode AS 'Whse',
    T0.OcrCode as Store,
    T0.ItemCode AS 'Item Code',
    T0.unitMsr AS 'unit',
    T0.Dscription AS 'DESCRPTN',
    T0.Quantity AS 'Quantity Sold',
    T0.U_GPBD AS 'Price Before Discount',
    T0.PriceAfVAT AS 'Price After Discount',
    T0.INMPrice AS 'Price After Discount(VAT-Ex)',
    T0.StockValue/T0.Quantity AS 'COST',

    T0.INMPrice * T0.Quantity AS 'TotalSales',
    T0.FreeTxt


    FROM INV1 T0

    INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
    INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
    INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
    INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode 
    INNER JOIN OJDT T6 ON T0.DocEntry=T6.BaseRef AND T6.TransType =13


    WHERE T3.DocType = 'I' 
    AND T1.ItemType <> 'F'     
    AND T3.TaxDate BETWEEN @DATEFROM AND  @DATETO
    AND T3.CANCELED='N'
    AND T3.isIns='N'
    AND T3.U_BO_DRS ='N' AND T3.U_BO_DSDD ='N' AND T3.U_BO_DSDV ='N' AND T3.U_BO_DSPD ='N'

    UNION ALL --AR RESERRVE
    SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,'' AS 'DE-AP','' AS 'TRANSTYPE',
    T3.BPLID AS 'BRANCH ID',
    'AR RESERVE' AS 'TYPE',
    T1.U_Category AS 'Category',
    T0.DocEntry AS 'Transaction#',T6.Number,
    T3.TaxDate AS 'Posting Date',
    t3.U_DocSeries AS 'Invoice No.',
    '' AS 'Reference',
    '' AS 'ReferenceDate',
    T3.CardName AS 'Customer',
    T4.CardFName AS 'Foreign Name',
    T3.Comments AS 'Comments',
    T0.WhsCode AS 'Whse',
    T0.OcrCode as Store,
    T0.ItemCode AS 'Item Code',
    T0.unitMsr AS 'unit',
    T0.Dscription AS 'DESCRPTN',
    T0.Quantity-ISNULL(T7.QTY,0) AS 'Quantity Sold',
    T0.U_GPBD AS 'Price Before Discount',
    T0.PriceAfVAT AS 'Price After Discount',
    T0.INMPrice AS 'Price After Discount(VAT-Ex)',
    CASE WHEN T0.UOMCODE=T0.UOMCODE2 
    THEN (SELECT AvgPrice FROM OITW WHERE ItemCode= T0.ItemCode AND WhsCode=T0.WhsCode) 
    ELSE  (SELECT AvgPrice FROM OITW WHERE ItemCode= T0.ItemCode AND WhsCode=T0.WhsCode)*T0.NumPerMsr
    END AS 'COST',

    T0.INMPrice * (T0.Quantity-ISNULL(T7.QTY,0)) AS 'TotalSales'
    ,NULL AS FreeTxt

    FROM INV1 T0

    INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
    INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
    INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
    INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode 
    INNER JOIN OJDT T6 ON T0.DocEntry=T6.BaseRef AND T6.TransType =13
    LEFT JOIN (SELECT SUM(Quantity)AS QTY,A0.BaseEntry,ITEMCODE FROM DLN1 A0 
                INNER JOIN ODLN A1 ON A0.DocEntry=A1.DocNum 
                WHERE CANCELED='N'
                GROUP BY  A0.BaseEntry ,ItemCode) AS T7 ON T0.DocEntry=T7.BaseEntry
                AND T7.ItemCode=T0.ItemCode

    WHERE T3.DocType = 'I' 
    AND T1.ItemType <> 'F'
    AND T3.TaxDate BETWEEN @DATEFROM AND  @DATETO
    AND T3.CANCELED='N'
    AND T3.isIns='Y'
    AND T3.U_BO_DRS ='N' AND T3.U_BO_DSDD ='N' AND T3.U_BO_DSDV ='N' AND T3.U_BO_DSPD ='N'
    AND T0.Quantity-ISNULL(T7.QTY,0)>0

    UNION ALL --DELIVERIES


    SELECT 
    T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,T0.DocEntry AS 'DE-AP', 15 AS 'TRANSTYPE',
    T3.BPLID AS 'BRANCH ID',
    'DELIVERY' AS 'TYPE',
    T1.U_Category AS 'Category',
    T0.BaseEntry AS 'Transaction#',T6.Number,

    T7.TaxDate AS 'Posting Date',
    T7.U_DocSeries AS 'Invoice No.',
    CONCAT('DN ',T0.DocEntry) AS 'Reference',
    CONVERT(VARCHAR(20),T3.TAXDATE,101) AS 'ReferenceDate',
    T7.CardName AS 'Customer',
    T4.CardFName AS 'Foreign Name',
    T7.Comments AS 'Comments',
    T0.WhsCode AS 'Whse',
    T0.OcrCode as Store,
    T0.ItemCode AS 'Item Code',
    T0.unitMsr AS 'unit',
    T0.Dscription AS 'DESCRPTN',
    T0.Quantity AS 'Quantity Sold',
    T0.U_GPBD AS 'Price Before Discount',
    T0.PriceAfVAT AS 'Price After Discount',
    T0.INMPrice AS 'Price After Discount(VAT-Ex)',
    T0.StockValue/T0.Quantity AS 'COST',
    T0.INMPrice * T0.Quantity AS 'TotalSales'
    ,NULL AS FreeTxt

    FROM DLN1 T0

    INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode AND T1.ItemType<>'F'
    INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
    INNER JOIN ODLN T3 ON T0.DocEntry = T3.DocNum
    INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
    INNER JOIN OJDT T6 ON T0.BaseEntry=T6.BaseRef AND T6.TransType =13 
    LEFT JOIN OINV T7 ON T0.BaseEntry=T7.DocNum


    WHERE T3.DocType = 'I' 
    AND T1.ItemType <> 'F'
    AND T7.TaxDate BETWEEN @DATEFROM AND  @DATETO
    AND T3.CANCELED='N'
    --AND T3.isIns='Y'

    UNION ALL --DROPSHIP--DROPSHIP

    SELECT DISTINCT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,

    -- ISNULL(T6.PO_#,T5.PO_#) AS 'DE-AP',
    -- 12/15 DE-AP
    -- CASE WHEN T6.APCNT>1 AND T6.ARCNT=0 
    -- THEN ''
    -- WHEN T6.APCNT>1 AND T6.ARCNT <> 0 
    -- THEN (SELECT top 1  A.DOCENTRY FROM PCH21 A
    --         INNER JOIN PCH1 B ON A.DocEntry=B.DocEntry 
    --         WHERE RefObjType=13
    --         AND RefDocNum=T0.DocEntry
    --         AND ItemCode=T0.ItemCode)
    -- ELSE 
    -- ISNULL((SELECT top 1 A.DOCENTRY FROM PCH21 A
    --         INNER JOIN PCH1 B ON A.DocEntry=B.DocEntry 
    --         WHERE RefObjType=13
    --         AND RefDocNum=T0.DocEntry
    --         AND ItemCode=T0.ItemCode),
    --     ISNULL(T6.PO_#,T5.PO_#))
    --     END AS 'DE-AP',
    CASE 
        WHEN  T5.PO_# IS NOT NULL 
        THEN T5.PO_#
        WHEN T6.PO_#  IS NOT NULL
        THEN T6.PO_#
        
        WHEN T7.PO_#  IS NOT NULL
        THEN T7.PO_# 
        ELSE ''
    END AS 'DE-AP',


    CASE WHEN ISNULL((SELECT top 1 A.DOCENTRY FROM PCH21 A
            INNER JOIN PCH1 B ON A.DocEntry=B.DocEntry 
            WHERE RefObjType=13
            AND RefDocNum=T0.DocEntry
            AND ItemCode=T0.ItemCode),ISNULL(T5.INMPrice,T6.INMPrice)) IS NOT NULL THEN 18 ELSE 0 END AS 'TRANSTYPE',
    T3.BPLID AS 'BRANCH ID',
    CASE 
        WHEN T3.isIns ='Y' 
        THEN 'AR RESERVE' 
        ELSE 'AR INVOICE' 
    END AS 'TYPE',
    T1.U_Category AS 'Category',
    T0.DocEntry AS 'Transaction#',T10.Number,
    T3.DocDate AS 'Posting Date',
    t3.U_DocSeries AS 'Invoice No.',
    CASE 
        WHEN  T5.DocEntry IS NOT NULL 
        THEN CONCAT('PO ',T5.DocNum)
        WHEN T6.RTYPE  IS NOT NULL
        THEN --CONCAT('AP ',T6.DocNum)
        CASE WHEN T6.APCNT>1 AND T6.ARCNT=0 
        THEN '1-PO M-AP NTagging'
        WHEN T6.APCNT>1 AND T6.ARCNT <> 0 
        THEN (SELECT top 1 CONCAT('AP ',A.DOCENTRY) FROM PCH21 A
                INNER JOIN PCH1 B ON A.DocEntry=B.DocEntry 
                WHERE RefObjType=13
                AND RefDocNum=T0.DocEntry
                AND ItemCode=T0.ItemCode)
        ELSE CONCAT('AP ',T6.DocNum)
        END

        --
        WHEN T7.RTYPE  IS NOT NULL
        THEN CONCAT('AP ',T7.DocNum)
        ELSE (SELECT top 1 CONCAT('AP ',A.DOCENTRY) FROM PCH21 A
                INNER JOIN PCH1 B ON A.DocEntry=B.DocEntry 
                WHERE RefObjType=13
                AND RefDocNum=T0.DocEntry
                AND ItemCode=T0.ItemCode)
    END AS 'Reference',
    
    CASE 
        WHEN  T5.TAXDATE IS NOT NULL
        THEN CONVERT(VARCHAR(20),T5.TAXDATE,101)
        WHEN T6.TAXDATE IS NOT NULL
        THEN --CONVERT(VARCHAR(20),T6.TAXDATE,101)
        CASE WHEN T6.APCNT>1 AND T6.ARCNT=0 
        THEN ''
        WHEN T6.APCNT>1 AND T6.ARCNT <> 0 
        THEN (SELECT top 1  CONVERT(VARCHAR(20),B.DocDate,101)FROM PCH21 A
                INNER JOIN PCH1 B ON A.DocEntry=B.DocEntry 
                WHERE RefObjType=13
                AND RefDocNum=T0.DocEntry
                AND ItemCode=T0.ItemCode)
        ELSE
        CONVERT(VARCHAR(20),T6.TAXDATE,101)
        END
        --
        WHEN T7.RTYPE  IS NOT NULL
        THEN CONVERT(VARCHAR(20),T7.TAXDATE,101)
        ELSE 
            (SELECT top 1 CONVERT(VARCHAR(20),B.DocDate,101)FROM PCH21 A
                INNER JOIN PCH1 B ON A.DocEntry=B.DocEntry 
                WHERE RefObjType=13
                AND RefDocNum=T0.DocEntry
                AND ItemCode=T0.ItemCode)

    END AS 'ReferenceDate',
    T3.CardName AS 'Customer',
    T4.CardFName AS 'Foreign Name',
    CASE 
        WHEN T9.Number IS NULL 
        THEN T3.Comments
        ELSE
        CONCAT(T3.Comments,' ; LC: ',T9.Number) 
    END AS 'Comments',
    T0.WhsCode AS 'Whse',
    T0.OcrCode as Store,
    T0.ItemCode AS 'Item Code',
    T0.unitMsr AS 'unit',
    T0.Dscription AS 'DESCRPTN',
    -- (T0.Quantity - ISNULL(T11.Quantity,0))

    -- AS 'Quantity Sold', 

     CASE 
        WHEN T6.Quantity IS NOT NULL 
        THEN IIF(T6.NumPerMsr>T0.NumPerMsr,(T6.QUANTITY*T6.NumPerMsr),T6.QUANTITY)
        WHEN T7.ARCNT=1
        THEN IIF(T7.NumPerMsr>T0.NumPerMsr,(T7.QUANTITY*T7.NumPerMsr),T7.QUANTITY)
        WHEN T7.ARCNT>1 AND T7.ARLAST=1
        
        THEN IIF(T7.NumPerMsr>T0.NumPerMsr,(T7.QUANTITY*T7.NumPerMsr),T7.QUANTITY)-ISNULL((SELECT SUM(QQ) FROM(
                                SELECT (SELECT SUM(Quantity) FROM INV1 WHERE DocEntry=Z.RefDocNum) AS QQ FROM PCH21 Z 
                                WHERE DocEntry=T7.DocEntry AND RefObjType=13
                                and LineNum<>(SELECT MAX(LineNum) FROM PCH21 WHERE DocEntry=Z.DocEntry)
                                )DDD),0) 

        -- WHEN T7.Quantity IS NOT NULL AND T7.APCNT>1
        -- THEN T0.Quantity
        
        --T7.Quantity

        -- WHEN T6.APCNT>1 AND T6.ARCNT=0 
        -- THEN T0.Quantity
        -- WHEN T6.APCNT>1 AND T6.ARCNT <> 0 
        -- THEN T6.Quantity
        -- WHEN T7.APCNT>1 AND T7.ARCNT=0 
        -- THEN T0.Quantity        
        -- WHEN T7.APCNT>1 AND T7.ARCNT <> 0 
        -- THEN T7.Quantity       
        -- WHEN T7.APCNT=1 AND T7.ARCNT =1 
        -- THEN T7.Quantity
        -- WHEN (SELECT COUNT(DocEntry)AS A FROM PCH21 WHERE RefObjType=13 AND DocEntry=(SELECT DocEntry from pch21 where RefDocNum=T0.DocEntry and RefObjType=13)) >1 
        -- THEN T7.Quantity-ISNULL((SELECT SUM(QQ) FROM(
        --                 SELECT (SELECT SUM(Quantity) FROM INV1 WHERE DocEntry=Z.RefDocNum) AS QQ FROM PCH21 Z 
        --                 WHERE DocEntry=T7.DocEntry AND RefObjType=13
        --                 and LineNum<>(SELECT MAX(LineNum) FROM PCH21 WHERE DocEntry=Z.DocEntry)
        --                 )DDD),0) 
       
    ELSE 
        (T0.Quantity - ISNULL(T11.Quantity,0))
       
    END AS 'Quantity Sold',

    T0.U_GPBD AS 'Price Before Discount',
    T0.PriceAfVAT AS 'Price After Discount',
    T0.INMPrice AS 'Price After Discount(VAT-Ex)',

    IIF(T0.ITEMCODE LIKE '%SVSVS%' ,0,
        CASE 
        WHEN T6.INMPrice IS NOT NULL 
            THEN IIF(T6.NumPerMsr>T0.NumPerMsr,(T6.INMPrice/T6.NumPerMsr),T6.INMPrice) 
            + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])
            *T6.[LANDEDCOST])/(T0.Quantity - ISNULL(T11.Quantity,0)),0)    

            
        WHEN T7.INMPrice IS NOT NULL 
            THEN IIF(T7.NumPerMsr>T0.NumPerMsr,(T7.INMPrice/T7.NumPerMsr),T7.INMPrice) 
            + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])
            *T7.[LANDEDCOST])/(T0.Quantity - ISNULL(T11.Quantity,0)),0)
            
        ELSE IIF(T5.NumPerMsr>T0.NumPerMsr,(T5.INMPrice/T5.NumPerMsr),T5.INMPrice) 
            + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])
            *T5.[LANDEDCOST])/(T0.Quantity - ISNULL(T11.Quantity,0)),0)
        END
    )
                                               
         AS 'COST',

    
    T0.INMPrice*(
        CASE 
        WHEN T6.Quantity IS NOT NULL 
        THEN IIF(T6.NumPerMsr>T0.NumPerMsr,(T6.QUANTITY*T6.NumPerMsr),T6.QUANTITY)
        WHEN T7.ARCNT=1
        THEN IIF(T7.NumPerMsr>T0.NumPerMsr,(T7.QUANTITY*T7.NumPerMsr),T7.QUANTITY)
        WHEN T7.ARCNT>1 AND T7.ARLAST=1
        
        THEN IIF(T7.NumPerMsr>T0.NumPerMsr,(T7.QUANTITY*T7.NumPerMsr),T7.QUANTITY)-ISNULL((SELECT SUM(QQ) FROM(
                                SELECT (SELECT SUM(Quantity) FROM INV1 WHERE DocEntry=Z.RefDocNum) AS QQ FROM PCH21 Z 
                                WHERE DocEntry=T7.DocEntry AND RefObjType=13
                                and LineNum<>(SELECT MAX(LineNum) FROM PCH21 WHERE DocEntry=Z.DocEntry)
                                )DDD),0) 
       
        ELSE 
            (T0.Quantity - ISNULL(T11.Quantity,0))
        
        END)
    AS 'TotalSales'
    ,NULL AS FreeTxt
    FROM INV1 T0
    INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
    INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
    INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
    INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
    --VIA PO
    LEFT JOIN (	
                SELECT TB.NumPerMsr,TA.DocEntry,TC.DocNum,TB.BaseEntry,TC.TaxDate ,TB.Quantity,TB.ItemCode,TB.WhsCode,TB.INMPRICE,TB.DocEntry AS 'PO_#','PO'AS 'RTYPE'
                -- ,CASE 
                -- WHEN TC.U_BrokerCode IS NOT NULL AND (SELECT U_VATType from OCRD where CardCode =TC.U_BrokerCode)='Vatable'
                -- THEN 				
                -- (TC.U_ARRASTRE+TC.U_BROKERAGE_FEE+TC.U_DOC_STAMP+TC.U_FREIGHT+TC.U_LABOR+TC.U_INSURANCE+TC.U_TRUCKING+TC.U_WHARFAGE+TC.U_OTHERS)/1.12 
                -- ELSE 
                -- (TC.U_ARRASTRE+TC.U_BROKERAGE_FEE+TC.U_DOC_STAMP+TC.U_FREIGHT+TC.U_LABOR+TC.U_INSURANCE+TC.U_TRUCKING+TC.U_WHARFAGE+TC.U_OTHERS)
                -- END 
                ,0 AS 'LANDEDCOST'
                FROM INV21 TA
                INNER JOIN POR1 TB ON TA.RefDocNum=TB.DocEntry 
                INNER JOIN OPOR TC ON TB.DocEntry=TC.DocNum
                WHERE 
                TA.RefObjType=22
                AND TC.CANCELED='N'
                AND TB.TrgetEntry=0
                )AS T5
                ON T5.DocEntry=T0.DocEntry
                AND T5.ItemCode=T0.ItemCode 
                -- AND T5.WhsCode=T0.WhsCode
    -- --VIA AP
    LEFT JOIN (
            SELECT TC.NumPerMsr, TA.DocEntry,TD.DocNum,TD.TaxDate ,TC.Quantity,TC.ItemCode,TC.WhsCode,TC.INMPRICE        ,TC.DocEntry AS 'PO_#','AP'AS 'RTYPE'            
            ,(SELECT COUNT(DISTINCT DOCENTRY) FROM PCH1 WHERE BaseType=22 AND BaseEntry=TB.DocEntry) AS APCNT
            ,(SELECT COUNT(DocEntry) FROM PCH21 WHERE RefObjType=13 AND DocEntry=TC.DocEntry) AS ARCNT 
           
           
            -- ,CASE 
            -- WHEN TD.U_BrokerCode IS NOT NULL AND (SELECT U_VATType from OCRD where CardCode =TD.U_BrokerCode)='Vatable'
            -- THEN 				
            -- (TD.U_ARRASTRE+TD.U_BROKERAGE_FEE+TD.U_DOC_STAMP+TD.U_FREIGHT+TD.U_LABOR+TD.U_INSURANCE+TD.U_TRUCKING+TD.U_WHARFAGE+TD.U_OTHERS)/1.12 
            -- ELSE 
            -- (TD.U_ARRASTRE+TD.U_BROKERAGE_FEE+TD.U_DOC_STAMP+TD.U_FREIGHT+TD.U_LABOR+TD.U_INSURANCE+TD.U_TRUCKING+TD.U_WHARFAGE+TD.U_OTHERS)
            -- END 
            ,0 AS 'LANDEDCOST'
            FROM INV21 TA
            INNER JOIN POR1 TB ON TA.RefDocNum=TB.DocEntry 
            INNER JOIN PCH1 TC ON TB.DocEntry=TC.BaseEntry AND TC.BaseType=22
            INNER JOIN OPCH TD ON TC.DocEntry=TD.DocNum 
            WHERE 
            TA.RefObjType=22
            AND TD.CANCELED='N'
            AND TD.DOCNUM NOT IN (SELECT DOCENTRY FROM PCH21 WHERE RefObjType=13)
            ) 
            AS T6
            ON T6.DocEntry=T0.DocEntry
            AND T6.ItemCode=T0.ItemCode
    -- --VIA AP
    LEFT JOIN (
                SELECT TC.NumPerMsr,TT.RefDocNum, TT.DocEntry,TD.DocNum,TD.TaxDate ,TC.Quantity,TC.ItemCode,TC.WhsCode,TC.INMPRICE        ,TC.DocEntry AS 'PO_#','AP'AS 'RTYPE'
                ,(SELECT COUNT(DISTINCT DOCENTRY) FROM PCH1 WHERE BaseType=22 AND BaseEntry=TB.DocEntry) AS APCNT
                ,(SELECT COUNT(DocEntry) FROM PCH21 WHERE RefObjType=13 AND DocEntry=TC.DocEntry) AS ARCNT 
                ,CASE WHEN (SELECT COUNT(DocEntry) FROM PCH21 WHERE RefObjType=13 AND DocEntry=TC.DocEntry)>1 
                        AND (SELECT TOP 1 RefDocNum FROM PCH21 WHERE RefObjType=13 AND DOCENTRY=TC.DOCENTRY ORDER BY LineNum DESC) =RefDocNum
                        THEN 1
                        ELSE 0
                        END
                
                AS ARLAST
                 ,
                --CASE 
                -- WHEN TD.U_BrokerCode IS NOT NULL AND (SELECT U_VATType from OCRD where CardCode =TD.U_BrokerCode)='Vatable'
                -- THEN 				
                -- (TD.U_ARRASTRE+TD.U_BROKERAGE_FEE+TD.U_DOC_STAMP+TD.U_FREIGHT+TD.U_LABOR+TD.U_INSURANCE+TD.U_TRUCKING+TD.U_WHARFAGE+TD.U_OTHERS)/1.12 
                -- ELSE 
                -- (TD.U_ARRASTRE+TD.U_BROKERAGE_FEE+TD.U_DOC_STAMP+TD.U_FREIGHT+TD.U_LABOR+TD.U_INSURANCE+TD.U_TRUCKING+TD.U_WHARFAGE+TD.U_OTHERS)
                -- END 
                0 AS 'LANDEDCOST'
                FROM  PCH21 TT
                INNER JOIN PCH1 TC ON TT.DocEntry=TC.DocEntry --AND TC.BaseType=22
                INNER JOIN OPCH TD ON TC.DocEntry=TD.DocNum 
                INNER JOIN POR1 TB ON TB.DocEntry=TC.BaseEntry AND TC.BaseType=22 
                WHERE 
                TT.RefObjType=13
                AND TD.CANCELED='N'
                ) 
                AS T7
                ON T7.RefDocNum=T0.DocEntry
                AND T7.ItemCode=T0.ItemCode


    --LANDED COST
    LEFT JOIN (SELECT  A0.DOCENTRY,A1.REFDOCNUM,A0.DocTotal-ISNULL(SUM(A3.DocTotal),0) AS 'LANDEDCOST',A2.Number FROM OPCH A0
            INNER JOIN PCH21 A1 ON A0.DOCNUM=A1.DocEntry
            INNER JOIN OJDT A2 ON A0.DocNum=A2.BaseRef AND TransType=18
            LEFT JOIN (SELECT TT.BaseEntry,DocTotal
                FROM ORPC T INNER JOIN RPC1 TT ON T.DocNum=TT.DocEntry 
                WHERE TT.BaseType=18
                )AS A3 ON A0.DocNum=A3.BaseEntry
            WHERE A1.RefObjType=13 AND A0.CANCELED='Z' AND A0.DocType='S'
            GROUP BY A0.DOCENTRY,A1.RefObjType,A1.REFDOCNUM,A1.DOCENTRY,A0.DocTotal,A2.Number) 
            AS T9
            ON T0.DocEntry=T9.REFDOCNUM 
    --JE
    INNER JOIN OJDT T10 ON T0.DocEntry=T10.BaseRef AND T10.TransType =13

    LEFT JOIN (SELECT A1.QUANTITY,A1.ITEMCODE,A0.RefDocNum FROM IGE21 A0
            INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY
            WHERE A0.REFOBJTYPE =13) 
            AS T11 ON T11.REFDOCNUM=T0.DOCENTRY AND T11.ITEMCODE=T0.ITEMCODE

    INNER JOIN (SELECT  DOCENTRY,SUM(A2.INMPrice*(A2.Quantity-ISNULL(A3.Quantity,0))) AS 'SALES SUM' 
                FROM INV1 A2 
                LEFT JOIN (SELECT B1.QUANTITY,REFDOCNUM,B1.ItemCode FROM IGE21 B0
                            INNER JOIN IGE1 B1 ON B0.DOCENTRY=B1.DOCENTRY
                            WHERE B0.REFOBJTYPE =13)
                            AS A3 ON A2.DocEntry=A3.REFDOCNUM AND A2.ItemCode=A3.ItemCode
                GROUP BY DOCENTRY)
            AS T12 ON T0.DocEntry=T12.DocEntry

    WHERE T3.DocType = 'I' 
    AND T1.ItemType <> 'F'
    AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
    AND T3.CANCELED='N'
    AND T3.ISINS='N'
    AND  T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y'  

    UNION ALL --DS PO=AP QTY BALANCE

    SELECT DISTINCT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,

    CASE 
        WHEN  T5.PO_# IS NOT NULL 
        THEN T5.PO_#
        ELSE ''
    END AS 'DE-AP',


    22 AS 'TRANSTYPE',
    T3.BPLID AS 'BRANCH ID',
    CASE 
        WHEN T3.isIns ='Y' 
        THEN 'AR RESERVE' 
        ELSE 'AR INVOICE' 
    END AS 'TYPE',
    T1.U_Category AS 'Category',
    T0.DocEntry AS 'Transaction#',T10.Number,
    T3.DocDate AS 'Posting Date',
    t3.U_DocSeries AS 'Invoice No.',
    
    CONCAT('PO ',T5.DocNum) AS 'Reference',
    
    CONVERT(VARCHAR(20),T5.TAXDATE,101) AS 'ReferenceDate',
    T3.CardName AS 'Customer',
    T4.CardFName AS 'Foreign Name',
    CASE 
        WHEN T9.Number IS NULL 
        THEN T3.Comments
        ELSE
        CONCAT(T3.Comments,' ; LC: ',T9.Number) 
    END AS 'Comments',
    T0.WhsCode AS 'Whse',
    T0.OcrCode as Store,
    T0.ItemCode AS 'Item Code',
    T0.unitMsr AS 'unit',
    T0.Dscription AS 'DESCRPTN',
 

    T5.TTLAPQTY 
     AS 'Quantity Sold',

    T0.U_GPBD AS 'Price Before Discount',
    T0.PriceAfVAT AS 'Price After Discount',
    T0.INMPrice AS 'Price After Discount(VAT-Ex)',
        
    ISNULL( IIF(T5.NumPerMsr>T0.NumPerMsr,(T5.INMPrice/T5.NumPerMsr),T5.INMPrice) + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])*T5.[LANDEDCOST])/T0.Quantity - ISNULL(T11.Quantity,0),0)
    ,0
    )
    AS 'COST',

    
    T0.INMPrice*T5.TTLAPQTY 
    AS 'TotalSales'
    ,NULL AS FreeTxt
    FROM INV1 T0
    INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
    INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
    INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
    INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
    --VIA PO
    LEFT JOIN (	
                SELECT TB.NumPerMsr,TA.DocEntry,TC.DocNum,TB.BaseEntry,TC.TaxDate ,TB.Quantity,TB.ItemCode,TB.WhsCode,TB.INMPRICE,TB.DocEntry AS 'PO_#','PO'AS 'RTYPE'               
                ,0 AS 'LANDEDCOST'
                ,TD.Quantity AS APQ
                
                ,TB.QUANTITY                
                -(ISNULL((SELECT SUM(SB.QUANTITY) AS APQTY FROM OPCH SA
                    INNER JOIN PCH1 SB ON SA.DocNum=SB.DocEntry
                    WHERE SA.CANCELED='N'
                    AND SB.BASEREF=TB.DocEntry AND SB.BaseType=TB.ObjType AND SB.ItemCode=TB.ItemCode),0) 
                +ISNULL((SELECT  SUM(A1.QUANTITY )FROM IGE21 A0
                    INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY AND A1.AcctCode LIKE '%CS010%'
                    WHERE A0.REFOBJTYPE =13 AND RefDocNum = TA.DocEntry),0))  
                AS 'TTLAPQTY' 

                ,CASE WHEN TC.DocStatus='O'
                THEN 1
                WHEN TC.DocStatus<>'O' AND (SELECT COUNT(DocEntry) FROM RIN1 WHERE BaseEntry=TA.DocEntry AND BaseType=13 )>0
                THEN 1
                ELSE 0
                END AS X

                FROM INV21 TA
                INNER JOIN POR1 TB ON TA.RefDocNum=TB.DocEntry 
                INNER JOIN OPOR TC ON TB.DocEntry=TC.DocNum
                INNER JOIN (SELECT AA.BASEREF,AA.BASETYPE, AA.DocEntry,AA.ItemCode,AA.Quantity,AA.ObjType FROM PCH1 AA INNER JOIN OPCH AB ON AA.DocEntry=AB.DocNum WHERE AB.CANCELED='N' AND AA.BaseType=22)
                AS TD ON TD.BASEREF=TB.DOCENTRY AND TD.BASETYPE=TB.ObjType
                
                WHERE 
                TA.RefObjType=22
                AND TC.CANCELED='N'
                -- AND TC.DocStatus='O'
                )AS T5
                ON T5.DocEntry=T0.DocEntry
                AND T5.ItemCode=T0.ItemCode 
                AND T5.TTLAPQTY >0
                AND T5.X=1

    LEFT JOIN (SELECT  A0.DOCENTRY,A1.REFDOCNUM,A0.DocTotal-ISNULL(SUM(A3.DocTotal),0) AS 'LANDEDCOST',A2.Number FROM OPCH A0
            INNER JOIN PCH21 A1 ON A0.DOCNUM=A1.DocEntry
            INNER JOIN OJDT A2 ON A0.DocNum=A2.BaseRef AND TransType=18
            LEFT JOIN (SELECT TT.BaseEntry,DocTotal
                FROM ORPC T INNER JOIN RPC1 TT ON T.DocNum=TT.DocEntry 
                WHERE TT.BaseType=18
                )AS A3 ON A0.DocNum=A3.BaseEntry
            WHERE A1.RefObjType=13 AND A0.CANCELED='Z' AND A0.DocType='S'
            GROUP BY A0.DOCENTRY,A1.RefObjType,A1.REFDOCNUM,A1.DOCENTRY,A0.DocTotal,A2.Number) 
            AS T9
            ON T0.DocEntry=T9.REFDOCNUM 
    --JE
    INNER JOIN OJDT T10 ON T0.DocEntry=T10.BaseRef AND T10.TransType =13

    LEFT JOIN (SELECT A1.QUANTITY,A1.ITEMCODE,A0.RefDocNum FROM IGE21 A0
            INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY
            WHERE A0.REFOBJTYPE =13) 
            AS T11 ON T11.REFDOCNUM=T0.DOCENTRY AND T11.ITEMCODE=T0.ITEMCODE

    INNER JOIN (SELECT  DOCENTRY,SUM(A2.INMPrice*(A2.Quantity-ISNULL(A3.Quantity,0))) AS 'SALES SUM' 
                FROM INV1 A2 
                LEFT JOIN (SELECT B1.QUANTITY,REFDOCNUM,B1.ItemCode FROM IGE21 B0
                            INNER JOIN IGE1 B1 ON B0.DOCENTRY=B1.DOCENTRY
                            WHERE B0.REFOBJTYPE =13)
                            AS A3 ON A2.DocEntry=A3.REFDOCNUM AND A2.ItemCode=A3.ItemCode
                GROUP BY DOCENTRY)
            AS T12 ON T0.DocEntry=T12.DocEntry

    WHERE T3.DocType = 'I' 
    AND T1.ItemType <> 'F'
    AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
    AND T3.CANCELED='N'
    AND T3.ISINS='N'
    AND  T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y'  


     UNION ALL --DS AP EXCESS TO PO

    SELECT DISTINCT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,

    CASE 
        WHEN  T5.PO_# IS NOT NULL 
        THEN T5.PO_#
        ELSE ''
    END AS 'DE-AP',


    999 AS 'TRANSTYPE',
    T3.BPLID AS 'BRANCH ID',
    CASE 
        WHEN T3.isIns ='Y' 
        THEN 'AR RESERVE' 
        ELSE 'AR INVOICE' 
    END AS 'TYPE',
    T1.U_Category AS 'Category',
    T0.DocEntry AS 'Transaction#',T10.Number,
    T3.DocDate AS 'Posting Date',
    t3.U_DocSeries AS 'Invoice No.',
    CONCAT('PO ',T5.DocNum) AS 'Reference',
    
    CONVERT(VARCHAR(20),T5.TAXDATE,101) AS 'ReferenceDate',
    T3.CardName AS 'Customer',
    T4.CardFName AS 'Foreign Name',
    CASE 
        WHEN T9.Number IS NULL 
        THEN T3.Comments
        ELSE
        CONCAT(T3.Comments,' ; LC: ',T9.Number) 
    END AS 'Comments',
    T0.WhsCode AS 'Whse',
    T0.OcrCode as Store,
    T0.ItemCode AS 'Item Code',
    T0.unitMsr AS 'unit',
    T0.Dscription AS 'DESCRPTN', 

    T5.TTLAPQTY 
     AS 'Quantity Sold',

    T0.U_GPBD AS 'Price Before Discount',
    T0.PriceAfVAT AS 'Price After Discount',
    T0.INMPrice AS 'Price After Discount(VAT-Ex)',
        
    ISNULL( IIF(T5.NumPerMsr>T0.NumPerMsr,(T5.INMPrice/T5.NumPerMsr),T5.INMPrice) + ISNULL(((T0.INMPrice*(T0.Quantity - ISNULL(T11.Quantity,0))/T12.[SALES SUM])*T5.[LANDEDCOST])/T0.Quantity - ISNULL(T11.Quantity,0),0)
    ,0
    )
    AS 'COST',

    
    T0.INMPrice*T5.TTLAPQTY 
    AS 'TotalSales'
    ,NULL AS FreeTxt
    FROM INV1 T0
    INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
    INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
    INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
    INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
    --VIA PO
    LEFT JOIN (	
                SELECT TB.NumPerMsr,TA.DocEntry,TC.DocNum,TB.BaseEntry,TC.TaxDate ,TB.Quantity,TB.ItemCode,TB.WhsCode,TB.INMPRICE,TB.DocEntry AS 'PO_#','PO'AS 'RTYPE'               
                ,0 AS 'LANDEDCOST'
                ,TD.Quantity AS APQ
                
                ,TB.QUANTITY
                
                -(ISNULL((SELECT SUM(SB.QUANTITY) AS APQTY FROM OPCH SA
                    INNER JOIN PCH1 SB ON SA.DocNum=SB.DocEntry
                    WHERE SA.CANCELED='N'
                    AND SB.BASEREF=TB.DocEntry AND SB.BaseType=TB.ObjType AND SB.ItemCode=TB.ItemCode),0) 
                +ISNULL((SELECT  SUM(A1.QUANTITY )FROM IGE21 A0
                    INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY AND A1.AcctCode LIKE '%CS010%'
                    WHERE A0.REFOBJTYPE =13 AND RefDocNum = TA.DocEntry),0))  
                AS 'TTLAPQTY' 

                ,CASE WHEN TC.DocStatus='O'
                THEN 1
                WHEN TC.DocStatus<>'O' AND (SELECT COUNT(DocEntry) FROM RIN1 WHERE BaseEntry=TA.DocEntry AND BaseType=13 )>0
                THEN 1
                ELSE 0
                END AS X

                FROM INV21 TA
                INNER JOIN POR1 TB ON TA.RefDocNum=TB.DocEntry 
                INNER JOIN OPOR TC ON TB.DocEntry=TC.DocNum
                INNER JOIN (SELECT AA.BASEREF,AA.BASETYPE, AA.DocEntry,AA.ItemCode,AA.Quantity,AA.ObjType FROM PCH1 AA INNER JOIN OPCH AB ON AA.DocEntry=AB.DocNum WHERE AB.CANCELED='N' AND AA.BaseType=22)
                AS TD ON TD.BASEREF=TB.DOCENTRY AND TD.BASETYPE=TB.ObjType
                
                
                WHERE 
                TA.RefObjType=22
                AND TC.CANCELED='N'
                -- AND TC.DocStatus='O'
                -- AND TB.TrgetEntry=0
                )AS T5
                ON T5.DocEntry=T0.DocEntry
                AND T5.ItemCode=T0.ItemCode 
                AND T5.TTLAPQTY <0
                AND T5.X=1
                -- AND T5.WhsCode=T0.WhsCode

    LEFT JOIN (SELECT  A0.DOCENTRY,A1.REFDOCNUM,A0.DocTotal-ISNULL(SUM(A3.DocTotal),0) AS 'LANDEDCOST',A2.Number FROM OPCH A0
            INNER JOIN PCH21 A1 ON A0.DOCNUM=A1.DocEntry
            INNER JOIN OJDT A2 ON A0.DocNum=A2.BaseRef AND TransType=18
            LEFT JOIN (SELECT TT.BaseEntry,DocTotal
                FROM ORPC T INNER JOIN RPC1 TT ON T.DocNum=TT.DocEntry 
                WHERE TT.BaseType=18
                )AS A3 ON A0.DocNum=A3.BaseEntry
            WHERE A1.RefObjType=13 AND A0.CANCELED='Z' AND A0.DocType='S'
            GROUP BY A0.DOCENTRY,A1.RefObjType,A1.REFDOCNUM,A1.DOCENTRY,A0.DocTotal,A2.Number) 
            AS T9
            ON T0.DocEntry=T9.REFDOCNUM 
    --JE
    INNER JOIN OJDT T10 ON T0.DocEntry=T10.BaseRef AND T10.TransType =13

    LEFT JOIN (SELECT A1.QUANTITY,A1.ITEMCODE,A0.RefDocNum FROM IGE21 A0
            INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY
            WHERE A0.REFOBJTYPE =13) 
            AS T11 ON T11.REFDOCNUM=T0.DOCENTRY AND T11.ITEMCODE=T0.ITEMCODE

    INNER JOIN (SELECT  DOCENTRY,SUM(A2.INMPrice*(A2.Quantity-ISNULL(A3.Quantity,0))) AS 'SALES SUM' 
                FROM INV1 A2 
                LEFT JOIN (SELECT B1.QUANTITY,REFDOCNUM,B1.ItemCode FROM IGE21 B0
                            INNER JOIN IGE1 B1 ON B0.DOCENTRY=B1.DOCENTRY
                            WHERE B0.REFOBJTYPE =13)
                            AS A3 ON A2.DocEntry=A3.REFDOCNUM AND A2.ItemCode=A3.ItemCode
                GROUP BY DOCENTRY)
            AS T12 ON T0.DocEntry=T12.DocEntry

    WHERE T3.DocType = 'I' 
    AND T1.ItemType <> 'F'
    AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
    AND T3.CANCELED='N'
    AND T3.ISINS='N'
    AND  T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y'  

    UNION ALL --GOODS ISSUE

    SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,'' AS 'DE-AP','' AS 'TRANSTYPE',
    T3.BPLID AS 'BRANCH ID',
    CASE WHEN T3.isIns ='Y' THEN 'AR RESERVE' ELSE 'AR INVOICE' END AS 'TYPE',
    T1.U_Category AS 'Category',
    T0.DocEntry AS 'Transaction#',T9.Number,
    T3.TaxDate AS 'Posting Date',
    t3.U_DocSeries AS 'Invoice No.',
    CASE WHEN  T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
    THEN CONCAT('GI ',T8.DocEntry)

    ELSE ''
    END AS 'Reference',
    CASE WHEN  T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
    THEN CONVERT(VARCHAR(20),T8.IssueDate,101)
    ELSE ''
    END AS 'ReferenceDate',
    T3.CardName AS 'Customer',
    T4.CardFName AS 'Foreign Name',
    T3.Comments AS 'Comments',
    T0.WhsCode AS 'Whse',
    T0.OcrCode as Store,
    T0.ItemCode AS 'Item Code',
    T0.unitMsr AS 'unit',
    T0.Dscription AS 'DESCRPTN',
    --T0.Quantity AS 'Quantity Sold',
    T8.Quantity 
        AS 'Quantity Sold',
    --T0.Quantity-ISNULL(T5.QTY,0) AS 'Quantity Sold',
    T0.U_GPBD AS 'Price Before Discount',
    T0.PriceAfVAT AS 'Price After Discount',
    T0.INMPrice AS 'Price After Discount(VAT-Ex)',
    T8.PRICE AS 'COST',

    T0.INMPrice * T8.Quantity AS 'TotalSales'
    ,NULL AS FreeTxt
    FROM INV1 T0

    INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
    INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
    INNER JOIN OINV T3 ON T0.DocEntry = T3.DocNum
    INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
    LEFT JOIN (SELECT SUM(Quantity) AS 'QTY', A0.BaseEntry , ItemCode,WHSCODE 
            FROM DLN1 A0 INNER JOIN ODLN A1 ON A0.DOCENTRY=A1.DOCNUM
            WHERE CANCELED = 'N'
            GROUP BY  A0.BaseEntry ,ItemCode,WHSCODE) AS T5  
            ON T5.BaseEntry =T0.DocEntry AND T5.ItemCode=T0.ItemCode AND T5.WHSCODE=T0.WHSCODE  

    INNER JOIN (SELECT A1.DOCENTRY,REFDOCNUM, A1.QUANTITY,A1.LINETOTAL/A1.QUANTITY AS 'PRICE',A0.IssueDate FROM IGE21 A0
            INNER JOIN IGE1 A1 ON A0.DOCENTRY=A1.DOCENTRY AND A1.AcctCode LIKE '%CS010%'
            WHERE A0.REFOBJTYPE =13) AS T8
            ON T8.REFDOCNUM=T0.DOCENTRY 
    INNER JOIN OJDT T9 ON T8.DOCENTRY=T9.BaseRef AND T9.TransType =60

    WHERE T3.DocType = 'I' 
    AND T1.ItemType <> 'F'
    AND T3.DocDate >= @DATEFROM AND T3.DocDate <= @DATETO
    AND T3.CANCELED='N'
    AND  T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 

    UNION ALL  --AR CM

    SELECT T2.ItmsGrpNam AS 'Department',T3.CANCELED,T1.SWW,'' AS 'DE-AP','' AS 'TRANSTYPE',
    T3.BPLID AS 'BRANCH ID',
    'AR Credit Memo' AS 'TYPE',
    T1.U_Category AS 'Category',
    T0.DocEntry AS 'Transaction#',T6.Number,
    T3.TaxDate AS 'Posting Date',
    T3.U_DocSeries AS 'Invoice No.',
    '' AS 'Reference',
    '' AS 'ReferenceDate',
    T3.CardName AS 'Customer',
    T4.CardFName AS 'Foreign Name',
    T3.Comments AS 'Comments',
    -- T0.ocrcode AS 'Whse',
    ISNULL(T0.WhsCode,(SELECT  ProfitCode FROM JDT1 A
    INNER JOIN  OJDT B ON A.TransId=B.Number AND B.TransType =14
    WHERE B.BaseRef=T0.DocEntry 
    and ShortName='RV010-0200-0000')) 
    AS 'Whse',
    T0.OcrCode as Store,
    T0.ItemCode AS 'Item Code',
    T0.unitMsr AS 'unit',
    T0.Dscription AS 'DESCRPTN',
    T0.Quantity * -1 AS 'Quantity Sold',
    T0.U_GPBD AS 'Price Before Discount',
    T0.PriceAfVAT * -1 AS 'Price After Discount',
    T0.INMPrice * -1 AS 'Price After Discount(VAT-Ex)',
    CASE 
    WHEN   T3.U_BO_DRS ='Y' OR T3.U_BO_DSDD ='Y' OR T3.U_BO_DSDV ='Y' OR T3.U_BO_DSPD ='Y' 
    THEN ISNULL(T7.INMPrice,ISNULL(T8.INMPrice,ISNULL(T9.INMPrice,T10.INMPrice)))
    WHEN (SELECT isIns FROM OINV WHERE DOCNUM=T0.BaseEntry AND CANCELED='N')='Y'
        THEN 
        CASE WHEN T0.ITEMCODE IN ((SELECT ITEMCODE FROM DLN1 A0 INNER JOIN ODLN A1 ON A0.DOCENTRY=A1.DOCNUM WHERE A0.BaseEntry=T0.BaseEntry AND CANCELED='N' AND A1.DOCNUM=T0.ActBaseNum))
                THEN (SELECT TOP 1 StockValue/Quantity AS 'PRICE' FROM DLN1 WHERE BaseEntry=T0.BaseEntry AND ItemCode=T0.ItemCode)
            
                ELSE (SELECT IIF(T0.UomCode=T0.UomCode2,AvgPrice,AvgPrice*T0.NumPerMsr) FROM OITW WHERE ItemCode= T0.ItemCode AND WhsCode=T0.WhsCode)
                END
    WHEN T0.BASETYPE=203
    THEN (SELECT DISTINCT A1.StockValue/A1.Quantity FROM DPI1 A0 INNER JOIN INV1 A1 ON A0.BaseEntry=A1.BaseEntry WHERE A0.DocEntry=T0.BaseEntry AND A1.ItemCode=T0.ItemCode)
    WHEN T0.BaseType=13
    THEN (SELECT TOP 1 StockValue/Quantity FROM INV1 WHERE DocEntry=T0.BaseEntry AND  ItemCode=T0.ItemCode AND T0.UomCode=UomCode AND ObjType=T0.BaseType)
                    
    --NEW                
    WHEN (SELECT COUNT(B.DocNum) AS X FROM RIN21 A
          INNER JOIN OINV B ON A.RefDocNum=B.DocNum AND A.RefObjType=13 AND B.isIns='Y'  WHERE A.DocEntry=T0.DocEntry )>0
    
    THEN (SELECT StockValue/Quantity FROM RIN21 A
          INNER JOIN INV1 B ON A.RefDocNum=B.DocEntry AND A.RefObjType=13                    
          WHERE A.DocEntry=T0.DocEntry AND B.ItemCode=T0.ItemCode)

    END *-1 AS 'Cost',
    (T0.INMPrice * T0.Quantity) * -1 AS 'TotalSales'
    ,NULL AS FreeTxt

    from RIN1 T0

    INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode 
    INNER JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
    INNER JOIN ORIN T3 ON T0.DocEntry = T3.DocNum
    INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
    INNER JOIN OJDT T6 ON T0.DocEntry=T6.BaseRef AND T6.TransType =14
    LEFT JOIN (
            SELECT TB.NumPerMsr,TA.DocEntry,TC.DocNum,TB.BaseEntry,TC.TaxDate ,TB.Quantity,TB.ItemCode,TB.WhsCode,TB.INMPRICE,TB.DocEntry AS 'PO_#','PO'AS 'RTYPE'
            ,0 AS 'LANDEDCOST'
            FROM INV21 TA
            INNER JOIN POR1 TB ON TA.RefDocNum=TB.DocEntry 
            INNER JOIN OPOR TC ON TB.DocEntry=TC.DocNum
            WHERE 
            TA.RefObjType=22
            AND TC.CANCELED='N'
            AND TB.TrgetEntry=0
            )AS T7 
            ON T7.DOCENTRY=T0.BaseEntry AND T7.ItemCode=T0.ItemCode
    --COST DROPSHIP
    LEFT JOIN (
            SELECT TC.NumPerMsr, TA.DocEntry,TD.DocNum,TD.TaxDate ,TC.Quantity,TC.ItemCode,TC.WhsCode,TC.INMPRICE        ,TC.DocEntry AS 'PO_#','AP'AS 'RTYPE'
            
            , 0 AS 'LANDEDCOST'
            FROM INV21 TA
            INNER JOIN POR1 TB ON TA.RefDocNum=TB.DocEntry 
            INNER JOIN PCH1 TC ON TB.DocEntry=TC.BaseEntry AND TC.BaseType=22  AND TB.ItemCode=TC.ItemCode
            INNER JOIN OPCH TD ON TC.DocEntry=TD.DocNum 
            
            -- INNER JOIN PCH21 TE ON TD.DocNum=TE.DocEntry AND TE.RefObjType=14
            WHERE 
            TA.RefObjType=22
            AND TD.CANCELED='N'
            AND (SELECT COUNT(DISTINCT DocEntry) FROM PCH1 WHERE BaseRef=TB.DocEntry AND BaseType=TB.ObjType)=1
            )AS T8
            ON T8.DocEntry=T0.BASEENTRY AND T8.ItemCode=T0.ItemCode and T0.BaseType=13

    LEFT JOIN (
            SELECT TC.NumPerMsr,TA.DocEntry,TD.DocNum,TD.TaxDate ,TC.Quantity,TC.ItemCode,TC.WhsCode,TC.INMPRICE        ,TC.DocEntry AS 'PO_#','AP'AS 'RTYPE'
           
            ,0 AS 'LANDEDCOST'
            ,TA.RefDocNum
            FROM PCH21 TA
            INNER JOIN PCH1 TC ON TA.DocEntry=TC.DocEntry AND TC.BaseType=22
            INNER JOIN OPCH TD ON TC.DocEntry=TD.DocNum 
            WHERE 
            TA.RefObjType=13
            AND TD.CANCELED='N'
            AND (SELECT COUNT(DISTINCT DocEntry) FROM PCH1 WHERE BaseRef=TC.BASEREF AND BaseType=TC.BaseRef)=1
            )AS T9
            ON T9.RefDocNum=T0.BaseRef AND T9.ItemCode=T0.ItemCode and T0.BaseType=13

    LEFT JOIN (
            SELECT TC.NumPerMsr,TA.DocEntry,TD.DocNum,TD.TaxDate ,TC.Quantity,TC.ItemCode,TC.WhsCode,TC.INMPRICE        ,TC.DocEntry AS 'PO_#','AP'AS 'RTYPE'
           
            ,0 AS 'LANDEDCOST'
            ,TA.RefDocNum
            ,TA.RefObjType
            FROM PCH21 TA
            INNER JOIN PCH1 TC ON TA.DocEntry=TC.DocEntry AND TC.BaseType=22
            INNER JOIN OPCH TD ON TC.DocEntry=TD.DocNum 
            -- INNER JOIN PCH21 TE ON TD.DocNum=TE.DocEntry AND TE.RefObjType=14
            WHERE 
            TA.RefObjType=14
            AND TD.CANCELED='N'
   
            )AS T10
            ON T10.RefDocNum=T0.DocEntry AND T10.ItemCode=T0.ItemCode
            --END COST DROP SHIP


    WHERE T3.DocType = 'I' 
    AND T1.ItemType <> 'F'
    AND T3.TaxDate >= @DATEFROM AND T3.TaxDate <= @DATETO
    AND T3.CANCELED='N'
    AND T0.BaseType<>203

)XX
WHERE [Posting Date] BETWEEN @DATEFROM AND  @DATETO
AND Store LIKE '%'+@STORE+'%'
AND Department LIKE '%'+@DEPARTMENT+'%'
AND DESCRPTN NOT LIKE '%DELIVERY CHARGE%'

)xxx
GROUP BY DESCRPTN,[Item Code],Department,Category,unit,Store
)DD
ORDER BY 
case when @SortBy='Gross Profit Percentage' then  [Gross Profit Percentage]
when @SortBy = 'Total Quantity' then [Total Quantity Sold]
when @SortBy ='Total Sales' then [Total Sales]
END DESC

