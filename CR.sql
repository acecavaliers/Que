-- DECLARE @DFROM AS DATE={?DateFrom}
-- ,@DTO AS DATE={?DateTo}
-- ,@CUSTOMER AS VARCHAR(100)='{?CustName}'
-- ,@BRANCH AS VARCHAR(100)='{?Branch}'
-- ,@STR AS VARCHAR(100)='{?Str}'
-- ,@TENDERTYPE AS VARCHAR(100)='{?TenderType}'
-- ,@P_ONE AS BIT ='{?PayLoc}'
-- ,@P_TWO AS BIT='{?PayLoc2}'

DECLARE @DFROM AS DATE='2023-05-20'
,@DTO AS DATE='2023-06-09'
,@CUSTOMER AS VARCHAR(100)=''
,@BRANCH AS VARCHAR(100)='kor'
,@STR AS VARCHAR(100)=''
,@TENDERTYPE AS VARCHAR(100)=''
,@P_ONE AS BIT ='0'
,@P_TWO AS BIT='1'

IF (@P_ONE =0 AND @P_TWO=0)

SELECT @P_ONE =1, @P_TWO=1
SELECT * FROM(
    SELECT DISTINCT TT.CardName,TT.TENDERTYPE,TT.DOCDATE,TT.BPLName,TT.PAYMENT_LOCATION,TT.U_CollRcptNo,TT.U_Collector,TT.U_CollRcptDate,TT.DocNum,TT.DocTotal,TT.AmntTendered,TT.CheckDate,TT.Bank, isnull(tt.CHCKEXT,tt.CheckNo) AS ChckNum,TT.CASHSUM,TT.CHECKSUM,TT.CHECKSUMPDC,TT.BANKTRANSFR,TT.CREDITCARD,TT.WtAppld,

    (SELECT CONCAT ('' , (SELECT Countries = STUFF((
        SELECT ' '+ CASE WHEN T2.InvType=T4.ObjType 
            THEN CONCAT(REPLACE(LEFT(T4.U_DOCSERIES,LEN(T4.U_DOCSERIES)-10),'CHARGE','CH'),CAST(RIGHT(T4.U_DOCSERIES,10) AS INT))
        WHEN T2.InvType=46
            THEN T0.TrsfrRef
        WHEN T2.InvType=18
            THEN CONCAT('AP Invoice No.',T2.DocEntry)
        End 
        FROM ORCT T0
        INNER JOIN RCT2 T2 ON T0.DocNum=T2.DocNum 
        LEFT JOIN OINV T4 ON T4.DOCENTRY = T2.DOCENTRY AND T2.InvType=T4.ObjType
        WHERE T0.DocNum =TT.DocNum 
        FOR XML PATH('')
        ),1, 1, '')
        ))  
    ) AS INF,
    CASE 
        -- WHEN TENDERTYPE='Wtax' THEN 404
        WHEN DOCTYPE <>'A' THEN
        (SELECT COUNT(DISTINCT aaaa) AS SS FROM(SELECT 
        CASE 
            WHEN INVTYPE =13  THEN (SELECT LEFT(U_DocSeries,6) FROM OINV WHERE OINV.DocNum=AA.DocEntry)
            WHEN INVTYPE =14  THEN (SELECT LEFT(U_DocSeries,6) FROM ORIN WHERE ORIN.DocNum=AA.DocEntry)
            WHEN INVTYPE =18  THEN (SELECT LEFT(U_DocSeries,6) FROM OPCH WHERE OPCH.DocNum=AA.DocEntry)
            WHEN INVTYPE =19  THEN (SELECT LEFT(U_DocSeries,6) FROM ORPC WHERE ORPC.DocNum=AA.DocEntry)
            WHEN INVTYPE =30  THEN (SELECT TOP 1 ProfitCode FROM JDT1 WHERE JDT1.TransId=AA.DocEntry AND (ProfitCode<>'' OR ProfitCode IS NOT NULL))
            WHEN INVTYPE =46  THEN ''
            WHEN INVTYPE =203  THEN (SELECT LEFT(U_DocSeries,6) FROM ODPI WHERE ODPI.DocNum=AA.DocEntry)
        END AS aaaa
        FROM RCT2 AA
        WHERE AA.DocNum =tt.DocNum
        )dd) 
        WHEN DOCTYPE ='A' AND TENDERTYPE<>'Wtax' THEN
        (SELECT  COUNT(DISTINCT aaaa) FROM(SELECT 
        OcrCode as aaaa
    FROM RCT4 AA
        WHERE AA.DocNum =tt.DocNum
        )dd) 
    END
    as strcnt,
    CASE 
        -- WHEN TENDERTYPE='Wtax' THEN @STR
        WHEN DOCTYPE <>'A' THEN
        (SELECT top 1 aaaa AS SS FROM(SELECT 
        CASE 
            WHEN INVTYPE =13  THEN (SELECT LEFT(U_DocSeries,6) FROM OINV WHERE OINV.DocNum=AA.DocEntry)
            WHEN INVTYPE =14  THEN (SELECT LEFT(U_DocSeries,6) FROM ORIN WHERE ORIN.DocNum=AA.DocEntry)
            WHEN INVTYPE =18  THEN (SELECT LEFT(U_DocSeries,6) FROM OPCH WHERE OPCH.DocNum=AA.DocEntry)
            WHEN INVTYPE =19  THEN (SELECT LEFT(U_DocSeries,6) FROM ORPC WHERE ORPC.DocNum=AA.DocEntry)
            WHEN INVTYPE =30  THEN (SELECT TOP 1  REPLACE(ProfitCode,'_','') FROM JDT1 WHERE JDT1.TransId=AA.DocEntry AND  (ProfitCode<>'' OR ProfitCode IS NOT NULL))
            WHEN INVTYPE =46  THEN ''
            WHEN INVTYPE =203  THEN (SELECT LEFT(U_DocSeries,6) FROM ODPI WHERE ODPI.DocNum=AA.DocEntry)
        END AS aaaa
        FROM RCT2 AA
        WHERE AA.DocNum =tt.DocNum
        )dd) 
        WHEN DOCTYPE ='A' AND TENDERTYPE<>'Wtax' THEN
        (SELECT  top 1 aaaa FROM(SELECT 
        REPLACE(OcrCode,'_','') as aaaa
    FROM RCT4 AA
        WHERE AA.DocNum =tt.DocNum
        )dd) 
    END
    as str,
    (SELECT 
        CONCAT(
            CASE WHEN C.[Street] = '' OR C.[Street] = NULL THEN '' ELSE C.[Street]+' 'END,
            CASE WHEN C.[StreetNo] = '' OR C.[StreetNo] = NULL THEN '' ELSE C.[StreetNo]+' 'END,
            CASE WHEN C.[Block] = '' OR C.[Block] = NULL THEN '' ELSE C.[Block]+' 'END,
            CASE WHEN C.[City] = '' OR C.[City] = NULL THEN '' ELSE C.[City]+', 'END,
            CASE WHEN C.[ZipCode] = '' OR C.[ZipCode] = NULL THEN '' ELSE C.[ZipCode]+' 'END,
            CASE WHEN C.[Country] = '' OR C.[Country] = NULL THEN '' ELSE C.[Country]END
            )
    FROM OWHS C
    WHERE C.WhsCode=DflWhs
    ) AS 'SAS',DflWhs

    FROM
    (
    SELECT DISTINCT T.CardName,T.BPLName, T.DocDate, T.U_PayLoc  AS 'Payment_Location', T.U_CollRcptNo, T.U_CollRcptDate, T.U_Collector,T.Canceled, T.DocNum, T1.DocEntry, T.DocTotal
    ,(CASE  WHEN T.TenderType = 'Credit Card' THEN T.TenderType + ' - ' +  T.CreditType  ELSE T.TenderType END) AS TenderType
    ,T.AmntTendered, T.CreditType, T.CheckDate, T.Bank, T.CheckNo,T.CHCKEXT, REPLACE(REPLACE(T2.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',  T3.WhsCode, T.CashSum
    ,CASE WHEN t.TenderType='On-Date Check' THEN T.[CheckSum]  END AS CHECKSUM
    ,T.BankTransfr, T.CreditCard
    ,CASE WHEN t.TenderType<>'On-Date Check' THEN T.[CheckSum]  END AS CHECKSUMPDC
    ,T1.WtAppld,CardCode,doctype,DflWhs
    
    FROM(
        
        SELECT T0.CardName,T0.BPLName,  T0.DocDate, T0.U_PayLoc, T0.U_CollRcptNo,T0.U_CollRcptDate,T0.U_Collector,T0.Canceled, T0.DocNum, 'Cash' as TenderType, T0.CashSum AS AmntTendered,T0.CashSum, NULL As [CheckSum], NULL AS BankTransfr,NULL AS CreditCard, NULL AS CheckSumPDC, T0.DocTotal, T0.BPLId, NULL AS CreditType, NULL AS CheckDate, NULL AS Bank, NULL AS CheckNo, NULL AS CHCKEXT,T0.CounterRef,T0.CardCode,t0.doctype
        
        FROM ORCT T0 
        WHERE T0.CashSum <> 0 
        AND T0.CardName <>'Tender Over'

        UNION

        SELECT T0.CardName,T0.BPLName, T0.DocDate, T0.U_PayLoc, T0.U_CollRcptNo, T0.U_CollRcptDate, T0.U_Collector,T0.Canceled, T0.DocNum
        ,CASE WHEN t1.U_ChkType='On Date' THEN 'On-Date Check' WHEN t1.U_ChkType IS NULL AND T0.DocDueDate=T1.DueDate THEN 'On-Date Check'  ELSE 'Post-Dated Check' END, T1.[CheckSum]
        ,NULL
        ,CASE WHEN (SELECT '1' FROM OPDF T2 WHERE T2.CardCode = T0.CardCode AND T2.DocDate = T0.DocDate AND T2.DocTime = T0.DocTime) IS NULL THEN  T1.[CheckSum] ELSE 0.00 END
        ,NULL,NULL
        ,CASE WHEN (SELECT '1' FROM OPDF T2 WHERE T2.CardCode = T0.CardCode AND T2.DocDate = T0.DocDate AND T2.DocTime = T0.DocTime) IS NULL THEN 0.00 ELSE T1.[CheckSum]  END
        ,T0.DocTotal, T0.BPLId, NULL, T1.DueDate, T1.BankCode, T1.CheckNum, T1.U_ChkNumExt,T0.CounterRef    ,T0.CardCode,t0.doctype
        FROM ORCT T0 
        INNER JOIN RCT1 T1 ON T0.DocNum = T1.DocNum 

        UNION 

        SELECT T0.CardName,T0.BPLName, T0.DocDate, T0.U_PayLoc, T0.U_CollRcptNo, T0.U_CollRcptDate, T0.U_Collector,T0.Canceled, T0.DocNum,'Bank Transfer', T0.TrsfrSum,NULL, NULL, T0.[TrsfrSum],NULL,NULL, T0.DocTotal, T0.BPLId, NULL, NULL, NULL, NULL, NULL ,T0.CounterRef  ,T0.CardCode,t0.doctype
        FROM ORCT T0 
        WHERE T0.[TrsfrSum] <> 0 
        
        UNION

        SELECT T0.CardName,T0.BPLName, T0.DocDate, T0.U_PayLoc, T0.U_CollRcptNo, T0.U_CollRcptDate, T0.U_Collector,T0.Canceled, T0.DocNum, 'Credit Card', T1.CreditSum,NULL, NULL, NULL,T0.[CreditSum],NULL, T0.DocTotal, T0.BPLId, T2.CardName, NULL, NULL, NULL, NULL,T0.CounterRef  ,T0.CardCode,t0.doctype
        FROM ORCT T0 
        INNER JOIN RCT3 T1 ON T0.DocNum = T1.DocNum 
        INNER JOIN OCRC T2 ON T2.CreditCard = T1.CreditCard


    )T

    LEFT JOIN [dbo].[INV1] T3 ON T.DocNum = T3.[DocEntry] 
    LEFT JOIN RCT2 T1 ON T.DocNum = T1.DocNum 
    LEFT JOIN [dbo].[OBPL] T2 ON T.[BPLId] = T2.[BPLId] AND [Disabled]='N'  
    WHERE T.Canceled = 'N' 
    AND T.U_PayLoc<> 'Store Collections' 
    AND T.U_PayLoc <>''  
    AND T.DocDate >= @DFROM 
    AND T.DocDate <= @DTO 
    AND T.CardName LIKE '%'+@CUSTOMER+'%' 
    AND T.BPLName LIKE '%'+@BRANCH+'%' 
    AND T.TenderType LIKE '%'+@TENDERTYPE+'%'   
    AND T.U_PayLoc IN ((CASE WHEN @P_ONE = 1 THEN 'Customer Site' ELSE NULL END), (CASE WHEN @P_TWO = 1 THEN 'Head Office' ELSE NULL END))



    UNION
    
    SELECT T0.CardName,T0.BPLName, T0.DocDate, NULL, T0.U_CollRcptNo, T0.U_CollRcptDate, T0.U_Collector,T0.Canceled, T0.DocNum,NULL,NULL, 'Wtax', SUM(T1.U_WTaxPay) ,NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL ,T0.CardCode,t0.doctype,
    (SELECT TOP 1 DflWhs FROM OBPL WHERE [Disabled]='N' AND BPLName LIKE '%'+@BRANCH+'%') as 'DflWhs'
    FROM ORCT T0 
    INNER JOIN RCT2 T1 ON T0.DocNum = T1.DocNum 
    WHERE T1.U_WTaxPay <> 0 
    AND T0.DocNum IN (SELECT DISTINCT TS.DocNum 
        FROM(
            SELECT T0.CardName,T0.BPLName, T0.DocDate, T0.U_PayLoc, T0.U_CollRcptNo,T0.U_CollRcptDate,T0.U_Collector, T0.Canceled, T0.DocNum, 'Cash' as TenderType, T0.CashSum AS AmntTendered,T0.CashSum, NULL As [CheckSum], NULL AS BankTransfr,NULL AS CreditCard, NULL AS CheckSumPDC, T0.DocTotal, T0.BPLId, NULL AS CreditType, NULL AS CheckDate, NULL AS Bank, NULL AS CheckNo, NULL AS CHCKEXT,T0.CounterRef ,T0.CardCode,t0.doctype
            FROM ORCT T0 WHERE T0.CashSum <> 0 AND T0.CardName <>'Tender Over'
            
            UNION

            SELECT T0.CardName,T0.BPLName, T0.DocDate, T0.U_PayLoc, T0.U_CollRcptNo, T0.U_CollRcptDate, T0.U_Collector, T0.Canceled, T0.DocNum
            ,CASE WHEN t1.U_ChkType='On Date' THEN 'On-Date Check' WHEN t1.U_ChkType IS NULL AND T0.DocDueDate=T1.DueDate THEN 'On-Date Check' ELSE 'Post-Dated Check'  END
            ,T1.[CheckSum],NULL
            ,CASE WHEN (SELECT '1' FROM OPDF T2 WHERE T2.CardCode = T0.CardCode AND T2.DocDate = T0.DocDate AND T2.DocTime = T0.DocTime) IS NULL THEN  T1.[CheckSum] ELSE 0.00 END
            ,NULL,NULL
            ,CASE WHEN (SELECT '1' FROM OPDF T2 WHERE T2.CardCode = T0.CardCode AND T2.DocDate = T0.DocDate AND T2.DocTime = T0.DocTime) IS NULL THEN 0.00 ELSE T1.[CheckSum]  END
            ,T0.DocTotal, T0.BPLId, NULL, T1.DueDate, T1.BankCode, T1.CheckNum, T1.U_ChkNumExt,T0.CounterRef ,T0.CardCode,t0.doctype
            FROM ORCT T0 
            INNER JOIN RCT1 T1 ON T0.DocNum = T1.DocNum

            UNION 

            SELECT T0.CardName,T0.BPLName, T0.DocDate, T0.U_PayLoc, T0.U_CollRcptNo, T0.U_CollRcptDate, T0.U_Collector, T0.Canceled, T0.DocNum,'Bank Transfer', T0.TrsfrSum,NULL, NULL, T0.[TrsfrSum],NULL,NULL, T0.DocTotal, T0.BPLId, NULL, NULL, NULL, NULL, NULL,T0.CounterRef,T0.CardCode,t0.doctype
            FROM ORCT T0 WHERE T0.[TrsfrSum] <> 0 
            
            UNION

            SELECT T0.CardName,T0.BPLName, T0.DocDate, T0.U_PayLoc, T0.U_CollRcptNo, T0.U_CollRcptDate, T0.U_Collector, T0.Canceled, T0.DocNum, 'Credit Card', T1.CreditSum,NULL, NULL, NULL,T0.[CreditSum],NULL, T0.DocTotal, T0.BPLId, T2.CardName, NULL, NULL, NULL, NULL,T0.CounterRef,T0.CardCode  ,t0.doctype
            FROM ORCT T0 INNER JOIN RCT3 T1 ON T0.DocNum = T1.DocNum INNER JOIN OCRC T2 ON T2.CreditCard = T1.CreditCard

        ) TS 

        LEFT JOIN [dbo].[INV1] T3 ON TS.DocNum = T3.[DocEntry] 
        LEFT JOIN RCT2 T1 ON TS.DocNum = T1.DocNum 
        LEFT JOIN [dbo].[OBPL] T2 ON TS.[BPLId] = T2.[BPLId] AND [Disabled]='N'  
        WHERE TS.Canceled = 'N' 
        AND TS.U_PayLoc<> 'Store Collections' 
        AND TS.U_PayLoc <>'' 
        AND TS.DocDate>= @DFROM 
        AND TS.DocDate <= @DTO 
        AND TS.CardName LIKE '%'+@CUSTOMER+'%' 
        AND TS.BPLName LIKE '%'+@BRANCH+'%'
        AND TS.TenderType LIKE '%'+@TENDERTYPE+'%' 
        AND TS.U_PayLoc IN ((CASE WHEN @P_ONE = 1 THEN 'Customer Site' ELSE NULL END), (CASE WHEN @P_TWO = 1 THEN 'Head Office' ELSE NULL END))

    )

    GROUP BY T0.CardName,T0.BPLName, T0.DocDate, T0.U_CollRcptNo, T0.U_CollRcptDate, T0.U_Collector,T0.Canceled, T0.DocNum,T1.U_wTaxComCode,T0.CardCode,t0.doctype
    ) TT 
)GG
WHERE GG.[str] LIKE '%'+@STR+'%'
ORDER BY GG.TenderType
