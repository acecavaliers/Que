


-- DECLARE @BRANCH VARCHAR(5)='{?Branch}',
--         @DATEFROM DATE={?DateFrom},
--         @DATETO DATE={?DateTo}


DECLARE @BRANCH VARCHAR(50)='ALL BRANCH',
        @DATEFROM DATE='01-01-2023',
        @DATETO DATE='12-31-2023'

SET @BRANCH=REPLACE(@BRANCH,'ALL BRANCH','')


SELECT 

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
WHEN X.TransType = 321 then 'Internal Reconciliation'
WHEN X.TransType = 10000071 then 'Inventory Posting'
WHEN X.TransType = 310000001 then 'Inventory Opening Balance'
WHEN X.TransType = 1470000049 then 'Capitalization'
WHEN X.TransType = 1470000060 then 'Capitalization Credit Memo'
WHEN X.TransType = 1470000071 then 'Depreciation Run'
WHEN X.TransType = 1470000075 then 'Manual Depreciation'
WHEN X.TransType = 1470000085 then 'Fixed Asset Reevaluation'
WHEN X.TransType = 1470000090 then 'Fixed Asset Transfer'
WHEN X.TransType = 1470000094 then 'Fixed Asset Retirement'

WHEN X.TransType = -4 then 'BN'
END AS TransactionType,
X.* 
FROM(
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
WHERE T0.TRANSTYPE IN ( '-2','-4','15','20','21','30','59','60','67','69','148','162','321','10000071','310000001','1470000049','1470000060','1470000071','1470000075','1470000085','1470000090','1470000094')  
AND T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   

UNION ALL
--AP INCLUDED
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DISTINCT TT.DocNum, TT.ObjType FROM PCH1 T1
            INNER JOIN OPCH TT ON T1.DocEntry=TT.DocNum
            INNER JOIN OITM T2 ON T1.ItemCode=T2.ItemCode
            INNER JOIN OITB T3 ON T3.ItmsGrpCod=T2.ItmsGrpCod
            WHERE 
            T2.ItmsGrpCod IN(100,123,125,126,127,129)
			--AND T1.DocENTRY=2038
            --AND TT.CANCELED='Y'

)T3 ON T3.DOCNUM=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   

UNION ALL
--AP LANDEDCOST EXCEPT(COST CLEARING, COST OF SALES)
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            
            SELECT DISTINCT T2.DocNum,T2.ObjType FROM  OPCH T2
            WHERE T2.DocType='S'
            AND T2.DOCNUM NOT IN (SELECT  DOCENTRY FROM PCH1 WHERE AcctCode IN ('CL020-2700-0000','CS010-0500-0000'))
            UNION ALL
            -- FROM STAND ALONE
            SELECT DISTINCT T2.DocNum,T2.ObjType FROM  OPCH T2
            INNER JOIN PCH1 T3 ON T3.DOCENTRY=T2.DOCNUM
            WHERE T2.DocType='S'
            AND T2.DOCNUM IN (SELECT  DOCENTRY FROM PCH1 WHERE AcctCode IN ('CL020-2700-0000','CS010-0500-0000'))
            AND T3.DocEntry IN ( SELECT  TrgetEntry FROM PCH1 WHERE  BaseRef IS NULL)
            
            UNION ALL
            --STAND ALONE
            SELECT DISTINCT T2.DocNum,T2.ObjType FROM  OPCH T2
            INNER JOIN PCH1 T3 ON T3.DOCENTRY=T2.DOCNUM
            WHERE T2.DocType='S'
            AND T2.DOCNUM IN (SELECT  DOCENTRY FROM PCH1 WHERE AcctCode IN ('CL020-2700-0000','CS010-0500-0000'))
            AND T3.DocEntry IN (SELECT  DocEntry FROM PCH1 A 
                                WHERE  BaseRef IS NULL AND BaseType=-1 
                                AND (SELECT COUNT(DISTINCT BaseType) FROM  PCH1 B WHERE A.DocEntry=B.DocEntry)=1 )
         
            

)T3 ON T3.DOCNUM=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   

