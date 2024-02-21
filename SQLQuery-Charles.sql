
-- '16-16-1674'

SELECT * FROM tbl_EmployeeInformation WHERE LNAME ='lamprea'

SELECT LNAME,FNAME,CNumber,TINNUmber FROM tbl_EmployeeInformation T0
INNER JOIN tbl_EmployeeRequirements T1 ON T0.EmpID=T1.EmpID 
WHERE T0.EmpID IN ('03-21-3451'
                    ,'03-22-3792'
                    ,'03-20-3240'
                    ,'03-21-3380'
                    ,'03-18-2526'
                    ,'27-18-2362'
                    ,'01-21-3654'
                    ,'02-20-3182'
                    ,'02-16-1548'

                    )



--('16-16-1674','06-22-3838','06-22-3840','07-20-3124','07-21-3608','07-19-2933','07-21-3422','13-17-1897','13-20-3071','13-18-2513')