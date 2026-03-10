/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Builds the manual-review database. Flags observations with
*					leave inconsistencies or institution-code conflicts, applies
*					prior corrections, and exports three priority-stratified
*					check datasets for hand review.

*   Input:		Default frame in memory (requires pos_on_leave, proper_leave,
*				inconsistent_instcod, panelid, and related spell variables)
*				code/build_database/add_old_corrections.do
*				code/build_database/flag_people_for_correction.do
*				code/build_database/extract_spell_revision.do
*				code/build_database/update_inst_labels.do
*				data/temporary/people_to_check_o (produced by extract_spell_revision.do)

*   Output:		data/temporary/people_to_check_new_o     (priority 1: new people)
*				data/temporary/people_to_check_medical_o (priority 2: medical school cases)
*				data/temporary/people_to_check_bug_o     (priority 3: likely bugs)
*				Default frame: adds problem_type, to_check

*===============================================================================
*/



*This part created the list of leave checks v1
cap drop problem_type
cap drop t
generate t=0
replace t=1 if (pos_on_leave&!proper_leave)
replace t=2 if inconsistent_instcod
egen problem_type=max(t), by(panelid)
drop t

cap label drop problem_type
label define problem_type 1 "Possible on leave" 2 "Inconsistent instcod"
label values problem_type problem_type
cap drop to_check
generate to_check=problem_type!=0


do "code/build_database/add_old_corrections.do"

do "code/build_database/flag_people_for_correction.do"


local important_variables check_priority new_spell new_instcod to_check ///
		problem_type pos_on_leave proper_leave inconsistent_instcod in_academia ///
		full_time in_tenure_track any_medical_drop any_exclusion

do "code/build_database/extract_spell_revision" people_to_check_o to_check 	///
	`important_variables'


frame change default
cap frame drop fix_dataset
frame create fix_dataset
frame change fix_dataset
	use "data/temporary/people_to_check_o", clear

	
	order panelid refid period refyr, first
	
	order acad_spell_id new_spell instcod new_instcod, after(refyr)

	foreach variable in check_priority problem_type {
		egen t_`variable'=min(`variable'), by(panelid)
		replace `variable'=t_`variable'
		cap drop t_`variable'
	}
	
	rename inst_name old_inst_name
	
	do "code/build_database/update_inst_labels.do" new_instcod
	
	rename inst_name new_inst_name
	rename old_inst_name inst_name
	
	order new_inst_name, after(inst_name)
	
	drop to_check
	
	generate leave_check=pos_on_leave&!proper_leave
	drop pos_on_leave proper_leave
	
	order leave_check inconsistent_instcod pdix acadpres wasvc, after(problem_type)

	
	generate should_include=in_academia&in_tenure_track&full_time&acadpres!=1&!(wasvc==1&(wapri==10|wasec==10))&pdix!=1
		
	preserve
		keep if check_priority==3
		save "data/temporary/people_to_check_bug_o", replace
	restore
	
	preserve
		keep if check_priority==1
		save "data/temporary/people_to_check_new_o", replace
	restore
	
	preserve
		keep if check_priority==2
		save "data/temporary/people_to_check_medical_o", replace
	restore
frame change default
cap frame drop fix_dataset
	