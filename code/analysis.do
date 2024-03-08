/*************************Main Rregression**************************************/

/*************Main Results********************/

clear

cd "/Users/wenchenwang/Desktop/Dissertation/Public_Updated_data/revision/CPS1/data_cleaning/updated"

use regression_newest.dta

drop if year == 2022

gen interaction = license*public

save cps_cleaned.dta, replace

/*merge m:m occ using lpred_ls.dta

drop _merge

drop if lemp_pred_ls == .
*/

clear

use cps_cleaned.dta

*1. General
reghdfe lnwage license public [aw=earnwt] if sample == 1, a(strata) cl(cpsidp)
outreg2 using Oster_wage.doc, replace ctitle(A)

*2. Demographic strata
reghdfe lnwage license public interaction [aw=earnwt] if sample == 1, a(strata) cl(cpsidp)
outreg2 using Oster_wage.doc, append ctitle(B)

*3. Adding state and occ fixed effects
reghdfe lnwage license public interaction [aw=earnwt] if sample == 1, a(strata statefip occ) cl(cpsidp)
outreg2 using Oster_wage.doc, append ctitle(C)

*4. Adding ind and month-year fixed effects
reghdfe lnwage license public interaction [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(cpsidp)
outreg2 using Oster_wage.doc, append ctitle(D)

*5. Adding certification and unionization
reghdfe lnwage license public interaction unioncat othercert [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(cpsidp)
outreg2 using Oster_wage.doc, append ctitle(E)

*robustness using controls instead of strata
local controls age age2 exp exp2 female black asian white Hispanic LessthanHS SomeCol AssoDeg Bachelor Graduate married citizencat veteran children unioncat othercert

reghdfe lnwage license public interaction `controls' [aw=earnwt] if sample == 1, a(statefip occ ind my) cl(cpsidp)

*xtreg: too slow with multiple level FE
gen id = _n
xtset id my

local controls age age2 exp exp2 female black asian white Hispanic LessthanHS SomeCol AssoDeg Bachelor Graduate married citizencat veteran children unioncat othercert

xtreg lnwage license public interaction `controls' i.statefip i.occ i.ind i.my if sample == 1, re cl(cpsidp)


*Fulltime indicator
drop ft_worker

/* create variable to indicate fulltime workers*/

	gen ft_worker=0
	replace ft_worker=1 if wkstat == 11
	replace ft_worker=1 if wkstat == 13
	replace ft_worker=1 if wkstat ==14
	replace ft_worker=1 if wkstat ==15
	label var ft_worker "Full-time Worker"
	tab ft_worker , miss

/* create variable to indicate parttime workers*/

	gen pt_worker=0
	replace pt_worker=1 if wkstat == 12
	replace pt_worker=1 if wkstat == 21
	replace pt_worker=1 if wkstat ==22
	replace pt_worker=1 if wkstat ==41
	replace pt_worker=1 if wkstat ==42
	label var pt_worker "Part-time Worker"
	tab pt_worker , miss
	


*1. General
reghdfe pt_worker license public [aw=earnwt] if sample == 1, a(strata) cl(cpsidp)
outreg2 using Oster_hour.doc, replace ctitle(A)

*2. Demographic strata
reghdfe pt_worker license public interaction [aw=earnwt] if sample == 1, a(strata) cl(cpsidp)
outreg2 using Oster_hour.doc, append ctitle(B)

*3. Adding state and occ fixed effects
reghdfe pt_worker license public interaction [aw=earnwt] if sample == 1, a(strata statefip occ) cl(cpsidp)
outreg2 using Oster_hour.doc, append ctitle(C)

*4. Adding ind and month-year fixed effects
reghdfe pt_worker license public interaction [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(cpsidp)
outreg2 using Oster_hour.doc, append ctitle(D)

*5. Adding certification and unionization
reghdfe pt_worker license public interaction unioncat othercert [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(cpsidp)
outreg2 using Oster_hour.doc, append ctitle(E)



* Voluntary vs Involuntary

/*create variable to indicate involuntary parttime workers*/
	gen involun_pt=0
	replace involun_pt=1 if wkstat == 21
	replace involun_pt=1 if wkstat ==22
	label var involun_pt "Involuntary Part-time Worker"
	tab involun_pt , miss
	
/*create variable to indicate voluntary parttime workers*/
	gen volun_pt=0
	replace volun_pt=1 if wkstat == 12
	replace volun_pt=1 if wkstat ==41
	label var volun_pt "Voluntary Part-time Worker"
	tab volun_pt , miss
	
*Voluntary
preserve 
drop if wkstat == 21
drop if wkstat == 22
drop if wkstat == 42

*1. General
reghdfe volun_pt license public [aw=earnwt] if sample == 1, a(strata) cl(cpsidp)
outreg2 using volun_hour.doc, replace ctitle(A)

*2. Demographic strata
reghdfe volun_pt license public interaction [aw=earnwt] if sample == 1, a(strata) cl(cpsidp)
outreg2 using volun_hour.doc, append ctitle(B)

*3. Adding state and occ fixed effects
reghdfe volun_pt license public interaction [aw=earnwt] if sample == 1, a(strata statefip occ) cl(cpsidp)
outreg2 using volun_hour.doc, append ctitle(C)

*4. Adding ind and month-year fixed effects
reghdfe volun_pt license public interaction [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(cpsidp)
outreg2 using volun_hour.doc, append ctitle(D)

*5. Adding certification and unionization
reghdfe volun_pt license public interaction unioncat othercert [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(cpsidp)
outreg2 using volun_hour.doc, append ctitle(E)

restore

*Involuntary
preserve 
drop if wkstat == 12
drop if wkstat == 41
drop if wkstat == 42

*1. General
reghdfe involun_pt license public [aw=earnwt] if sample == 1, a(strata) cl(cpsidp)
outreg2 using involun_hour.doc, replace ctitle(A)

*2. Demographic strata
reghdfe involun_pt license public interaction [aw=earnwt] if sample == 1, a(strata) cl(cpsidp)
outreg2 using involun_hour.doc, append ctitle(B)

*3. Adding state and occ fixed effects
reghdfe involun_pt license public interaction [aw=earnwt] if sample == 1, a(strata statefip occ) cl(cpsidp)
outreg2 using involun_hour.doc, append ctitle(C)

*4. Adding ind and month-year fixed effects
reghdfe involun_pt license public interaction [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(cpsidp)
outreg2 using involun_hour.doc, append ctitle(D)

*5. Adding certification and unionization
reghdfe involun_pt license public interaction unioncat othercert [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(cpsidp)
outreg2 using involun_hour.doc, append ctitle(E)

restore



*Selection on Observables: PSM

*Propensity Score Matching

*Weights Formation

*Interaction score
gen age3= age^3
gen age4= age^4
gen age5= age^5
gen age6= age^6
gen age7= age^7

gen exp3= exp^3
gen exp4= exp^4
gen exp5= exp^5
gen exp6= exp^6
gen exp7= exp^7

local sixth="age exp age2 exp2 age3 exp3 age4 exp4 age5 exp5 age6 exp6"

local otherstuff female black asian Hispanic LessthanHS SomeCol AssoDeg Bachelor Graduate northeast midwest south married citizencat unioncat veteran metrostat children

qui logit interaction `otherstuff' `sixth'
predict p_lic_l, pr

* trim area of common support 
sum p_lic_l if interaction==1
sum p_lic_l if interaction==0

replace p_lic_l=. if p_lic_l<  .0001387 
replace p_lic_l=. if p_lic_l>  .7004709

gen atetwt_l_4 = earnwt*((p_lic_l)/(1-(p_lic_l))) if interaction==0 & p_lic_l>0
replace atetwt_l_4 = earnwt if interaction==1 


*License score

local sixth="age exp age2 exp2 age3 exp3 age4 exp4 age5 exp5 age6 exp6"

local otherstuff female black asian Hispanic LessthanHS SomeCol AssoDeg Bachelor Graduate northeast midwest south married citizencat unioncat veteran metrostat children

qui logit license `otherstuff' `sixth'
predict p_lic_l, pr

* trim area of common support 
sum p_lic_l if license==1
sum p_lic_l if license==0

replace p_lic_l=. if p_lic_l< .0016593
replace p_lic_l=. if p_lic_l>   .7912685

gen atetwt_l_2 = earnwt*((p_lic_l)/(1-(p_lic_l))) if license==0 & p_lic_l>0
replace atetwt_l_2 = earnwt if license==1 


*1. General
reghdfe lnwage license public [aw=atetwt_l_4] if sample == 1, a(strata) cl(state_occ)
outreg2 using Oster_wage_psm.doc, replace ctitle(A)

*1. Demographic strata
reghdfe lnwage license public interaction [aw=atetwt_l_4] if sample == 1, a(strata) cl(state_occ)
outreg2 using Oster_wage_psm.doc, append ctitle(B)

*2. Adding state and occ fixed effects
reghdfe lnwage license public interaction [aw=atetwt_l_4] if sample == 1, a(strata statefip occ) cl(state_occ)
outreg2 using Oster_wage_psm.doc, append ctitle(C)

*3. Adding ind and month-year fixed effects
reghdfe lnwage license public interaction [aw=atetwt_l_4] if sample == 1, a(strata statefip occ ind my) cl(state_occ)
outreg2 using Oster_wage_psm.doc, append ctitle(D)

*4. Adding certification and unionization
reghdfe lnwage license public interaction unioncat othercert[aw=atetwt_l_4] if sample == 1, a(strata statefip occ ind my) cl(state_occ)
outreg2 using Oster_wage_psm.doc, append ctitle(E)


*Total Hours

*1. General
reghdfe ln_hour license public [aw=atetwt_l_4] if sample == 1, a(strata) cl(state_occ)
outreg2 using Oster_hour_psm.doc, replace ctitle(A)

*1. Demographic strata
reghdfe ln_hour license public interaction [aw=atetwt_l_4] if sample == 1, a(strata) cl(state_occ)
outreg2 using Oster_hour_psm.doc, append ctitle(B)

*2. Adding state and occ fixed effects
reghdfe ln_hour license public interaction [aw=atetwt_l_4] if sample == 1, a(strata statefip occ) cl(state_occ)
outreg2 using Oster_hour_psm.doc, append ctitle(C)

*3. Adding ind and month-year fixed effects
reghdfe ln_hour license public interaction [aw=atetwt_l_4] if sample == 1, a(strata statefip occ ind my) cl(state_occ)
outreg2 using Oster_hour_psm.doc, append ctitle(D)

*4. Adding certification and unionization
reghdfe ln_hour license public interaction unioncat other_cert [aw=atetwt_l_4] if sample == 1, a(strata statefip occ ind my) cl(state_occ)
outreg2 using Oster_hour_psm.doc, append ctitle(E)


*Check share selection on observables

local otherstuff age exp female black asian Hispanic LessthanHS SomeCol AssoDeg Bachelor Graduate northeast midwest south married citizencat unioncat veteran metrostat children


reghdfe license_sh `otherstuff' [aw=wtfinl] if sample == 1, a(statefip occ ind my) cl(state_occ)

/*Licensing share


egen license_m = mean (license_sh)
egen public_m = mean (public_sh)
gen license_c = license_sh-license_m
gen public_c = public_sh-public_m
gen interaction_c = license_c*public_c

gen interaction2 = license_sh*public_sh

*1. Demographic strata
reghdfe lnwage license_sh public_sh interaction3 [aw=earnwt] if sample == 1, a(strata) cl(state_occ)
outreg2 using Oster_wage_sh.doc, replace ctitle(A)

*2. Adding state and occ fixed effects
reghdfe lnwage license_sh public_sh interaction3 [aw=earnwt] if sample == 1, a(strata statefip occ) cl(state_occ)
outreg2 using Oster_wage_sh.doc, append ctitle(B)

*3. Adding ind and month-year fixed effects
reghdfe lnwage license_sh public_sh interaction3 [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(state_occ)
outreg2 using Oster_wage_sh.doc, append ctitle(C)

*4. Adding certification and unionization
reghdfe lnwage license_sh public_sh interaction2 union_sh otherc_sh [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(state_occ)
outreg2 using Oster_wage_sh.doc, append ctitle(D)

margins, at(license_sh=(0(0.2)1) public_sh=(0.3 0.4 0.5))
marginsplot, noci ytitle("Predicted Wage")

*Total Hours
preserve 

gen ln_hour=ln(uhrswork1)
drop if ln_hour == .

*1. Demographic strata
reghdfe ln_hour license_sh public_sh interaction3 [aw=earnwt] if sample == 1, a(strata) cl(state_occ)
outreg2 using Oster_hour_sh.doc, replace ctitle(A)

*2. Adding state and occ fixed effects
reghdfe ln_hour license_sh public_sh interaction3 [aw=earnwt] if sample == 1, a(strata statefip occ) cl(state_occ)
outreg2 using Oster_hour_sh.doc, append ctitle(B)

*3. Adding ind and month-year fixed effects
reghdfe ln_hour license_sh public_sh interaction3 [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(state_occ)
outreg2 using Oster_hour_sh.doc, append ctitle(C)

*4. Adding certification and unionization
reghdfe ln_hour license_sh public_sh interaction2 union_sh otherc_sh [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(state_occ)
outreg2 using Oster_hour_sh.doc, append ctitle(D)

restore
*/

***Selection Correction (Finkelsein et al.)

*Wage

	*1. regular regression

reghdfe lnwage license public interaction unioncat other_cert [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(state_occ)

	*2. houshold regression
	
reghdfe lnwage license public interaction unioncat other_cert [aw=earnwt] if sample == 1, a(strata statefip occ ind my cpsid) cl(state_occ)	

	* 3. individual regression
	
reghdfe lnwage license public interaction unioncat other_cert [aw=earnwt] if sample == 1, a(strata statefip occ ind my cpsidp) cl(state_occ)	


*Hours worked

preserve 

gen ln_hour=ln(uhrswork1)
drop if ln_hour == .

	*1. regular regression

reghdfe ln_hour license public interaction unioncat other_cert [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(state_occ)

	*2. houshold regression
	
reghdfe ln_hour license public interaction unioncat other_cert [aw=earnwt] if sample == 1, a(strata statefip occ ind my cpsid) cl(state_occ)	

	* 3. individual regression
	
reghdfe ln_hour license public interaction unioncat other_cert [aw=earnwt] if sample == 1, a(strata statefip occ ind my cpsidp) cl(state_occ)

restore		


/*Propensity Score Matching

*Weights Formation
gen age3= age^3
gen age4= age^4
gen age5= age^5
gen age6= age^6
gen age7= age^7

gen exp3= exp^3
gen exp4= exp^4
gen exp5= exp^5
gen exp6= exp^6
gen exp7= exp^7

local sixth="age exp age2 exp2 age3 exp3 age4 exp4 age5 exp5 age6 exp6"

local otherstuff female black asian Hispanic LessthanHS SomeCol AssoDeg Bachelor Graduate northeast midwest south married citizencat unioncat veteran metrostat

qui logit license `otherstuff' `sixth'
predict p_lic_l, pr

* trim area of common support 
sum p_lic_l if license==1
sum p_lic_l if license==0

replace p_lic_l=. if p_lic_l<  .0045498
replace p_lic_l=. if p_lic_l> .7511722

gen atetwt_l_4 = earnwtrd*((p_lic_l)/(1-(p_lic_l))) if license==0 & p_lic_l>0
replace atetwt_l_4 = earnwtrd if license==1 

*/


*Quantile Regression
local controls age age2 exp exp2 female black asian Hispanic LessthanHS SomeCol AssoDeg Bachelor Graduate married citizencat veteran unioncat
rifsureg lnwage public license interaction `controls' [aw=earnwt], qs(10(10)90)
margins, dydx(license) nose
marginsplot

local controls age age2 exp exp2 female black asian Hispanic LessthanHS SomeCol AssoDeg Bachelor Graduate married citizencat veteran unioncat
rifsureg lnwage public license interaction `controls' [aw=earnwt], qs(10(10)90)
margins, dydx(interaction) nose
marginsplot

local controls age age2 exp exp2 female black asian Hispanic LessthanHS SomeCol AssoDeg Bachelor Graduate married citizencat veteran unioncat
xtrifreg lnwage public license interaction [aw=wtfinl], fe i(statefip)  q(10)

**rqr

ssc install rqr
net install qrprocess, from("https://raw.githubusercontent.com/bmelly/Stata/main/")

*Interaction
rqr lnwage license, quantile(.1(.1).9) controls(interaction public unioncat other_cert) absorb(strata statefip occ ind my)

rqrplot, xlab(, nogrid) ylab(license, nogrid)

rqr lnwage interaction, quantile(.1(.1).9) controls(license public unioncat other_cert) absorb(strata statefip occ ind my)

rqrplot, xlab(, nogrid) ylab(interaction, nogrid)

*Subsample

rqr lnwage license if public == 1, quantile(.1(.1).9) controls(unioncat other_cert) absorb(strata statefip occ ind my)

rqrplot

rqr lnwage license if public == 0, quantile(.1(.1).9) controls(unioncat other_cert) absorb(strata statefip occ ind my)

rqrplot







