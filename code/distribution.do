*Wage Distribution

*****Kernel Density Decomposition
*Overall Sector Density
preserve
drop if lnwage<1
drop if lnwage > 5
kdensity lnwage if public==0, gen(evalm1 densm1) width(0.10) nograph
kdensity lnwage if public==1, gen(evalf1 densf1) width(0.10) nograph

graph twoway (histogram lnwage if public==1, bin(50) lcolor(erose) fi(inten80)) (connected densf1 evalf1, m(i) lp(dash) lw(medium) lc(red)) (histogram lnwage if public==0, bin(50) lcolor(blue) fcolor(none)) (connected densm1 evalm1, m(i) lp(longdash) lw(medium) lc(blue)),ytitle("Density") ylabel(0.0 0.2 0.4 0.6 0.8) xlabel(1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0) xtitle("Log(wage)") legend(ring(0) pos(2) col(1) lab(1 "Public") lab(2 " ") lab(3 "Private") lab(4 " ") region(lstyle(none)) symxsize(8) keygap(1) textwidth(25)) saving(nlsy00_dens,replace)
restore

pctile evalf2=lnwage if a_w==1 , nq(100) 
pctile evalm2=lnwage if a_w==0 , nq(100)
gen qdiff=evalm2-evalf2 if _n<100
gen qtau=_n/100 if _n<100

graph twoway (line qdiff qtau if qtau>0.0 & qtau<1.0, connect(l) m(i) lw(medium) lc(black) ) , yline(-.0553384, lpattern(solid) lcolor(red)) yline(.0117498 -.1224266, lpattern(dash) lcolor(erose)) xlabel(0.0 0.2 0.4 0.6 0.8 1.0) ylabel(0.0 0.2 0.4 0.6 0.8) xtitle("Quantile") ytitle("Log Wage Differential") saving(nlsy00_qplot,replace)

*Overall Licensing Density
preserve
drop if lnwage<1
drop if lnwage > 5
kdensity lnwage if license==0, gen(evalm1 densm1) width(0.10) nograph
kdensity lnwage if license==1, gen(evalf1 densf1) width(0.10) nograph

graph twoway (histogram lnwage if license==1, bin(50) lcolor(erose) fi(inten80)) (connected densf1 evalf1, m(i) lp(dash) lw(medium) lc(red)) (histogram lnwage if license==0, bin(50) lcolor(blue) fcolor(none)) (connected densm1 evalm1, m(i) lp(longdash) lw(medium) lc(blue)),ytitle("Density") ylabel(0.0 0.2 0.4 0.6 0.8) xlabel(1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0) xtitle("Log(wage)") legend(ring(0) pos(2) col(1) lab(1 "licensed") lab(2 " ") lab(3 "Unlicensed") lab(4 " ") region(lstyle(none)) symxsize(8) keygap(1) textwidth(25)) saving(nlsy00_dens,replace)
restore

pctile evalf2=lnwage if license==1 , nq(100) 
pctile evalm2=lnwage if license==0 , nq(100)
gen qdiff=evalm2-evalf2 if _n<100
gen qtau=_n/100 if _n<100

graph twoway (line qdiff qtau if qtau>0.0 & qtau<1.0, connect(l) m(i) lw(medium) lc(black) ) , yline( -.2444947, lpattern(solid) lcolor(red)) yline(-.1889195 -.3000699, lpattern(dash) lcolor(erose)) xlabel(0.0 0.2 0.4 0.6 0.8 1.0) ylabel(0.0 0.2 0.4 0.6 0.8)  xtitle("Quantile") ytitle("Log Wage Differential") saving(nlsy00_qplot,replace)

*Begin by the density of licensed log wage of public and private
preserve
drop if license == 0
drop if lnwage<1
drop if lnwage >5


gen hweight = wtfinl*uhrswork1/100 /*hours weighted*/
drop if hweight == 0
drop if hweight == .

quietly sum lnwage, detail
gen xstep=(r(max)-r(min))/200
gen kwage=r(min)+(_n-1)*xstep if _n<=200

kdensity lnwage [aweight=hweight] if public==1, at(kwage) gauss width(0.065) generate(w_A fd_A) nograph
 
kdensity lnwage [aweight=hweight] if public==0 , at(kwage) gauss width(0.065) generate(w_W fd_W) nograph 
	
label var fd_A "Licensed Public"
label var fd_W "Licensed Private"
label var kwage "Log(Wage)"

graph twoway (connected fd_A kwage if kwage>=0 & kwage<=4.5, ms(i) lc(blue)) (connected fd_W kwage if kwage>=0 & kwage<=4.5, ms(i) lc(magenta)), xlabel(.69 1.61 2.3 3.22 4.14) ylabel(0.0 0.2 0.4 0.6 0.8) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)

