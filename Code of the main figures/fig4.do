clear all
set more off, permanently
cd "input path"   // change to the input folder
import delimited "tradability_data.csv"

***************************** ALL GOODS TOGETHER *******************************

// Graph tradability on elasticity
set scheme lean2
graph twoway (qfitci tradability elasticity) (scatter tradability elasticity), name(p1, replace)

// With absolute value
gen elabsolute = abs(elasticity)
graph twoway (qfitci tradability elabsolute) (scatter tradability elabsolute), name(p1abs, replace)

// With log-tradability
gen log_trade = ln(tradability)
graph twoway (lfitci log_trade elabsolute) (scatter log_trade elabsolute, xtitle("Absolute pass-through") ytitle("Log tradability") title("a) All goods", size(medlarge)) leg(off)), name(p1log, replace)


********************************* BY CATEGORY **********************************

// Subsets of the data by good category
frame copy default retail
frame copy default service
frame copy default hh
frame copy default other

// Retail goods only
frame change retail
keep if cat=="RETAIL"
graph twoway (lfitci log_trade elabsolute) (scatter log_trade elabsolute, leg(off) title("b) Food & Beverages", size(medlarge)) xtitle("Absolute pass-through") ytitle("Log tradability") ylabel(-2 0 2 4 6 8) ysc(r(-2 8))), name(p2, replace)

// Service only
frame change service
keep if cat=="SER"
graph twoway (lfitci log_trade elabsolute) (scatter log_trade elabsolute, leg(off) title("d) Services", size(medlarge)) xtitle("Absolute pass-through") ytitle("Log tradability") ylabel(-2 0 2 4 6 8) ysc(r(-2 8))), name(p3, replace)

// HH goods only
frame change hh
keep if cat=="HH"
graph twoway (lfitci log_trade elabsolute) (scatter log_trade elabsolute, leg(off) title("c) Household products", size(medlarge)) xtitle("Absolute pass-through") ytitle("Log tradability") ylabel(-2 0 2 4 6 8) ysc(r(-2 8))), name(p4, replace)

// Other goods only
frame change other
keep if cat=="OTHER"
graph twoway (lfitci log_trade elabsolute) (scatter log_trade elabsolute, leg(off) title("e) Industrial and other goods", size(medlarge)) xtitle("Absolute pass-through") ytitle("Log tradability") ylabel(-2 0 2 4 6 8) ysc(r(-2 8))), name(p5, replace)

// Combine the figures
graph combine p2 p4 p3 p5, name(p6, replace) imargin(0)
graph combine p1log p6, col(1) name(p7, replace)
graph display p7, ysize(11) xsize(8)

graph export "output_path/fig4.pdf", replace // Change to the output path here