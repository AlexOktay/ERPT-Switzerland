clear all
set more off, permanently
cd "path here"   // change to the input folder
import delimited "tradability_data.csv"

***************************** ALL GOODS TOGETHER *******************************

// Graph tradability on elasticity
graph twoway (qfitci tradability elasticity) (scatter tradability elasticity), name(p1, replace)

// With absolute value
gen elabsolute = abs(elasticity)
graph twoway (qfitci tradability elabsolute) (scatter tradability elabsolute), name(p1abs, replace)

// With log-tradability
replace tradability = 1 if tradability == 0 // for the log
gen log_trade = ln(tradability)
reg elabsolute log_trade
local eq = `"`eq' Slope: `: display %4.3f _b[log_trade]' "'
graph twoway (lfitci elabsolute log_trade , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute log_trade , msymbol(circle) leg(off) title("a) All goods", size(medium) color(black)) xtitle("Log tradability") ytitle("Absolute pass-through")  mcolor(gs4%70) msize(medlarge) mlwidth(0)), name(p1log, replace) graphregion(color(white)) bgcolor(white) xlabel(-2 0 2 4 6 8) xsc(r(-2 8))  text(0.9 6.5 `"`eq'"') ylabel(0 0.2 0.4 0.6 0.8 1) ysc(r(0 1))


********************************* BY CATEGORY **********************************

// Subsets of the data by good category
frame copy default retail
frame copy default service
frame copy default hh
frame copy default other

// Retail goods only
frame change retail
keep if cat=="RETAIL"
reg elabsolute log_trade
local eq = `"Slope: `: display %4.3f _b[log_trade]' "'
graph twoway (lfitci elabsolute log_trade , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute log_trade , msymbol(circle) leg(off) title("b) Food & Beverages", size(medlarge) color(black) margin(b=-3)) xtitle(" ") ytitle("") ylabel(0 0.2 0.4 0.6 0.8 1) ysc(r(0 1)) mcolor(gs4%70) msize(medlarge) mlwidth(0)), name(p2, replace) graphregion(color(white)) bgcolor(white) xlabel(-2 0 2 4 6 8) xsc(r(-2 8)) xtitle("Log tradability") ytitle("Absolute pass-through") text(0.9 6.5 `"`eq'"')


// Service only
frame change service
keep if cat=="SER"
reg elabsolute log_trade
local eq = `"Slope: `: display %4.3f _b[log_trade]' "'
graph twoway (lfitci elabsolute log_trade , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute log_trade , msymbol(circle) leg(off) title("d) Services", size(medlarge) color(black) margin(b=-3)) xtitle(" ") ytitle("") ylabel(0 0.2 0.4 0.6 0.8 1) ysc(r(0 1)) mcolor(gs4%70) msize(medlarge) mlwidth(0)), name(p3, replace) graphregion(color(white)) bgcolor(white) xlabel(-2 0 2 4 6 8) xsc(r(-2 8)) xtitle("Log tradability") ytitle("Absolute pass-through") text(0.9 6.5 `"`eq'"')

// HH goods only
frame change hh
keep if cat=="HH"
reg elabsolute log_trade
local eq = `"Slope: `: display %4.3f _b[log_trade]' "'
graph twoway (lfitci elabsolute log_trade , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute log_trade , msymbol(circle) leg(off) title("c) Household products", size(medlarge) color(black) margin(b=-3)) xtitle(" ") ytitle("") ylabel(0 0.2 0.4 0.6 0.8 1) ysc(r(0 1)) mcolor(gs4%70) msize(medlarge) mlwidth(0)), name(p4, replace) graphregion(color(white)) bgcolor(white) xlabel(-2 0 2 4 6 8) xsc(r(-2 8)) xtitle("Log tradability") ytitle("Absolute pass-through") text(0.9 6.5 `"`eq'"')


// Other goods only
frame change other
keep if cat=="OTHER"
reg elabsolute log_trade
local eq = `"Slope: `: display %4.3f _b[log_trade]' "'
graph twoway (lfitci elabsolute log_trade , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute log_trade , msymbol(circle) leg(off) title("e) Industrial and other goods", size(medlarge) color(black) margin(b=-3)) xtitle(" ") ytitle("") ylabel(0 0.2 0.4 0.6 0.8 1) ysc(r(0 1)) mcolor(gs4%70) msize(medlarge) mlwidth(0)), name(p5, replace) graphregion(color(white)) bgcolor(white) xlabel(-2 0 2 4 6 8) xsc(r(-2 8)) xtitle("Log tradability") ytitle("Absolute pass-through") text(0.9 6.5 `"`eq'"')


// Combine the figures
graph combine p2 p4 p3 p5, name(p6, replace) imargin(0) plotregion(fcolor(white)) graphregion(fcolor(white))
graph combine p1log p6, col(1) name(p7, replace) plotregion(fcolor(white)) graphregion(fcolor(white))
graph display p7, ysize(11) xsize(8) 

// Export
graph export "output_path/fig5.pdf", replace // Change to the output path here
