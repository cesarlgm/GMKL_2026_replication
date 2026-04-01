/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Orchestrates four sequential correction passes applied to
*					the in-memory faculty panel dataset. Sources sub-scripts that
*					merge inconsistent institution-code fixes, modification lists,
*					leave-check corrections, and a final pass of recent manual
*					corrections; generates t_corrected/t2_corrected/t3_corrected/
*					t4_corrected flags and corresponding new-spell/new-instcod
*					variables for each pass.

*   Input: 	data/additional_processing/inconsistent_movers_shu
*			data/additional_processing/modification_list_old_part_shu
*			data/additional_processing/leave_check_v4_renamed
*			code/build_database/correct_inconsistent_instcods_v2.do
*			code/build_database/add_old_modification_lists.do
*			code/build_database/add_leave_check_v4.do
*			code/build_database/add_new_corrected_people.do

*   Output: 	In-memory variables: t_corrected, t_new_spell, t_new_instcod,
*				t2_corrected, t2_new_spell, t2_new_instcod,
*				t3_corrected, t3_new_spell, t3_new_instcod,
*				t4_corrected, t4_new_spell, t4_new_instcod


*===============================================================================
*/
do "code/build_database/correct_inconsistent_instcods_v2.do"
cap drop t_corrected
cap drop t2_corrected
cap drop t3_corrected

generate 	t_corrected=_merge==3
egen 		t_id_corrected=max(_merge==3), by(panelid)
generate 	t_new_spell=shu_spell		if  t_corrected
generate 	t_new_instcod=shuinstcod	if 	t_corrected

cap drop _merge
cap drop shu_spell
cap drop shuinstcod


*Add changes from the modification list
do "code/build_database/add_old_modification_lists.do"

generate t2_corrected=_merge==3
egen 	 t2_id_corrected=max(_merge==3), by(panelid)
generate t2_new_spell=new_acad_spell_id 	if t2_corrected
generate t2_new_instcod=new_instcod 		if t2_corrected

cap drop _merge
cap drop new_acad_spell_id
cap drop new_instcod

*Adding leave check v4
do "code/build_database/add_leave_check_v4.do"

generate t3_corrected=_merge==3
egen 	 t3_id_corrected=max(_merge==3), by(panelid)
generate t3_new_spell=shuacad_spell 	if t3_corrected
generate t3_new_instcod=shuinstcod 		if t3_corrected

cap drop _merge
cap drop shuacad_spell
cap drop shuinstcod


*Add the recent corrections
do "code/build_database/add_new_corrected_people.do"

generate t4_corrected=_merge==3
egen 	 t4_id_corrected=max(_merge==3), by(panelid)
generate t4_new_spell=new_spell		 	if t3_corrected
generate t4_new_instcod=new_instcod		if t3_corrected

cap drop _merge
cap drop new_spell
cap drop new_instcod