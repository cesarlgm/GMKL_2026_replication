/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Censored version of the old modification list merge step.
*					Loads the old academic-spell modification list, drops
*					observations linked to medical centers (institution
*					identifiers replaced with placeholders in this public
*					release), and merges the corrected spell and institution
*					codes into the in-memory dataset on refid-refyr.

*   Input: 		data/raw/modification_list_old_part_shu.dta
*   Output: 	In-memory update — adds new_acad_spell_id, new_instcod,
*				and t_solved via 1:1 merge on refid refyr


*===============================================================================
*/

preserve
tempfile old_list
	use "data/raw/modification_list_old_part_shu", clear

	gen_medical_center
	
	egen any_medical=max(medical_center), by(panelid)
	
	drop if any_medical==1
	
	keep refid refyr new_acad_spell_id new_instcod
	
	generate t_solved=1
save `old_list'
restore

cap drop _merge
merge 1:1 refid refyr using `old_list'
