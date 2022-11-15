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


* 1 - FULL SAMPLE -------------------------------------------------------------
preserve
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
	xlabel(-24 "Jan13" -12 "Jan14" 0 "Jan15" 11 "Dec15") ///
	ytitle("Dynamic DiD coefficient") ///
	legend(off) ///
	xsize(5.5) ysize(3.5)  /// auto: 5.5x4
	graphregion(color(white))
	
graph export "U:\0. Documents\4. Academic\ERPT\Version 2 R\Replication-2021a-main\Output/fig3.pdf", replace // Change to the output path here

twoway (sc coef time_to_treat, connect(line)) ///
	(rcap ci_top ci_bottom time_to_treat)	///
	(function y = 0, range(time_to_treat)) ///
	(function y = 0, range(`bottom_range' `top_range') horiz), ///
	xlabel(-24 "Jan13" -12 "Jan14" 0 "Jan15" 11 "Dec15") ///
	ytitle("Dynamic DiD coefficient") ///
	legend(off) ///
	graphregion(color(white)) ///
	title("Europe (baseline)") ///
	name(g1, replace)
restore


* 2. EU--------------------------------------------------------------------
preserve

// Modify the control group
drop if country2 == 23 | country2 == 27 | country2 == 14 | country2 == 22 | country2 == 33

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
	xlabel(-24 "Jan13" -12 "Jan14" 0 "Jan15" 11 "Dec15") ///
	ytitle("Dynamic DiD coefficient") ///
	legend(off) ///
	graphregion(color(white)) ///
	title("Europan Union") ///
	name(g2, replace)
restore


* 3. Eurozone------------------------------------------------------------------
preserve

// Modify the control group
keep if country2 == 1 | country2 == 2 | country2 == 5 | country2 == 8 | country2 == 9 | country2 == 10 | country2 == 11 | country2 == 12 | country2 == 15 | country2 == 16 | country2 == 17 | country2 == 18 | country2 == 19 | country2 == 20 | country2 == 21 | country2 == 25 | country2 == 28 | country2 == 29 | country2 == 30 | country2 == 32 

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
	xlabel(-24 "Jan13" -12 "Jan14" 0 "Jan15" 11 "Dec15") ///
	ytitle("Dynamic DiD coefficient") ///
	legend(off) ///
	graphregion(color(white)) ///
	title("Eurozone") ///
	name(g3, replace)
restore

* 4. Exclduding South -------------------------------------------------------------
preserve

// Modify the control group
drop if country2 == 16 | country2 == 30 | country2 == 12 | country2 == 25

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
	xlabel(-24 "Jan13" -12 "Jan14" 0 "Jan15" 11 "Dec15") ///
	ytitle("Dynamic DiD coefficient") ///
	legend(off) ///
	graphregion(color(white)) ///
	title("Europe excl. south") ///
	name(g4, replace)
restore

* 5. Germanic--------------------------------------------------------------------
preserve

// Modify the control group
keep if country2 == 1 | country2 == 11 | country2 == 32

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
	xlabel(-24 "Jan13" -12 "Jan14" 0 "Jan15" 11 "Dec15") ///
	ytitle("Dynamic DiD coefficient") ///
	legend(off) ///
	graphregion(color(white)) ///
	title("Germanic countries") ///
	name(g5, replace)
restore

* 6. Direct neighbors ---------------------------------------------------------------
preserve

// Modify the control group
keep if country2 == 10 | country2 == 32 | country2 == 1 | country2 == 16 | country2 == 11

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
	xlabel(-24 "Jan13" -12 "Jan14" 0 "Jan15" 11 "Dec15") ///
	ytitle("Dynamic DiD coefficient") ///
	legend(off) ///
	graphregion(color(white)) ///
	title("Direct neighbors") ///
	name(g6, replace)
restore


* 7. Non-EUR --------------------------------------------------------------------
preserve

// Modify the control group
keep if country2 == 32 | country2 == 34 | country2 == 3 | country2 == 6 | country2 == 7| country2 == 4| country2 == 13| country2 == 24| country2 == 26| country2 == 31

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
	xlabel(-24 "Jan13" -12 "Jan14" 0 "Jan15" 11 "Dec15") ///
	ytitle("Dynamic DiD coefficient") ///
	legend(off) ///
	graphregion(color(white)) ///
	title("Non-EUR currency") ///
	name(g7, replace)
restore

* 8. High GDP --------------------------------------------------------------------
preserve

// Modify the control group
keep if country2 == 32 | country2 == 19 | country2 == 15 | country2 == 7 | country2 == 23 | country2 == 14| country2 == 21 | country2 == 1| country2 == 31| country2 == 2| country2 == 11

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
	xlabel(-24 "Jan13" -12 "Jan14" 0 "Jan15" 11 "Dec15") ///
	ytitle("Dynamic DiD coefficient") ///
	legend(off) ///
	graphregion(color(white)) ///
	title("High GDP per capita") ///
	name(g8, replace)
restore

* COMBINE AND EXPORT-----------------------------------------------------------
graph combine g1 g2 g3 g4 g5 g6 g7 g8, name(combined, replace) cols(2) plotregion(fcolor(white)) graphregion(fcolor(white))
graph display combined,ysize(14) xsize(10)
graph export "output_path/fig3.pdf", replace // Change to the output path here
