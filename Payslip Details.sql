
-- select lname,fname, mname, PeriodFrom,T0.sss,SSSLoan,T0.Pagibig,T0.PLoan as 'Pagibigloan',T0.PhilHealth,T0.WTax,T0.OD as 'Overdrop',T0.Vale from tbl_Payroll T0
-- INNER JOIN tbl_EmployeeInformation T1 ON T0.EmpID=T1.EmpID
-- where T0.EmpID IN ('09-20-3061','09-20-3243','09-19-2893','09-19-2891','02-19-2974','02-18-2258','06-19-2652')
-- ORDER BY Lname, PeriodFrom

-- select Name, PeriodFrom,T0.sss,SSSLoan,T0.Pagibig,T0.PLoan as 'Pagibigloan',T0.PhilHealth,T0.WTax,T0.OD as 'Overdrop',T0.Vale 
-- from tbl_Payroll t0
-- where T0.EmpID IN ('09-20-3061','09-20-3243','09-19-2893','09-19-2891','02-19-2974','02-18-2258','06-19-2652')
-- ORDER BY name, PeriodFrom




-- --='06-20-3140' and PeriodFrom = '2022-04-18'

-- select * from tbl_Payroll where EmpID='06-20-3140' and PeriodFrom='2022-04-18'

-- select * from tbl_Details where EmpID='06-20-3140'

-- select * from tbl_OtherDetails where EmpID='06-20-3140' and DFrom ='2022-04-18'



-- -- SELECT * FROM tbl_DailyTimeRecords WHERE   UserID='02-21-3330' AND DATE BETWEEN '2022-04-18' AND '2022-04-23'  

-- -- SELECT * FROM tbl_WeeklyReport WHERE UserID ='02-21-3330' AND DateFrom ='2022-04-18'

-- -- SELECT * FROM tbl_Details WHERE   EMPID='02-21-3330'ORDER BY DATE


-- select * from tbl_EmployeeInformation where Lname like '%yacan%'

-- select * from tbl_EmployeeInformation where EmpID in ('09-20-3061','09-20-3243','09-19-2893','09-19-2891','02-19-2974','02-18-2258','06-19-2652')

-- select * from tbl_Details


SELECT tbl_Payroll.Name,PeriodFrom,
	-- tbl_EmployeeInformation.DaysLeave, tbl_Payroll.EmpID,tbl_EmployeeInformation.ZKNo, tbl_EmployeeInformation.DHired, tbl_EmployeeInformation.AccNo, 
	-- tbl_EmployeeInformation.F2SRemarks,
	-- tbl_WeeklyReport.TotalLate, tbl_WeeklyReport.TotalUndertime , tbl_WeeklyReport.Present, tbl_WeeklyReport.Absent,
	-- tbl_Payroll.Name, tbl_EmployeeInformation.[Position], tbl_Payroll.Department, tbl_Payroll.Company, tbl_Payroll.RatePD,
	-- CASE WHEN tbl_Payroll.ColaPD = 0 THEN 0 ELSE (tbl_Payroll.Cola / tbl_Payroll.ColaPD) END AS ColaDays,
	-- tbl_Payroll.ColaPD, tbl_Payroll.NOD, tbl_Payroll.Holiday, tbl_Payroll.Cola, tbl_Payroll.Rate AS Salary, tbl_Payroll.Overtime, 
	-- tbl_Payroll.SOthers, 
	tbl_Payroll.SSS, tbl_Payroll.SSSLoan,
	tbl_Payroll.Pagibig,  tbl_Payroll.PLoan as 'PagibigLoan',
	tbl_Payroll.CalamityLoan,
	CalamityLoanSSS,

	tbl_Payroll.PhilHealth, 
	tbl_Payroll.WTax, 
	tbl_Payroll.OD,
	-- (tbl_Payroll.ValeB+tbl_Payroll.F2SB+tbl_Payroll.OthersB) AS ValeB,
	(tbl_Payroll.F2S+tbl_Payroll.Vale+tbl_Payroll.DOthers)AS 'Cash Advance',
	
	-- tbl_Payroll.COOP,
	tbl_OtherDetails.OADet
	-- tbl_Payroll.F2S, tbl_Payroll.CBond,
	--  tbl_Payroll.DOthers, tbl_Payroll.TSalary, tbl_Payroll.TDeduction, tbl_Payroll.Net,
	-- tbl_Payroll.PeriodFrom , tbl_Payroll.PeriodTo, tbl_Payroll.COOPB, tbl_Payroll.OthersB, 
	-- tbl_Payroll.SSSB, tbl_Payroll.PagibigB, tbl_Payroll.ODB,
	-- tbl_Payroll.F2SB,(tbl_Payroll.PeriodTo + 2) AS PayDate,  tbl_Payroll.CalamityB,
	-- tbl_OtherDetails.HolDet, 
	-- tbl_OtherDetails.AbsentDate
	-- tbl_EmployeeRequirements.SSSNumber, tbl_EmployeeRequirements.PhiNumber, tbl_EmployeeRequirements.TINNUmber , tbl_EmployeeRequirements.PagibigNumber
	-- (tbl_EmployeeInformation.Rate / 480) as LateUnder, (tbl_EmployeeInformation.CBond) as CashBond, (CONVERT(VARCHAR(15), tbl_Payroll.PeriodFrom, 101) + ' - ' + CONVERT(VARCHAR(15), tbl_Payroll.PeriodTo, 101)) as PPeriod, [dbo].[fn_GetUsedLeave](tbl_Payroll.EmpID, tbl_Payroll.PeriodFrom, tbl_Payroll.PeriodTo) AS LeavesUsed
	-- NightDiff , NDHours,Gender,CalamityLoanSSS,CalamitySSSB
	FROM tbl_Payroll  LEFT OUTER JOIN tbl_OtherDetails ON tbl_Payroll.PeriodFrom = tbl_OtherDetails.DFrom AND tbl_Payroll.EmpID = tbl_OtherDetails.EmpID LEFT OUTER JOIN tbl_WeeklyReport ON tbl_Payroll.PeriodFrom = tbl_WeeklyReport.DateFrom AND tbl_Payroll.EmpID = tbl_WeeklyReport.UserID LEFT OUTER JOIN tbl_EmployeeInformation ON tbl_Payroll.EmpID = tbl_EmployeeInformation.EmpID
	where tbl_Payroll.EmpID IN ('09-20-3061','09-20-3243','09-19-2893','09-19-2891','02-19-2974','02-18-2258','06-19-2652')
	ORDER BY name, PeriodFrom