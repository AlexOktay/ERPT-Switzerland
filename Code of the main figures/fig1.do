clear all
set more off, permanently
cd "input path"   // change to the input folder

************************** Euro-zone Figure ************************************
use dataset_final_normalized2014
keep country month x_17 


// Base plot
set scheme s2mono
graph twoway (line x_17 month if country==2, lcolor(cranberry) lwidth(0.5) xline(13) xtitle("") ytitle("Price index") xlabel(1 "Jan14" 7 "July14" 13 "Jan15" 19 "July15" 24 "Dec15") graphregion(color(white))) ///
(line x_17 month if country==1, lcolor(navy) lpattern(solid) lwidth(0.5)) ///
, legend( label (2 "Europe (excl. Switzerland)") label (1 "Switzerland")) name(p1, replace)


//  Plot with EURCHF data
gen eurchf=.
replace eurchf = 1.2231 if month== 1 & country==1
replace eurchf = 1.216 if month== 2 & country==1
replace eurchf = 1.2199 if month== 3 & country==1
replace eurchf = 1.2195 if month== 4 & country==1
replace eurchf = 1.221 if month== 5 & country==1
replace eurchf = 1.2151 if month== 6 & country==1
replace eurchf = 1.2165 if month== 7 & country==1
replace eurchf = 1.2061 if month== 8 & country==1
replace eurchf = 1.2065 if month== 9 & country==1
replace eurchf = 1.2059 if month== 10 & country==1
replace eurchf = 1.2018 if month== 11 & country==1
replace eurchf = 1.2025 if month== 12 & country==1
replace eurchf = 1.0442 if month== 13 & country==1
replace eurchf = 1.0668 if month== 14 & country==1
replace eurchf = 1.0455 if month== 15 & country==1
replace eurchf = 1.0493 if month== 16 & country==1
replace eurchf = 1.0342 if month== 17 & country==1
replace eurchf = 1.0377 if month== 18 & country==1
replace eurchf = 1.0536 if month== 19 & country==1
replace eurchf = 1.0793 if month== 20 & country==1
replace eurchf = 1.0926 if month== 21 & country==1
replace eurchf = 1.0867 if month== 22 & country==1
replace eurchf = 1.0906 if month== 23 & country==1
replace eurchf = 1.0817 if month== 24 & country==1

graph twoway (line x_17 month if country==2, lcolor(cranberry) lwidth(0.5) xline(13) xtitle("") ytitle("Price index") xlabel(1 "Jan14" 7 "July14" 13 "Jan15" 19 "July15" 24 "Dec15") graphregion(color(white)) yaxis(1)) ///
(line x_17 month if country==1, lcolor(navy) lpattern(solid) lwidth(0.5) yaxis(1)) ///
(line eurchf month if country==1,yaxis(2) lcolor(navy) lpattern(dash)) ///
, legend( label (2 "European consumer prices") label (1 "Swiss consumer prices") label (3 "EUR/CHF (rhs)")) name(p1, replace)

graph export "outputpath/fig1.pdf", replace
