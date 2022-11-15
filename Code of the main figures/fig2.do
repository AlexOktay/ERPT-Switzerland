clear all
set more off, permanently
cd "path here"   // change to the input folder
import delimited "control_graph_data.csv"

set scheme s2mono

graph twoway (line europe month, lpattern(solid) lcolor(blue)) ///
 (line switzerland month, lpattern(solid) lcolor(cranberry)) ///
 (line eu month,lcolor(black%35)) ///
 (line eurozone month,lcolor(black%35)) ///
 (line noneur month,lpattern(solid) lcolor(black%55)) ///
 (line directneighbours month, lpattern(solid) lcolor(black%35))  ///
 (line highgdp month, lpattern(dash) lcolor(black%35)) ///
 (line germanic month,lpattern(shortdash) lcolor(black%35)) ///
 (line excludsouthern month,lpattern(longdash) lcolor(black%35) ///
 legend( label (1 "Europe (baseline)") label (7 "High GDP per capita") label (5 "Non-EUR currency")  label (9 "Excluding Southern EU")) xtitle("") ytitle("Price") xlabel(1 "Jan14" 7 "July14" 13 "Jan15" 19 "July15" 24 "Dec15") graphregion(color(white))), xline(13, lpattern(dash)) name(p1, replace)

graph export "output_path/fig2.pdf", replace // Change to the output path here
