DECLARE @dfrom DATE ={?DateFrom},@dto date={?DateTo},@RPT VARCHAR(100)='{?RPT}',@WTCode VARCHAR(10)
--  DECLARE @dfrom DATE ='2021-01-01',@dto date='2023-12-20',@RPT VARCHAR(100)='All',@WTCode VARCHAR(10)='FW01'


IF (@RPT='ALL')
BEGIN
    SELECT* FROM(
        SELECT *,WTSum + ISNULL((SELECT ISNULL(sum(Credit),0) - ISNULL(sum(Debit),0) from JDT1 WHERE U_DocNum=TT.DocNum and U_BaseDocType=TT.ObjType and ShortName=TT.CardCode),0) AS WTSAM 
        FROM (
            SELECT DISTINCT
            T0.DocNum,T4.DOCENTRY,
            'A/R Invoice' AS 'A/R Credit Memo',
            T2.WTCode,
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T5.CardCode,
            T0.BPLName, 
            T3.ObjType,
            T0.DocDate, 
            CASE WHEN T5.U_Collector=''
            THEN T0.DocTotal
            ELSE t4.SumApplied - t4.U_WTaxPay
            END as 'DocTotal' ,
            CASE WHEN T5.U_Collector=''
            THEN 
            T0.WTSum
            ELSE t4.U_WTaxPay
            END as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T5.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,T4.U_wTaxComCode) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T5.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T5.U_WTaxRecDate) AS 'Received Date'

            FROM OINV T0 
            INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
            INNER JOIN INV5 T2 ON T0.DocNum = T2.AbsEntry 
            INNER JOIN INV1 T3 ON T3.DocEntry = T0.DocEntry
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T5.Canceled='N'

        UNION ALL 

            SELECT DISTINCT
            T0.DocNum,null,
            'A/R CM' AS 'A/R Credit Memo',
            T2.WTCode,
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T5.CardCode,
            T0.BPLName, 
            T3.ObjType,
            T0.DocDate, 
            T0.DocTotal * -1, 
            T0.WTSum * -1, 
            T0.U_WTax, 
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',
            null as 'U_wTaxComCode',
            T0.U_WTAXRECBY AS 'Received By',
            t0.U_WTaxRecDate AS 'Received Date'

            FROM ORIN T0 
            INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
            INNER JOIN RIN5 T2 ON T0.DocNum = T2.AbsEntry 
            INNER JOIN RIN1 T3 ON T3.DocEntry = T0.DocEntry
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T5.Canceled='N'

        UNION ALL 

            --ARDPI
            SELECT DISTINCT
            T0.DocNum,T4.DOCENTRY,
            'A/R DPI' AS 'A/R Credit Memo',
            T2.WTCode,
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T5.CardCode,
            T0.BPLName, 
            T3.ObjType,
            T0.DocDate,
            CASE WHEN T5.U_Collector=''
            THEN T0.DocTotal
            ELSE t4.SumApplied - t4.U_WTaxPay
            END as 'DocTotal' ,
            CASE WHEN T5.U_Collector=''
            THEN T0.WTSum 
            ELSE t4.U_WTaxPay 
            END as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T5.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',
            (SELECT DISTINCT WhsCode FROM DPI1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,T4.U_wTaxComCode) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T5.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T5.U_WTAXRECBY) AS 'Received Date'

            FROM ODPI T0 
            INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
            INNER JOIN DPI5 T2 ON T0.DocNum = T2.AbsEntry 
            INNER JOIN DPI1 T3 ON T3.DocEntry = T0.DocEntry
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T5.Canceled='N'

        UNION ALL
            --JE
            SELECT DISTINCT
            T0.Number,
            T4.DOCENTRY,
            'JE' AS 'A/R Credit Memo',
            T2.WTCode,
            '' AS 'U_ALIAS_VENDOR',
            T5.CardName AS 'CardName',
            T5.CardCode,
            T5.BPLName, 
            T3.ObjType,
            T0.TaxDate,
            t4.SumApplied - t4.U_WTaxPay as 'DocTotal',
            t4.U_WTaxPay as 'WTSum',
            T5.U_WTax AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',
            T0.Ref3 AS 'Warehouse',
            T4.U_wTaxComCode as 'U_wTaxComCode',
            T5.U_WTAXRECBY AS 'Received By',
            T5.U_WTaxRecDate AS 'Received Date'

            FROM OJDT T0 
            INNER JOIN JDT2 T2 ON T0.Number = T2.AbsEntry 
            INNER JOIN JDT1 T3 ON T3.TransId = T0.Number
            INNER JOIN OBPL T1 ON T3.BPLId = T1.[BPLId] 
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.TransId AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.Memo NOT LIKE  'N' 
            AND T0.TaxDate between @dfrom and @dto
            AND T5.Canceled='N'

        UNION ALL
            --JE Adjustments AR/
            SELECT DISTINCT
            T0.DocNum,T3.DOCENTRY,
            'JE - AR' AS 'A/R Credit Memo',
            T2.U_WtaxCode as 'WTCode',
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T4.CardCode,
            T0.BPLName, 
            T0.ObjType,
            T0.DocDate, 
            CASE WHEN T4.U_Collector=''
            THEN T0.DocTotal
            ELSE T3.SumApplied - (SELECT A.U_WTaxPay FROM RCT2 A WHERE A.DocNum=T4.DOCNUM AND A.DOCENTRY=T2.TransId AND A.InvType=30)
            END as 'DocTotal' ,
            0 as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T4.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T0.DocNum) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,(SELECT A.U_wTaxComCode FROM RCT2 A WHERE A.DocNum=T4.DOCNUM AND A.DOCENTRY=T2.TransId AND A.InvType=30)) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T4.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T4.U_WTaxRecDate) AS 'Received Date'

            FROM OINV T0 
            INNER JOIN OBPL T1 ON T0.BPLId = T1.BPLId 
            INNER JOIN JDT1 T2 ON T0.DocNum = T2.U_DocNum AND T0.ObjType = T2.U_BaseDocType 
            INNER JOIN RCT2 T3 ON T3.DocEntry = T0.DocNum AND T3.InvType=T0.ObjType
            INNER JOIN ORCT T4 ON T4.DocNum = T3.DocNum AND T4.Canceled='N'

            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto

            UNION ALL 

            SELECT DISTINCT
            T0.DocNum,T3.DOCENTRY,
            'JE - ARDPI' AS 'A/R Credit Memo',
            T2.U_WtaxCode as 'WTCode',
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T4.CardCode,
            T0.BPLName, 
            T0.ObjType,
            T0.DocDate, 
            CASE WHEN T4.U_Collector=''
            THEN T0.DocTotal
            ELSE T3.SumApplied - T3.U_WTaxPay
            END as 'DocTotal' ,           
            0 as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T4.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T0.DocNum) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,(SELECT A.U_wTaxComCode FROM RCT2 A WHERE A.DocNum=T4.DOCNUM AND A.DOCENTRY=T2.TransId AND A.InvType=30)) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T4.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T4.U_WTaxRecDate) AS 'Received Date'

            FROM ODPI T0 
            INNER JOIN OBPL T1 ON T0.BPLId = T1.BPLId 
            INNER JOIN JDT1 T2 ON T0.DocNum = T2.U_DocNum AND T0.ObjType = T2.U_BaseDocType 
            INNER JOIN RCT2 T3 ON T3.DocEntry = T0.DocNum AND T3.InvType=T0.ObjType
            INNER JOIN ORCT T4 ON T4.DocNum = T3.DocNum AND T4.Canceled='N'

            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto

        ) TT
    )DD 
   WHERE WTSAM>0
   AND WTCode=@WTCode
