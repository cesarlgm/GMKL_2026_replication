/*
*===============================================================================
*Project: Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu)
*
*Description: counts and tabulates for-profit institutions in the analysis sample
*	by merging IPEDS sector classifications onto the institution-level database
*	and producing a frequency table by sector code. Results are displayed in the
*	console for reporting in the paper text.
*
*Input files:
*	- data/raw/IPEDS_v2.dta
*	- data/output/institution_level_database_clean.dta
*
*Output files:
*	- (none — tabulation displayed in console only)
*===============================================================================
*/

use "data/raw/IPEDS_v2", clear 

gcollapse (min) sector, by(instcod)

tostring instcod, replace

tempfile sector
save `sector'


use "data/output/institution_level_database_clean.dta", clear
merge 1:1 instcod using `sector', keep(3) nogen


table sector