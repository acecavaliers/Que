

Declare @fromdate as date

Declare @Todate as date

Declare @Trans as VARCHAR(200)

Declare @WHS as VARCHAR(200)

set @fromdate ={?dfrom}

set @Todate = {?dto}

set @Trans='{?TransType}'

set @WHS= replace('{?TransType}', 'All','')

if (@Trans='Customer')
BEGIN
    SELECT 
    ROW_NUMBER() OVER (PARTITION BY C ORDER BY CardName) AS row_number,
    CONCAT('G',C) AS SS,
    CardName as 'ItemName',
    C,
    CardCode as 'Itemcode',

    SUM(ISNULL([1],0))  [Jan],

    SUM(ISNULL([2],0)) [Feb],

    SUM(ISNULL([3],0)) [Mar],

    SUM(ISNULL([4],0)) [Apr],

    SUM(ISNULL([5],0)) [May],

    SUM(ISNULL([6],0)) [Jun],

    SUM(ISNULL([7],0)) [Jul],

    SUM(ISNULL([8],0)) [Aug],

    SUM(ISNULL([9],0)) [Sep],

    SUM(ISNULL([10],0)) [Oct],

    SUM(ISNULL([11],0)) [Nov],

    SUM(ISNULL([12],0)) [Dec],

    SUM(ISNULL([1G],0))  [JanG],

    SUM(ISNULL([2],0)) [FebG],

    SUM(ISNULL([3G],0)) [MarG],

    SUM(ISNULL([4G],0)) [AprG],

    SUM(ISNULL([5G],0)) [MayG],

    SUM(ISNULL([6G],0)) [JunG],

    SUM(ISNULL([7G],0)) [JulG],

    SUM(ISNULL([8G],0)) [AugG],

    SUM(ISNULL([9G],0)) [SepG],

    SUM(ISNULL([10G],0)) [OctG],

    SUM(ISNULL([11G],0)) [NovG],

    SUM(ISNULL([12G],0)) [DecG]

    FROM

    (

    SELECT C, CardCode,CardName,[month],GRSSmonth,SUM(Volume) AS TTL,SUM(GRSS) AS GRSS FROM (
        SELECT T2.CardCode,t2.CardName, T3.Name AS C, T2.DocTotal Volume, 
        t2.GrosProfit as GRSS, 
        month(T2.TaxDate) as month,
        CONCAT(month(T2.TaxDate),'G') as GRSSmonth

        FROM OINV T2
        INNER JOIN dbo.[@SALESAGENT] T3 ON T3.Code=T2.U_SalesAgent 
        INNER JOIN INV1 T4 ON T4.DOCENTRY=T2.DocNum
        WHERE TaxDate between @fromdate and @todate
        AND U_SALESAGENT<>''
        AND CANCELED='N'
        AND REPLACE(WhsCode,'KORKM2','KOROST') LIKE '%'+@WHS+'%'
        

        UNION ALL 

        SELECT T2.CardCode,t2.CardName, T3.Name AS C, t2.DocTotal*-1 as Volume, 
        t2.GrosProfit*-1  as GRSS, 
        month(T2.TaxDate) as month,
        CONCAT(month(T2.TaxDate),'G') as GRSSmonth

        FROM ORIN T2 
        INNER JOIN dbo.[@SALESAGENT] T3 ON T3.Code=T2.U_SalesAgent 
        INNER JOIN RIN1 T4 ON T4.DOCENTRY=T2.DocNum
        WHERE TaxDate between @fromdate and @todate
        AND U_SALESAGENT<>''
        AND CANCELED='N'
        AND REPLACE(WhsCode,'KORKM2','KOROST') LIKE '%'+@WHS+'%'

        )D
        -- WHERE ItemCode NOT LIKE'%SVSVS%'
    Group by C, CardCode,CardName,[month],GRSSmonth
    ) S

    Pivot

    (sum([TTL]) For Month IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]))P


    Pivot

    (sum([GRSS]) For GRSSmonth IN ([1G],[2G],[3G],[4G],[5G],[6G],[7G],[8G],[9G],[10G],[11G],[12G]))P2

    GROUP BY C,CardCode,CardName
