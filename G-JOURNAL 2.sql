-- DECLARE @BRANCH VARCHAR(5)='{?Branch}',
--         @DATEFROM DATE={?DateFrom},
--         @DATETO DATE={?DateTo}


DECLARE @BRANCH VARCHAR(5)='0',
        @DATEFROM DATE='01-01-2021',
        @DATETO DATE='12-31-2022'

SET @BRANCH=REPLACE(@BRANCH,'0','')


SELECT 
-- ROW_NUMBER() OVER(PARTITION BY X.[Account Code] ORDER BY X.[JE Entry] ASC ) AS Row#,
CASE WHEN X.TRANSTYPE = 69 THEN 'Landed Costs'
WHEN X.TransType = -2 THEN 'Opening Balance'
WHEN X.TransType = 15 THEN 'Delivery'
WHEN X.TransType = 67 then 'Inventory Transfer'
WHEN X.TransType = 21 then 'Goods Return'
WHEN X.TransType = 18 then 'A/P Invoice'
WHEN X.TransType = 19 then 'A/P Credit Memo'
WHEN X.TransType = 13 then 'A/R Invoice'
WHEN X.TransType = 162 then 'Inventory Reevaluation'
WHEN X.TransType = 59 then 'Goods Receipt'
WHEN X.TransType = 60 then 'Goods Issue'
WHEN X.TransType = 20 then 'GRPO'
WHEN X.TransType = 14 then 'A/R Credit Memo'
WHEN X.TransType = 30 then CASE WHEN X.TransCode='OBB' THEN 'Opening Balance' ELSE 'Journal Entry' END
WHEN X.TransType = 24 then 'Incoming Payment'
WHEN X.TransType = 25 then 'Deposit'
WHEN X.TransType = 46 then 'Outgoing Payments'
WHEN X.TransType = 203 then 'A/R Downpayment'
WHEN X.TransType = 204 then 'A/P Downpayment'
-- WHEN X.TransType = 321 then 'Internal Reconciliation'
WHEN X.TransType = 10000071 then 'Inventory Posting'
-- WHEN X.TransType = 310000001 then 'Inventory Opening Balance'
WHEN X.TransType=310000001 then 'Begining Balance'
-- WHEN X.TransType = -2 then 'Opening Balance'
WHEN X.TransType = 1470000049 then 'Capitalization'
WHEN X.TransType = 1470000071 then 'Depreciation Run'
WHEN X.TransType = 1470000075 then 'Manual Depreciation'
WHEN X.TransType = 1470000085 then 'Fixed Asset Reevaluation'
WHEN X.TransType = 1470000090 then 'Fixed Asset Transfer'
WHEN X.TransType = 1470000094 then 'Fixed Asset Retirement'

