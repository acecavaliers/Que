
SELECT *,MONTH(TaxDate) AS MM ,YEAR(TaxDate) AS YY FROM(
SELECT 'INV' AS 'TYPE', aa.DocNum, aa.CardName,
case when CardName like '%WALK-IN%' then U_Customer
else aa.CardName
end as 'WALK-IN',
CC.Name AS AGENT,ItemCode,Dscription,UOMCODE,Quantity,TaxDate,LineTotal as Total,GrssProfit,WhsCode
FROM OINV AA
INNER JOIN INV1 BB ON AA.DocNum=BB.DOCENTRY
INNER JOIN dbo.[@SALESAGENT] CC ON CC.Code=AA.U_SalesAgent 
WHERE U_SALESAGENT<>''
AND CANCELED='N'

union ALL

SELECT 'CM' AS 'TYPE', aa.DocNum, aa.CardName,
case when CardName like '%WALK-IN%' then U_Customer
else aa.CardName
end as 'WALK-IN',
CC.Name AS AGENT,ItemCode,Dscription,UOMCODE,Quantity*-1,TaxDate,LineTotal*-1 as Total,GrssProfit,WhsCode
FROM ORIN AA
INNER JOIN RIN1 BB ON AA.DocNum=BB.DOCENTRY
INNER JOIN dbo.[@SALESAGENT] CC ON CC.Code=AA.U_SalesAgent 
WHERE U_SALESAGENT<>''
AND CANCELED='N'
)DD



-- DASSSADSADAS


SELECT AGENT,ItemCode,MM,SUM(Total) AS TTL,SUM(GrssProfit) AS GRSS  FROM(
SELECT
CC.Name AS AGENT,ItemCode,MONTH(TaxDate) AS MM,LineTotal as Total,GrssProfit
FROM OINV AA
INNER JOIN INV1 BB ON AA.DocNum=BB.DOCENTRY
INNER JOIN dbo.[@SALESAGENT] CC ON CC.Code=AA.U_SalesAgent 
WHERE U_SALESAGENT<>''
AND CANCELED='N'

union ALL

SELECT 
CC.Name AS AGENT,ItemCode,MONTH(TaxDate) AS MM,LineTotal*-1 as Total,GrssProfit
FROM ORIN AA
INNER JOIN RIN1 BB ON AA.DocNum=BB.DOCENTRY
INNER JOIN dbo.[@SALESAGENT] CC ON CC.Code=AA.U_SalesAgent 
WHERE U_SALESAGENT<>''
AND CANCELED='N'
)DD
GROUP BY AGENT,ItemCode,MM



SELECT 
CC.Name AS AGENT,ItemCode,MONTH(TaxDate) AS MM,LineTotal as Total,GrssProfit
FROM OINV AA
INNER JOIN INV1 BB ON AA.DocNum=BB.DOCENTRY
INNER JOIN dbo.[@SALESAGENT] CC ON CC.Code=AA.U_SalesAgent 
WHERE U_SALESAGENT<>''
AND CANCELED='N'

UNION
SELECT
CC.Name AS AGENT,ItemCode,MONTH(TaxDate) AS MM,LineTotal*-1 as Total,GrssProfit
FROM ORIN AA
INNER JOIN RIN1 BB ON AA.DocNum=BB.DOCENTRY
INNER JOIN dbo.[@SALESAGENT] CC ON CC.Code=AA.U_SalesAgent 
WHERE U_SALESAGENT<>''
AND CANCELED='N'

SELECT TOP 1 GrosProfit,DocTotal , *FROM OINV