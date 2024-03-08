*Analysis

clear
cd "/Users/wenchenwang/Desktop/Dissertation/Public_Updated_data/revision/CPS1/robustness/sipp/new data"
use sipp_all.dta

drop if year == 2022

* Universally licensed indicator
	destring occ, replace
	merge m:1 occ using ground_truth_statecert.dta, nogen keep (1 3)

	gen sample = 1
	replace sample = 0 if gt == 1
	
/*Generate Strata*/

egen agecat = cut(age), group(10)
egen expcat = cut (exp), group(10)

egen strata = group(agecat expcat female black asian hispanic white LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate married citizen metro)


gen interaction = license * public	

* Drop people with wages below half the federal minimum wage
replace hourwage = . if hourwage < .5*7.25

*Drop missing
destring sippid, replace
destring ind, replace

foreach v in swave spanel sippid year monthcode tfipsst male female white black asian other_race hispanic nonhispanic age age2 married LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate citizen noncitizen metro nonmetro metrocat3 my exp exp2 profcert statecert license othercert unemployed classwork public union uhrswork1 hourly hourwage lnwage lnhour occ state_occ ind wpfinwgt {

	drop if `v'== .
	
}

*Input the CPI (from BLS CPI calculator: https://www.bls.gov/data/inflation_calculator.htm)*/

	generate cpiadjfactor = 0
	replace cpiadjfactor = 1 if year==2015
	replace cpiadjfactor = 0.9865 if year==2016
	replace cpiadjfactor = 0.9624 if year==2017
	replace cpiadjfactor = 0.9429 if year==2018
	replace cpiadjfactor = 0.9285 if year==2019
	replace cpiadjfactor = 0.9059 if year==2020
	replace cpiadjfactor = 0.8934 if year==2021
	replace cpiadjfactor = 0.83 if year==2022

	label variable cpiadjfactor "CPI adjustment factor"
	
	*Compute Real Wage and Real Earnings by adjusting for inflation using the CPI.
	
	gen real_hrwage = hourwage * cpiadjfactor
	label variable real_hrwage "Real Hourly Wage"

*Descriptive Statistics

cap mata: mata drop __000003

*By Licensing
gen private = public==0

qui mean public private LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian hispanic union female exp age real_hrwage uhrswork1 [pw=wpfinwgt]
count if e(sample)
est store des_full

qui mean public private LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian hispanic union female exp age real_hrwage uhrswork1 [pw=wpfinwgt] if license==1
count if e(sample)
est store des_licensed

qui mean public private LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian hispanic union female exp age real_hrwage uhrswork1 [pw=wpfinwgt] if license==0
count if e(sample)
est store des_unlicensed

est table des_full des_licensed des_unlicensed, stfmt(%9.4g) stat (N)
return list

matrix des = r(coef)
putexcel set descriptive.xlsx, modify
putexcel A3 = matrix(des), rownames nformat(number_d2)

*By Sector
gen unlicense = license==0

qui mean license unlicense LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian hispanic union female exp age real_hrwage uhrswork1 [pw=wpfinwgt]
count if e(sample)
est store des_full_2

qui mean license unlicense LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian hispanic union female exp age real_hrwage uhrswork1 [pw=wpfinwgt] if public==1
count if e(sample)
est store des_public

qui mean license unlicense LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate white black asian hispanic union female exp age real_hrwage uhrswork1 [pw=wpfinwgt] if public==0
count if e(sample)
est store des_private

est table des_full_2 des_public des_private, stfmt(%9.4g) stat (N)
return list

matrix des = r(coef)
putexcel set descriptive.xlsx, modify
putexcel I3 = matrix(des), rownames nformat(number_d2)


*Wage


*1. General
reghdfe lnwage license public [pw=wpfinwgt] if sample == 1, a(strata) cl(state_occ)
outreg2 using Oster_wage.doc, replace ctitle(A)

*2. Interaction
reghdfe lnwage license public interaction [pw=wpfinwgt] if sample == 1, a(strata) cl(state_occ)
outreg2 using Oster_wage.doc, append ctitle(B)

*3. Adding controls & state and occ fixed effects

reghdfe lnwage license public interaction [pw=wpfinwgt] if sample == 1, a(strata tfipsst occ) cl(state_occ)
outreg2 using Oster_wage.doc, append ctitle(C)

*4. Adding ind and month-year fixed effects
reghdfe lnwage license public interaction [pw=wpfinwgt] if sample == 1, a(strata tfipsst occ ind my) cl(state_occ)
outreg2 using Oster_wage.doc, append ctitle(D)

*5. Adding certification and unionization

reghdfe lnwage license public interaction union othercert [pw=wpfinwgt]if sample == 1, a(strata tfipsst occ ind my) cl(state_occ)
outreg2 using Oster_wage.doc, append ctitle(E)


*Total Hours

*1. General
reghdfe lnhour license public [pw=wpfinwgt] if sample == 1, a(strata) cl(state_occ)
outreg2 using Oster_hour.doc, replace ctitle(A)

*2. Interaction
reghdfe lnhour license public interaction [pw=wpfinwgt] if sample == 1, a(strata) cl(state_occ)
outreg2 using Oster_hour.doc, append ctitle(B)

*3. Adding controls & state and occ fixed effects

reghdfe lnhour license public interaction [pw=wpfinwgt] if sample == 1, a(strata tfipsst occ) cl(state_occ)
outreg2 using Oster_hour.doc, append ctitle(C)

*4. Adding ind and month-year fixed effects
reghdfe lnhour license public interaction [pw=wpfinwgt] if sample == 1, a(strata tfipsst occ ind my) cl(state_occ)
outreg2 using Oster_hour.doc, append ctitle(D)

*5. Adding certification and unionization

reghdfe lnhour license public interaction union othercert [pw=wpfinwgt]if sample == 1, a(strata tfipsst occ ind my) cl(state_occ)
outreg2 using Oster_hour.doc, append ctitle(E)
