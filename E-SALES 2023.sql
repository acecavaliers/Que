
Declare @DateFrom date ={?dateFrom} , @DateTo Date={?dateTo} , @Store Varchar(20), @Branch Varchar(20),@USER VARCHAR(50), @SsTR Varchar(20) ='{?Store}', @bBranch Varchar(20) ='{?Branch}',@STR1 VARCHAR(30)
-- Declare  @DateFrom date ='2023-01-01' , @DateTo Date='2023-06-01' , @Store Varchar(20), @Branch Varchar(20),@USER VARCHAR(50), @SsTR Varchar(20) ='', @bBranch Varchar(20) =''
-- ,@STR1 VARCHAR(30)=''

SET @USER =''

SELECT @Branch=BPLName, @Store=C.Address3 FROM OWHS C
INNER JOIN OUDG T1 ON C.WhsCode=T1.Warehouse
INNER JOIN OUSR T2 ON  T2.DfltsGroup=T1.Code
INNER JOIN OBPL T3 ON  C.BPLId=T3.BPLId
WHERE T2.U_Name =@USER


SET @STR1 =@Store

IF(@USER NOT LIKE '%-SS%' AND @USER NOT LIKE  '%-BM%')
    BEGIN
        IF(@SsTR<>'')
            BEGIN
            SELECT  @Store=@SsTR,@STR1=@SsTR
            END        
        IF(@bBranch<>'')
            BEGIN                
            SELECT  @Branch=@bBranch
            END
        IF(@SsTR='')
            BEGIN
            SELECT  @Store=''
            END        
        IF(@bBranch='')
            BEGIN                
            SELECT   @Branch=''
            END        
    END

