clear all
set more off, permanently
cd "path here"   // change to the input folder
import delimited "results_with_import.csv"

// Graph elasticity on import share
set scheme lean2
graph twoway (lfitci elasticity imp_share) (scatter elasticity imp_share, title("a) Elasticity on import share") msymbol(o) xtitle("Import share") ylabel(0 0.2 0.4) ysc(r(-0.1 0.5)) legend(rows(1))  ), name(p1, replace)

// Graph elasticity on EUR invoice share
graph twoway (lfitci elasticity auer_eurshare) (scatter elasticity auer_eurshare, title("b) Elasticity on EUR invoice share") msymbol(o) ylabel(0 0.2 0.4) xtitle("EUR share") ysc(r(-0.1 0.5)) ), name(p2, replace)

// Combine the twoway
grc1leg p1 p2, name(p3, replace)
graph display p3, ysize(4) xsize(8)

graph export "output_path/fig5.pdf", replace // Change to the output path here