/*
*===============================================================================
*Project: Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu)
*
*Description: counts the number of faculty with inconsistent institution coding
*	across spells (identified by the flag_spell_inconsistencies script) and writes
*	the count to a LaTeX snippet for inline citation in the paper.
*
*Input files:
*	- data/temporary/switcher_file.dta
*
*Output files:
*	- results/text/n_inconsistent_movers.tex
*===============================================================================
*/

*Output the number of inconsistent movers
use "data/temporary/switcher_file", clear

do "code/build_database/flag_spell_inconsistencies.do"


summ panelid if inconsistent_instcod==1

local file_name "results/text/n_inconsistent_movers.tex"

rm "`file_name'"
writeln "`file_name'" "`r(N)'"s