ELSE IF(@USER LIKE '%-BM%')
    BEGIN
        IF(@SsTR<>'')
            BEGIN
            SELECT  @Store=@SsTR,@STR1=@SsTR
            END        
        IF(@SsTR='')
            BEGIN
            SELECT  @Store=''
            END        
    END


    BEGIN

        SELECT DISTINCT  Esales.*,
        (SELECT  CONCAT(CASE WHEN T.[Street] = '' OR T.[Street] = NULL THEN '' ELSE T.[Street]+' 'END,
            CASE WHEN T.[StreetNo] = '' OR T.[StreetNo] = NULL THEN '' ELSE T.[StreetNo]+' 'END,
            CASE WHEN T.[Block] = '' OR T.[Block] = NULL THEN '' ELSE T.[Block]+' 'END,
            CASE WHEN T.[City] = '' OR T.[City] = NULL THEN '' ELSE T.[City]+' 'END,
            CASE WHEN T.[ZipCode] = '' OR T.[ZipCode] = NULL THEN '' ELSE T.[ZipCode]+' 'END,
            CASE WHEN T.[Country] = '' OR T.[Country] = NULL THEN '' ELSE T.[Country]END
        )as 'Addr' FROM OWHS T WHERE  T.Address3 like'%'+@STR1+'%' AND T.WhsName LIKE '%GOOD STOCKS%' AND T.WhsCode LIKE '%'+REPLACE(@STR1,'_','')+'%' ) as C_Addr,
        (SELECT  T.Address3 as 'ocrcode' FROM OWHS T WHERE  T.Address3 like '%'+@STR1+'%' AND T.WhsName LIKE '%GOOD STOCKS%' AND T.WhsCode LIKE '%'+REPLACE(@STR1,'_','')+'%' ) as 'str_ocrcode'

        FROM
        (SELECT DISTINCT
        T0.taxdate AS 'TransDate',
        t0.docentry as TNUM,
        CASE WHEN T0.ISINS = 'Y' THEN 
        CONCAT('RES-',T0.DocEntry) 
        ELSE
        CONCAT('IN-',T0.DocEntry) END AS 'TransNum',
        T0.NumAtCard AS 'Refnum',
        T2.OcrCode AS 'Store_Performance', 
        T0.CardCode AS 'CardCode',
        T0.CardName AS 'Customer',
        T0.U_ADDRESS AS Address,
        T3.ADDRESS AS ADDRS,
        T1.LicTradNum AS 'TIN',
        T0.max1099 / 1.12 AS 'VAT-Ex',
        T0.max1099 - (Max1099/1.12) AS 'VAT',
        T0.max1099 AS 'VAT-Inc',
        T0.Comments AS 'Comments',
        (SELECT CONCAT('(',U_Description,')') FROM OINV T INNER JOIN dbo.[@REASONCODE] Z ON Z.Code=T.U_ReasonCancelCode 
        WHERE CANCELED='C'
        AND T.DocNum IN (SELECT TOP 1 DocEntry FROM INV1 WHERE BaseEntry=T0.DocNum AND BaseType =T0.ObjType))
        AS 'REZON',
        T0.U_DOCSeries AS 'DocSeries',
        T1.GROUPCODE,
        NULL  AS BaseEntry,
        T0.CANCELED,
        t3.BPLName,
        IIF((select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode) IS NULL,T2.OcrCode,(select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode)) AS 'ZZ'
        FROM OINV T0
        INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
        INNER JOIN INV1 T2 ON T0.DocNum = T2.DocEntry
        INNER JOIN OBPL T3 ON T0.BPLID=T3.BPLID
        WHERE T0.U_DocSeries NOT LIKE '%OB%' AND T0.CANCELED <> 'C'  
        AND T0.taxdate >=@DateFrom AND T0.taxdate <= @DateTo
        AND T3.BPLName LIKE '%'+@Branch+'%' AND T3.BPLName NOT LIKE '%DC%'

        UNION ALL
        SELECT DISTINCT
        T0.taxdate AS 'TransDate',
        t0.docentry as TNUM,
        CONCAT('CM-',T0.DocEntry)  AS 'TransNum',
        T0.NumAtCard AS 'Refnum',
        T2.OcrCode AS 'Store_Performance',
        T0.CardCode AS 'CardCode',
        T0.CardName AS 'Customer',
        T0.U_ADDRESS AS Address,
        T3.ADDRESS AS ADDRS,
        T1.LicTradNum AS 'TIN',
        (T0.Max1099 / 1.12) * -1 AS 'VAT-Ex',
        (T0.max1099 - (T0.Max1099/1.12)) *-1 AS 'VAT',
        T0.max1099 * -1 AS 'VAT-Inc',
        T0.Comments AS 'Comments',
        (SELECT CONCAT('(',U_Description,')') FROM ORIN T INNER JOIN dbo.[@REASONCODE] Z ON Z.Code=T.U_ReasonCancelCode 
        WHERE CANCELED='C'
        AND T.DocNum IN (SELECT TOP 1 DocEntry FROM RIN1 WHERE BaseEntry=T0.DocNum AND BaseType =T0.ObjType))
        AS 'REZON',
        T0.U_DOCSeries AS 'DocSeries',
        T1.GROUPCODE,
        T2.BaseEntry AS BaseEntry,
        T0.CANCELED,
        t3.BPLName,
        IIF((select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode) IS NULL,T2.OcrCode,(select  owhs.Address3 from owhs where OWHS.U_WhseExt=t2.WhsCode)) AS 'ZZ'
        FROM orin T0
        INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
        INNER JOIN RIN1 T2 ON T0.DocNum = T2.DocEntry
        INNER JOIN OBPL T3 ON T0.BPLID=T3.BPLID
        WHERE T0.U_DocSeries NOT LIKE '%OB%' AND T0.CANCELED <> 'C' 
        AND T0.taxdate >=@DateFrom AND T0.taxdate <= @DateTo
        AND T3.BPLName LIKE '%'+@Branch+'%' AND T3.BPLName NOT LIKE '%DC%' 
        AND T2.BaseEntry NOT IN (SELECT DISTINCT DOCNUM FROM ODPI T INNER JOIN RIN1 TT ON T.DocNum=TT.BaseEntry)

        ) 
        Esales
        WHERE ZZ LIKE '%'+@Store+'%'
        ORDER BY TNUM ASC
    END