UNION ALL

--APCM SERVICES
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DISTINCT T2.DocNum,T2.ObjType FROM RPC1 T1
            INNER JOIN ORPC T2 ON T1.DocEntry=T2.DocNum
            WHERE T2.DocType='S'
            AND AcctCode NOT IN ('CL020-2700-0000','CS010-0500-0000')
            AND Canceled='N'

)T3 ON T3.DOCNUM=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO  

UNION ALL
--APDPI

SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DocNum,T0.ObjType FROM ODPO T0
           )T3 ON T3.DocNum=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO  

-- UNION ALL
--AP WITH APDPI

-- SELECT 
-- T0.Number as 'JE Entry', '' AS 'TRANS_TP',
-- T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
-- T0.TaxDate AS Date,
-- T0.NUMBER AS 'Base Reference',
-- CASE WHEN T0.MEMO <> T1.LINEMEMO THEN
-- concat(t0.Memo,' : ', T1.LineMemo)
-- ELSE t0.Memo
-- END as 'Brief Description',
-- T1.Account as 'Account Code',
-- T2.Acctname as 'Account Name',
-- '' as 'PHP Balance',
-- T1.Debit AS 'PHP Debit',
-- T1.Credit AS 'PHP Credit'

-- FROM OJDT t0 
-- INNER JOIN JDT1 T1 ON T0.NUMBER = T1.TRANSID 
-- LEFT OUTER JOIN OACT T2 ON T1.ACCOUNT = T2.AcctCode
-- INNER JOIN (
--             SELECT DocEntry,T0.OBJCODE FROM PCH9 T0

--            )T3 ON T3.DocEntry=T0.BASEREF AND T0.TRANSTYPE=T3.OBJCODE
-- WHERE 
-- T1.BPLNAME LIKE '%'+@BRANCH+'%'       
-- AND LEFT(T1.Account,10) LIKE '%CA060-1100%'
-- AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO  


UNION ALL
--INCOMING CREDIT CARD AND CHECKS

SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DISTINCT T0.DocNum,T0.ObjType,T1.CreditAcct AS ACCT,SourceLine,T2.TransId FROM ORCT T0
            INNER JOIN RCT3 T1 ON T0.DocNum=T1.DocNum
            INNER JOIN JDT1 T2 ON T0.DOCNUM=T2.BASEREF AND T2.TRANSTYPE=T0.ObjType AND T1.CreditAcct=T2.Account
            WHERE T0.CREDITSUM >0 AND Canceled='N'

            UNION ALL

            SELECT DISTINCT T0.DocNum,T0.ObjType,CheckAcct  AS ACCT ,SourceLine,T1.TransId  FROM ORCT T0
            INNER JOIN JDT1 T1 ON T0.DOCNUM=T1.BASEREF AND T1.TRANSTYPE=T0.ObjType  AND CheckAcct=T1.Account
            WHERE  T0.CHECKSUM>0 AND Canceled='N'--CashAcct IS NULL AND TrsfrAcct IS NULL AND Canceled='N'

            )T3 ON T3.TransId=T1.TransId AND T1.SourceLine=T3.SourceLine
WHERE

T1.BPLName LIKE '%'+@BRANCH+'%'        
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO  


