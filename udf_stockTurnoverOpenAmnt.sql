CREATE FUNCTION udf_stockTurnoverOpenAmnt(
    
    @ITM VARCHAR(50),
    @PERIODFROM DATE,
    @STR VARCHAR(50)
)
RETURNS DECIMAL(16,2)
AS 
BEGIN
    DECLARE @result DECIMAL(16,2)
    SELECT @result=(SELECT
    CASE
        WHEN YEAR(TAXDATE) <> YEAR(createDate) THEN 
            TransValue +
            (
                SELECT Balance
                FROM OINM
                WHERE ItemCode = @ITM
                AND Warehouse = @STR
                AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND DATEADD(DAY, -1, @PERIODFROM)
                AND TransType <> 18
                ORDER BY TaxDate DESC,TransSeq DESC
                OFFSET 1 ROW FETCH NEXT 1 ROW ONLY
            )
        ELSE
            Balance + ISNULL(
                (
                    SELECT SUM(TransValue)
                    FROM OINM
                    WHERE ItemCode = @ITM
                    AND Warehouse = @STR
                    AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND DATEADD(DAY, -1, @PERIODFROM)
                    AND TransType IN (60, 59)
                    AND YEAR(CreateDate) > YEAR(TaxDate)
                ),
                0
            )
    END
    FROM OINM
    WHERE ItemCode = @ITM
    AND Warehouse = @STR
    AND TaxDate BETWEEN DATEADD(YEAR, -1, @PERIODFROM) AND DATEADD(DAY, -1, @PERIODFROM)
    AND TransType <> 18
    ORDER BY  TaxDate DESC,TransSeq DESC
    OFFSET 0 ROW FETCH NEXT 1 ROW ONLY )
    RETURN @result;
END;