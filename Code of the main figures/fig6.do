clear all
set more off, permanently
cd "path here"   // change to the input folder
import delimited "tradability_data.csv"

***************************** ALL GOODS TOGETHER *******************************

// Graph import share on elasticity
drop if importshare=="NA"
destring importshare, replace

gen elabsolute = abs(elasticity)
reg elabsolute importshare
local eq = `"`eq' Slope: `: display %4.3f _b[importshare]' "'
graph twoway (lfitci elabsolute importshare , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute importshare ,  msymbol(circle) leg(off) title("a) All goods", size(medium) color(black)) xtitle("Import share") ytitle("Absolute pass-through") ylabel(0 0.2 0.4 0.6 0.8) ysc(r(0 0.8)) mcolor(gs4%70) msize(medlarge) mlwidth(0)), name(p1abs, replace) graphregion(color(white)) bgcolor(white) xlabel(0 0.2 0.4 0.6 0.8 1) xscale(r(0 1)) text(0.7 0.85 `"`eq'"')

 
********************************* BY CATEGORY **********************************

// Subsets of the data by good category
frame copy default retail
frame copy default service
frame copy default hh
frame copy default other

// Retail goods only
frame change retail
keep if cat=="RETAIL"
reg elabsolute importshare
local eq = `" Slope: `: display %4.3f _b[importshare]' "'
graph twoway (lfitci elabsolute importshare , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute importshare , msymbol(circle) leg(off) title("b) Food & Beverages", size(medlarge) color(black) margin(b=-3)) xtitle(" ") ytitle("") ylabel(0 0.2 0.4 0.6 0.8) ysc(r(0 0.8)) mcolor(gs4%70) msize(medlarge) mlwidth(0)), name(p2, replace) graphregion(color(white)) bgcolor(white) xlabel(0 0.2 0.4 0.6 0.8 1) xscale(r(0 1)) xtitle("Import share") ytitle("Absolute pass-through")  text(0.7 0.85 `"`eq'"')

// Service only
frame change service
keep if cat=="SER"
reg elabsolute importshare
local eq = `" Slope: `: display %4.3f _b[importshare]' "'
graph twoway (lfitci elabsolute importshare , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute importshare , msymbol(circle) leg(off) title("d) Services", size(medlarge) color(black) margin(b=-3)) xtitle(" ") ytitle("") ylabel(0 0.2 0.4 0.6 0.8) ysc(r(0 0.8)) mcolor(gs4%70) msize(medlarge) mlwidth(0)), name(p3, replace) graphregion(color(white)) bgcolor(white) xlabel(0 0.2 0.4 0.6 0.8 1) xscale(r(0 1)) xtitle("Import share") ytitle("Absolute pass-through")  text(0.7 0.85 `"`eq'"')
 
// HH goods only
frame change hh
keep if cat=="HH"
reg elabsolute importshare
local eq = `" Slope: `: display %4.3f _b[importshare]' "'
graph twoway (lfitci elabsolute importshare , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute importshare , msymbol(circle) leg(off) title("c) Household products", size(medlarge) color(black) margin(b=-3)) xtitle(" ") ytitle("") ylabel(0 0.2 0.4 0.6 0.8) ysc(r(0 0.8)) mcolor(gs4%70) msize(medlarge) mlwidth(0)), name(p4, replace) graphregion(color( white)) bgcolor(white) xlabel(0 0.2 0.4 0.6 0.8 1) xscale(r(0 1)) xtitle("Import share") ytitle("Absolute pass-through")  text(0.7 0.85 `"`eq'"')

// Other goods only
frame change other
keep if cat=="OTHER"
reg elabsolute importshare
local eq = `" Slope: `: display %4.3f _b[importshare]' "'
graph twoway (lfitci elabsolute importshare , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute importshare , msymbol(circle) leg(off) title("e) Industrial and other goods", size(medlarge) color(black) margin(b=-3)) xtitle(" ") ytitle("") ylabel(0 0.2 0.4 0.6 0.8) ysc(r(0 0.8)) mcolor(gs4%70) msize(medlarge) mlwidth(0)), name(p5, replace) graphregion(color(white)) bgcolor(white) xlabel(0 0.2 0.4 0.6 0.8 1) xscale(r(0 1)) xtitle("Import share") ytitle("Absolute pass-through")  text(0.7 0.85 `"`eq'"')

// Combine the figures
graph combine p2 p4 p3 p5, name(p6, replace) imargin(0) plotregion(fcolor(white)) graphregion(fcolor(white))
graph combine p1abs p6, col(1) name(p7, replace) plotregion(fcolor(white)) graphregion(fcolor(white))
graph display p7, ysize(11) xsize(8) 
graph export "output_path/fig6.pdf", replace // Change to the output path here
