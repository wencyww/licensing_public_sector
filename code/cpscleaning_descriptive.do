/********CPS Data Cleaning Program***********/

clear
cap log close
cd "/Users/wenchenwang/Desktop/Dissertation/Public_Updated_data/revision/CPS1/data_cleaning/updated"
use working_cps1_new.dta


********General Labor and Sample related**************

 /* keep age 16-64 wage and salary workers who had job wk before survey. */

   keep if age>=16 & age<=64
   gen age2 = age^2

 /*Drop self-employed workers and people who are in the armed forces and people who are unmpaid family workers*/
	
	drop if classwkr < 22
	drop if classwkr == 26
	drop if classwkr == 29
	

	* Keep employed workers
	keep if empstat == 10 | empstat == 12

	
* Merge in Census division codes

	gen sfips = statefip
	merge m:1 sfips using census_division_to_state_xwalk.dta, nogen
	drop sfips _merge

	
 /* create region. */
	
	gen northeast=0
	replace northeast = 1 if region == 11
	replace northeast= 1 if region == 12


	gen midwest=0
	replace midwest = 1 if region == 21
	replace midwest = 1 if region == 22

	
	gen south=0
	replace south = 1 if region == 31
	replace south = 1 if region == 32
	replace south = 1 if region == 33
	
	gen west=0
	replace west = 1 if region == 41
	replace west = 1 if region == 42
	
/* create educational category*/
	
	tab educ
	tab educ, nolabel

	gen LessthanHS = 0
	replace LessthanHS = 1 if educ < 73

	gen HSgrad = 0 
	replace HSgrad = 1 if educ == 73

	gen SomeCol = 0
	replace SomeCol = 1 if educ == 81

	gen AssoDeg = 0
	replace AssoDeg = 1 if educ == 91 | educ == 92

	gen Bachelor = 0 
	replace Bachelor = 1 if educ == 111

	gen Graduate = 0 
	replace Graduate = 1 if educ > 111

/* create racial category*/

	*main race
	gen white = 0
	replace white = 1 if race == 100

	gen black = 0
	replace black = 1 if race == 200 | race == 801

	gen asian = 0
	replace asian = 1 if race == 651| race == 803 | race 	== 806 | race == 808 | race == 801 | race == 811 | 		race == 812 | race == 814 | race == 818
	
	*hispanic status
	gen Hispanic = 1
	replace Hispanic = 0 if hispan == 0 

/*create sector category*/
	
	gen private = 0
	replace private = 1 if classwkr == 22 | classwkr == 23

	gen public = 0
	replace public = 1 if classwkr == 25 | classwkr == 27 	|classwkr == 28

/* other categorical variables*/

	*marital status
	gen married = 0
	replace married = 1 if marst < 3
	
	*citizenship
	gen citizencat = 1
	replace citizencat = 0 if citizen == 5
	
	*veteran status
	gen veteran = 1
	replace veteran = 0 if vetstat == 1

	*union status
	gen unioncat = 1
	replace unioncat = 0 if union == 1
	
	*metro status: lives in MSA
	gen metrostat = 0
	replace metrostat = 1 if metro == 2 | 3

	
/* create variable "female" equals one if the individual is female, zero otherwise. */

	gen female = 0 
	replace female = 1 if sex == 2

/* create variable "educomp" to indicate the number of years of completed schooling. */
	
	gen educomp = 0
	replace educomp = 4 if educ == 10
	replace educomp = 6 if educ == 20
	replace educomp = 8 if educ == 30
	replace educomp = 9 if educ == 40
	replace educomp = 10 if educ == 50
	replace educomp = 11 if educ == 60|71
	replace educomp = 12 if educ == 73
	replace educomp = 13 if educ == 81
	replace educomp = 14 if educ == 91
	replace educomp = 15 if educ == 92
	replace educomp = 16 if educ == 111
	replace educomp = 18 if educ == 123
	replace educomp = 20 if educ == 124
	replace educomp = 22 if educ == 125

/* create variable "exp" to indicate the number of years of experience*/

	gen exp=max(age-educomp-6,0)
	gen exp2 = exp^2
	
	drop educomp
	
/* create variable to indicate fulltime workers*/

	gen ft_worker=0
	replace ft_worker=1 if wkstat == 11
	replace ft_worker=1 if wkstat == 13
	replace ft_worker=1 if wkstat ==14
	replace ft_worker=1 if wkstat ==15
	label var ft_worker "Full-time Worker"
	tab ft_worker , miss