restore

*Difference
gen diff=fd_W-fd_A if _n<=200

graph twoway (line diff kwage if kwage>=1 & kwage<=4.5, ms(i) lc(blue)), yline(0, lpatter(dash) lcolor(red)) ylabel(0.0 0.2 0.4 0.6 0.8) xlabel(1.61 2.3 3.22 4.14) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)


*Then do the density of unlicensed log wage for Public and Private
preserve

drop if license == 1
drop if lnwage<1
drop if lnwage >5


gen hweight = wtfinl*uhrswork1/100 /*hours weighted*/
drop if hweight == 0
drop if hweight == .

quietly sum lnwage, detail
gen xstep=(r(max)-r(min))/200
gen kwage=r(min)+(_n-1)*xstep if _n<=200

kdensity lnwage [aweight=hweight] if public==1, at(kwage) gauss width(0.065) generate(w_A fd_A) nograph
 
kdensity lnwage [aweight=hweight] if public==0 , at(kwage) gauss width(0.065) generate(w_W fd_W) nograph 
	
label var fd_A "Unlicensed Public"
label var fd_W "Unlicensed Private"
label var kwage "Log(Wage)"

graph twoway (connected fd_A kwage if kwage>=0 & kwage<=4.5, ms(i) lc(blue)) (connected fd_W kwage if kwage>=0 & kwage<=4.5, ms(i) lc(magenta)), xlabel(.69 1.61 2.3 3.22 4.14) ylabel(0.0 0.2 0.4 0.6 0.8) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)

restore
*Difference
gen diff=fd_W-fd_A if _n<=200

graph twoway (line diff kwage if kwage>=1 & kwage<=4.5, ms(i) lc(blue)), yline(0, lpatter(dash) lcolor(red)) ylabel(0.0 0.2 0.4 0.6 0.8) xlabel(1.61 2.3 3.22 4.14) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)

*Density of public sector log wage
preserve
drop if public == 0
drop if lnwage<1
drop if lnwage >5


gen hweight = wtfinl*uhrswork1/100 /*hours weighted*/
drop if hweight == 0
drop if hweight == .

quietly sum lnwage, detail
gen xstep=(r(max)-r(min))/200
gen kwage=r(min)+(_n-1)*xstep if _n<=200

kdensity lnwage [aweight=hweight] if license==1, at(kwage) gauss width(0.065) generate(w_L fd_L) nograph  
 
kdensity lnwage [aweight=hweight] if license==0 , at(kwage) gauss width(0.065) generate(w_U fd_U) nograph 
	
label var fd_L "Public Licensed"
label var fd_U "Public Unlicensed"
label var kwage "Log(Wage)"

graph twoway (connected fd_L kwage if kwage>=0 & kwage<=4.5, ms(i) lc(blue)) (connected fd_U kwage if kwage>=0 & kwage<=4.5, ms(i) lc(magenta)), xlabel(.69 1.61 2.3 3.22 4.14) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)

restore

*Difference
gen diff=fd_U-fd_L if _n<=200

graph twoway (line diff kwage if kwage>=1 & kwage<=4.5, ms(i) lc(blue)), yline(0, lpatter(dash) lcolor(red)) ylabel(0.0 0.2 0.4 0.6 0.8) xlabel(1.61 2.3 2.99 3.68 4.14) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)


*White Sample Density Comparison
preserve
drop if public==1
drop if lnwage<1
drop if lnwage >5


gen hweight = wtfinl*uhrswork1/100 /*hours weighted*/
drop if hweight == 0
drop if hweight == .

quietly sum lnwage, detail
gen xstep=(r(max)-r(min))/200
gen kwage=r(min)+(_n-1)*xstep if _n<=200

kdensity lnwage [aweight=hweight] if license==1, at(kwage) gauss width(0.065) generate(w_L fd_L) nograph
 
kdensity lnwage [aweight=hweight] if license==0 , at(kwage) gauss width(0.065) generate(w_U fd_U) nograph 
	
label var fd_L "Private Licensed"
label var fd_U "Private Unlicensed"
label var kwage "Log(Wage)"

graph twoway (connected fd_L kwage if kwage>=0 & kwage<=4.5, ms(i) lc(blue)) (connected fd_U kwage if kwage>=0 & kwage<=4.5, ms(i) lc(magenta)), xlabel(.69 1.61 2.3 3.22 4.14) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)

restore

*Difference
gen diff=fd_U-fd_L if _n<=200

graph twoway (line diff kwage if kwage>=1 & kwage<=4.5, ms(i) lc(blue)), yline(0, lpatter(dash) lcolor(red)) ylabel(0.0 0.2 0.4 0.6 0.8) xlabel(1.61 2.3 3.22 4.14) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)

