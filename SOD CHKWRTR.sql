DECLARE @SEPARATOR VARCHAR(1)='|'

SELECT DISTINCT  
CONCAT(
T0.PRFID,
(select count(A0.PRFID) from tbl_PRFHeader A0 where A0.PRFID = T0.PRFID )
,T0.TotalPaid 
,cast(format(t0.ChkDate,'MM/dd/yyyy') as varchar) 
,t0.TotalPaid 
,1 
, t1.Code 
,0 
,t1.SuppName 
,1 
,0 
,t0.PaymentFor 
,0 
,cast(format(T0.DateFrom, 'MM/dd/yyyy') AS varchar)
, Cast(format(T0.DateTo,'MM/dd/yyyy') AS varchar) 
,T2.PayableGL
,T2.PayableAcctTitle
,T0.TotalPaid 
,'CB22161' 
,t0.CVNum
,T0.TotalPaid 
,CAST(REPLACE(SUBSTRING(CVNum, PATINDEX('%[0-9%', CVNum), LEN(CVNum)),'-','')AS VARCHAR) 
,T3.CheckName
,cast(Format(T3.DatePrepared,'MM/dd/yyyy') as Varchar) 
,T4.Signatory
,(SELECT Credit FROM PRF_DB_SOD.dbo.tbl_JE WHERE PRFID = T0.PRFID AND Csubcode = 'OCL0613') 
,REPLACE(SUBSTRING(TIN, PATINDEX('%[0-9%', TIN), LEN(TIN)),'-','')
,Replace(Replace(T1.Address,char(13),''),char(10),'')
,T1.ZipCode 
,T0.DatePrep)
FROM tbl_PRFHeader t0
INNER JOIN tbl_Supplier t1 on t0.SuppID = t1.SuppID
INNER join tbl_PRFDetails t2 on t2.PRFID = t0.PRFID
INNER JOIN tbl_CheckWrite T3 on T3.PRFID = T0.PRFID
INNER JOIN tbl_Company T4 on T4.CompID = T0.CompID
INNER  JOIN tbl_JE T5 on T5.PRFID = T0.PRFID
WHERE T0.PRFID = 242229

DECLARE @SEPARATOR VARCHAR(1)='|'

SELECT DISTINCT  T0.PRFID,
(select count(A0.PRFID) from tbl_PRFHeader A0 where A0.PRFID = T0.PRFID ) as 'Total Count'
,T0.TotalPaid as 'Total Amount'
,cast(format(t0.ChkDate,'MM/dd/yyyy') as varchar) as 'Check Date'
,t0.TotalPaid as 'Check Amount'
,1 as 'Payee Classification'
, t1.Code as 'Payee Code'
,0 as 'Crossed or Uncrossed Check'
,t1.SuppName as 'Payee Name'
,1 as 'Pick-up or Delivery'
,0 as Claimant
,t0.PaymentFor as Particulars
,0 as 'Authorized Representative Name'
,cast(format(T0.DateFrom, 'MM/dd/yyyy') AS varchar)as 'Tax Period From'
, Cast(format(T0.DateTo,'MM/dd/yyyy') AS varchar) as 'Tax Period To'
,T2.PayableGL as 'Account Code'
,T2.PayableAcctTitle as 'Account Title'
,T0.TotalPaid as 'Debit Amount'
,'CB22161' as 'CB'
,t0.CVNum
,T0.TotalPaid as 'Credit Amount'
,CAST(REPLACE(SUBSTRING(CVNum, PATINDEX('%[0-9%', CVNum), LEN(CVNum)),'-','')AS VARCHAR) as CVNumOnly
,T3.CheckName
,cast(Format(T3.DatePrepared,'MM/dd/yyyy') as Varchar) AS DatePrepared
,T4.Signatory
,(SELECT Credit FROM PRF_DB_SOD.dbo.tbl_JE WHERE PRFID = T0.PRFID AND Csubcode = 'OCL0613') AS JECredit
,REPLACE(SUBSTRING(TIN, PATINDEX('%[0-9%', TIN), LEN(TIN)),'-','')AS Payee_TIN
,Replace(Replace(T1.Address,char(13),''),char(10),'')AS Payee_Address
,T1.ZipCode AS Payee_ZIpCode
,Cast(format(T0.DatePrep, 'MM/dd/yyyy') AS VARCHAR) AS DatePrep
FROM tbl_PRFHeader t0
INNER JOIN tbl_Supplier t1 on t0.SuppID = t1.SuppID
INNER join tbl_PRFDetails t2 on t2.PRFID = t0.PRFID
INNER JOIN tbl_CheckWrite T3 on T3.PRFID = T0.PRFID
INNER JOIN tbl_Company T4 on T4.CompID = T0.CompID
INNER  JOIN tbl_JE T5 on T5.PRFID = T0.PRFID
WHERE T0.PRFID = 242229