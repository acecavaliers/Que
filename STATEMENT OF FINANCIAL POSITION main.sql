
-- DECLARE @BRANCH Varchar(5)='3',
-- @STR VARCHAR(100)='GSC_NAP',
-- @DATETO DATE ='2023-01-01',  
-- @DATETOPREV DATE ='2023-01-31'

DECLARE @BRANCH Varchar(5)='{?brachID}',
@DATETO DATE ={?DateTo},  
@DATETOPREV DATE ={?DateToPrev},  
@STR VARCHAR(100)='{?Store}'

SET @BRANCH = REPLACE(@BRANCH,'0','')
SET @STR = REPLACE(@STR,'All','')

if(@STR='')
--PER BRANCH
BEGIN
    SELECT AcctCode,AcctName,Levels,GrpLine,GroupMask,FatherNum,(select concat(AcctCode,' - ', AcctName) FROM OACT R  WHERE R.AcctCode=T0.FatherNum) as 'GROUP',
    --Current Year

        ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <= @DATETO),0) AS 'L7',

    --Previous Year  


            ISNULL((SELECT sum(Debit)-sum(Credit) FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND Account like '%'+ LEFT(AcctCode,5) +'%'
                    AND TAXDATE <= @DATETOPREV),0) AS 'P7'


    FROM OACT T0
    WHERE LEVELS=3 AND GROUPMASK BETWEEN 1 AND 10
    ORDER BY GrpLine
END
if(@STR<>'')
--PER STORE
BEGIN
    SELECT AcctCode,AcctName,Levels,GrpLine,GroupMask,FatherNum,(select concat(AcctCode,' - ', AcctName) FROM OACT R  WHERE R.AcctCode=T0.FatherNum) as 'GROUP',
    --Current Year

ISNULL((SELECT sum(Debit)-sum(Credit) 
        FROM JDT1 
        WHERE ProfitCode LIKE '%'+@STR+'%' 
        AND Account like '%'+ LEFT(AcctCode,5) +'%'
        AND TAXDATE <= @DATETO),0) 

+

ISNULL((SELECT SUM(val) FROM
(SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@STR+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
FROM JDT1 
WHERE ProfitCode LIKE '%'+@STR+'%' 
AND Account like '%'+ LEFT(AcctCode,5) +'%'
AND TAXDATE <= @DATETO)XX),0)
        
AS 'L7',

    --Previous Year  


ISNULL((SELECT sum(Debit)-sum(Credit) 
        FROM JDT1 
        WHERE ProfitCode LIKE '%'+@STR+'%' 
        AND Account like '%'+ LEFT(AcctCode,5) +'%'
        AND TAXDATE <= @DATETOPREV),0) 
+

ISNULL((SELECT SUM(val) FROM
(SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@STR+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
FROM JDT1 
WHERE ProfitCode LIKE '%'+@STR+'%' 
AND Account like '%'+ LEFT(AcctCode,5) +'%'
AND TAXDATE <= @DATETOPREV)XX),0)
        
AS 'P7'


    FROM OACT T0
    WHERE LEVELS=3 AND GROUPMASK BETWEEN 1 AND 10
    ORDER BY GrpLine
END