# The Labor Market Effects of Occupational Licensing in the Public Sector

## Abstract: 
In the U.S., occupational licensing is more prevalent in the public sector than in the private sector, but the influence of occupational regulation for public sector workers, and how it is compared to that of private sector workers, has not been analyzed in detail.  Our study examines how licensing impacts key labor market outcomes of wages and part-time work.  Our results show that having an occupational license has positive effects on hourly wages and negative effects on the probability of part-time work in both sectors, mirroring licensing’s effects as a whole.  When we disaggregate licensing’s effects into sector comparison using an interaction term between licensing and sector, licensing’s wage effect is 1.83% less in the public sector, and public sector workers have 2.01% less probability to involve in part-time work.  We further look at how licensing differentially affects the wage distribution between the two sectors using unconditional quantile regression, and we find that at the lower wage distribution, licensing’s wage effects are almost the same between the public and the private sector. The difference of licensing’s wage effects between two sectors becomes larger as we move along the wage distribution quantiles.

## Installation
This repository aims to provide all of the datasets and STATA codes used in the paper, for replication purposes.

## Codes
### CPS
-Data cleaning

`do "$dir/code/cpscleaning_descriptive.do"`

-Summary statistics

`do "$dir/code/summary_stats.do"`

-Fixed Effects with Propensity Score Matching

`do "$dir/code/analysis.do"`

-Bayes adjustment for licensing share

`do "$dir/code/betabinomial_nomle.do`

`do "$dir/code/betabin_pubc.do`

`do "$dir/code/betabin_unionc.do`

-Robustness check: Heckman and IV

`do "$dir/code/robustness.do"`

-Selection on unobservables: occupation quartiles and Finkelsein et al. (2018)

`do "$dir/code/selection_occ.do"`

-Graphs: map and wage distribution

`do "$dir/code/distribution.do"`

`do "$dir/code/map.do"`

### SIPP
-Data cleaning

`do "$dir/code/sipp_data_cleaner.do"`

-Summary statistics

`do "$dir/code/summary_stats_sipp.do"`

-Fixed Effects with Propensity Score Matching

`do "$dir/code/analysis_sipp.do"`

## Contact
If have any questions, contact wenchenw@illinois.edu