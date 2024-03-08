
* Load data

	cd "/Users/wenchenwang/Desktop/Paper_Updated_data/4. shares"
	
	use regression_with_all_sh.dta, clear

	set more off

* Totals for licensed
	

	* Licensed
	bys state_occ: egen sum_unionc = sum(unioncat)
	bys state_occ: egen obs_unionc = count(unioncat)

* Collapse

	keep sum_* obs_* wtfinl statefip occ state_occ
	collapse (first) sum_* obs_* (sum) wtfinl, by(statef occ state_occ)
	
	gen sh_unionc = sum_unionc/obs_unionc
	
	egen occ_n = group(occ)
	
* For-loops
	
	* Licensed
	
	quietly summ occ_n
	local max = r(max)
	
	file open TABLES using "betabin_results_unionc.txt", write replace
	file write TABLES "occ, a_unionc, b_unionc" _n
	
	forvalues i = 1/`max' {

			// di `i' " of " `max'
			
			quietly summ sh_unionc if occ_n == `i' [aw=obs_unionc]
			local test = r(mean)
			if `test' != 0 {
					
				quietly summ sh_unionc if occ_n == `i' [aw=obs_unionc]
				local mean = r(mean)
				local variance = r(Var)
				local a = ((`mean')^2-(`mean')^3-`mean'*`variance')/`variance' // from betafit.ado
			
				local b = `a'/`mean'-`a'	
				local a3 : di %5.3f `a'
				local b3 : di %5.3f `b'
				
				quietly summ occ if occ_n == `i'
				local occ = r(mean)
				
				quietly file write TABLES ("`occ', `a3', `b3'") _n
				// betaprior, mean(`mean') var(`variance')
			
			}
	}

	quietly copy "betabin_results_unionc.txt" "betabin_results_unionc.csv", replace
	file close TABLES
	
	* Create main treatment variable

	* Step 1: Create leave out mean cell shares for licensed, other certification, and unionization
	
	clear
	use regression_with_all_sh

	
		* Licensed share
		egen n_obs_unionc = count(unioncat), by(state_occ)
		bys state_occ: egen ct_unionc = sum(unioncat) if n_obs_unionc > 1
		gen lo_mean_unionc = ct_unionc - unioncat if n_obs_unionc > 1
		replace lo_mean_unionc = lo_mean_unionc/(n_obs_unionc-1) if n_obs_unionc > 1
		
	* Step 2: Use beta-binomial results to adjust licensed shares
	
		* Load beta-binomial results
		
		preserve 
		
		import delimited "/Users/wenchenwang/Desktop/Paper_Updated_data/4. shares/betabin_results_unionc.csv", encoding(ISO-8859-1) clear
		save tmp3
			
		restore
		merge m:1 occ using tmp3, nogen
		
		gen unionc = unioncat
		
		* Replace missing or out-of-domain empirical Bayes prior w/ uninformative ones

			foreach v of varlist a_* b_* {
				replace `v' = 1 if `v' < 0 | missing(`v')
			}

		* Adjust values
		
			foreach v in unionc {
			
				gen ct_`v'_lo = ct_`v' - `v' if n_obs_`v' > 1
				gen n_obs_`v'_lo = n_obs_`v' - 1 if n_obs_`v' > 1

				gen a_`v'_new = a_`v' + ct_`v'_lo
				gen b_`v'_new = b_`v' + n_obs_`v'_lo - ct_`v'_lo
				gen sh_`v' = a_`v'_new / (a_`v'_new + b_`v'_new)
				
				gen sd_cme_`v' = sqrt(a_`v'_new * b_`v'_new/((a_`v'_new + b_`v'_new)^2 * (a_`v'_new + b_`v'_new + 1)))
				drop ct_`v' ct_`v'_lo n_obs_`v' n_obs_`v'_lo a_`v' b_`v' a_`v'_new b_`v'_new 
			
			}
		
		
		rename sh_unionc union_sh
		
		save regression_with_all_sh_3
