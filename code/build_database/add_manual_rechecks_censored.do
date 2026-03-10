/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Applies manual rechecks to overwrite acad_spell_id and instcod
*				using two hand-verified correction files (medical and new people);
*				drops observations that remain unresolved (missing acad_spell_id)
*				after both correction passes.

*   Input: 	Default frame in memory (main analysis dataset)
*			data/raw/people_to_check_medical  (hand-verified corrections, medical)
*			data/raw/people_to_check_new      (hand-verified corrections, new people)
*   Output: 	Modifies default frame in place: corrects acad_spell_id and instcod
*			for matched records; drops observations with missing acad_spell_id.


*===============================================================================
*/



frame change default
cap frame drop add_fixes_medical
frame create add_fixes_medical
frame change add_fixes_medical
	use "data/raw/people_to_check_medical", clear

	keep refid period new_spell new_instcod

	tempfile fixes_medical
	save `fixes_medical'
frame change default
frame drop add_fixes_medical

cap frame drop add_fixes_new
frame create add_fixes_new
frame change add_fixes_new
	use "data/raw/people_to_check_new", clear

	keep refid period new_spell new_instcod

	tempfile fixes_new
	save `fixes_new'
frame change default
frame drop add_fixes_new


drop if missing(panelid)

cap drop _merge

*Adding fixes from medical file
merge 1:1 refid period using `fixes_medical', keep(1 3)

replace acad_spell_id=new_spell 	if _merge==3
replace instcod=new_instcod 		if _merge==3

drop if missing(acad_spell_id)

cap drop _merge

*Adding fixes from new people file
merge 1:1 refid period using `fixes_new', keep(1 3)


replace acad_spell_id=new_spell 	if _merge==3
replace instcod=new_instcod 		if _merge==3

drop if missing(acad_spell_id)

cap drop _merge

****************************************************************************************** Censored code ***********************
*Finally I add the corrections I have to force to all the people
replace instcod="XXXX" if instcod=="XXXX"
