*Data Cleaning SIPP
clear
set more off
cap log close
cd "/Users/wenchenwang/Desktop/Dissertation/Public_Updated_data/revision/CPS1/robustness/sipp/new data"

foreach v in 2015 2016 2018 2019 2020 2021 2022 {

*Append different waves and years of data
use pu`v'.dta
gen year = `v'

foreach var of varlist *{
     rename `var' `=lower("`var'")'
}

*Cleaning

sort ssuid shhadid pnum
egen sippid = concat(ssuid pnum)

drop if wpfinwgt == .

*Montly state residence drop foreign
destring tehc_st, replace
gen tfipsst = tehc_st
drop if tfipsst > 56

*Dempgraphic characteristics 
tab esex, gen(sexcat)
rename sexcat1 male
rename sexcat2 female

tab erace, gen(racecat)
rename racecat1 white
rename racecat2 black
rename racecat3 asian
rename racecat4 other_race

tab eorigin, gen(hispaniccat)
rename hispaniccat1 hispanic
rename hispaniccat2 nonhispanic

gen age = tage
gen age2 = age^2
drop if age <16
drop if age >64

tab ems
tab ems, nolabel
gen married = 0
replace married = 1 if ems < 3

tab eeduc

gen LessthanHS = 0
replace LessthanHS = 1 if eeduc < 39

gen HSgrad = 0 
replace HSgrad = 1 if eeduc== 39

gen SomeCol = 0 
replace SomeCol = 1 if eeduc== 40 | eeduc== 41

gen AssoDeg = 0 
replace AssoDeg = 1 if eeduc== 42

gen Bachelor = 0 
replace Bachelor = 1 if eeduc== 43

gen Graduate = 0 
replace Graduate = 1 if eeduc > =44

tab ecitizen, gen(citizencat)
rename citizencat1 citizen
rename citizencat2 noncitizen

/*Not directly veteran status and have many missing values*/
tab evaany, gen(vetbenefit)
rename vetbenefit1 vetbene
rename vetbenefit2 nonvetebene

tab tehc_metro, gen(metrocat)
rename metrocat1 metro
rename metrocat2 nonmetro
replace metrocat3 = . if metrocat3 == 1

*Number of Children do not have

*month-year indicator
gen my = year*12 + monthcode

/* create variable "educomp" to indicate the number of years of completed schooling. */
	
	gen educomp = 0
	replace educomp = 4 if eeduc <=32
	replace educomp = 6 if eeduc == 33
	replace educomp = 8 if eeduc == 34
	replace educomp = 9 if eeduc == 35
	replace educomp = 10 if eeduc == 36
	replace educomp = 11 if eeduc == 37|38
	replace educomp = 12 if eeduc == 39
	replace educomp = 13 if eeduc == 40
	replace educomp = 14 if eeduc == 41
	replace educomp = 15 if eeduc == 42
	replace educomp = 16 if eeduc == 43
	replace educomp = 18 if educ == 44
	replace educomp = 20 if eeduc == 45
	replace educomp = 22 if eeduc == 46
	
/* create variable "exp" to indicate the number of years of experience*/

	gen exp=max(age-educomp-6,0)
	gen exp2 = exp^2
	
	drop educomp

*Generate licensing indicator

tab eprocert

tab ewhocert1 //Starting wave 2014 no jobert variable

*Map SIPP indicator to CPS indicator
  
	*Q1: profcert
	gen profcert = . 
	replace profcert = 1 if eprocert == 1
	replace profcert = 0 if eprocert == 2
	
	*Q2: statecert
	gen statecert = .
	replace statecert = 1 if ewhocert1 == 1
	replace statecert = 0 if ewhocert1 == 2

*Enforce logical statements

	*An individual cannot hold a state-issued license/certification (Q2) if they do not hold any license/certification (Q1)
	replace statecert = 0 if profcert == 0
	
	*licensing variable
	gen license = 0
	replace license = 1 if profcert == 1 & statecert == 1
	
	* Code other certification variable
	gen othercert = (profcert == 1)
	replace othercert = 0 if statecert == 1

	
*Drop unemployed observations

tab rmesr
tab rmesr, nolabel
gen unemployed = 0 
replace unemployed = 1 if rmesr > 5
drop if unemployed == 1

/*Drop self-employed workers and people who are in the armed forces & unpaid family workers*/

gen classwork = ejb1_clwrk

drop if classwork > 6 | classwork == 2

destring tnj_occ, replace

drop if tnj_occ != .

*Sector
gen public = .
replace public = 1 if classwork <= 4
replace public = 0 if classwork > 4

*Union
tab ejb1_union
gen union = 1
replace union = 0 if ejb1_union == 2

*Hours worked: likely job 1 is the main job based on the summary for weekly hours worked
sum tjb1_mwkhrs
gen uhrswork1 = tjb1_mwkhrs

*Hourly pay
gen hourly = .
replace hourly = ejb1_payhr1 == 2
replace hourly = ejb1_payhr2 == 2 if hourly == .
replace hourly = ejb1_payhr3 == 2 if hourly == .

gen hourwage = .
replace hourwage = tjb1_hourly1
replace hourwage = tjb1_hourly2 if hourwage == .
replace hourwage = tjb1_hourly3 if hourwage == .

*Impute hourly wages for workers not paid hourly
replace hourwage = tjb1_msum/(uhrswork1*4) if hourwage == . 

*For imputed wage: Need to contact help to find values flag values

gen lnwage = log(hourwage)
gen lnhour = log(uhrswork1)

*state-occ cells
gen occ = tjb1_occ
egen state_occ = group (tfipsst occ)

*Industry
gen ind = tjb1_ind


keep swave spanel sippid year monthcode tfipsst male female white black asian other_race hispanic nonhispanic age age2 married LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate citizen noncitizen vetbene nonvetebene metro nonmetro metrocat3 my exp exp2 profcert statecert license othercert unemployed classwork public union uhrswork1 hourly hourwage lnwage lnhour occ state_occ ind wpfinwgt

save `v'_cleaned.dta, replace


}

*Append
clear

use 2015_cleaned.dta
append using 2016_cleaned 2018_cleaned 2019_cleaned 2020_cleaned 2022_cleaned

save sipp_all.dta, replace
