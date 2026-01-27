/*
*===============================================================================
*Project: Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu) 
*
*Description: outputs the number of leave episodes for reporting in the paper text, counting faculty with proper leave spells from academic employment
*
*Input files:
*	- data/raw/leave_check_v4_renamed.dta
*
*Output files:
*	- results/text/n_leaves.tex
*===============================================================================
*/

*Outputting the number of leave episodes
use "data/raw/leave_check_v4_renamed.dta", clear

summ panelid if proper_leave==1

local file_name "results/text/n_leaves.tex"

cap rm "`file_name'"
writeln "`file_name'" "`r(N)'"