END

--Reported

IF (@RPT='REPORTED')
BEGIN
    SELECT* FROM(
        SELECT *,WTSum + ISNULL((SELECT ISNULL(sum(Credit),0) - ISNULL(sum(Debit),0) from JDT1 WHERE U_DocNum=TT.DocNum and U_BaseDocType=TT.ObjType and ShortName=TT.CardCode),0) AS WTSAM 
        FROM (
            SELECT DISTINCT
            T0.DocNum,T4.DOCENTRY,
            'A/R Invoice' AS 'A/R Credit Memo',
            T2.WTCode,
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T5.CardCode,
            T0.BPLName, 
            T3.ObjType,
            T0.DocDate, 
            CASE WHEN T5.U_Collector=''
            THEN T0.DocTotal
            ELSE t4.SumApplied - t4.U_WTaxPay
            END as 'DocTotal' ,
            CASE WHEN T5.U_Collector=''
            THEN 
            T0.WTSum
            ELSE t4.U_WTaxPay
            END as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T5.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,T4.U_wTaxComCode) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T5.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T5.U_WTaxRecDate) AS 'Received Date'

            FROM OINV T0 
            INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
            INNER JOIN INV5 T2 ON T0.DocNum = T2.AbsEntry 
            INNER JOIN INV1 T3 ON T3.DocEntry = T0.DocEntry
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T5.Canceled='N'
            AND T0.DocNum IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

        UNION ALL 

            SELECT DISTINCT
            T0.DocNum,null,
            'A/R CM' AS 'A/R Credit Memo',
            T2.WTCode,
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T5.CardCode,
            T0.BPLName, 
            T3.ObjType,
            T0.DocDate, 
            T0.DocTotal * -1, 
            T0.WTSum * -1, 
            T0.U_WTax, 
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',
            null as 'U_wTaxComCode',
            T0.U_WTAXRECBY AS 'Received By',
            t0.U_WTaxRecDate AS 'Received Date'

            FROM ORIN T0 
            INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
            INNER JOIN RIN5 T2 ON T0.DocNum = T2.AbsEntry 
            INNER JOIN RIN1 T3 ON T3.DocEntry = T0.DocEntry
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T5.Canceled='N'
            AND T0.DocNum IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

        UNION ALL 

            --ARDPI
            SELECT DISTINCT
            T0.DocNum,T4.DOCENTRY,
            'A/R DPI' AS 'A/R Credit Memo',
            T2.WTCode,
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T5.CardCode,
            T0.BPLName, 
            T3.ObjType,
            T0.DocDate,
            CASE WHEN T5.U_Collector=''
            THEN T0.DocTotal
            ELSE t4.SumApplied - t4.U_WTaxPay
            END as 'DocTotal' ,
            CASE WHEN T5.U_Collector=''
            THEN T0.WTSum 
            ELSE t4.U_WTaxPay 
            END as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T5.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',
            (SELECT DISTINCT WhsCode FROM DPI1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,T4.U_wTaxComCode) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T5.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T5.U_WTAXRECBY) AS 'Received Date'

            FROM ODPI T0 
            INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
            INNER JOIN DPI5 T2 ON T0.DocNum = T2.AbsEntry 
            INNER JOIN DPI1 T3 ON T3.DocEntry = T0.DocEntry
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T5.Canceled='N'
            AND T0.DocNum IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

        UNION ALL
            --JE
            SELECT DISTINCT
            T0.Number,
            T4.DOCENTRY,
            'JE' AS 'A/R Credit Memo',
            T2.WTCode,
            '' AS 'U_ALIAS_VENDOR',
            T5.CardName AS 'CardName',
            T5.CardCode,
            T5.BPLName, 
            T3.ObjType,
            T0.TaxDate,
            t4.SumApplied - t4.U_WTaxPay as 'DocTotal',
            t4.U_WTaxPay as 'WTSum',
            T5.U_WTax AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',
            T0.Ref3 AS 'Warehouse',
            T4.U_wTaxComCode as 'U_wTaxComCode',
            T5.U_WTAXRECBY AS 'Received By',
            T5.U_WTaxRecDate AS 'Received Date'

            FROM OJDT T0 
            INNER JOIN JDT2 T2 ON T0.Number = T2.AbsEntry 
            INNER JOIN JDT1 T3 ON T3.TransId = T0.Number
            INNER JOIN OBPL T1 ON T3.BPLId = T1.[BPLId] 
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.TransId AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.Memo NOT LIKE  'N' 
            AND T0.TaxDate between @dfrom and @dto
            AND T5.Canceled='N'
            AND T0.Number IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

        UNION ALL
            --JE Adjustments AR/
            SELECT DISTINCT
            T0.DocNum,T3.DOCENTRY,
            'JE - AR' AS 'A/R Credit Memo',
            T2.U_WtaxCode as 'WTCode',
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T4.CardCode,
            T0.BPLName, 
            T0.ObjType,
            T0.DocDate, 
            CASE WHEN T4.U_Collector=''
            THEN T0.DocTotal
            ELSE T3.SumApplied - (SELECT A.U_WTaxPay FROM RCT2 A WHERE A.DocNum=T4.DOCNUM AND A.DOCENTRY=T2.TransId AND A.InvType=30)
            END as 'DocTotal' ,
            0 as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T4.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T0.DocNum) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,(SELECT A.U_wTaxComCode FROM RCT2 A WHERE A.DocNum=T4.DOCNUM AND A.DOCENTRY=T2.TransId AND A.InvType=30)) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T4.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T4.U_WTaxRecDate) AS 'Received Date'

            FROM OINV T0 
            INNER JOIN OBPL T1 ON T0.BPLId = T1.BPLId 
            INNER JOIN JDT1 T2 ON T0.DocNum = T2.U_DocNum AND T0.ObjType = T2.U_BaseDocType 
            INNER JOIN RCT2 T3 ON T3.DocEntry = T0.DocNum AND T3.InvType=T0.ObjType
            INNER JOIN ORCT T4 ON T4.DocNum = T3.DocNum AND T4.Canceled='N'

            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T0.DocNum IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

            UNION ALL 

            SELECT DISTINCT
            T0.DocNum,T3.DOCENTRY,
            'JE - ARDPI' AS 'A/R Credit Memo',
            T2.U_WtaxCode as 'WTCode',
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T4.CardCode,
            T0.BPLName, 
            T0.ObjType,
            T0.DocDate, 
            CASE WHEN T4.U_Collector=''
            THEN T0.DocTotal
            ELSE T3.SumApplied - T3.U_WTaxPay
            END as 'DocTotal' ,           
            0 as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T4.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T0.DocNum) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,(SELECT A.U_wTaxComCode FROM RCT2 A WHERE A.DocNum=T4.DOCNUM AND A.DOCENTRY=T2.TransId AND A.InvType=30)) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T4.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T4.U_WTaxRecDate) AS 'Received Date'

            FROM ODPI T0 
            INNER JOIN OBPL T1 ON T0.BPLId = T1.BPLId 
            INNER JOIN JDT1 T2 ON T0.DocNum = T2.U_DocNum AND T0.ObjType = T2.U_BaseDocType 
            INNER JOIN RCT2 T3 ON T3.DocEntry = T0.DocNum AND T3.InvType=T0.ObjType
            INNER JOIN ORCT T4 ON T4.DocNum = T3.DocNum AND T4.Canceled='N'

            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T0.DocNum IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

        ) TT
    )DD 
   WHERE WTSAM>0
   AND WTCode=@WTCode