WHEN X.TransType = -4 then 'BN'
END AS TransactionType,
X.* FROM(
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,t1.BPLId,
T0.REFDATE AS Date,
T0.NUMBER AS 'Base Reference',
CASE WHEN T0.MEMO <> T1.LINEMEMO THEN
concat(t0.Memo,' : ', T1.LineMemo)
ELSE t0.Memo
END as 'Brief Description',
T1.Account as 'Account Code',
T2.Acctname as 'Account Name',
'' as 'PHP Balance',
T1.Debit AS 'PHP Debit',
T1.Credit AS 'PHP Credit'

FROM OJDT t0 
INNER JOIN JDT1 T1 ON T0.NUMBER = T1.TRANSID 
LEFT OUTER JOIN OACT T2 ON T1.ACCOUNT = T2.AcctCode
WHERE T0.TRANSTYPE IN ( '-2','-4','15','20','21','30','59','60','67','69','148','162','203','204','10000071','310000001','1470000049','1470000071','1470000075','1470000085','1470000090','1470000094')  
AND T1.BPLId LIKE '%'+@BRANCH+'%'       
AND T0.REFDATE BETWEEN @DATEFROM AND @DATETO                  

UNION ALL
--ADVANCE CLEARING
SELECT 
T0.Number as 'JE Entry', 'ADVANCE CLEARING' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,t1.BPLId,
T0.REFDATE AS Date,
T0.NUMBER AS 'Base Reference',
CASE WHEN T0.MEMO <> T1.LINEMEMO THEN
concat(t0.Memo,' : ', T1.LineMemo)
ELSE t0.Memo
END as 'Brief Description',
T1.Account as 'Account Code',
T2.Acctname as 'Account Name',
'' as 'PHP Balance',
T1.Debit AS 'PHP Debit',
T1.Credit AS 'PHP Credit'

FROM OJDT t0 
INNER JOIN JDT1 T1 ON T0.NUMBER = T1.TRANSID 
LEFT OUTER JOIN OACT T2 ON T1.ACCOUNT = T2.AcctCode
WHERE T1.BaseRef IN (SELECT t1.docnum FROM ODPO T0 INNER JOIN VPM2 T1 ON T0.DocNum=T1.DOCENTRY)
AND T1.TransType=46 AND T1.CheckAbs IS NULL
AND T1.BPLId LIKE '%'+@BRANCH+'%'       
AND T0.REFDATE BETWEEN @DATEFROM AND @DATETO                  



UNION ALL
--//AR & AP WITH ARDPI /APDPI
SELECT 

T0.Number as 'JE Entry',T3.TRANS_TP,
T0.TransType,T0.TransCode,T1.Line_ID,t1.BPLId,
T0.REFDATE AS Date,
T0.NUMBER AS 'Base Reference',
CASE WHEN T0.MEMO <> T1.LINEMEMO THEN
concat(t0.Memo,' : ', T1.LineMemo)
ELSE t0.Memo
END as 'Brief Description',
T1.Account as 'Account Code',
T2.Acctname as 'Account Name',
'' as 'PHP Balance',
T1.Debit AS 'PHP Debit',
T1.Credit AS 'PHP Credit'

FROM OJDT t0 
INNER JOIN JDT1 T1 ON T0.NUMBER = T1.TRANSID 
LEFT OUTER JOIN OACT T2 ON T1.ACCOUNT = T2.AcctCode
INNER  JOIN (SELECT DocEntry ,ObjCode, 'AR W/ARDPI' AS 'TRANS_TP' FROM  INV9 
            UNION ALL 
            SELECT DocEntry ,ObjCode, 'AP W/APDPI' AS 'TRANS_TP' FROM  PCH9 
            UNION ALL 
            -- SELECT DocNum AS 'DocEntry',ObjType, 'INCOMING ON ACCT' AS 'TRANS_TP' FROM ORCT WHERE DocType='A' AND Canceled='N'
            -- UNION ALL
            --INCOMING / OUTGOING ON ACCT FOR CHECK AND CREDIT CARD
            SELECT DocNum AS 'DocEntry',ObjType, 'INCOMING CHECK' AS 'TRANS_TP' FROM ORCT where CheckAcct is not null AND DocType='A' AND Canceled='N'
            UNION ALL
            SELECT DocNum AS 'DocEntry',ObjType, 'INCOMING CARD' AS 'TRANS_TP' FROM ORCT where CheckAcct is null and CashAcct is null and TrsfrAcct is null AND DocType='A' AND Canceled='N'
            UNION ALL             
            SELECT DocNum AS 'DocEntry',ObjType, 'INCOMING CHECK' AS 'TRANS_TP' FROM OVPM where CheckAcct is not null AND DocType='A' AND Canceled='N'
            UNION ALL
            SELECT DocNum AS 'DocEntry',ObjType, 'INCOMING CARD' AS 'TRANS_TP' FROM OVPM where CheckAcct is null and CashAcct is null and TrsfrAcct is null AND DocType='A' AND Canceled='N'
            --// END INCOMING / OUTGOING ON ACCT FOR CHECK AND CREDIT CARD
            UNION ALL 

            SELECT DocNum AS 'DocEntry',ObjType, 'OUTGOING ON ACCT' AS 'TRANS_TP' FROM OVPM WHERE DocType='A' AND Canceled='N'
            UNION ALL 
            SELECT DocNum AS 'DocEntry',ObjType, 'OUTGOING ON BOUNCED CHECK' AS 'TRANS_TP' FROM OVPM WHERE PayNoDoc='Y' AND U_PaymentType='BC' AND Canceled='N'
            UNION ALL 
            SELECT DocNum AS 'DocEntry',ObjType, 'OUTGOING ON BOUNCED CHECK' AS 'TRANS_TP' FROM ORCT WHERE PayNoDoc='Y' AND U_PaymentType='BC' AND Canceled='N'
            UNION ALL 
            SELECT DeposNum AS 'DocEntry',ObjType, 'DEPOSIT CASH' AS 'TRANS_TP' FROM ODPS WHERE DeposType='C' AND Canceled='N'
            UNION ALL                       
            SELECT DocNum AS 'DocEntry',ObjType, 'VENDORS /AP' AS 'TRANS_TP'  FROM OPCH 
            WHERE CANCELED='N' --AND CardCode IN (SELECT CARDCODE FROM OCRD WHERE CARDTYPE='S' AND U_TaxPayerClass='Y' )
            AND CardCode IN ('V000107','V000011','V000012','V000013','V000014','V000018','V000023','V000032','V000037','V000039',
                             'V000060','V000061','V000062','V000064','V000067','V000072','V000095','V000098','V000105','V000107',
	                          'V000118','V000126','V000128','V000130','V000137','V000153','V000154','V000172')
            ) AS T3
            ON T1.BaseRef=T3.DocEntry AND T1.TransType=T3.ObjCode
WHERE  T1.BPLId LIKE '%'+@BRANCH+'%' 
AND T0.REFDATE BETWEEN @DATEFROM AND @DATETO

)X

ORDER BY 
X.[JE Entry], X.Line_ID ASC


-- SELECT TransId,* FROM OVPM WHERE DocNum=8

-- SELECT T0.DocEntry AS 'APDPR #',T0.* FROM VPM2 t0 
-- -- INNER JOIN JDT1 T3 ON T0.DocTransId = T3.TRANSID 
-- WHERE  t0.DocNum =8

-- select CheckAbs,* from jdt1 where TransId=70
