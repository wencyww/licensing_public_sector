* Load data

	clear

	cd "/Users/wenchenwang/Desktop/Dissertation/Public_Updated_data/revision"
	
	use revision_updated.dta
	
	set more off
	set matsize 4000
	
* Reshape data

	keep lemp occ statef
	duplicates drop
	
	fillin occ statef
	gen emp = exp(lemp)
	
	bys statef: egen tot_emp = sum(emp)
	
	gen s_emp = emp/tot_emp
	drop tot_emp emp lemp
	replace s_emp = 0 if s_emp == .
	
	drop if occ == .
	drop _fillin

	reshape wide s_emp, i(state) j(occ)
	
* Run PCA 

	egen st = group(state)
	
	foreach v of varlist s_emp* {
		gen p_`v' = .
	}
	
	tempfile tmp
	save `tmp', replace
	
	forvalues s = 1/51 {
		
		foreach v of varlist s_emp* {
		
			di "State: `s', Industry: `v'"
			
			quietly save `tmp', replace
			quietly drop `v'
		
			quietly pca s_emp* if st != `s'
			quietly predict pc1 pc2 pc3 pc4 pc5, score
			
			quietly keep st pc1 pc2 pc3 pc4 pc5
			quietly merge 1:1 st using `tmp', nogen
		
			quietly reg `v' pc1 pc2 pc3 pc4 pc5 if st != `s'
			quietly predict p__`v', xb
			
			quietly replace p_`v' = p__`v' if st == `s'
			quietly drop p__`v'
			
			quietly drop pc1 pc2 pc3 pc4 pc5
			
		}
		
		
	}
	
	reshape long s_emp p_s_emp, i(st state) j(occ)
	
	drop st
	
	save lpred_ld.dta, replace
