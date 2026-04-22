
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Merges leave-check corrections (v4) into the main in-memory
*				dataset. Loads corrections into a temporary Stata frame, drops
*				observations associated with medical centers (excluded due to
*				inconsistent coding), and merges the remaining corrections back
*				into the default frame on refid-refyr. 

*   Input: 	data/raw/leave_check_v4_renamed.dta
*   Output: 	Modifies default frame in place: adds shuinstcod and shuacad_spell
*			from the corrections file via 1:1 merge on refid-refyr.


*===============================================================================
*/

*Add leave check v4
cap frame drop leave_check
frame create leave_check
frame change leave_check
	tempfile corrections
	use "data/raw/leave_check_v4_processed", clear

	*I am ignoring the corrections on medical centers. Shu was quite inconsistent in her decisions.
	gen_medical_center

	egen any_medical=max(medical_center), by(panelid)
	
	drop if any_medical==1
	
	keep refid refyr shuinstcod shuacad_spell
save `corrections'


frame change default
frame drop leave_check

	
cap drop _merge

cap drop shuinstcod
cap drop shuacad_spell

merge 1:1 refid refyr using `corrections', keep(1 3)