END

if (@Trans='Item')
BEGIN
    SELECT
    ROW_NUMBER() OVER (PARTITION BY C ORDER BY (SELECT ItemName FROM OITM WHERE OITM.ItemCode=P2.ItemCode)) AS row_number,
    CONCAT('G',C) AS SS,
    (SELECT ItemName FROM OITM WHERE OITM.ItemCode=P2.ItemCode) AS ItemName,
    C,
    Itemcode,

    SUM(ISNULL([1],0))  [Jan],

    SUM(ISNULL([2],0)) [Feb],

    SUM(ISNULL([3],0)) [Mar],

    SUM(ISNULL([4],0)) [Apr],

    SUM(ISNULL([5],0)) [May],

    SUM(ISNULL([6],0)) [Jun],

    SUM(ISNULL([7],0)) [Jul],

    SUM(ISNULL([8],0)) [Aug],

    SUM(ISNULL([9],0)) [Sep],

    SUM(ISNULL([10],0)) [Oct],

    SUM(ISNULL([11],0)) [Nov],

    SUM(ISNULL([12],0)) [Dec],

    SUM(ISNULL([1G],0))  [JanG],

    SUM(ISNULL([2],0)) [FebG],

    SUM(ISNULL([3G],0)) [MarG],

    SUM(ISNULL([4G],0)) [AprG],

    SUM(ISNULL([5G],0)) [MayG],

    SUM(ISNULL([6G],0)) [JunG],

    SUM(ISNULL([7G],0)) [JulG],

    SUM(ISNULL([8G],0)) [AugG],

    SUM(ISNULL([9G],0)) [SepG],

    SUM(ISNULL([10G],0)) [OctG],

    SUM(ISNULL([11G],0)) [NovG],

    SUM(ISNULL([12G],0)) [DecG]

    FROM

    (

    SELECT C, ItemCode,[month],GRSSmonth,SUM(Volume) AS TTL,SUM(GRSS) AS GRSS FROM (
        SELECT T1.itemcode, T3.Name AS C, t1.LineTotal as Volume, 
        t1.GrssProfit as GRSS, 
        month(T2.TaxDate) as month,
        CONCAT(month(T2.TaxDate),'G') as GRSSmonth

        FROM INV1 T1 
        INNER JOIN OINV T2 ON T1.docentry = T2.docentry
        INNER JOIN dbo.[@SALESAGENT] T3 ON T3.Code=T2.U_SalesAgent 
        WHERE TaxDate between @fromdate and @todate
        AND U_SALESAGENT<>''
        AND CANCELED='N'
        AND REPLACE(WhsCode,'KORKM2','KOROST') LIKE '%'+@WHS+'%'
        

        UNION ALL 

        SELECT T1.itemcode, T3.Name AS C, t1.LineTotal*-1 as Volume, 
        t1.GrssProfit*-1  as GRSS, 
        month(T2.TaxDate) as month,
        CONCAT(month(T2.TaxDate),'G') as GRSSmonth

        FROM RIN1 T1 
        INNER JOIN ORIN T2 ON T1.docentry = T2.docentry
        INNER JOIN dbo.[@SALESAGENT] T3 ON T3.Code=T2.U_SalesAgent 
        WHERE TaxDate between @fromdate and @todate
        AND U_SALESAGENT<>''
        AND CANCELED='N'
        AND REPLACE(WhsCode,'KORKM2','KOROST') LIKE '%'+@WHS+'%'
        )D
        WHERE ItemCode NOT LIKE'%SVSVS%'
    Group by C, ItemCode,[month],GRSSmonth
    ) S

    Pivot

    (sum([TTL]) For Month IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]))P


    Pivot

    (sum([GRSS]) For GRSSmonth IN ([1G],[2G],[3G],[4G],[5G],[6G],[7G],[8G],[9G],[10G],[11G],[12G]))P2

    GROUP BY C,ItemCode
END