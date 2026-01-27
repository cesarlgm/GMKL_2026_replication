/*
*===============================================================================
*Project: Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu) 
*
*Description: outputs the number of inconsistent movers for reporting in the paper text, identifying faculty with inconsistent institution coding across spells
*
*Input files:
*	- data/temporary/switcher_file
*
*Output files:
*	- results/text/n_leaves.tex
*===============================================================================
*/

*Output the number of inconsistent movers
use "data/temporary/switcher_file", clear

do "code/build_database/flag_spell_inconsistencies.do"


summ panelid if inconsistent_instcod==1

local file_name "results/text/n_leaves.tex"

rm "`file_name'"
writeln "`file_name'" "`r(N)'"