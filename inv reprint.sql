
DECLARE @CNT INT

SET @CNT= (SELECT COUNT(*) AS cnt from dbo.[@REPRINTING] where U_Doctype='ARINV' AND  U_Printed='N' AND U_DocNamber={?DocKey@})

IF (@CNT=0)
BEGIN    
    SELECT COUNT(U_DocNamber) AS cnt,U_ReasonCode,CreateDate
    FROM dbo.[@REPRINTING] 
    WHERE U_Doctype='ARINV' AND  U_Printed='N' AND U_DocNamber={?DocKey@} 
    GROUP by U_ReasonCode,CreateDate
END

IF (@CNT>0)
BEGIN    
    SELECT COUNT(U_DocNamber) AS cnt,U_ReasonCode,CreateDate
    FROM dbo.[@REPRINTING] 
    WHERE U_Doctype='ARINV' AND  U_Printed='N' AND U_DocNamber={?DocKey@} 
    GROUP by U_ReasonCode,CreateDate

    EXEC dbo.SP_PREPRINT_BY_AC {?DocKey@},'ARINV'
END