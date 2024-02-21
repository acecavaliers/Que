


DECLARE @dt as varchar(1) ='',
 @DateFrom DATE='2023-01-01', 
 @Dateto date= '2023-12-31',
@Branch Varchar(50) = ''




set @branch = replace((@branch),'ALL BRANCH','')

----------------------------------------- CASH
SELECT * FROM (
SELECT DISTINCT
T0.DOCNUM AS 'DOCNUM',
T0.TaxDate as 'Document Date',
T0.Docdate as 'Posting Date',
CONCAT('RC ',T0.DOCNUM) as 'Cash Receipt #',

CASE WHEN T0.U_PayLoc LIKE '%Store Collect%' THEN
		CONCAT (T0.U_CollRcptNo ,
		  		(SELECT Countries = STUFF((
         SELECT
			'; '+CASE WHEN T3.InvType = 203 Then ''
			WHEN T3.InvType = 46 Then ''
			WHEN T3.InvType = 13 Then 'AR' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 14 Then 'CM' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 30 Then ''
			END
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, '')))
	 WHEN T0.U_PayLoc = '' THEN

  		(SELECT Countries = STUFF((
         SELECT
			', '+CASE WHEN T3.InvType = 203 Then 'ARDPI'
			WHEN T3.InvType = 46 Then 'OP'
			WHEN T3.InvType = 13 Then 'AR'
			WHEN T3.InvType = 14 Then 'CM'
			WHEN T3.InvType = 30 Then 'JE'
			END,
			+'-' + CONVERT(varchar(10), T3.DOCENTRY)
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, ''))

	 WHEN T0.U_PayLoc LIKE '%Customer%' THEN
		CONCAT (T0.U_CollRcptNo ,
		  		(SELECT Countries = STUFF((
         SELECT
			'; '+CASE WHEN T3.InvType = 203 Then ''
			WHEN T3.InvType = 46 Then ''
			WHEN T3.InvType = 13 Then 'AR' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 14 Then 'CM' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 30 Then ''
			END
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, '')))
	 WHEN T0.U_PayLoc LIKE '%Head%' THEN
		CONCAT (T0.U_CollRcptNo ,
		  		(SELECT Countries = STUFF((
         SELECT
			'; '+CASE WHEN T3.InvType = 203 Then ''
			WHEN T3.InvType = 46 Then ''
			WHEN T3.InvType = 13 Then 'AR' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 14 Then 'CM' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 30 Then ''
			END
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, '')))
END AS 'Reference #',

T0.CardCode as 'Customer Code',
T0.CardName as 'Customer Name',
ISNULL((T1.LicTradNum),'-') as 'Customer TIN',
T3.Account as 'Account Code',
T4.AcctName as 'Account Name',

T3.DEBIT AS 'PHP Debit',

T3.CREDIT AS 'PHP Credit',
T2.MEMO as 'Remarks',
T3.BPLNAME,
t2.Number,
NULL AS SourceLine
FROM ORCT T0
left JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN OJDT T2 ON T0.TRANSID = T2.Number
INNER JOIN JDT1 T3 ON T2.NUMBER = T3.TRANSID
AND (T0.CashAcct = T3.Account OR T0.CashAcct = T3.ContraAct)
INNER JOIN OACT T4 ON T3.Account = T4.AcctCode
INNER JOIN (
        SELECT T0.DocNum,T0.ObjType,T0.CashAcct AS ACCT,SourceLine,T2.TransId FROM ORCT T0
        INNER JOIN JDT1 T2 ON T0.DOCNUM=T2.BASEREF AND T2.TRANSTYPE=T0.ObjType AND T0.CashAcct=T2.Account
        WHERE T0.CashSum >0 
		AND T0.DocType<>'A'
)T5 ON T3.TransId=T5.TransId AND T3.SourceLine=T5.SourceLine
WHERE 

-- T0.CASHSUM > 0.00 AND CHECKSUM=0 AND TrsfrSum=0 AND CreditSum=0 AND 
T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
AND T3.BPLName like  '%'+@Branch+'%'
and t3.TransType!=310000001
AND T0.Canceled = 'N'

----------------------------------------- // CASH
UNION ALL
--CASH TENDER SHORT OVER 
SELECT DISTINCT
T0.DOCNUM AS 'DOCNUM',
T0.TaxDate as 'Document Date',
T0.Docdate as 'Posting Date',
CONCAT('RC ',T0.DOCNUM) as 'Cash Receipt #',

CASE WHEN T0.U_PayLoc LIKE '%Store Collect%' THEN
		CONCAT (T0.U_CollRcptNo ,
		  		(SELECT Countries = STUFF((
         SELECT
			'; '+CASE WHEN T3.InvType = 203 Then ''
			WHEN T3.InvType = 46 Then ''
			WHEN T3.InvType = 13 Then 'AR' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 14 Then 'CM' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 30 Then ''
			END
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, '')))
	 WHEN T0.U_PayLoc = '' THEN

  		(SELECT Countries = STUFF((
         SELECT
			', '+CASE WHEN T3.InvType = 203 Then 'ARDPI'
			WHEN T3.InvType = 46 Then 'OP'
			WHEN T3.InvType = 13 Then 'AR'
			WHEN T3.InvType = 14 Then 'CM'
			WHEN T3.InvType = 30 Then 'JE'
			END,
			+'-' + CONVERT(varchar(10), T3.DOCENTRY)
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, ''))

	 WHEN T0.U_PayLoc LIKE '%Customer%' THEN
		CONCAT (T0.U_CollRcptNo ,
		  		(SELECT Countries = STUFF((
         SELECT
			'; '+CASE WHEN T3.InvType = 203 Then ''
			WHEN T3.InvType = 46 Then ''
			WHEN T3.InvType = 13 Then 'AR' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 14 Then 'CM' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 30 Then ''
			END
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, '')))
	 WHEN T0.U_PayLoc LIKE '%Head%' THEN
		CONCAT (T0.U_CollRcptNo ,
		  		(SELECT Countries = STUFF((
         SELECT
			'; '+CASE WHEN T3.InvType = 203 Then ''
			WHEN T3.InvType = 46 Then ''
			WHEN T3.InvType = 13 Then 'AR' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 14 Then 'CM' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 30 Then ''
			END
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, '')))
END AS 'Reference #',

T0.CardCode as 'Customer Code',
T0.CardName as 'Customer Name',
ISNULL((T1.LicTradNum),'-') as 'Customer TIN',
T3.Account as 'Account Code',
T4.AcctName as 'Account Name',

T3.DEBIT AS 'PHP Debit',

T3.CREDIT AS 'PHP Credit',
T2.MEMO as 'Remarks',
T3.BPLNAME,
t2.Number,
NULL AS SourceLine
FROM ORCT T0
left JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN OJDT T2 ON T0.TRANSID = T2.Number
INNER JOIN JDT1 T3 ON T2.NUMBER = T3.TRANSID
AND (T0.CashAcct = T3.Account OR T0.CashAcct = T3.ContraAct)
INNER JOIN OACT T4 ON T3.Account = T4.AcctCode
INNER JOIN (
        SELECT T0.DocNum,T0.ObjType,T0.CashAcct AS ACCT,SourceLine,T2.TransId FROM ORCT T0
        INNER JOIN JDT1 T2 ON T0.DOCNUM=T2.BASEREF AND T2.TRANSTYPE=T0.ObjType AND T0.CashAcct=T2.Account
        WHERE T0.CashSum >0 
		AND T0.DocType='A'
)T5 ON T3.TransId=T5.TransId --AND T3.SourceLine=T5.SourceLine
WHERE 

-- T0.CASHSUM > 0.00 AND CHECKSUM=0 AND TrsfrSum=0 AND CreditSum=0 AND 
T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
AND T3.BPLName like  '%'+@Branch+'%'
and t3.TransType!=310000001
AND T0.Canceled = 'N'


UNION ALL
SELECT DISTINCT
(SELECT TOP 1 RcptNum FROM OCHH WHERE OCHH.TransNum = T3.TransId AND OCHH.CheckSum = CASE WHEN T3.DEBIT = 0 THEN T3.CREDIT ELSE T3.DEBIT END)DOCNUM,
--
T8.DeposDate as 'Document Date',
T8.U_PostingDate as 'Posting Date',
CONCAT('DP ',T8.DeposNum) as 'Cash Receipt #',
--CONVERT(varchar(10), CONCAT('RC ' , T6.RcptNum)) AS 'Reference #',
CONVERT(varchar(10), CONCAT('RC ' ,(SELECT TOP 1 RcptNum FROM OCHH WHERE OCHH.TransNum = T3.TransId AND OCHH.CheckSum = CASE WHEN T3.DEBIT = 0 THEN T3.CREDIT ELSE T3.DEBIT END)))  AS 'Reference #',

T0.CardCode as 'Customer Code',
T0.CardName as 'Customer Name',
T1.LicTradNum as 'Customer TIN',
T3.ACCOUNT AS 'Account Code',
T4.AcctName AS 'Account Name',

T3.DEBIT AS 'PHP DEBIT',

T3.CREDIT AS 'PHP CREDIT',

t8.Memo as 'Remarks',
T3.BPLNAME,
t2.Number,
TT.SourceLine
FROM ORCT T0 
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE 
inner join rct1 T5 on T0.docentry=T5.docnum
INNER JOIN OCHH T6 ON T6.CheckKey=T5.CheckAbs 
INNER JOIN DPS1 T7 ON T7.CheckKey = T6.CheckKey
INNER JOIN ODPS T8 ON T8.DeposId = T7.DepositId
INNER JOIN OJDT T2 ON T2.BASEREF = T8.DEPOSNUM
--INNER JOIN OJDT T2 ON T2.BASEREF = T8.DEPOSNUM
INNER JOIN JDT1 T3 ON T2.NUMBER = T3.TRANSID  AND T0.DocNum = T6.RcptNum
INNER JOIN OACT T4 ON T3.Account = T4.AcctCode
INNER JOIN (
        SELECT T0.DeposNum,T0.ObjType,T0.BanckAcct AS ACCT,SourceLine,T2.TransId FROM ODPS T0
        INNER JOIN JDT1 T2 ON T0.DeposNum=T2.BASEREF AND T2.TRANSTYPE=T0.ObjType AND T0.BanckAcct=T2.Account
        WHERE T0.DeposType='K'
)TT ON T3.TransId=TT.TransId AND T3.SourceLine=TT.SourceLine
WHERE
--  T0.CheckSum > 0.00 AND CashSum=0 AND TrsfrSum=0 AND CreditSum=0 
-- AND 
-- T0.CANCELED = 'N' 
-- AND 
T8.DEPOSTYPE = 'K'  
AND T2.TRANSTYPE = 25 
AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
AND T3.TransType!=310000001
AND T3.BPLName like  '%'+@Branch+'%'


----------------------------------------- // CHECKS

UNION ALL
-----------------------------------------
----------------------------------------- CREDIT CARD
select
DISTINCT

-- T4.RctAbs as DOCNUM,
T0.DeposNum AS DOCNUM, 
T0.DEPOSDATE as 'Document Date',
T0.U_PostingDate as 'Posting Date',
CONCAT('DP ',T0.DeposNum) as 'Cash Receipt #',
CASE WHEN T4.RctAbs IS NULL THEN CONCAT('DP ' , T0.DeposNum) ELSE
CONVERT(varchar(10), CONCAT('RC ' ,T4.RctAbs)) END as 'Reference #',
ISNULL(t4.CardCode,'-') as 'Customer Code',
ISNULL(t4.cardname,'-') as 'Customer Name',
ISNULL(ISNULL((SELECT TOP 1 U_TIN FROM RCT2 A 
                INNER JOIN OINV B ON A.DocEntry=B.DocNum AND A.INVTYPE=B.ObjType 
                WHERE U_TIN IS NOT NULL)
            , T7.LicTradNum),'-') 

AS 'Customer TIN',
T2.Account AS 'Account Code',
T3.AcctName AS 'Account Name',
T2.Debit AS 'PHP Debit',
T2.Credit AS 'PHP Credit',
T0.MEMO AS 'Remarks',
T2.BPLName,
t1.Number,
NULL AS SourceLine
from odps T0
INNER JOIN OJDT T1 ON T0.DeposNum = T1.BaseRef AND T1.TransType = 25
INNER JOIN JDT1 T2 ON T1.TransId = T2.TransId
INNER JOIN OACT T3 ON T2.Account = T3.AcctCode
LEFT JOIN OCRH T4 ON t4.VoucherNum = T2.Ref3Line AND T4.CreditSum=(T2.Debit+T2.Credit) AND T0.DeposNum=T4.DepNum
LEFT JOIN OCRD T7 ON T4.CARDCODE = T7.CARDCODE
LEFT JOIN ORCT T8 ON T4.RctAbs = T8.DocNum
where T0.DeposType = 'v'

AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
AND T2.TransType!=310000001

----------------------------------------- // CREDIT CARD
UNION ALL
-----------------------------------------
----------------------------------------- BANK TRANSFERS

SELECT DISTINCT
T0.DOCNUM AS 'DOCNUM',
T0.TaxDate as 'Document Date',
T0.Docdate as 'Posting Date',
CONCAT('RC ',T0.DOCNUM) as 'Cash Receipt #',

CASE WHEN T0.U_PayLoc LIKE '%Store Collect%' THEN
		T0.U_CollRcptNo
	 WHEN T0.U_PayLoc = '' THEN

  		(SELECT Countries = STUFF((
         SELECT
			', '+CASE WHEN T3.InvType = 203 Then 'ARDPI'
			WHEN T3.InvType = 46 Then 'OP'
			WHEN T3.InvType = 13 Then 'AR'
			WHEN T3.InvType = 14 Then 'CM'
			WHEN T3.InvType = 30 Then 'JE'
			END,
			+'-' + CONVERT(varchar(10), T3.DOCENTRY)
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, ''))

	 WHEN T0.U_PayLoc LIKE '%Customer%' THEN
		T0.U_CollRcptNo
	 WHEN T0.U_PayLoc LIKE '%Head%' THEN
		T0.U_CollRcptNo
END AS 'Reference #',

T0.CardCode as 'Customer Code',
T0.CardName as 'Customer Name',
ISNULL((T1.LicTradNum),'-') as 'Customer TIN',
t4.Account as 'Account Code',
T5.AcctName AS 'Account Name',
T4.DEBIT AS 'PHP Debit',

T4.CREDIT AS 'PHP Credit',
T2.MEMO as 'Remarks',
T4.BPLNAME,
t2.Number,
NULL AS SourceLine

FROM ORCT T0
LEFT JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN OJDT T2 ON T0.TRANSID = T2.Number
INNER JOIN JDT1 T4 ON T2.NUMBER = T4.TRANSID
INNER JOIN OACT T5 ON T4.Account = T5.AcctCode
INNER JOIN (
        SELECT T0.DocNum,T0.ObjType,T0.TrsfrAcct AS ACCT,SourceLine,T2.TransId FROM ORCT T0
        INNER JOIN JDT1 T2 ON T0.DOCNUM=T2.BASEREF AND T2.TRANSTYPE=T0.ObjType AND T0.TrsfrAcct=T2.Account
        WHERE T0.trsfrSum >0 
        AND T0.DocType<>'A'
)TT ON T4.TransId=TT.TransId AND T4.SourceLine=TT.SourceLine
WHERE 
-- T0.trsfrSum > 0.00 AND CHECKSUM=0 AND CashSum=0 AND CreditSum=0 
-- AND 
T0.CANCELED = 'N'
AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
AND T4.TransType!=310000001
AND T4.BPLName like  '%'+@Branch+'%'

UNION ALL 

SELECT DISTINCT
T0.DOCNUM AS 'DOCNUM',
T0.TaxDate as 'Document Date',
T0.Docdate as 'Posting Date',
CONCAT('RC ',T0.DOCNUM) as 'Cash Receipt #',

CASE WHEN T0.U_PayLoc LIKE '%Store Collect%' THEN
		T0.U_CollRcptNo
	 WHEN T0.U_PayLoc = '' THEN

  		(SELECT Countries = STUFF((
         SELECT
			', '+CASE WHEN T3.InvType = 203 Then 'ARDPI'
			WHEN T3.InvType = 46 Then 'OP'
			WHEN T3.InvType = 13 Then 'AR'
			WHEN T3.InvType = 14 Then 'CM'
			WHEN T3.InvType = 30 Then 'JE'
			END,
			+'-' + CONVERT(varchar(10), T3.DOCENTRY)
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, ''))

	 WHEN T0.U_PayLoc LIKE '%Customer%' THEN
		T0.U_CollRcptNo
	 WHEN T0.U_PayLoc LIKE '%Head%' THEN
		T0.U_CollRcptNo
END AS 'Reference #',

T0.CardCode as 'Customer Code',
T0.CardName as 'Customer Name',
ISNULL((T1.LicTradNum),'-') as 'Customer TIN',
t4.Account as 'Account Code',
T5.AcctName AS 'Account Name',
T4.DEBIT AS 'PHP Debit',

T4.CREDIT AS 'PHP Credit',
T2.MEMO as 'Remarks',
T4.BPLNAME,
t2.Number,
NULL AS SourceLine

FROM ORCT T0
LEFT JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN OJDT T2 ON T0.TRANSID = T2.Number
INNER JOIN JDT1 T4 ON T2.NUMBER = T4.TRANSID
INNER JOIN OACT T5 ON T4.Account = T5.AcctCode
INNER JOIN (
        SELECT T0.DocNum,T0.ObjType,T0.TrsfrAcct AS ACCT,SourceLine,T2.TransId FROM ORCT T0
        INNER JOIN JDT1 T2 ON T0.DOCNUM=T2.BASEREF AND T2.TRANSTYPE=T0.ObjType AND T0.TrsfrAcct=T2.Account
        WHERE T0.trsfrSum >0 
        AND T0.DocType='A'
)TT ON T4.TransId=TT.TransId --AND T4.SourceLine=TT.SourceLine
WHERE 
-- T0.trsfrSum > 0.00 AND CHECKSUM=0 AND CashSum=0 AND CreditSum=0 
-- AND 
T0.CANCELED = 'N'
AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
AND T4.TransType!=310000001
AND T4.BPLName like  '%'+@Branch+'%'

UNION ALL 
--INCOMING CANCELED

SELECT DISTINCT
T0.DOCNUM AS 'DOCNUM',
T0.TaxDate as 'Document Date',
T0.Docdate as 'Posting Date',
CONCAT('RC ',T0.DOCNUM) as 'Cash Receipt #',

CASE WHEN T0.U_PayLoc LIKE '%Store Collect%' THEN
		T0.U_CollRcptNo
	 WHEN T0.U_PayLoc = '' THEN

  		(SELECT Countries = STUFF((
         SELECT
			', '+CASE WHEN T3.InvType = 203 Then 'ARDPI'
			WHEN T3.InvType = 46 Then 'OP'
			WHEN T3.InvType = 13 Then 'AR'
			WHEN T3.InvType = 14 Then 'CM'
			WHEN T3.InvType = 30 Then 'JE'
			END,
			+'-' + CONVERT(varchar(10), T3.DOCENTRY)
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, ''))

	 WHEN T0.U_PayLoc LIKE '%Customer%' THEN
		T0.U_CollRcptNo
	 WHEN T0.U_PayLoc LIKE '%Head%' THEN
		T0.U_CollRcptNo
END AS 'Reference #',

T0.CardCode as 'Customer Code',
T0.CardName as 'Customer Name',
ISNULL((T1.LicTradNum),'-') as 'Customer TIN',
t4.Account as 'Account Code',
T5.AcctName AS 'Account Name',
T4.DEBIT AS 'PHP Debit',

T4.CREDIT AS 'PHP Credit',
T2.MEMO as 'Remarks',
T4.BPLNAME,
t2.Number,
NULL AS SourceLine

FROM ORCT T0
LEFT JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN OJDT T2 ON T0.TRANSID = T2.Number
INNER JOIN JDT1 T4 ON T2.NUMBER = T4.TRANSID
INNER JOIN OACT T5 ON T4.Account = T5.AcctCode
 INNER JOIN (
            

            SELECT  T0.DocNum,T0.ObjType,CashAcct  AS ACCT ,SourceLine, T1.TransId FROM ORCT T0
            INNER JOIN JDT1 T1 ON T0.DOCNUM=T1.BASEREF AND T1.TRANSTYPE=T0.ObjType  AND CashAcct=T1.Account
            WHERE  T0.CashSum>0 AND Canceled='Y'--CashAcct IS NULL AND TrsfrAcct IS NULL AND Canceled='Y'

            UNION ALL

            SELECT  T0.DocNum,T0.ObjType,TrsfrAcct  AS ACCT ,SourceLine, T1.TransId  FROM ORCT T0
            INNER JOIN JDT1 T1 ON T0.DOCNUM=T1.BASEREF AND T1.TRANSTYPE=T0.ObjType  AND TrsfrAcct=T1.Account
            WHERE  T0.TrsfrSum>0 AND Canceled='Y'--CashAcct IS NULL AND TrsfrAcct IS NULL AND Canceled='N'

         

            )T3 ON T3.TransId=T4.TransId --AND T4.SourceLine=T3.SourceLine
            
 WHERE 
 T4.BPLName LIKE '%'+@BRANCH+'%'       
 AND T0.TaxDate BETWEEN @DATEFROM AND @DATETO  


)X

where [Document Date] BETWEEN @DateFrom and @DateTo
AND  BPLNAME LIKE '%'+@BRANCH+'%'
-- AND Number= 99706
-- AND SourceLine IS NOT NULL



-- select * from odps where DeposNum=2569