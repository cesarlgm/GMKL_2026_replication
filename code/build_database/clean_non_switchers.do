
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	cleans the database of people who did not switch institutions

*   Input: data/temporary/non_switcher_file.dta
*          data/temporary/non_switcher_file_part2.dta
*   Output: data/temporary/non_switcher_file_fixed.dta
					

*===============================================================================
*/





use "data/temporary/non_switcher_file", clear
append using "data/temporary/non_switcher_file_part2"

drop if inlist(instcod,"999999")
drop if inlist(inst_name,"")	

egen in_us=min(emus), by(panelid acad_spell_id)
drop if !in_us
***********************************************************************************************************************************
replace instcod=XXXX if instcod==XXXX


*Dropping puerto rico and the territories
drop if emst>=66&!missing(emst)


do "code/build_database/update_observation_type.do"
	
do "code/build_database/update_acad_spell_id.do"

*Recomputing spell level variables.
do "code/build_database/recompute_spell_level_variables.do"


do "code/build_database/global_instcod_merge.do"

do "code/build_database/drop_special_instcods.do"

do "code/build_database/institution_code_corrections.do" 1

do "code/build_database/update_inst_labels.do"

save "data/temporary/non_switcher_file_fixed", replace