UNION ALL
 --INCOMING CANCELED + --OUTGOING BOUNCED CHECK

 SELECT 
 T0.Number as 'JE Entry', '' AS 'TRANS_TP',
 T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
 T0.TaxDate AS Date,
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
 INNER JOIN (
            SELECT  T0.DocNum,T0.ObjType,T1.CreditAcct AS ACCT,SourceLine,T2.TransId FROM ORCT T0
            INNER JOIN RCT3 T1 ON T0.DocNum=T1.DocNum
            INNER JOIN JDT1 T2 ON T0.DOCNUM=T2.BASEREF AND T2.TRANSTYPE=T0.ObjType AND T1.CreditAcct=T2.Account
            WHERE T0.CREDITSUM >0 AND Canceled='Y'

            UNION ALL

            SELECT T0.DocNum,T0.ObjType,T0.CheckAcct AS ACCT,SourceLine,T2.TransId FROM ORCT T0
            INNER JOIN JDT1 T2 ON T0.DOCNUM=T2.BASEREF AND T2.TRANSTYPE=T0.ObjType AND T0.CheckAcct=T2.Account
            WHERE  T0.CHECKSUM>0 AND Canceled='Y'

            UNION ALL

            SELECT  T0.DocNum,T0.ObjType,CashAcct  AS ACCT ,SourceLine, T1.TransId FROM ORCT T0
            INNER JOIN JDT1 T1 ON T0.DOCNUM=T1.BASEREF AND T1.TRANSTYPE=T0.ObjType  AND CashAcct=T1.Account
            WHERE  T0.CashSum>0 AND Canceled='Y'--CashAcct IS NULL AND TrsfrAcct IS NULL AND Canceled='Y'

            UNION ALL

            SELECT  T0.DocNum,T0.ObjType,TrsfrAcct  AS ACCT ,SourceLine, T1.TransId  FROM ORCT T0
            INNER JOIN JDT1 T1 ON T0.DOCNUM=T1.BASEREF AND T1.TRANSTYPE=T0.ObjType  AND TrsfrAcct=T1.Account
            WHERE  T0.TrsfrSum>0 AND Canceled='Y'--CashAcct IS NULL AND TrsfrAcct IS NULL AND Canceled='N'

            UNION ALL
            --OUTGOING BOUNCED CHECK

            SELECT  T0.DocNum,T0.ObjType,CheckAcct  AS ACCT ,SourceLine, T1.TransId FROM ORCT T0
            INNER JOIN JDT1 T1 ON T0.DOCNUM=T1.BASEREF AND T1.TRANSTYPE=T0.ObjType  AND CheckAcct=T1.Account
            WHERE  T0.CheckSum>0 AND T0.U_PAYMENTTYPE='BC'
            
            UNION ALL
            --OUTGOING BOUNCED CASH
            SELECT  T0.DocNum,T0.ObjType,CashAcct  AS ACCT ,SourceLine, T1.TransId FROM OVPM T0
            INNER JOIN JDT1 T1 ON T0.DOCNUM=T1.BASEREF AND T1.TRANSTYPE=T0.ObjType  AND CashAcct=T1.Account
            WHERE  T0.CashSum>0 AND T0.U_PAYMENTTYPE='BC'
            
            UNION ALL
            --OUTGOING BOUNCED BNKTRANSFER
            SELECT  T0.DocNum,T0.ObjType,TrsfrAcct  AS ACCT ,SourceLine, T1.TransId FROM OVPM T0
            INNER JOIN JDT1 T1 ON T0.DOCNUM=T1.BASEREF AND T1.TRANSTYPE=T0.ObjType  AND TrsfrAcct=T1.Account
            WHERE  T0.TrsfrSum>0 AND T0.U_PAYMENTTYPE='BC'

             UNION ALL
            --OUTGOING BOUNCED CREDIT CARD
            SELECT  T0.DocNum,T0.ObjType,T1.CreditAcct AS ACCT,SourceLine,T2.TransId FROM ORCT T0
            INNER JOIN RCT3 T1 ON T0.DocNum=T1.DocNum
            INNER JOIN JDT1 T2 ON T0.DOCNUM=T2.BASEREF AND T2.TRANSTYPE=T0.ObjType AND T1.CreditAcct=T2.Account            
            WHERE  T0.CreditSum>0 AND T0.U_PAYMENTTYPE='BC'

            )T3 ON T3.TransId=T1.TransId AND T1.SourceLine=T3.SourceLine
            
 WHERE 
 T1.BPLName LIKE '%'+@BRANCH+'%'       
 AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   
    

