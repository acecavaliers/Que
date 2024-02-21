
-- DECLARE @CNAME VARCHAR(200) =''
-- ,@DFROM DATE = '2023-01-01'
-- ,@DTO DATE = '2023-01-31'
-- ,@RPT VARCHAR(100)='REPORTED'


DECLARE @CNAME VARCHAR(200) ='{?paramName}'
,@DFROM DATE = {?paramFrom}
,@DTO DATE = {?paramTo}
,@RPT VARCHAR(100)='{?RPT}'

IF (@RPT='ALL')
BEGIN
    SELECT 
    
    *
    ,ISNULL(U_wTaxComCode,(SELECT U_wTaxComCode FROM VPM2 AA INNER JOIN OVPM AB ON AA.DocNum=AB.DocNum WHERE AA.DOCENTRY=DOC# AND InvType=DOT AND AB.Canceled='N') ) AS 'wTaxComCode'

    ,(SELECT U_CheckRelDate FROM VPM2 AA INNER JOIN OVPM AB ON AA.DocNum=AB.DocNum WHERE AA.DOCENTRY=DOC# AND InvType=DOT AND AB.Canceled='N') AS 'WTaxRecDate'

    FROM
    (SELECT 
    'A/P Invoice' as 'A/P Invoice',
    t1.ObjType AS 'DOT',
    T1.U_wTaxComCode,
    T1.U_WTaxRecBy,
    T1.U_ALIAS_VENDOR,
    numatcard,
    CANCELED,
    LicTradNum,
    CardCode,
    CardName,
    Address,
    Address2,
    DocNum,
    DocNum AS 'DOC#',
    DocDate,
    Taxdate,
    T2.U_ATC,
    T3.Rate,
    TaxbleAmnt,
    WTAmnt,
    VatPaid,
    AcctName AS ControlAcct ,
    (SELECT TOP 1 x1.Acctcode from PCH1 x1 WHERE T1.Docnum = x1.Docentry) as acct,
    (SELECT TOP 1 x2.AcctName from PCH1 x1 
    LEFT JOIN OACT x2 on x1.acctcode = x2.Acctcode
    WHERE T1.Docnum = x1.Docentry) as acctName
    FROM PCH5 T0 
    INNER JOIN OPCH T1
    ON T0.AbsEntry=T1.DocNum 
    INNER JOIN OWHT T2 ON T0.WTCode=T2.WTCode 
    INNER JOIN WHT1 T3 ON T2.WTCode=T3.WTCode 
    INNER JOIN OACT T4 ON T1.CtlAccount=T4.AcctCode
    WHERE CARDNAME LIKE '%'+@CNAME+'%'
    AND TaxDate BETWEEN @DFROM AND @DTO

    UNION ALL

    SELECT 
    'A/P DPI' as 'A/P DPI',
    t1.ObjType AS 'DOT',
    T1.U_wTaxComCode,
    T1.U_WTaxRecBy,
    T1.U_ALIAS_VENDOR,
    numatcard,
    CANCELED,
    LicTradNum,
    CardCode,
    CardName,
    Address,
    Address2,
    DocNum,
    DocNum AS 'DOC#',
    DocDate,
    taxdate,
    T2.U_ATC,
    T3.Rate,
    TaxbleAmnt,
    WTAmnt,
    VatPaid,
    AcctName AS ControlAcct ,
    (SELECT TOP 1 x1.Acctcode from dpo1 x1 WHERE T1.Docnum = x1.Docentry) as acct,
    (SELECT TOP 1 x2.AcctName from DPO1 x1 
    LEFT JOIN OACT x2 on x1.acctcode = x2.Acctcode
    WHERE T1.Docnum = x1.Docentry) as acctName
    FROM DPO5 T0 INNER JOIN ODPO T1
    ON T0.AbsEntry=T1.DocNum INNER JOIN OWHT T2
    ON T0.WTCode=T2.WTCode INNER JOIN WHT1 T3
    ON T2.WTCode=T3.WTCode INNER JOIN OACT T4
    ON T1.CtlAccount=T4.AcctCode
    WHERE CARDNAME LIKE '%'+@CNAME+'%'
    AND TaxDate BETWEEN @DFROM AND @DTO

    UNION ALL

    SELECT 
    'A/P CM' as 'A/P CM',
    t1.ObjType AS 'DOT',
    T1.U_wTaxComCode,
    T1.U_WTaxRecBy,
    T1.U_ALIAS_VENDOR,
    numatcard,
    CANCELED,
    LicTradNum,
    CardCode,
    CardName,
    Address,
    Address2,
    DocNum,
    DocNum AS 'DOC#',
    DocDate,
    taxdate,
    T2.U_ATC,
    T3.Rate,
    TaxbleAmnt * -1,
    WTAmnt * -1,
    VatPaid,
    AcctName AS ControlAcct ,
    (SELECT TOP 1 x1.Acctcode from rpc1 x1 WHERE T1.Docnum = x1.Docentry) as acct,
    (SELECT TOP 1 x2.AcctName from rpc1 x1 
    LEFT JOIN OACT x2 on x1.acctcode = x2.Acctcode
    WHERE T1.Docnum = x1.Docentry) as acctName
    FROM RPC5 T0 
    INNER JOIN ORPC T1 ON T0.AbsEntry=T1.DocNum 
    INNER JOIN OWHT T2 ON T0.WTCode=T2.WTCode 
    INNER JOIN WHT1 T3 ON T2.WTCode=T3.WTCode 
    INNER JOIN OACT T4 ON T1.CtlAccount=T4.AcctCode
    WHERE CARDNAME LIKE '%'+@CNAME+'%'
    AND TaxDate BETWEEN @DFROM AND @DTO

    ) 
    Monitoring

    ORDER BY Docdate
END

IF (@RPT='UNREPORTED')
BEGIN
    SELECT *
    ,ISNULL(U_wTaxComCode,(SELECT U_wTaxComCode FROM VPM2 AA INNER JOIN OVPM AB ON AA.DocNum=AB.DocNum WHERE AA.DOCENTRY=DOC# AND InvType=DOT AND AB.Canceled='N') ) AS 'wTaxComCode'
    
    ,(SELECT U_CheckRelDate FROM VPM2 AA INNER JOIN OVPM AB ON AA.DocNum=AB.DocNum WHERE AA.DOCENTRY=DOC# AND InvType=DOT AND AB.Canceled='N') AS 'WTaxRecDate'
     FROM
    (SELECT 
    'A/P Invoice' as 'A/P Invoice',
    t1.ObjType AS 'DOT',
    T1.U_wTaxComCode,
    T1.U_WTaxRecBy,
    T1.U_ALIAS_VENDOR,
    numatcard,
    CANCELED,
    LicTradNum,
    CardCode,
    CardName,
    Address,
    Address2,
    DocNum,
    DocNum AS 'DOC#',
    DocDate,
    Taxdate,
    T2.U_ATC,
    T3.Rate,
    TaxbleAmnt,
    WTAmnt,
    VatPaid,
    AcctName AS ControlAcct ,
    (SELECT TOP 1 x1.Acctcode from PCH1 x1 WHERE T1.Docnum = x1.Docentry) as acct,
    (SELECT TOP 1 x2.AcctName from PCH1 x1 
    LEFT JOIN OACT x2 on x1.acctcode = x2.Acctcode
    WHERE T1.Docnum = x1.Docentry) as acctName
    FROM PCH5 T0 
    INNER JOIN OPCH T1
    ON T0.AbsEntry=T1.DocNum 
    INNER JOIN OWHT T2 ON T0.WTCode=T2.WTCode 
    INNER JOIN WHT1 T3 ON T2.WTCode=T3.WTCode 
    INNER JOIN OACT T4 ON T1.CtlAccount=T4.AcctCode
    WHERE CARDNAME LIKE '%'+@CNAME+'%'
    AND TaxDate BETWEEN @DFROM AND @DTO
    AND T1.DocNum NOT IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=18 AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account='CL020-1800-0000')

    UNION ALL

    SELECT 
    'A/P DPI' as 'A/P DPI',
    t1.ObjType AS 'DOT',
    T1.U_wTaxComCode,
    T1.U_WTaxRecBy,
    T1.U_ALIAS_VENDOR,
    numatcard,
    CANCELED,
    LicTradNum,
    CardCode,
    CardName,
    Address,
    Address2,
    DocNum,
    DocNum AS 'DOC#',
    DocDate,
    taxdate,
    T2.U_ATC,
    T3.Rate,
    TaxbleAmnt,
    WTAmnt,
    VatPaid,
    AcctName AS ControlAcct ,
    (SELECT TOP 1 x1.Acctcode from dpo1 x1 WHERE T1.Docnum = x1.Docentry) as acct,
    (SELECT TOP 1 x2.AcctName from DPO1 x1 
    LEFT JOIN OACT x2 on x1.acctcode = x2.Acctcode
    WHERE T1.Docnum = x1.Docentry) as acctName
    FROM DPO5 T0 INNER JOIN ODPO T1
    ON T0.AbsEntry=T1.DocNum INNER JOIN OWHT T2
    ON T0.WTCode=T2.WTCode INNER JOIN WHT1 T3
    ON T2.WTCode=T3.WTCode INNER JOIN OACT T4
    ON T1.CtlAccount=T4.AcctCode
    WHERE CARDNAME LIKE '%'+@CNAME+'%'
    AND TaxDate BETWEEN @DFROM AND @DTO
    AND T1.DocNum NOT IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=204 AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account='CL020-1800-0000')

    UNION ALL

    SELECT 
    'A/P CM' as 'A/P CM',
    t1.ObjType AS 'DOT',
    T1.U_wTaxComCode,
    T1.U_WTaxRecBy,
    T1.U_ALIAS_VENDOR,
    numatcard,
    CANCELED,
    LicTradNum,
    CardCode,
    CardName,
    Address,
    Address2,
    DocNum,
    DocNum AS 'DOC#',
    DocDate,
    taxdate,
    T2.U_ATC,
    T3.Rate,
    TaxbleAmnt * -1,
    WTAmnt * -1,
    VatPaid,
    AcctName AS ControlAcct ,
    (SELECT TOP 1 x1.Acctcode from rpc1 x1 WHERE T1.Docnum = x1.Docentry) as acct,
    (SELECT TOP 1 x2.AcctName from rpc1 x1 
    LEFT JOIN OACT x2 on x1.acctcode = x2.Acctcode
    WHERE T1.Docnum = x1.Docentry) as acctName
    FROM RPC5 T0 
    INNER JOIN ORPC T1 ON T0.AbsEntry=T1.DocNum 
    INNER JOIN OWHT T2 ON T0.WTCode=T2.WTCode 
    INNER JOIN WHT1 T3 ON T2.WTCode=T3.WTCode 
    INNER JOIN OACT T4 ON T1.CtlAccount=T4.AcctCode
    WHERE CARDNAME LIKE '%'+@CNAME+'%'
    AND TaxDate BETWEEN @DFROM AND @DTO
    AND T1.DocNum NOT IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=19 AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account='CL020-1800-0000')

    ) 
    Monitoring

    ORDER BY Docdate
END

IF (@RPT='REPORTED')
BEGIN
    SELECT *
    ,ISNULL(U_wTaxComCode,(SELECT U_wTaxComCode FROM VPM2 AA INNER JOIN OVPM AB ON AA.DocNum=AB.DocNum WHERE AA.DOCENTRY=DOC# AND InvType=DOT AND AB.Canceled='N') ) AS 'wTaxComCode'
    
    ,(SELECT U_CheckRelDate FROM VPM2 AA INNER JOIN OVPM AB ON AA.DocNum=AB.DocNum WHERE AA.DOCENTRY=DOC# AND InvType=DOT AND AB.Canceled='N') AS 'WTaxRecDate'
    FROM
    (SELECT 
    'A/P Invoice' as 'A/P Invoice',
    t1.ObjType AS 'DOT',
    T1.U_wTaxComCode,
    T1.U_WTaxRecBy,
    T1.U_ALIAS_VENDOR,
    numatcard,
    CANCELED,
    LicTradNum,
    CardCode,
    CardName,
    Address,
    Address2,
    DocNum,
    DocNum AS 'DOC#',
    DocDate,
    Taxdate,
    T2.U_ATC,
    T3.Rate,
    TaxbleAmnt,
    WTAmnt,
    VatPaid,
    AcctName AS ControlAcct ,
    (SELECT TOP 1 x1.Acctcode from PCH1 x1 WHERE T1.Docnum = x1.Docentry) as acct,
    (SELECT TOP 1 x2.AcctName from PCH1 x1 
    LEFT JOIN OACT x2 on x1.acctcode = x2.Acctcode
    WHERE T1.Docnum = x1.Docentry) as acctName
    FROM PCH5 T0 
    INNER JOIN OPCH T1
    ON T0.AbsEntry=T1.DocNum 
    INNER JOIN OWHT T2 ON T0.WTCode=T2.WTCode 
    INNER JOIN WHT1 T3 ON T2.WTCode=T3.WTCode 
    INNER JOIN OACT T4 ON T1.CtlAccount=T4.AcctCode
    WHERE CARDNAME LIKE '%'+@CNAME+'%'
    AND TaxDate BETWEEN @DFROM AND @DTO
    AND T1.DocNum IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=18 AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account='CL020-1800-0000')

    UNION ALL

    SELECT 
    'A/P DPI' as 'A/P DPI',
    t1.ObjType AS 'DOT',
    T1.U_wTaxComCode,
    T1.U_WTaxRecBy,
    T1.U_ALIAS_VENDOR,
    numatcard,
    CANCELED,
    LicTradNum,
    CardCode,
    CardName,
    Address,
    Address2,
    DocNum,
    DocNum AS 'DOC#',
    DocDate,
    taxdate,
    T2.U_ATC,
    T3.Rate,
    TaxbleAmnt,
    WTAmnt,
    VatPaid,
    AcctName AS ControlAcct ,
    (SELECT TOP 1 x1.Acctcode from dpo1 x1 WHERE T1.Docnum = x1.Docentry) as acct,
    (SELECT TOP 1 x2.AcctName from DPO1 x1 
    LEFT JOIN OACT x2 on x1.acctcode = x2.Acctcode
    WHERE T1.Docnum = x1.Docentry) as acctName
    FROM DPO5 T0 INNER JOIN ODPO T1
    ON T0.AbsEntry=T1.DocNum INNER JOIN OWHT T2
    ON T0.WTCode=T2.WTCode INNER JOIN WHT1 T3
    ON T2.WTCode=T3.WTCode INNER JOIN OACT T4
    ON T1.CtlAccount=T4.AcctCode
    WHERE CARDNAME LIKE '%'+@CNAME+'%'
    AND TaxDate BETWEEN @DFROM AND @DTO
    AND T1.DocNum IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=204 AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account='CL020-1800-0000')

    UNION ALL

    SELECT 
    'A/P CM' as 'A/P CM',
    t1.ObjType AS 'DOT',
    T1.U_wTaxComCode,
    T1.U_WTaxRecBy,
    T1.U_ALIAS_VENDOR,
    numatcard,
    CANCELED,
    LicTradNum,
    CardCode,
    CardName,
    Address,
    Address2,
    DocNum,
    DocNum AS 'DOC#',
    DocDate,
    taxdate,
    T2.U_ATC,
    T3.Rate,
    TaxbleAmnt * -1,
    WTAmnt * -1,
    VatPaid,
    AcctName AS ControlAcct ,
    (SELECT TOP 1 x1.Acctcode from rpc1 x1 WHERE T1.Docnum = x1.Docentry) as acct,
    (SELECT TOP 1 x2.AcctName from rpc1 x1 
    LEFT JOIN OACT x2 on x1.acctcode = x2.Acctcode
    WHERE T1.Docnum = x1.Docentry) as acctName
    FROM RPC5 T0 
    INNER JOIN ORPC T1 ON T0.AbsEntry=T1.DocNum 
    INNER JOIN OWHT T2 ON T0.WTCode=T2.WTCode 
    INNER JOIN WHT1 T3 ON T2.WTCode=T3.WTCode 
    INNER JOIN OACT T4 ON T1.CtlAccount=T4.AcctCode
    WHERE CARDNAME LIKE '%'+@CNAME+'%'
    AND TaxDate BETWEEN @DFROM AND @DTO
    AND T1.DocNum IN (SELECT SrcObjAbs from ITR1 INNER JOIN OITR ON OITR.ReconNum=ITR1.ReconNum WHERE CANCELED='N' AND SrcObjTyp=19 AND IsSystem='N' AND ReconDate BETWEEN @DFROM AND @DTO AND Account='CL020-1800-0000')

    ) 
    Monitoring

    ORDER BY Docdate
END


