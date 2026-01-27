/*
*===============================================================================
*Project: Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu) 
*
*Description: analyzes the number and distribution of for-profit schools in the sample by merging IPEDS sector information with institution-level database
*
*Input files:
*	- data/raw/IPEDS_v2
*	- data/output/institution_level_database_clean.dta
*
*Output files:
*	- (Summary table displayed in console)
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