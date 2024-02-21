SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [dbo].[SVF_IncomeStatementAmt]
(	
	@sBranchID VARCHAR (5),
  @sStore VARCHAR(20),
  @sAccountCode VARCHAR(100),
  @dDateFrom DATE,
  @dDateTo DATE,
  @iCondition INTEGER,
  @iResult INTEGER
  -- SELECT dbo.SVF_IncomeStatementAmt(4,'','OP190-1400-0000',@dDateFrom,@dDateTo,1,1)
)
RETURNS DECIMAL(18,5)
AS
BEGIN
-- Type 1 = Current
-- Type 2 = Previous

  DECLARE @mAmnt DECIMAL(18,5)
IF @sStore=''
BEGIN
  --CURRENT YEAR BY BRANCH
  IF @iCondition=1 AND @iResult=0 
  BEGIN
    SELECT @mAmnt= (Select  COUNT(TaxDate)from jdt1  where  BPLID LIKE '%'+@sBranchID+'%' AND TransType=-3 and TAXDATE  BETWEEN @dDateFrom AND @dDateTo)
  END   
  
  IF @iCondition=1 AND @iResult=1 
  BEGIN
    SELECT @mAmnt= ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account =
	                (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode  AND AcctCode='OP190-1400-0000' )),0)
  END  
  
  IF @iCondition=1 AND @iResult=2 
  BEGIN
    SELECT @mAmnt= ISNULL((select  sum(Debit)-sum(Credit) from jdt1 where TransType=-3 and TAXDATE  BETWEEN @dDateFrom AND @dDateTo and Account =  
                  (select AcctCode from oact where FatherNum=@sAccountCode AND AcctCode='OP190-1400-0000')),0)	

  END  
  
  IF @iCondition=2 AND @iResult=0 
  BEGIN
    SELECT @mAmnt= ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account =@sAccountCode ),0)+
                  CASE 
                  WHEN @sAccountCode ='OP190-1400-0000' AND 
                    ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo  AND Account  = 
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 AND AcctCode='OP190-1400-0000' )),0) < 0
                  THEN 
                    ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo  AND Account  IN 
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode  )),0)
                      - 
                    ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account =
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode  AND AcctCode='OP190-1400-0000' )),0)
                  ELSE
                    ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo  AND Account  IN 
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode AND AcctCode<>'OP190-1400-0000' )),0)
                  END
                      +
                  ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo AND Account  IN 
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode))),0)+
                  ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo AND Account  IN  
                    (SELECT AcctCode FROM OACT WHERE levels=5 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode)))),0)+
                  ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo AND Account  IN  
                    (SELECT AcctCode FROM OACT WHERE levels=6 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=5 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode))))),0)
  END  
  
  IF @iCondition=2 AND @iResult=1 
  BEGIN
    SELECT @mAmnt= ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE TransType=-3 and  BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                  (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode) ),0)
                  -
                  ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE TransType=-3 and  BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                  (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode AND AcctCode='OP190-1400-0000') ),0)
  END  
  
  IF @iCondition=2 AND @iResult=2 
  BEGIN
    SELECT @mAmnt= ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE TransType=-3 and  BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                  (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode) ),0)
                  +
                  ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE TransType=-3 and  BPLID LIKE '%'+@sBranchID+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                  (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN 
                  (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode)) ),0)
  END  
END