/* create variable to indicate fullyear workers: 40-52 weeks*/
/*No wkswork1 and wkswork2*/

	gen byte fullyear= wksworkorg>=40 & wksworkorg<=52
	label variable fullyear "worked 40 to 52 weeks usually"
	
/* create new employment weights. */
	drop if wtfinl == .
	gen wtrd=round(wtfinl,1)
	label variable wtrd "personal weight, rounded to nearest integer"
	
	/*gen wgt_wks=wtfinl*wksworkorg
	gen wgt_hrs=wgt*wksworkorg*uhrsworkorg
	gen wgt_hrs_ft=wgt*uhrsworkorg*/
	
  /* Redo earning's weights.  According to Unicon:
   When the Outgoing Rotation files are produced, two rotations are extracted from each of the 
   twelve months and gathered into a single annual file. The weights on the file must be modified 
   by the user before they will give reliable counts. Since the final weight is gathered from 12 
   months but only 2/8 rotations, the weight on the outgoing file should be divided by 3 (12/4) 
   before it is applied. The earner weight is gathered from 12 months from the 2 rotations. Since 
   those two rotations were originally weighted to give a full sample, the earner weight must be 
   divided by 12, not 3. 
    */
	
	replace earnwt = earnwt/12
	
	drop if earnwt==.
   gen earnwtrd=round(earnwt,1)
   label variable earnwtrd "earnings weight, rounded to nearest integer"
   
/*create total hours worked variable for employment

	gen totHour = uhrsworkorg*wksworkorg*/
			

/* Top codes and restrictions */
	
	** We flag those who are earning more than the current earnings top coded times 1.5 divided by 35 hours/week
	
	**From IPUMS: For the years 2003 forward, for usual hours worked <29, the topcode is $99.99, and for usual hours worked 29+, the topcode is $2884.61/(usual hours worked)
	
		
	**Make indicators for hourly worker
	gen byte hourlyworker=0
	replace hourlyworker=1 if paidhour==2
	
*Start from here re-run

/* Recode all of the hour variables to be topcoded at 99*/
foreach v of varlist uhrs* {
		replace `v' = ahrswork1 if `v' == 997 | `v' == 998
	}
foreach v of varlist uhrs* {
		replace `v' = . if `v' == 999
	}
foreach v of varlist ahrs* {
		replace `v' = . if `v' == 999
	}	

	replace uhrsworkorg =99 if uhrsworkorg >=99 & uhrsworkorg <.
	
	replace uhrsworkt =99 if uhrsworkt >=99 & uhrsworkt <.
	
	replace uhrswork1 =99 if uhrswork1 >=99 & uhrswork1 <.
	
	replace uhrswork2 =99 if uhrswork1 >=99 & uhrswork1 <.
	
	replace ahrsworkt =99 if ahrsworkt >=99 & ahrsworkt <.
	
	replace ahrswork1 =99 if ahrswork1 >=99 & ahrswork1 <.
	
	replace ahrswork2 =99 if ahrswork2 >=99 & ahrswork1 <.
	
*Drop wages, earnings for individuals w/ allocated earnings
	replace hourwage = . if qearnwee == 4
	replace earnweek = . if qearnwee == 4
	
* Fix NIUs for hourwage
	replace hourwage = . if hourwage == 999.99
	replace earnweek = . if earnweek == 9999.99
	
	*Make an hourly wage for everyone
	gen hr_wage = earnweek/uhrswork1
	
	** We must 'windsorize' hourly wages that are based on top coded earnings
	
	replace earnweek=(earnweek*1.5) if earnweek>=2884.61
	
	* Winsorize wages of workers at the topcoded weekly earnings / 35
	replace hr_wage = (earnweek*1.5)/35 if earnweek>=2884.61 

	
	* We now allow hourly workers to use their hourly rate of pay
	replace hr_wage=hourwage if hourlyworker==1 & hourwage!=.

	* Drop people with wages below half the federal minimum wage
	replace hr_wage = . if hr_wage < .5*7.25

	sum hr_wage

	gen lnwage=ln(hr_wage)
	gen lhours = ln(uhrswork1)

