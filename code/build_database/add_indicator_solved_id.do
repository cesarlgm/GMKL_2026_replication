/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	solves issues with institution codes in the database 

*   Input:  Default frame (main SDR panel dataset, already in memory)
*           code/build_database/correct_inconsistent_instcods_v2.do
*           code/build_database/add_old_modification_lists.do
*           code/build_database/add_leave_check_v4.do
*           code/build_database/add_new_corrected_people.do
*           data/raw/people_to_check_medical.dta
*           data/raw/people_to_check_new.dta
*   Output: Modifies default frame in memory; adds solved_id, to_solve, and
*           intermediate correction indicators (t_corrected-t6_corrected,
*           t_id_corrected-t6_id_corrected, t_to_solve)	

*===============================================================================
*/


frame change default
{ 
	do "code/build_database/correct_inconsistent_instcods_v2.do"
	cap drop t_corrected
	cap drop t2_corrected
	cap drop t3_corrected

	generate 	t_corrected=_merge==3
	egen 		t_id_corrected=max(_merge==3), by(panelid)

	cap drop _merge
	cap drop shu_spell
	cap drop shuinstcod


	*Add changes from the modification list
	do "code/build_database/add_old_modification_lists.do"

	generate t2_corrected=_merge==3
	egen 	 t2_id_corrected=max(_merge==3), by(panelid)

	cap drop _merge
	cap drop new_acad_spell_id
	cap drop new_instcod

	*Adding leave check v4
	do "code/build_database/add_leave_check_v4.do"

	generate t3_corrected=_merge==3
	egen 	 t3_id_corrected=max(_merge==3), by(panelid)
	
	cap drop _merge
	cap drop shuacad_spell
	cap drop shuinstcod


	*Add the recent corrections
	do "code/build_database/add_new_corrected_people.do"

	generate t4_corrected=_merge==3
	egen 	 t4_id_corrected=max(_merge==3), by(panelid)
	
	cap drop _merge
	cap drop new_spell
	cap drop new_instcod
	
		
		
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
	
	generate t5_corrected=_merge==3
	egen 	 t5_id_corrected=max(_merge==3), by(panelid)

	cap drop _merge
	cap drop new_spell
	cap drop new_instcod
	
	
	*Adding fixes from new people file
	merge 1:1 refid period using `fixes_new', keep(1 3)


	generate t6_corrected=_merge==3
	egen 	 t6_id_corrected=max(_merge==3), by(panelid)

	cap drop _merge
	cap drop new_spell
	cap drop new_instcod
	

	drop if missing(acad_spell_id)

	cap drop _merge


}

	
	egen solved_id= rowmax(*_id_corrected)


	cap drop t_to_solve
	generate t_to_solve=(inconsistent_instcod|(pos_on_leave==1&!proper_leave))& ///
		!solved_id
		
	egen to_solve=max(t_to_solve), by(panelid)