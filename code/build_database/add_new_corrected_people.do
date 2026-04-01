/*
*===============================================================================
*Project: Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu)
*
*Description: Merges corrected person-spell records from the hand-verified
*	corrections file into the default in-memory dataset. Creates a temporary
*	frame to load the corrections, then merges 1:1 on refid and refyr to add
*	or overwrite new_spell and new_instcod for flagged individuals.
*
*Input files:
*	- data/raw/people_to_check_new_proc.dta (hand-verified spell corrections)
*	- In-memory dataset in default frame (must contain refid and refyr)
*
*Output files:
*	- In-memory dataset updated with new_spell and new_instcod
*
*Called by:
*	- add_indicator_solved_id.do
*	- add_old_corrections.do
*===============================================================================
*/

*Add leave check v4
cap frame change default
cap frame drop new_people
frame create new_people
frame change new_people
	tempfile corrections
	use "data/raw/people_to_check_new_cases_second_pass_corrected.dta", clear
	
	keep refid refyr new_spell new_instcod
	
save `corrections'


frame change default
frame drop new_people

	
cap drop _merge

cap drop new_spell
cap drop new_instcod

merge 1:1 refid refyr using `corrections', keep(1 3)
