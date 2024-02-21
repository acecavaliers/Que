SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SP_PREPRINT_BY_AC] 
 -- Add the parameters for the stored procedure here
	@DOCNUM VARCHAR(20),
    @DOCTYPE VARCHAR(50)
   
AS
BEGIN
DECLARE  @CNT INT
    IF  (@DOCTYPE IN ('CWTA','CWTC','LOF','WSD','WSP','WTP'))
        BEGIN

                SET @CNT= (SELECT COUNT(*) from dbo.[@printed_report] where U_Doctype=@DOCTYPE AND  U_Docnum=@DOCNUM )

                IF (@CNT=0)
                BEGIN  

                    SELECT 1 AS cnt_R
                    EXEC dbo.SP_PRINTED_REPORTS_BY_AC @DOCNUM,@DOCTYPE
                END

                IF (@CNT>0)
                BEGIN    
                    IF (select COUNT(U_DocNamber) from dbo.[@REPRINTING] WHERE U_Doctype=@DOCTYPE AND U_Printed='N' AND U_DocNamber=@DOCNUM)>0
                    BEGIN
                        SELECT 1 AS cnt_R

                        UPDATE dbo.[@REPRINTING] SET U_Printed='Y'  WHERE U_Doctype=@DOCTYPE AND U_Printed='N' AND U_DocNamber=@DOCNUM
                        -- EXEC dbo.SP_PREPRINT_BY_AC @DOCNUM,@DOCTYPE
                    END
                    ELSE
                    BEGIN
                        SELECT 0 AS cnt_R
                    END

                END

        END
    ELSE
        BEGIN            

                SET @CNT= (SELECT COUNT(*) AS cnt from dbo.[@REPRINTING] where U_Doctype=@DOCTYPE AND  U_Printed='N' AND U_DocNamber=@DOCNUM)

                IF (@CNT=0)
                BEGIN    
                    SELECT COUNT(U_DocNamber) AS cnt,U_ReasonCode,CreateDate
                    FROM dbo.[@REPRINTING] 
                    WHERE U_Doctype=@DOCTYPE AND  U_Printed='N' AND U_DocNamber=@DOCNUM 
                    GROUP by U_ReasonCode,CreateDate
                END

                IF (@CNT>0)
                BEGIN    
                    SELECT COUNT(U_DocNamber) AS cnt,U_ReasonCode,CreateDate
                    FROM dbo.[@REPRINTING] 
                    WHERE U_Doctype=@DOCTYPE AND  U_Printed='N' AND U_DocNamber=@DOCNUM 
                    GROUP by U_ReasonCode,CreateDate

                    UPDATE dbo.[@REPRINTING] SET U_Printed='Y'  WHERE U_Doctype=@DOCTYPE AND U_Printed='N' AND U_DocNamber=@DOCNUM
                END

        END
END
GO
