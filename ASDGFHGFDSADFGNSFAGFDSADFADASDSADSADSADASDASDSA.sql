





DECLARE @ITM VARCHAR(50)='',
@PERIODFROM DATE='2022-01-01',
@PERIODTO DATE='2023-08-31',
@STR VARCHAR(50)='KOROSTGS'



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
where ItemCode ='0006140CMCMT' --in ('0006262TBRTG','0006140CMCMT','0004227ETPMP')--LIKE '%'+@ITM+'%'
and Warehouse IN ('KOROSTGS','KORKM2GS')
and TaxDate BETWEEN @PERIODFROM and @PERIODTO
ORDER by CreateDate desc, TransSeq DESC
        

-- SELECT * FROM OIPF WHERE DocNum=228

-- SELECT TargetDoc,ItemCode,* FROM IPF1 WHERE DocEntry=108
-- SELECT TargetDoc,ItemCode,* FROM IPF1 WHERE DocEntry=228

