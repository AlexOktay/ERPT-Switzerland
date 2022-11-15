clear all
set more off, permanently
cd "input path"   // change to the input folder
import delimited "tradability_data.csv"

* TRADABILITY
replace tradability = 1 if tradability==0 // for the log
gen y = abs(elasticity)
gen x1 = log(tradability)
reg y x1, vce(robust) // Tradability
eststo reg1

* IMPORT SHARE
drop if importshare=="NA"
destring importshare, replace
gen x2 = importshare
reg y x2, vce(robust) // Import share
eststo reg2
reg y x1 x2 c.x1#c.x2, vce(robust) // interaction
eststo reg4

* AUER EUR INVOICE SHARE
frame create default2
frame change default2
import delimited "results_with_import.csv"
save importshare, replace
frame change default
merge m:1 goodtype using importshare.dta
drop _merge
gen x3 = auer_eurshare

reg y x3, vce(robust) // EUR invoice share
eststo reg3

reg y x1 x2 x3, vce(robust) // EUR invoice share
eststo reg5

* Esttab
esttab reg1 reg2 reg3 reg5 reg4  using "U:\0. Documents\4. Academic\ERPT\Version 2 R\Replication-2021a-main\Output/tablereg.tex", se star(* 0.10 ** 0.05 *** 0.01)  stats(N r2 r2_a, fmt(%9.0g %9.2f %9.2f)) replace
