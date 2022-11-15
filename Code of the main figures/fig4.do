clear all
set more off, permanently
cd "input path"   // change to the input folder


* Import datasets
import delimited "control_graph_data.csv"
save control.dta, replace

clear *
import delimited "synthetic_weights.csv"
save synthetic_weights.dta, replace

use synthetic_dataset, replace
merge m:1 country using synthetic_weights
drop _merge
* No weight:hungary slovakia finland

* Aggregate using the synthetic weights
keep country month x_17 weight_normalized
gen price = x_17*weight_normalized
replace price = x_17 if country=="Switzerland"
gen groupID=1
replace groupID =2 if country != "Switzerland"
bysort groupID month: egen price_synth = sum(price)
keep if country == "Switzerland" | country=="Portugal"
keep price_synth groupID month
reshape wide price_synth, i(month) j(groupID)

* Merge with baseline data
merge 1:1 month using control
drop _merge

* Plot
set scheme s2mono
graph twoway (line price_synth2 month, lpattern(solid) lcolor(navy)  lwidth(0.5)) ///
 (line europe month, lpattern(dash) lcolor(navy)  lwidth(0.4)) ///
 (line price_synth1 month, lpattern(solid) lcolor(cranberry)  lwidth(0.5)),  ///
 legend( label (1 "Europe (synthetic)") label (2 "Europe (baseline)") label (3 "Switzerland")) xtitle("") ytitle("Price") xlabel(1 "Jan14" 7 "July14" 13 "Jan15" 19 "July15" 24 "Dec15") graphregion(color(white)) xline(13, lpattern(dash)) name(p1, replace)
 
* Export
graph export "output_path/fig4.pdf", replace // Change to the output path here