UNION ALL
--DEPOSIT CREDIT CARD AND CHEQUE EXEMPT
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DeposNum,ObjType FROM ODPS WHERE DeposType='C' --AND Memo <> 'CANCELED' 
           )T3 ON T3.DeposNum=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   

UNION ALL
--ARDPI
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DocNum,ObjType FROM ODPI
           )T3 ON T3.DocNum=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   


-- UNION ALL
-- --ALL ARINV OUTPUTTAX FROM ARDI
-- SELECT 
-- T0.Number as 'JE Entry', '' AS 'TRANS_TP',
-- T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
-- T0.TaxDate AS Date,
-- T0.NUMBER AS 'Base Reference',
-- CASE WHEN T0.MEMO <> T1.LINEMEMO THEN
-- concat(t0.Memo,' : ', T1.LineMemo)
-- ELSE t0.Memo
-- END as 'Brief Description',
-- T1.Account as 'Account Code',
-- T2.Acctname as 'Account Name',
-- '' as 'PHP Balance',
-- T1.Debit AS 'PHP Debit',
-- T1.Credit AS 'PHP Credit'

-- FROM OJDT t0 
-- INNER JOIN JDT1 T1 ON T0.NUMBER = T1.TRANSID 
-- LEFT OUTER JOIN OACT T2 ON T1.ACCOUNT = T2.AcctCode
-- INNER JOIN (
--             SELECT DocNum,T0.ObjType FROM OINV T0
--             INNER JOIN INV9 T1 ON T1.DocEntry=T0.DocNum
--            )T3 ON T3.DocNum=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
-- WHERE 
-- T1.BPLNAME LIKE '%'+@BRANCH+'%'       
-- AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   
-- -- AND T1.Account LIKE '%CL020-2600%'

UNION ALL
--ALL ARINV  INVENTORY
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DocNum,T0.ObjType FROM OINV T0
           )T3 ON T3.DocNum=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   
AND T1.Account LIKE '%CA040-0100%' 

UNION ALL
--ALL ARINV COST OF SALES
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DocNum,T0.ObjType FROM OINV T0
           )T3 ON T3.DocNum=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   
AND T1.Account ='CS010-0100-0000'

UNION ALL
--ALL ARCM INN TRADE GS
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DocNum,T0.ObjType FROM ORIN T0
           )T3 ON T3.DocNum=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   
AND T1.Account LIKE '%CA040-0100%'

UNION ALL
--ALL ARCM INV TRADE BAD STOCKS
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DocNum,T0.ObjType FROM ORIN T0
           )T3 ON T3.DocNum=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   
AND T1.Account LIKE '%CA040-0200%'



UNION ALL
--ALL ARCM COST OF SALES
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT DocNum,T0.ObjType FROM ORIN T0
           )T3 ON T3.DocNum=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO   
AND T1.Account ='CS010-0100-0000'


UNION ALL

--ARCM FROM ARDPI
SELECT 
T0.Number as 'JE Entry', '' AS 'TRANS_TP',
T0.TransType,T0.TransCode,T1.Line_ID,T1.BPLName,
T0.TaxDate AS Date,
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
INNER JOIN (
            SELECT T0.DocEntry,T0.ObjType  FROM RIN1 T0
            INNER JOIN ODPI T1 ON T0.BaseRef=T1.DocNum AND T0.BaseType=T1.ObjType
           

)T3 ON T3.DocEntry=T0.BASEREF AND T0.TRANSTYPE=T3.ObjType
WHERE 
T1.BPLName LIKE '%'+@BRANCH+'%'       
AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO  

)X
-- where [JE Entry] in (49037)
ORDER BY                               
X.[JE Entry], X.Line_ID ASC