IF  @sStore<>''
BEGIN
--CURRENT YEAR BY STORE
  IF @iCondition=1 AND @iResult=0 
  BEGIN
    SELECT @mAmnt=(
                    Select  COUNT(TaxDate)from jdt1  where  ProfitCode LIKE '%'+@sStore+'%' AND TransType=-3 and TAXDATE  BETWEEN @dDateFrom AND @dDateTo
         
                  )
  END   
  
  IF @iCondition=1 AND @iResult=1 
  BEGIN
    SELECT @mAmnt=( ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account =
	                  (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode  AND AcctCode='OP190-1400-0000' )),0)
                    +
                    ISNULL(
                    (SELECT SUM(val) FROM
                    (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                    FROM JDT1 WHERE  ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account =
	                  (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode  AND AcctCode='OP190-1400-0000' ))XX),0)
                  )
  END  
  
  IF @iCondition=1 AND @iResult=2 
  BEGIN
    SELECT @mAmnt= (ISNULL((select  sum(Debit)-sum(Credit) from jdt1 where TransType=-3 and TAXDATE  BETWEEN @dDateFrom AND @dDateTo and Account =  
                    (select AcctCode from oact where FatherNum=@sAccountCode AND AcctCode='OP190-1400-0000')),0)	                  
                   )

  END  
  
  IF @iCondition=2 AND @iResult=0 
  BEGIN
    SELECT @mAmnt= (ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account =@sAccountCode ),0)
                    +
                    ISNULL(
                    (SELECT SUM(val) FROM
                    (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                    FROM JDT1 WHERE  ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account =@sAccountCode )XX),0)
                   )
    
    +
                  CASE 
                  WHEN @sAccountCode ='OP190-1400-0000' AND 
                    (
                      ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo  AND Account  = 
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 AND AcctCode='OP190-1400-0000' )),0)
                      +
                      ISNULL(
                      (SELECT SUM(val) FROM
                      (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                      FROM JDT1 WHERE  ProfitCode LIKE '%HO_ACCTG%'AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo  AND Account  = 
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 AND AcctCode='OP190-1400-0000' ))XX),0)
                    ) < 0
                  THEN 
                    (
                      ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo  AND Account  IN 
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode  )),0)
                      +
                      ISNULL(
                      (SELECT SUM(val) FROM
                      (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                      FROM JDT1 WHERE  ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo  AND Account  IN 
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode  ))XX),0)
                    )
                    - 
                    (  
                      ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account =
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode  AND AcctCode='OP190-1400-0000' )),0)
                      +
                      ISNULL(
                      (SELECT SUM(val) FROM
                      (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                      FROM JDT1 WHERE  ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account =
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode  AND AcctCode='OP190-1400-0000' ))XX),0)
                    )
                  ELSE

                    ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE  ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo  AND Account  IN 
                      (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode AND AcctCode<>'OP190-1400-0000' )),0)
                    +
                    ISNULL(
                    (SELECT SUM(val) FROM
                    (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                    FROM JDT1 WHERE  ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo  AND Account  IN 
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode AND AcctCode<>'OP190-1400-0000' ))XX),0)
                  END
                  +
                ( 
                  ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo AND Account  IN 
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode))),0)
                  +
                  ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo AND Account  IN  
                    (SELECT AcctCode FROM OACT WHERE levels=5 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode)))),0)
                  +
                  ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo AND Account  IN  
                    (SELECT AcctCode FROM OACT WHERE levels=6 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=5 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode))))),0)

                   +

                  ISNULL(
                    (SELECT SUM(val) FROM
                    (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                    FROM JDT1 WHERE ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo AND Account  IN 
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode)))XX),0)
                  +
                  ISNULL(
                    (SELECT SUM(val) FROM
                    (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                    FROM JDT1 WHERE ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo AND Account  IN  
                    (SELECT AcctCode FROM OACT WHERE levels=5 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode))))XX),0)
                  +
                  ISNULL(
                    (SELECT SUM(val) FROM
                    (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                     FROM JDT1 WHERE ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE  BETWEEN @dDateFrom AND @dDateTo AND Account  IN  
                    (SELECT AcctCode FROM OACT WHERE levels=6 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=5 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN  
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode)))))XX),0)
                )
  END  
  
  IF @iCondition=2 AND @iResult=1 
  BEGIN
    SELECT @mAmnt=(
                    ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE TransType=-3 and  ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode) ),0)
                    +
                    ISNULL(
                    (SELECT SUM(val) FROM
                    (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                    FROM JDT1 WHERE TransType=-3 and  ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode) )XX),0)
                  )
                  -
                  (
                    ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE TransType=-3 and  ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode AND AcctCode='OP190-1400-0000') ),0)
                    +
                    ISNULL(
                    (SELECT SUM(val) FROM
                    (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                    FROM JDT1 WHERE TransType=-3 and  ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode AND AcctCode='OP190-1400-0000') )XX),0)
                  )
  END  
  
  IF @iCondition=2 AND @iResult=2 
  BEGIN
    SELECT @mAmnt= (
                    ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE TransType=-3 and  ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode) ),0)
                    +
                    ISNULL((SELECT SUM(val) FROM
                    (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                    FROM JDT1 WHERE TransType=-3 and  ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode) )XX),0)
                  )
                  +
                  (
                    ISNULL((SELECT SUM(debit)-SUM(credit)FROM JDT1 WHERE TransType=-3 and  ProfitCode LIKE '%'+@sStore+'%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN 
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode)) ),0)
                    +
                    ISNULL(
                    (SELECT SUM(val) FROM
                    (SELECT ((SELECT PrcAmount from OCR1 where PrcCode like '%'+@sStore+'%' and OcrCode='HO_ACCTG' and TaxDate BETWEEN ValidFrom and isnull(ValidTo,GETDATE()))/100) *((debit)-(credit)) as val 
                    FROM JDT1 WHERE TransType=-3 and  ProfitCode LIKE '%HO_ACCTG%' AND TAXDATE BETWEEN @dDateFrom AND @dDateTo AND Account IN 
                    (SELECT AcctCode FROM OACT WHERE levels=4 and GROUPMASK BETWEEN 4 AND 8 and FatherNum IN 
                    (SELECT AcctCode FROM OACT WHERE levels=3 and GROUPMASK BETWEEN 4 AND 8 and FatherNum=@sAccountCode)) )XX),0)
                  )
  END  
END 
 

  RETURN @mAmnt
END
GO