*Counterfactual Kernel Density
gen hweight = wtfinl*uhrswork1/100 /*hours weighted*/
drop if hweight == 0
drop if hweight == .

quietly sum lnwage, detail
gen xstep=(r(max)-r(min))/200
gen kwage=r(min)+(_n-1)*xstep if _n<=200

forvalues t=0/1 { 
	probit license northeast midwest south LessthanHS SomeCol AssoDeg Bachelor Graduate black asian Hispanic married citizencat veteran unioncat metrostat female exp exp2 [pweight=wtfinl] if public==`t'
	predict pruncx_`t', p
}

*Public Distribution
gen phiux=pruncx_0/pruncx_1 if license==1 & public==1
replace phiux=(1-pruncx_0)/(1-pruncx_1) if license==0 & public==1
replace phiux=phiux*hweight/1000.0 if public==1

kdensity lnwage [aweight=hweight] if license==1, at(kwage) gauss width(0.065) generate(wALA fdALA) nograph

kdensity lnwage [aweight=phiux] if license==1, at(kwage) gauss width(0.065) generate(wALW fdALW) nograp

kdensity lnwage [aweight=hweight] if License==0, at(kwage) gauss width(0.065) generate(wALA fdALA) nograph

kdensity lnwage [aweight=phiux] if License==0 , at(kwage) gauss width(0.065) generate(wALW fdALW) nograp



label var fdALW "license Counterfactual"
label var fdALA "license Actual"
label var kwage "Log(Wage)"

graph twoway (connected fdALA kwage if kwage>=0 & kwage<=4.5, ms(i) lc(blue)) (connected fdALW kwage if kwage>=0 & kwage<=4.5, ms(i) lp(dash) lc(magenta)), xlabel(.69 1.61 2.3 3.22 4.14) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)

*Difference
gen diff=fdALA-fdALW if _n<=200

graph twoway (line diff kwage if kwage>=1 & kwage<=4.5, ms(i) lc(blue)), yline(0, lpatter(dash) lcolor(red)) ylabel(0.0 0.2 0.4 0.6 0.8) xlabel(1.61 2.3 3.22 4.14) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)


*Private Distribution
gen phiux2=pruncx_1/pruncx_0 if license==1 & public==0
replace phiux2=(1-pruncx_1)/(1-pruncx_0) if license==0 & public==0
replace phiux2=phiux2*hweight/1000.0 if public==0

kdensity lnwage [aweight=hweight] if public==0, at(kwage) gauss width(0.065) generate(wWLW fdWLW) nograph

kdensity lnwage [aweight=phiux2] if public==0 , at(kwage) gauss width(0.065) generate(wWLA fdWLA) nograp

label var fdWLA "Private Counterfactual"
label var fdWLW "Private Actual"
label var kwage "Log(Wage)"

graph twoway (connected fdWLW kwage if kwage>=0 & kwage<=4.5, ms(i) lc(blue)) (connected fdWLA kwage if kwage>=0 & kwage<=4.5, ms(i) lp(dash) lc(magenta)), xlabel(.69 1.61 2.3 3.22 4.14) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)

gen diff2=fdWLW-fdWLA if _n<=200

graph twoway (line diff2 kwage if kwage>=1 & kwage<=4.5, ms(i) lc(blue)), yline(0, lpatter(dash) lcolor(red)) ylabel(0.0 0.2 0.4 0.6 0.8) xlabel(1.61 2.3 3.22 4.14) xline(0.748 1.065,lstyle(grid)) scheme(s1color) saving(dflfig4a, replace)

*Unconditional Quantile Regression
ssc install rif

local controls northeast midwest south LessthanHS SomeCol AssoDeg Bachelor Graduate black asian Hispanic married citizencat veteran unioncat metrostat female exp exp2
rifsureg lnwage public license `controls', qs(10(10)90)
margins, dydx(license) nose
marginsplot

local controls northeast midwest south LessthanHS SomeCol AssoDeg Bachelor Graduate black asian Hispanic married citizencat veteran unioncat metrostat female exp exp2
eg lnwage a_w license race_license `controls' [aw=atetwt_l], qs(10(10)90)
margins, dydx(race_license) nose
marginsplot

/*Quantile Regression: Too Slow
ssc install qregplot

local controls age age2 exp exp2 female black asian Hispanic LessthanHS SomeCol AssoDeg Bachelor Graduate married citizencat veteran

qreg lnwage license public unioncat  `controls' [pw=wtfinl], vce (robust)

qregplot license,  /// Variables to be plotted
estore(e_qreg) /// Request Storing the variables in memory
q(5(5)95) // and indicates what quantiles to plot*/

