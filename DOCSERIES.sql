DECLARE @DD INT='2023',
@STR VARCHAR(50)='DCC'

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'ARCM' FROM ORIN T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'ARINV-CASH' FROM OINV T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' AND U_DocSeries LIKE '%CASH%' ORDER BY TaxDate DESC

-- UNION ALL


-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'ARINV-CHARGE' FROM OINV T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' AND U_DocSeries LIKE '%CHARGE%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'SO' FROM ORDR T0 
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'SQ' FROM OQUT T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'DELIVERY' FROM ODLN T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'ARDPI' FROM ODPI T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'P REQ' FROM OPRQ T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'P QUOTE' FROM OPQT T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'P ORDER' FROM OPOR T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'GRPO' FROM OPDN T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'GOODS RETURN REQUEST' FROM OPRR T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'GOODS RETURN' FROM ORPD T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'APDPI' FROM ODPO T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'APINV' FROM OPCH T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'GOODS RECEIPT' FROM OIGN T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'GOODS ISSUE' FROM OIGE T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'INV TRANS RQ' FROM OWTQ T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

-- SELECT TOP 1 DocNum,U_DocSeries,TaxDate, 'INV TRANS' FROM OWTR T0
-- WHERE YEAR(TaxDate)=@DD AND LEFT(U_DocSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC

-- UNION ALL

SELECT TOP 1 DocNum,U_WSlipSeries,TaxDate, 'WITHDRAWAL SLIP' FROM OINV T0
WHERE YEAR(TaxDate)=@DD AND LEFT(U_WSlipSeries,6) LIKE '%'+@STR+'%'  ORDER BY TaxDate DESC

-- UNION ALL

SELECT TOP 1 DocNum,U_WSlipSeries,TaxDate, 'ATW' FROM OPOR T0
WHERE YEAR(TaxDate)=@DD AND LEFT(U_WSlipSeries,6) LIKE '%'+@STR+'%' ORDER BY TaxDate DESC