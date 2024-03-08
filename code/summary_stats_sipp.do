/*******************************Summary Statistics*********************************************************************************************/

cd "/Users/wenchenwang/Desktop/Paper_Updated_data/3. desciptive_weights"
use regression_cleaned

*By Licensing
qui mean public private educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic northeast midwest south west married citizencat veteran unioncat female exp age real_hrwage real_earnweek ft_worker uhrswork1 [pw=wtrd]
count if e(sample)
est store des_full

qui mean public private educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic northeast midwest south west married citizencat veteran unioncat female exp age real_hrwage real_earnweek ft_worker uhrswork1 [pw=wtrd] if license==1
count if e(sample)
est store des_licensed

qui mean public private educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic northeast midwest south west married citizencat veteran unioncat female exp age real_hrwage real_earnweek ft_worker uhrswork1 [pw=wtrd] if license==0
count if e(sample)
est store des_unlicensed

est table des_full des_licensed des_unlicensed, stfmt(%9.4g) stat (N)
return list

matrix des = r(coef)
putexcel set descriptive.xlsx, modify
putexcel A3 = matrix(des), rownames nformat(number_d2)

*By Sector
gen unlicense = license==0

qui mean license unlicense educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic northeast midwest south west married citizencat veteran unioncat female exp age real_hrwage real_earnweek ft_worker uhrswork1 [pw=wtrd]
count if e(sample)
est store des_full_2

qui mean license unlicense educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic northeast midwest south west married citizencat veteran unioncat female exp age real_hrwage real_earnweek ft_worker uhrswork1 [pw=wtrd] if public==1
count if e(sample)
est store des_public

qui mean license unlicense educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic northeast midwest south west married citizencat veteran unioncat female exp age real_hrwage real_earnweek ft_worker uhrswork1 [pw=wtrd] if public==0
count if e(sample)
est store des_private

est table des_full_2 des_public des_private, stfmt(%9.4g) stat (N)
return list

matrix des = r(coef)
putexcel set descriptive.xlsx, modify
putexcel I3 = matrix(des), rownames nformat(number_d2)

*Sector Specific
mean hr_wage, over(classwkr)
mean uhrswork1, over(classwkr)

*Occupation Specific
mean license, over(occ_cat)
est store occ
est table occ, stfmt(%9.4g) stat (N)
return list

matrix des = r(coef)
putexcel set histogram.xlsx, modify
putexcel A2 = matrix(des), rownames nformat(number_d2)

mean public, over(occ_cat)
est store occ2
est table occ2, stfmt(%9.4g) stat (N)
return list

matrix des = r(coef)
putexcel set histogram.xlsx, modify
putexcel E2 = matrix(des), rownames nformat(number_d2)

mean hr_wage, over(occ_cat)
est store occ3
est table occ3, stfmt(%9.4g) stat (N)

matrix des = r(coef)
putexcel set histogram.xlsx, modify
putexcel A39 = matrix(des), rownames nformat(number_d2)

mean uhrswork1, over(occ_cat)
est store occ4
est table occ4, stfmt(%9.4g) stat (N)

matrix des = r(coef)
putexcel set histogram.xlsx, modify
putexcel A64 = matrix(des), rownames nformat(number_d2)
