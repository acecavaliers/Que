
DECLARE @CNT INT

,@WTC VARCHAR(50)='{?WTCOMCODE}'

SET @CNT= (SELECT COUNT(*) from dbo.[@printed_report] where U_Doctype='WTP' AND  U_Docnum=@WTC )

IF (@CNT=0)
BEGIN    
    SELECT 1 AS cnt_R
    EXEC dbo.SP_PRINTED_REPORTS_BY_AC @WTC,'WTP'
END

IF (@CNT>0)
BEGIN    
    IF (select COUNT(U_DocNamber) from dbo.[@REPRINTING] WHERE U_Doctype='WTP' AND U_Printed='N' AND U_DocNamber=@WTC)>0
    BEGIN
        SELECT 1 AS cnt_R
        EXEC dbo.SP_PREPRINT_BY_AC @WTC,'WTP'
    END
    ELSE
    BEGIN
        SELECT 0 AS cnt_R
    END
END