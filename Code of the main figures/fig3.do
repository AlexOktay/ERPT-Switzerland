clear all
set more off, permanently
cd "path here"   // change to the input folder
import delimited "pretrend2013.csv"
* ssc install reghdfe // if needed

* Reshape data
reshape long v, i(country) j(month)
replace month=month-1
rename v x_17

* Disclaimer: part of the code has been taken from LOST:  https://lost-stats.github.io/Model_Estimation/Research_Design/event_study.html#:~:text=Difference%2Din%2DDifferences%20Event%20Study,periods%20in%20your%20respective%20study. 

* Formatting
recast float month
encode country, gen(country2)
label values country2 . // CH = 32
gen treatment_time=25  // 13 if 2014-2015
replace treatment_time=. if country2!=32
keep country2 month treatment_time x_17

* Time-to-treat (TTT) as the number of months after/before treatment (0 if untreated country)
g time_to_treat = month - treatment_time
replace time_to_treat = 0 if missing(treatment_time)
g treat = !missing(treatment_time)

* Shift TTT as we can't have negative-valued factors
summ time_to_treat
g shifted_ttt = time_to_treat - r(min)
summ shifted_ttt if time_to_treat == -1
local true_neg1 = r(mean)

* Regress interaction with fixed effect for country and months (cluster at country level) 
reghdfe x_17 ib`true_neg1'.shifted_ttt, a(country2 month) vce(cluster country2)

* Pull out coefficients and SEs
g coef = .
g se = .
levelsof shifted_ttt, l(times)
foreach t in `times' {
	replace coef = _b[`t'.shifted_ttt] if shifted_ttt == `t'
	replace se = _se[`t'.shifted_ttt] if shifted_ttt == `t'
}

* Make confidence intervals
g ci_top = coef+1.96*se
g ci_bottom = coef - 1.96*se

* Switch back to TTT with negative values
keep time_to_treat coef se ci_*
duplicates drop
sort time_to_treat

* Plot
summ ci_top
local top_range = r(max)
summ ci_bottom
local bottom_range = r(min)

set scheme s2mono

twoway (sc coef time_to_treat, connect(line)) ///
	(rcap ci_top ci_bottom time_to_treat)	///
	(function y = 0, range(time_to_treat)) ///
	(function y = 0, range(`bottom_range' `top_range') horiz), ///
	xtitle("Time to treatment (in months)") ///
	ytitle("Dynamic DiD coefficient") ///
	legend(off) ///
	xsize(5.5) ysize(3.5)  /// auto: 5.5x4
	graphregion(color(white)) 
	
graph export "output_path/fig3.pdf", replace // Change to the output path here
