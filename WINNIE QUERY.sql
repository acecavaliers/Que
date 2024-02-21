
--STOCK TURNOVER
DECLARE @ITM VARCHAR(50)='0006219CMCMT',
@PERIODFROM DATE='2022-01-01',
@PERIODTO DATE='2023-08-31',
@STR VARCHAR(50)='KORatpGS'


SELECT 
case    
when TransType =13 then 'ARINV'
when TransType =14 then 'ARCM'
when TransType =15 then 'DR'
when TransType =18 then 'AP'
when TransType =19 then 'APCM'
when TransType =20 then 'GRPO'
when TransType =21 then 'Goods Return'
when TransType =59 then 'Goods Receipt'
when TransType =60 then 'Goods Issue'
when TransType =67 then 'Inventory Transfer'
when TransType =69 then 'Landed Costs'
when TransType =162 then 'Inventory Revaluation'
when TransType =10000071 then 'Inventory Posting'
when TransType =310000001 then 'OBB'
end AS TTYPE,   
ItemCode,Warehouse,Dscription,Balance,TransValue,TaxDate as TD,CreateDate as CD,*
from OINM 
where ItemCode = @ITM
and REPLACE(Warehouse,'KORKM2GS','KOROSTGS')=@STR
and TaxDate BETWEEN @PERIODFROM and @PERIODTO
ORDER by CreateDate desc, TransSeq DESC
        

---AP OUTGOING
select T0.DocNum as 'OUTGOING#'
,T1.DOCNUM AS 'AP#'
,T1.TaxDate AS 'AP TAXDATE'
,T0.AppliedSys
,T1.DocTotal
,'N/A' AS U_WTax
-- ,T0.U_WTax
,T0.U_GrossAmt
,'N/A' AS U_Balances
-- ,T0.U_Balances
,T0.SumApplied
,'N/A' AS U_WTaxPay
-- ,T0.U_WTaxPay
from VPM2 T0
INNER JOIN OPCH T1 ON T1.DOCENTRY=T0.DOCENTRY AND T0.INVTYPE=18

WHERE InvType=18
-- AND T0.DOCNUM=242
and T1.TaxDate LIKE '%2022%'