/*Exclude people with computed hourly wages in the top 1% and bottom 1% of the sample
	
	centile hourwage, centile(1 99)
	drop if hourwage>r(c_2) | hourwage<r(c_1)*/


	*Deal with allocation flag???
	
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
	
	gen real_hrwage = hr_wage * cpiadjfactor
	gen real_earnweek = earnweek * cpiadjfactor
	label variable real_hrwage "Real Hourly Wage"
	label variable real_earnweek "Real Weekly Earnings"
	
	*Add nchild

	merge m:m cpsidp using nchild_covid.dta, keep(1 3)


	* Has children at home
	gen children = nchild > 0
	replace children = . if nchild ==.

	* Universally licensed indicator
	merge m:1 occ using ground_truth_statecert.dta, nogen keep (1 3)
	drop occ_name

	* Create sample definition
	gen sample = 1
	replace sample = 0 if gt == 1


/*Generate Strata*/

egen agecat = cut(age), group(10)
egen expcat = cut (exp), group(10

egen strata = group(agecat expcat children female black asian Hispanic white LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate married citizencat veteran metrostat)

*Baseline: Individual Licensing indicator

gen my = year*12 + month



*Enforce logical statements
		
		* An individual cannot hold a state-issued license/certification (Q2) if they do not hold any license/certification (Q1)
		replace statecert = 1 if profcert == 1 

		* A certification cannot be required for ones job if they do not hold a professional certification
		replace jobcert = 1 if profcert == 1
	
		* An individual cannot hold an "occupational license" if the state-issued license/certification is not mandatory.
		replace statecert = 1 if jobcert == 1 

	* Recode cert variables to 0/1

		foreach v of varlist profcert jobcert statecert { 
			gen `v'_ = (`v' == 2)
			drop `v'
			rename `v'_ `v'
		}
		
	*Create licensing variables
	gen license=0
	replace license = 1 if profcert== 1 & statecert == 1
	
	* Code other certification variable
	gen othercert = (profcert == 1)
	replace othercert = 0 if statecert == 1
		
	
	* State-occ cells
	egen state_occ = group(statefip occ)
		
	
/*Check for missing data*/

foreach v in license othercert public white black Hispanic asian age exp female LessthanHS HSgrad SomeCol AssoDeg Bachelor Graduate married unioncat veteran citizencat metrostat northeast midwest south west nchild lnwage lhours{
	drop if `v' == .
}

/*Occupational Categories*/
tab occ2010

/*useful package from website https://blog.stata.com/2018/06/07/export-tabulation-results-to-excel-update/

net install http://www.stata.com/users/kcrow/tab2xl, replace

tab2xl occ2010 using testfile, col(1) row(1)
tab2xl occ2010 using testfile2, nolabel col(1) row(1)*/


*Count Categories*/
qui tab occ2010

ret li
*create occupational groups based on https://cps.ipums.org/cps-action/variables/OCC2010#description_section

gen occ_cat=0

*1. Management in Business, Science, and Arts 
replace occ_cat=1 if occ2010 >0 & occ2010 <= 430
*2. Bussiness Operations and Financial Specialists
replace occ_cat=2 if occ2010 >=500 & occ2010 <=950
*3. Computer and Mathematical 
replace occ_cat=3 if occ2010>=1000 & occ2010 <=1240
*4. Architecture and Engineering
replace occ_cat=4 if occ2010>=1300 & occ2010 <=1540
*5. Technicians
replace occ_cat=5 if occ2010>=1550 & occ2010 <=1560
*6. Life, Physical, and Social Science
replace occ_cat=6 if occ2010>=1600 & occ2010 <=1980
*7. Community and Social Services
replace occ_cat=7 if occ2010>=2000 & occ2010 <=2060
*8. Legal
replace occ_cat=8 if occ2010>=2100 & occ2010 <=2150
*9. Education, Training, and Library
replace occ_cat=9 if occ2010>=2200 & occ2010 <=2550
*10. Arts, Design, Entertainment, Sports, and Media
replace occ_cat=10 if occ2010>=2600 & occ2010 <=2920
*11. Healthcare Practitioners, Technicians and Support
replace occ_cat=11 if occ2010>=3000 & occ2010 <=3650
*12. Protective Service
replace occ_cat=12 if occ2010>=3700 & occ2010 <=3950
*13. Food Preparation and Serving
replace occ_cat=13 if occ2010>=4000 & occ2010 <=4150
*14. Building and Grounds Cleaning and Maintenance
replace occ_cat=14 if occ2010>=4200 & occ2010 <=4250
*15. Personal Care and Service
replace occ_cat=15 if occ2010>=4300 & occ2010 <=4650
*16. Sales and Related 
replace occ_cat=16 if occ2010>=4700 & occ2010 <=4965
*17. Office and Administrative Support
replace occ_cat=17 if occ2010>=5000 & occ2010 <=5940
*18. Farming, Fisheries, and Forestry
replace occ_cat=18 if occ2010>=6005 & occ2010 <=6130
*19. Construction and Extraction
replace occ_cat=19 if occ2010>=6200 & occ2010 <=6940
*20. Installation, Maintenance, and Repair
replace occ_cat=20 if occ2010>=7000 & occ2010 <=7630
*21. Production
replace occ_cat=21 if occ2010>=7700 & occ2010 <=8965
*22. Transportation and Material Moving
replace occ_cat=22 if occ2010>=9000 & occ2010 <=9750

tab occ_cat

/*Kleiner and Soltas additional variables*/

	* Race (non-Hispanic white, non-Hispanic black, Hispanic, other)
	gen race_recode = .
	replace race_recode = 0 if race == 100
	replace race_recode = 1 if race == 200
	replace race_recode = 2 if race == 651
	replace race_recode = 3 if race != 100 & race != 200 & race != 651 & race !=.

	* Hispanic
	gen hisp_recode = hispan == 0
	replace hisp_recode = . if hispan ==.
	
	* Map from education categories to years of education 
	* Estimates from Park (EL 2004), "Estimation of sheepskin effects using the old and the new measures of educational attainment in the Current Population Survey"

		* Men, white
		gen edyears =  0
		replace edyears = .32  if (race_recode==0 & sex==1 & educ == 0)
		replace edyears = 3.19 if (race_recode==0 & sex==1 & educ == 10)
		replace edyears = 7.24 if (race_recode==0 & sex==1 & (educ == 20 | educ == 30))
		replace edyears = 8.97 if (race_recode==0 & sex==1 & educ == 40)
		replace edyears = 9.92 if (race_recode==0 & sex==1 & educ == 50)
		replace edyears = 10.86 if (race_recode==0 & sex==1 & educ == 60)
		replace edyears = 11.58 if (race_recode==0 & sex==1 & educ == 71)
		replace edyears = 11.99 if (race_recode==0 & sex==1 & educ == 73)
		replace edyears = 13.48 if (race_recode==0 & sex==1 & educ == 81)
		replace edyears = 14.23 if (race_recode==0 & sex==1 & (educ == 91 | educ == 92))
		replace edyears = 16.17 if (race_recode==0 & sex==1 & educ == 111)
		replace edyears = 17.68 if (race_recode==0 & sex==1 & educ == 123)
		replace edyears = 17.71 if (race_recode==0 & sex==1 & educ == 124)
		replace edyears = 17.83 if (race_recode==0 & sex==1 & educ == 125)

		* Female, white
		replace edyears = 0.62 if (race_recode==0 & sex==2 & educ == 0)
		replace edyears = 3.15 if (race_recode==0 & sex==2 & educ == 10)
		replace edyears = 7.23 if (race_recode==0 & sex==2 & (educ == 20 | educ == 30))
		replace edyears = 8.99 if (race_recode==0 & sex==2 & educ == 40)
		replace edyears = 9.95 if (race_recode==0 & sex==2 & educ == 50)
		replace edyears = 10.87 if (race_recode==0 & sex==2 & educ == 60)
		replace edyears = 11.73 if (race_recode==0 & sex==2 & educ == 71)
		replace edyears = 12.00 if (race_recode==0 & sex==2 & educ == 73)
		replace edyears = 13.35 if (race_recode==0 & sex==2 & educ == 81)
		replace edyears = 14.22 if (race_recode==0 & sex==2 & (educ == 91 | educ == 92))
		replace edyears = 16.15 if (race_recode==0 & sex==2 & educ == 111)
		replace edyears = 17.64 if (race_recode==0 & sex==2 & educ == 123)
		replace edyears = 17.00 if (race_recode==0 & sex==2 & educ == 124)
		replace edyears = 17.76 if (race_recode==0 & sex==2 & educ == 125)

		* Men, black
		replace edyears = .92  if (race_recode==1 & sex==1 & educ == 0)
		replace edyears = 3.28 if (race_recode==1 & sex==1 & educ == 10)
		replace edyears = 7.04 if (race_recode==1 & sex==1 & (educ == 20 | educ == 30))
		replace edyears = 9.02 if (race_recode==1 & sex==1 & educ == 40)
		replace edyears = 9.91 if (race_recode==1 & sex==1 & educ == 50)
		replace edyears = 10.90 if (race_recode==1 & sex==1 & educ == 60)
		replace edyears = 11.41 if (race_recode==1 & sex==1 & educ == 71)
		replace edyears = 11.98 if (race_recode==1 & sex==1 & educ == 73)
		replace edyears = 13.57 if (race_recode==1 & sex==1 & educ == 81)
		replace edyears = 14.33 if (race_recode==1 & sex==1 & (educ == 91 | educ == 92))
		replace edyears = 16.13 if (race_recode==1 & sex==1 & educ == 111)
		replace edyears = 17.51 if (race_recode==1 & sex==1 & educ == 123)
		replace edyears = 17.83 if (race_recode==1 & sex==1 & educ == 124)
		replace edyears = 18.00 if (race_recode==1 & sex==1 & educ == 125)

		* Female, black
		replace edyears = 0.00 if (race_recode==1 & sex==2 & educ == 0)
		replace edyears = 2.90 if (race_recode==1 & sex==2 & educ == 10)
		replace edyears = 7.03 if (race_recode==1 & sex==2 & (educ == 20 | educ == 30))
		replace edyears = 9.05 if (race_recode==1 & sex==2 & educ == 40)
		replace edyears = 9.99 if (race_recode==1 & sex==2 & educ == 50)
		replace edyears = 10.85 if (race_recode==1 & sex==2 & educ == 60)
		replace edyears = 11.64 if (race_recode==1 & sex==2 & educ == 71)
		replace edyears = 12.00 if (race_recode==1 & sex==2 & educ == 73)
		replace edyears = 13.43 if (race_recode==1 & sex==2 & educ == 81)
		replace edyears = 14.33 if (race_recode==1 & sex==2 & (educ == 91 | educ == 92))
		replace edyears = 16.04 if (race_recode==1 & sex==2 & educ == 111)
		replace edyears = 17.69 if (race_recode==1 & sex==2 & educ == 123)
		replace edyears = 17.40 if (race_recode==1 & sex==2 & educ == 124)
		replace edyears = 18.00 if (race_recode==1 & sex==2 & educ == 125)

		* Men, other
		replace edyears = .62  if ((race_recode==2 | race_recode==3) & sex==1 & educ == 0)
		replace edyears = 3.24 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 10)
		replace edyears = 7.14 if ((race_recode==2 | race_recode==3) & sex==1 & (educ == 20 | educ == 30))
		replace edyears = 9.00 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 40)
		replace edyears = 9.92 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 50)
		replace edyears = 10.88 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 60)
		replace edyears = 11.50 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 71)
		replace edyears = 11.99 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 73)
		replace edyears = 13.53 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 81)
		replace edyears = 14.28 if ((race_recode==2 | race_recode==3) & sex==1 & (educ == 91 | educ == 92))
		replace edyears = 16.15 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 111)
		replace edyears = 17.60 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 123)
		replace edyears = 17.77 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 124)
		replace edyears = 17.92 if ((race_recode==2 | race_recode==3) & sex==1 & educ == 125)

		* Female, other
		replace edyears = 0.31 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 0)
		replace edyears = 3.03 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 10)
		replace edyears = 7.13 if ((race_recode==2 | race_recode==3) & sex==2 & (educ == 20 | educ == 30))
		replace edyears = 9.02 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 40)
		replace edyears = 9.97 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 50)
		replace edyears = 10.86 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 60)
		replace edyears = 11.69 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 71)
		replace edyears = 12.00 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 73)
		replace edyears = 13.47 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 81)
		replace edyears = 14.28 if ((race_recode==2 | race_recode==3) & sex==2 & (educ == 91 | educ == 92))
		replace edyears = 16.10 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 111)
		replace edyears = 17.67 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 123)
		replace edyears = 17.20 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 124)
		replace edyears = 17.88 if ((race_recode==2 | race_recode==3) & sex==2 & educ == 125)
		


save regression_newest.dta, replace
