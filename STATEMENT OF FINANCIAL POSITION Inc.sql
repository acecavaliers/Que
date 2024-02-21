DECLARE @BRANCH varchar(5)='{?brachID}',@DATETO DATE ={?DateTo} ,  @DATETOPREV DATE ={?DateToPrev}
SET @BRANCH = REPLACE(@BRANCH,'0','')

SELECT SUM(InventoryShortage)+SUM(L7) AS 'INCOME',SUM(InventoryShortagePrev)+SUM(P7) AS 'INCOME_PREV' FROM(
SELECT 
--Current Year
ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE <= @DATETO AND Account =
	(SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode  AND AcctCode='OP190-1400-0000' )),0) AS 'InventoryShortage',

ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE <= @DATETO AND Account =T0.AcctCode ),0)

+

    CASE WHEN T0.AcctCode ='OP190-1400-0000' AND 
        ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETO  AND Account  = 
            (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 AND AcctCode='OP190-1400-0000' )),0) < 0
    THEN 
        ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETO  AND Account  IN 
            (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode  )),0) 
            
            - 

        ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE <= @DATETO AND Account =
            (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode  AND AcctCode='OP190-1400-0000' )),0)

    ELSE
        ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETO  AND Account  IN 
            (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode AND AcctCode<>'OP190-1400-0000' )),0)
    END

+
ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETO AND Account  IN 
	(SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode))),0)
    
+

ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETO AND Account  IN  
	(SELECT AcctCode FROM OACT WHERE levels=5 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode)))),0)
    
+

ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETO AND Account  IN  
	(SELECT AcctCode FROM OACT WHERE levels=6 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=5 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode))))),0) 
    
AS 'L7',

--Previous Year  
ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE <= @DATETOPREV AND Account =
	(SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode  AND AcctCode='OP190-1400-0000' )),0) AS 'InventoryShortagePrev',

ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE <= @DATETOPREV AND Account =T0.AcctCode ),0)

+
    CASE WHEN T0.AcctCode ='OP190-1400-0000' AND 
        ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETOPREV  AND Account  =  
            (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 AND AcctCode='OP190-1400-0000' )),0) < 0
    THEN 
    ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETOPREV  AND Account  IN  
            (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode  )),0) 
            
            -  

        ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE <= @DATETOPREV AND Account =
            (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode  AND AcctCode='OP190-1400-0000' )),0)

    ELSE
        ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETOPREV  AND Account  IN  
            (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode AND AcctCode<>'OP190-1400-0000' )),0)
    END 

+

ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETOPREV AND Account  IN  
	(SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode))),0)

+

ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETOPREV AND Account  IN  
	(SELECT AcctCode FROM OACT WHERE levels=5 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode)))),0)
    
+

ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE BPLID LIKE '%'+@BRANCH+'%' AND TAXDATE  <= @DATETOPREV AND Account  IN  
	(SELECT AcctCode FROM OACT WHERE levels=6 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=5 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
	(SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=T0.AcctCode))))),0) AS 'P7'

FROM OACT T0
WHERE LEVELS=2 AND GROUPMASK BETWEEN 4 AND 8

)X