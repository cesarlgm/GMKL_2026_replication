/*
*===============================================================================
*Project: Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu)
*
*Description: counts the number of proper leave episodes in the raw leave data
*	and writes the count to a LaTeX snippet for inline citation in the paper.
*
*Input files:
*	- data/raw/leave_check_v4_processed.dta
*
*Output files:
*	- results/text/n_leaves.tex
*===============================================================================
*/

*Outputting the number of leave episodes
use "data/raw/leave_check_v4_processed.dta", clear

summ panelid if proper_leave==1

local file_name "results/text/n_leaves.tex"

cap rm "`file_name'"
writeln "`file_name'" "`r(N)'"