END

--Unreported

IF (@RPT='UNREPORTED')
BEGIN
    SELECT* FROM(
        SELECT *,WTSum + ISNULL((SELECT ISNULL(sum(Credit),0) - ISNULL(sum(Debit),0) from JDT1 WHERE U_DocNum=TT.DocNum and U_BaseDocType=TT.ObjType and ShortName=TT.CardCode),0) AS WTSAM 
        FROM (
            SELECT DISTINCT
            T0.DocNum,T4.DOCENTRY,
            'A/R Invoice' AS 'A/R Credit Memo',
            T2.WTCode,
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T5.CardCode,
            T0.BPLName, 
            T3.ObjType,
            T0.DocDate, 
            CASE WHEN T5.U_Collector=''
            THEN T0.DocTotal
            ELSE t4.SumApplied - t4.U_WTaxPay
            END as 'DocTotal' ,
            CASE WHEN T5.U_Collector=''
            THEN 
            T0.WTSum
            ELSE t4.U_WTaxPay
            END as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T5.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,T4.U_wTaxComCode) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T5.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T5.U_WTaxRecDate) AS 'Received Date'

            FROM OINV T0 
            INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
            INNER JOIN INV5 T2 ON T0.DocNum = T2.AbsEntry 
            INNER JOIN INV1 T3 ON T3.DocEntry = T0.DocEntry
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T5.Canceled='N'
            AND T0.DocNum NOT IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

        UNION ALL 

            SELECT DISTINCT
            T0.DocNum,null,
            'A/R CM' AS 'A/R Credit Memo',
            T2.WTCode,
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T5.CardCode,
            T0.BPLName, 
            T3.ObjType,
            T0.DocDate, 
            T0.DocTotal * -1, 
            T0.WTSum * -1, 
            T0.U_WTax, 
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',
            null as 'U_wTaxComCode',
            T0.U_WTAXRECBY AS 'Received By',
            t0.U_WTaxRecDate AS 'Received Date'

            FROM ORIN T0 
            INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
            INNER JOIN RIN5 T2 ON T0.DocNum = T2.AbsEntry 
            INNER JOIN RIN1 T3 ON T3.DocEntry = T0.DocEntry
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T5.Canceled='N'
            AND T0.DocNum NOT IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

        UNION ALL 

            --ARDPI
            SELECT DISTINCT
            T0.DocNum,T4.DOCENTRY,
            'A/R DPI' AS 'A/R Credit Memo',
            T2.WTCode,
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T5.CardCode,
            T0.BPLName, 
            T3.ObjType,
            T0.DocDate,
            CASE WHEN T5.U_Collector=''
            THEN T0.DocTotal
            ELSE t4.SumApplied - t4.U_WTaxPay
            END as 'DocTotal' ,
            CASE WHEN T5.U_Collector=''
            THEN T0.WTSum 
            ELSE t4.U_WTaxPay 
            END as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T5.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',
            (SELECT DISTINCT WhsCode FROM DPI1 WHERE DocEntry = T3.DocEntry) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,T4.U_wTaxComCode) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T5.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T5.U_WTAXRECBY) AS 'Received Date'

            FROM ODPI T0 
            INNER JOIN OBPL AS T1 ON T0.[BPLId] = T1.[BPLId] 
            INNER JOIN DPI5 T2 ON T0.DocNum = T2.AbsEntry 
            INNER JOIN DPI1 T3 ON T3.DocEntry = T0.DocEntry
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.DocEntry AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T5.Canceled='N'
            AND T0.DocNum NOT IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

        UNION ALL
            --JE
            SELECT DISTINCT
            T0.Number,
            T4.DOCENTRY,
            'JE' AS 'A/R Credit Memo',
            T2.WTCode,
            '' AS 'U_ALIAS_VENDOR',
            T5.CardName AS 'CardName',
            T5.CardCode,
            T5.BPLName, 
            T3.ObjType,
            T0.TaxDate,
            t4.SumApplied - t4.U_WTaxPay as 'DocTotal',
            t4.U_WTaxPay as 'WTSum',
            T5.U_WTax AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS',
            T0.Ref3 AS 'Warehouse',
            T4.U_wTaxComCode as 'U_wTaxComCode',
            T5.U_WTAXRECBY AS 'Received By',
            T5.U_WTaxRecDate AS 'Received Date'

            FROM OJDT T0 
            INNER JOIN JDT2 T2 ON T0.Number = T2.AbsEntry 
            INNER JOIN JDT1 T3 ON T3.TransId = T0.Number
            INNER JOIN OBPL T1 ON T3.BPLId = T1.[BPLId] 
            INNER JOIN RCT2 T4 ON T4.DocEntry=T3.TransId AND T4.InvType=T0.ObjType
            INNER JOIN ORCT T5 ON T5.DocNum=T4.DocNum
            WHERE T0.Memo NOT LIKE  'N' 
            AND T0.TaxDate between @dfrom and @dto
            AND T5.Canceled='N'
            AND T0.Number NOT IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

        UNION ALL
            --JE Adjustments AR/
            SELECT DISTINCT
            T0.DocNum,T3.DOCENTRY,
            'JE - AR' AS 'A/R Credit Memo',
            T2.U_WtaxCode as 'WTCode',
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T4.CardCode,
            T0.BPLName, 
            T0.ObjType,
            T0.DocDate, 
            CASE WHEN T4.U_Collector=''
            THEN T0.DocTotal
            ELSE T3.SumApplied - (SELECT A.U_WTaxPay FROM RCT2 A WHERE A.DocNum=T4.DOCNUM AND A.DOCENTRY=T2.TransId AND A.InvType=30)
            END as 'DocTotal' ,
            0 as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T4.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T0.DocNum) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,(SELECT A.U_wTaxComCode FROM RCT2 A WHERE A.DocNum=T4.DOCNUM AND A.DOCENTRY=T2.TransId AND A.InvType=30)) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T4.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T4.U_WTaxRecDate) AS 'Received Date'

            FROM OINV T0 
            INNER JOIN OBPL T1 ON T0.BPLId = T1.BPLId 
            INNER JOIN JDT1 T2 ON T0.DocNum = T2.U_DocNum AND T0.ObjType = T2.U_BaseDocType 
            INNER JOIN RCT2 T3 ON T3.DocEntry = T0.DocNum AND T3.InvType=T0.ObjType
            INNER JOIN ORCT T4 ON T4.DocNum = T3.DocNum AND T4.Canceled='N'

            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T0.DocNum NOT IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

            UNION ALL 

            SELECT DISTINCT
            T0.DocNum,T3.DOCENTRY,
            'JE - ARDPI' AS 'A/R Credit Memo',
            T2.U_WtaxCode as 'WTCode',
            T0.U_ALIAS_VENDOR,
            IIF(T0.U_Customer IS NOT NULL,T0.U_Customer,T0.CardName) AS 'CardName',
            T4.CardCode,
            T0.BPLName, 
            T0.ObjType,
            T0.DocDate, 
            CASE WHEN T4.U_Collector=''
            THEN T0.DocTotal
            ELSE T3.SumApplied - T3.U_WTaxPay
            END as 'DocTotal' ,           
            0 as 'WTSum',
            IIF(T0.U_WTax <> 'Received',T4.U_WTax,T0.U_WTax) AS 'U_WTax',
            REPLACE(REPLACE(T1.[Address],char(13),' '),char(10),' ') AS 'ADDRESS', 
            (SELECT DISTINCT WhsCode FROM INV1 WHERE DocEntry = T0.DocNum) AS 'Warehouse',
            ISNULL(T0.U_wTaxComCode,(SELECT A.U_wTaxComCode FROM RCT2 A WHERE A.DocNum=T4.DOCNUM AND A.DOCENTRY=T2.TransId AND A.InvType=30)) as 'U_wTaxComCode',
            ISNULL(T0.U_WTAXRECBY,T4.U_WTAXRECBY) AS 'Received By',
            ISNULL(t0.U_WTaxRecDate,T4.U_WTaxRecDate) AS 'Received Date'

            FROM ODPI T0 
            INNER JOIN OBPL T1 ON T0.BPLId = T1.BPLId 
            INNER JOIN JDT1 T2 ON T0.DocNum = T2.U_DocNum AND T0.ObjType = T2.U_BaseDocType 
            INNER JOIN RCT2 T3 ON T3.DocEntry = T0.DocNum AND T3.InvType=T0.ObjType
            INNER JOIN ORCT T4 ON T4.DocNum = T3.DocNum AND T4.Canceled='N'

            WHERE T0.CANCELED = 'N' 
            AND T0.DocDate between @dfrom and @dto
            AND T0.DocNum NOT IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=T0.ObjType AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account IN('CA060-1000-0000'))

        ) TT
    )DD 
   WHERE WTSAM>0
   AND WTCode=@WTCode
END


