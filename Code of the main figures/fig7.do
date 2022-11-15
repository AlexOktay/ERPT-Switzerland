clear all
set more off, permanently
cd "path here"   // change to the input folder
import delimited "results_with_import.csv"

// Graph elasticity on EUR invoice share
gen elabsolute = abs(elasticity)
reg elabsolute auer_eurshare
local eq = `"`eq' Slope: `: display %4.3f _b[auer_eurshare]' "'
graph twoway (lfitci elabsolute auer_eurshare , clcolor(gs2) acolor(gs2%30) alwidth(0)) (scatter elabsolute auer_eurshare ,  msymbol(circle) leg(off) xtitle("EUR-invoicing share") ytitle("Absolute pass-through") mcolor(gs4%85) msize(medlarge) mlwidth(0)), name(p1abs, replace) graphregion(color(white)) bgcolor(white) text(0.38 0.73 `"`eq'"')

graph export "output_path/fig7.pdf", replace // Change to the output path here
