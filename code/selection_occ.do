/******Selection Issue***************/

**# Bookmark #1
clear

cd "/Users/wenchenwang/Desktop/Dissertation/Public_Updated_data/revision/CPS1"
use revision_updated_1.dta

* Create transition-rate measure 

merge m:1 cpsidp using asec.dta, nogen keep (1 3)

gen change_occ = (occly != occ) if !missing(occ) & !missing(occly)
drop if qmigrat1 == 3 | occly == 0

collapse (mean) change_occ (rawsum) wtfinl [aw=asecwt], by(strata agecat expcat children female black asian Hispanic white LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate married citizencat veteran metrostat)

save change_occ.dta, replace

* Settings
clear
use revision_updated_1.dta

reghdfe lnwage license public interaction unioncat other_cert [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(state_occ)

local wage_effect = _b[interaction]


reghdfe ln_hour license public interaction unioncat other_cert [aw=earnwt] if sample == 1, a(strata statefip occ ind my) cl(state_occ)
local hours_effect = _b[interaction]


merge m:1 agecat expcat children female black asian Hispanic white LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate married citizencat veteran metrostat using change_occ.dta, nogen keep(3)

keep if sample == 1


* Find quartiles of the predicted occupational transition rate distribution

summ change_occ [aw=wtfinl], d

local p25 = r(p25)
local p50 = r(p50)
local p75 = r(p75)

gen change_occ_grp = .
replace change_occ_grp = 0 if change_occ < `p25' 
replace change_occ_grp = 1 if change_occ < `p50' & missing(change_occ_grp)
replace change_occ_grp = 2 if change_occ < `p75' & missing(change_occ_grp)
replace change_occ_grp = 3 if change_occ >= `p75' & missing(change_occ_grp)
replace change_occ_grp = . if missing(change_occ)


* Report predicted occupational transition rate by quartile
	
	reg change_occ i.change_occ_grp [aw=wtfinl], r cl(strata)
	
	lincom _cons
	local val1 = r(estimate)
	local val_se1 = r(se)
	insert_into_file using selection_ests.csv, key(val1) value(`val1')
	insert_into_file using selection_ests.csv, key(se1) value(`val_se1')
	
	summ change_occ if change_occ_grp == 0 [aw=wtfinl]
	local N = r(N)
	insert_into_file using selection_ests.csv, key(N1) value(`N') format(%12.0fc)
	
	lincom _cons+1.change_occ_grp
	local val2 = r(estimate)
	local val_se2 = r(se)
	insert_into_file using selection_ests.csv, key(val2) value(`val2')
	insert_into_file using selection_ests.csv, key(se2) value(`val_se2')
	
	summ change_occ if change_occ_grp == 1 [aw=wtfinl]
	local N = r(N)
	insert_into_file using selection_ests.csv, key(N2) value(`N') format(%12.0fc)

	lincom _cons+2.change_occ_grp
	local val3 = r(estimate)
	local val_se3 = r(se)
	insert_into_file using selection_ests.csv, key(val3) value(`val3')
	insert_into_file using selection_ests.csv, key(se3) value(`val_se3')
	
	summ change_occ if change_occ_grp == 2 [aw=wtfinl]
	local N = r(N)
	insert_into_file using selection_ests.csv, key(N3) value(`N') format(%12.0fc)
	
	lincom _cons+3.change_occ_grp
	local val4 = r(estimate)
	local val_se4 = r(se)
	insert_into_file using selection_ests.csv, key(val4) value(`val4')
	insert_into_file using selection_ests.csv, key(se4) value(`val_se4')
	
	summ change_occ if change_occ_grp == 3 [aw=wtfinl]
	local N = r(N)
	insert_into_file using selection_ests.csv, key(N4) value(`N') format(%12.0fc)
	
	lincom 3.change_occ_grp
	local pval = r(p)
	insert_into_file using selection_ests.csv, key(pval_test0) value(`pval')

*** Analysis by quartile

	** Wage
	
	gen interaction2 = license_sh*public_sh
		
		* Estimates by quartile
		forvalues i = 0/3 {
			reghdfe lnwage license_sh public_sh interaction2 union_sh otherc_sh if change_occ_grp == `i' [aw=earnwt], a(strata statefip occ ind my) cl(state_occ)
			outreg2 using occ_quartile_sh.doc, append ctitle(`i')

		}
		
		* Test that estimates for Q1 and Q4 are the same
		reghdfe lnwage change_occ_grp#license change_occ_grp#public i.change_occ_grp#interaction i.change_occ_grp#unioncat i.change_occ_grp#other_cert [aw=earnwt], a(change_occ_grp#strata change_occ_grp#statefip change_occ_grp#occ change_occ_grp#ind change_occ_grp#my) cl(state_occ)
		test 0.change_occ_grp#1.interaction == 3.change_occ_grp#0.interaction
		local pval_1 = r(p)
		insert_into_file using selection_ests.csv, key(pval_1) value(`pval_1')
		
	** Hour

		forvalues i = 0/3 {
			reghdfe ln_hour license_sh public_sh interaction2 union_sh otherc_sh if change_occ_grp == `i' [aw=earnwt], a(strata statefip occ ind my) cl(state_occ)
			outreg2 using occ_quartile_hour_sh.doc, append ctitle(`i')
		}


	* Test that estimates for Q1 and Q4 are the same
preserve 

gen ln_hour=ln(uhrswork1)
drop if ln_hour == .

		reghdfe ln_hour change_occ_grp#license change_occ_grp#public i.change_occ_grp#interaction i.change_occ_grp#unioncat i.change_occ_grp#other_cert [aw=earnwt], a(change_occ_grp#strata change_occ_grp#statefip change_occ_grp#occ change_occ_grp#ind change_occ_grp#my) cl(state_occ)
		test -0.change_occ_grp#1.interaction == 3.change_occ_grp#0.interaction
		
restore
