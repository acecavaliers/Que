CREATE FUNCTION udf_stockTurnoverCloseAmnt(
    
    @ITM VARCHAR(50),
    @PERIODFROM DATE,
    @PERIODTO DATE,
    @STR VARCHAR(50)
)
RETURNS DECIMAL(16,2)
AS 
BEGIN
    DECLARE @result DECIMAL(16,2)
    SELECT @result=IIF(
        (SELECT Balance FROM oinm
            WHERE TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND DATEADD(DAY, -1, @PERIODFROM)
            AND ItemCode = @ITM
            ORDER BY  createDate DESC,TransSeq DESC
            OFFSET 0 ROW FETCH NEXT 1 ROW ONLY) = 0
        AND
        (SELECT Balance FROM oinm
            WHERE TaxDate BETWEEN @PERIODFROM AND @PERIODTO
            AND ItemCode = @ITM
            ORDER BY  createDate DESC,TransSeq DESC
            OFFSET 0 ROW FETCH NEXT 1 ROW ONLY) IS NULL,
        0,
        ISNULL(
            (SELECT
                CASE WHEN TRANSTYPE=20 AND (SELECT U_APCPRICEAP FROM OPCH P1 INNER JOIN PCH1 PP ON P1.DOCNUM=PP.DOCENTRY 
                    WHERE CANCELED='N' AND PP.BaseEntry=AAA.BASE_REF AND PP.BASETYPE=20 AND ItemCode=AAA.ItemCode)='Y' THEN 
                    (SELECT BALANCE FROM OINM WHERE TRANSTYPE=18 AND BASE_REF=(SELECT TrgetEntry FROM PDN1 WHERE DOCENTRY=AAA.BASE_REF AND ItemCode=AAA.ItemCode) AND ItemCode=AAA.ItemCode)
                
                ELSE Balance  END
            
            FROM OINM AAA
                WHERE ItemCode = @ITM
                AND Warehouse = @STR
                AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM)  AND @PERIODTO
                AND TransValue<>0
                -- AND TransType <> 18
                ORDER BY createDate DESC,TransSeq DESC
                OFFSET 0 ROW FETCH NEXT 1 ROW ONLY),
            IIF(
                (SELECT COUNT(ItemCode) FROM OINM A0
                    WHERE ItemCode = @ITM
                    AND Warehouse = @STR
                    AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND @PERIODTO) = 1,
                (SELECT Balance FROM OINM A0
                    WHERE ItemCode = @ITM
                    AND Warehouse = @STR
                    AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND @PERIODTO),
                0
            )
        )
    )
    RETURN @result;
END;