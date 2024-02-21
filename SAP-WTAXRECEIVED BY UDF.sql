IF $[$46.0.0]=CONVERT(DATETIME,$[$U_WTaxRecDate.0])
BEGIN
		IF $[$U_WTax.0]='N/A' OR $[$U_WTax.0]='Not Received'
		BEGIN
				 SELECT ''
		END
		ELSE
		BEGIN
				 SELECT (T1.lastName +', '+ t1.firstName) AS Uname FROM OUSR T0 INNER JOIN OHEM T1
				ON T0.USERID=T1.userId
				WHERE T0.USERID=$[USER]
		END

END
ELSE
BEGIN


		IF $[$U_WTax.0]='N/A' OR $[$U_WTax.0]='Not Received'
		BEGIN
				 SELECT ''
		END
		ELSE
		BEGIN
				 SELECT (lastName + ',' + firstName) AS Name, Active FROM  OHEM WHERE position IN  (2,3,5) AND Active='Y'
						  ORDER BY lastName
		END
END