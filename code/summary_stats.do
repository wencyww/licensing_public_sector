/*******************************Summary Statistics*********************************************************************************************/

cd "/Users/wenchenwang/Desktop/Dissertation/Public_Updated_data/revision/CPS1/data_cleaning/updated"

clear

use cps_cleaned.dta

cap mata mata drop  __000003


*By Licensing
qui mean public private educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic married unioncat female exp age [pw=wtrd]
count if e(sample)
est store des_full_1

qui mean real_hrwage real_earnweek ft_worker uhrswork1 [aw=earnwt]
count if e(sample)
est store des_full_2


qui mean public private educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic married unioncat female exp age [pw=wtrd] if license==1
count if e(sample)
est store des_licensed_1

qui mean real_hrwage real_earnweek ft_worker uhrswork1 [aw=earnwt] if license == 1
count if e(sample)
est store des_licensed_2

qui mean public private educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic married unioncat female exp age [pw=wtrd] if license==0
count if e(sample)
est store des_unlicensed_1

qui mean real_hrwage real_earnweek ft_worker uhrswork1 [aw=earnwt] if license == 0
count if e(sample)
est store des_unlicensed_2


est table des_full_1 des_full_2 des_licensed_1 des_licensed_2 des_unlicensed_1 des_unlicensed_2, stfmt(%9.4g) stat (N)
return list

matrix des = r(coef)
putexcel set descriptive.xlsx, modify
putexcel A3 = matrix(des), rownames nformat(number_d2)

*By Sector

qui mean license unlicense educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic married unioncat female exp age [pw=wtrd] if public==1
count if e(sample)
est store des_public_1

qui mean real_hrwage real_earnweek ft_worker uhrswork1 [aw=earnwt] if public == 1
count if e(sample)
est store des_public_2

qui mean license unlicense educ LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian Hispanic married unioncat female exp age [pw=wtrd] if public==0
count if e(sample)
est store des_private_1

qui mean real_hrwage real_earnweek ft_worker uhrswork1 [aw=earnwt] if public == 0
count if e(sample)
est store des_private_2

est table des_public_1 des_public_2 des_private_1 des_private_2, stfmt(%9.4g) stat (N)
return list

matrix des = r(coef)
putexcel set descriptive.xlsx, modify
putexcel O3 = matrix(des), rownames nformat(number_d2)

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
