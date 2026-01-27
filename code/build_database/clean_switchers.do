
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	restricts the sample we use for the work history

*   Input: data/temporary/file_with_sample_restrictions.dta
*   Output: data/temporary/switcher_file_fixed.dta
					

*===============================================================================
*/



clear 
tempfile old_file
	use "data/raw/switcher_file_coding_mistake", clear
	keep panelid period acad_spell_id instcod refid refyr 
	rename (acad_spell_id instcod) (old_acad_id old_instcod)
save `old_file'


use refyr refid acadpres phdfield_orig nacedmg nacedng carneg carn05c naced ndgmeng   ndgrmed ///
	wapri wasvc wasec using "data/temporary/file_with_sample_restrictions"
save "data/temporary/auxiliary_vars", replace

use "data/temporary/switcher_file", clear
merge 1:1 refid refyr using `old_file'
generate difference=(old_instcod!=instcod) if _merge==3
egen ti_difference=max(difference), by(panelid)


cap drop _merge 
cap drop old_instcod old_acad_id
cap drop temp

*===============================================================================
*PRELIMINARY CLEANING
*===============================================================================

*Forced change uniform starting date within the spells
*-------------------------------------------------------------------------------
*If there is variace of dates within the spell, then I replace with the modal date_group
*Whenever there are several modes, I replace with minimum mode

*I had done this in previous parts. Here I am just updating the start date, after
*all the operations I performed on the dates.
egen modal_date=		mode(start_date_f), ///
	by(panelid acad_spell_id) minmode missing
replace start_date_f=	modal_date if ///
	!missing(modal_date)&start_date_f!=modal_date
drop modal_date

*No variance in dates at this moment


*Force uniform spell location within the spell. I am being conservative. If some-
*one tells me that they were not in the mainland at any moment within the spell 
*I assyne that they were not in the mainland the whole period.

egen temp=max(not_mainland), by(panelid acad_spell_id)
replace not_mainland=temp

drop temp


*===============================================================================
*ITERATIVE CHECKING AND CORRECTION OF SPELL INCONSISTENCIES
*===============================================================================
*First thing I do is weeding out observations that are outside the largest 
*connected set
do "code/build_database/drop_unconnected_unis.do" "first_filter"



*===============================================================================
*ITERATIVE CHECKING AND CORRECTION OF SPELL INCONSISTENCIES
*===============================================================================
 
/*------------------------------------------------------------------------------
*FIRST ITERATION
Correct spell id based on starting date and instcod
*------------------------------------------------------------------------------*/

*STEP 1: FLAGGING POSSIBLE SPELL PROBLEMS
preserve
	tempfile problem_flags
	
	keep panelid acad_spell_id start_date_f instcod spell_location not_mainland
	duplicates drop

	*Counting the number of spells that are within mainland US
	egen temp=count(acad_spell_id) if spell_location==1&not_mainland==0, by(panelid)
	egen n_spells_US=max(temp), by(panelid)
	drop temp
	
	generate problem_type=.
	replace	 problem_type=missing(start_date_f)


	sort panelid acad_spell_id
	
	*Flag> starting date is in the wrong order
	by panelid: generate wrong_order=start_date_f<start_date_f[_n-1] 	if _n>1
	
	*Flag> starting date is same even though they are different spells
	by panelid: generate same_date=start_date_f==start_date_f[_n-1] 	if _n>1
	
	
	replace problem_type=2 if wrong_order==1
	replace problem_type=3 if same_date==1
	

	drop wrong_order same_date
	
	cap label define problem_type 1 "Missing stating date" ///
		2 "Wrong oder start date"  3 "Same starting date" 
		
	label values problem_type problem_type

	*Flag> I don't know the institution
	generate unknown_institution=inlist(instcod, "999999", "777777")
	
	replace  	problem_type=4 if unknown_institution==1
	
	label 		define problem_type 4 "Unknown institution",  modify
	
	sort panelid acad_spell_id
	by panelid: generate same_instcod=instcod==instcod[_n-1]
	replace  	problem_type=5 if same_instcod==1
	
	label define problem_type 5 "Same instcod",  modify
	
	egen any_problem=max(problem_type), by(panelid)
	
	drop unknown_institution same_instcod 

	sort panelid acad_spell_id
	by panelid: generate same_date=	abs(start_date_f-start_date_f[_n-1])<366 if _n>1
	by panelid: generate same_instcod= instcod==instcod[_n-1] if _n>1

	*STEP 1.1> CORRECT SPELL ID FOR EVERYBODY WITH SAME DATE AND INSTCOD
	sort panelid acad_spell_id
	generate spell_sum=0
	by panelid: replace  spell_sum=1 if _n>1
	by panelid: replace  spell_sum=0 if _n>1&same_date==1&same_instcod==1
	by panelid: generate new_spell_id=acad_spell_id if _n==1
	by panelid: replace new_spell_id=new_spell_id[_n-1]+spell_sum if _n>1
	
	drop same_date same_instcod spell_sum 
	save `problem_flags'
restore


*STEP 2: ADDING FLAGS TO THE DATASET
merge m:1 panelid acad_spell_id using `problem_flags', nogen 

*I agree with my replacements (Wohoo)
keep if !missing(acad_spell_id)


*Only modifications that have happend so far are the changes based on institution code
*STEP 3: REPLACING SPELL IDS
replace acad_spell_id=new_spell_id

do "code/build_database/recompute_spell_level_variables.do"


/*------------------------------------------------------------------------------
*SECOND ITERATION
Correct spell id based on instcod
*------------------------------------------------------------------------------*/
*STEP 1: FLAGGING POSSIBLE SPELL PROBLEMS
preserve
	tempfile problem_flags
	
	keep panelid acad_spell_id start_date_f instcod spell_location not_mainland
	duplicates drop
	
	cap drop problem_type

	*Counting the number of spells that are within the US
	egen temp=count(acad_spell_id) if spell_location==1&not_mainland==0, by(panelid)
	egen n_spells_US=max(temp), by(panelid)
	drop temp
	
	generate problem_type=.
	replace	 problem_type=missing(start_date_f)


	sort panelid acad_spell_id
	
	*Flag> starting date is in the wrong order
	by panelid: generate wrong_order=start_date_f<start_date_f[_n-1] 	if _n>1
	
	*Flag> starting date is same even though they are different spells
	by panelid: generate same_date=start_date_f==start_date_f[_n-1] 	if _n>1
	
	
	replace problem_type=2 if wrong_order==1
	replace problem_type=3 if same_date==1
	

	drop wrong_order same_date
	
	cap label define problem_type 1 "Missing stating date" ///
		2 "Wrong oder start date"  3 "Same starting date" 
		
	label values problem_type problem_type

	*Flag> I don't know the institution
	generate unknown_institution=inlist(instcod, "999999", "777777")
	
	replace  	problem_type=4 if unknown_institution==1
	
	label 		define problem_type 4 "Unknown institution",  modify
	
	sort panelid acad_spell_id
	by panelid: generate same_instcod=instcod==instcod[_n-1]
	replace  	problem_type=5 if same_instcod==1
	
	label define problem_type 5 "Same instcod",  modify
	
	egen any_problem=max(problem_type), by(panelid)
	
	drop unknown_institution same_instcod 
	
	
	*---------------------------------------------------------------------------
	*I will replace all instances in which the instcod is the same
	*---------------------------------------------------------------------------
	
	sort panelid acad_spell_id
	by panelid: generate same_instcod= instcod==instcod[_n-1] if _n>1
	
	sort panelid acad_spell_id
	generate spell_sum=0
	by panelid: replace  spell_sum=1 if _n>1
	by panelid: replace  spell_sum=0 if _n>1&same_instcod==1
	by panelid: generate new_spell_id=acad_spell_id if _n==1
	by panelid: replace  new_spell_id=new_spell_id[_n-1]+spell_sum if _n>1
	
	save `problem_flags'
restore
*STEP 2: ADDING FLAGS TO THE DATASET
merge m:1 panelid acad_spell_id using `problem_flags', nogen update replace



*STEP 3: REPLACING SPELL IDS
replace acad_spell_id=new_spell_id

do "code/build_database/recompute_spell_level_variables.do"

*Dropping all spells outside the US
drop if !spell_location



********************************************************************************
*MISCELLANEOUS CHECKS
********************************************************************************
*See that community colleges are not here

generate comm_college_flag=regexm(inst_name,"community+")
order comm_college_flag, after(inst_name)

drop if comm_college_flag==1

assert comm_college_flag==0


*Drop observations without wages as I cannot use them anyways
drop if missing(salary)

********************************************************************************
*FOURTH ITERATION: MANUAL CORRECTIONS FROM SHU
********************************************************************************
do "code/build_database/check_n_movers.do"

*Applying manual corrections. This filters unconnected institutions again
do "code/build_database/institution_code_corrections"

*I recompute the spell level variables
do "code/build_database/recompute_spell_level_variables.do"

do "code/build_database/update_observation_type.do"

*Here I drop "special" institutions	
do "code/build_database/drop_special_instcods.do"

*Here I flag potential leave episodes
do "code/build_database/flag_leave_episodes.do"

*This just creates a flag of episodes that might be an issue
do "code/build_database/flag_spell_inconsistencies.do"

do "code/build_database/create_check_database.do"

do "code/build_database/add_manual_rechecks.do"

do "code/build_database/recompute_spell_level_variables.do"

do "code/build_database/update_observation_type.do"
	
do "code/build_database/update_acad_spell_id.do"
	
do "code/build_database/recompute_spell_level_variables.do"


cap drop consecutive-_merge

cap drop problem_type
cap drop any_problem


*I separate the guys that became non-switchers to add them later
preserve
	keep if n_spells_US<2
	save "data/temporary/non_switcher_file_part2", replace 
restore

drop if n_spells_US<2

cap order inst_name, after(instcod)
order refid refyr, first



/*******************************************************************************
*FIFTH ITERATION
*Recovering some additional unknown institution codes.
*******************************************************************************/

preserve
	tempfile problem_flags
	
	keep panelid acad_spell_id start_date_f instcod spell_location not_mainland
	duplicates drop
	
	sort panelid acad_spell_id
	
	cap drop problem_type

	*Counting the number of spells that are within the US
	egen temp=count(acad_spell_id) if spell_location==1&not_mainland==0, by(panelid)
	egen n_spells_US=max(temp), by(panelid)
	drop temp
	
	generate problem_type=.
	replace	 problem_type=missing(start_date_f)


	sort panelid acad_spell_id
	
	*Flag> starting date is in the wrong order
	by panelid: generate wrong_order=start_date_f<start_date_f[_n-1] & ///
		 !missing(start_date_f[_n-1]) if _n>1
	
	*Flag> starting date is same even though they are different spells
	by panelid: generate same_date=start_date_f==start_date_f[_n-1] 	if _n>1
	
	
	replace problem_type=2 if wrong_order==1
	replace problem_type=3 if same_date==1
	

	drop wrong_order same_date
	
	cap label define problem_type 1 "Missing stating date" ///
		2 "Wrong oder start date"  3 "Same starting date" 
		
	label values problem_type problem_type
	
	*Flag> I don't know the institution
	generate unknown_institution=inlist(instcod, "999999", "777777")
	
	replace  	problem_type=4 if unknown_institution==1
	
	label 		define problem_type 4 "Unknown institution",  modify
	
	sort panelid acad_spell_id
	by panelid: generate same_instcod=instcod==instcod[_n-1]
	replace  	problem_type=5 if same_instcod==1
	
	label define problem_type 5 "Same instcod",  modify
	
	egen any_problem=max(problem_type*inlist(problem_type, 2, 3, 5)), by(panelid)
	label values any_problem problem_type
	
	drop unknown_institution same_instcod 
	
	drop if acad_spell_id==.
	
	save `problem_flags'
restore

merge m:1 panelid acad_spell_id using `problem_flags', nogen
replace problem_type=0 	if missing(problem_type)
replace any_problem=0 	if missing(any_problem)


do "code/build_database/update_inst_labels.do"

preserve
	tempfile remaining_missing
	cap drop any_unknown
	cap drop old_date
	egen any_unknown=max(problem_type==4), by(panelid)
	keep if any_unknown

	keep 		panelid start_date_f acad_spell_id instcod inst_name
	
	duplicates drop
	
	sort panelid acad_spell_id
	generate 	old_date=	start_date_f<mdy(1,1,1987)
	by panelid: generate  same_date=abs(start_date_f-start_date_f[_n-1])<366 if _n>1 & !old_date
	by panelid: replace   same_date=abs(start_date_f-start_date_f[_n-1])<732 if _n>1 & old_date
	
	generate new_instcod=instcod
	by panelid:  replace new_instcod=instcod[_n-1] if same_date==1&_n>1 /// 
		&instcod[_n-1]!="999999" & instcod=="999999"
	
	cap drop same_date
	by panelid: generate  same_date=abs(start_date_f-start_date_f[_n+1])<366 if _n<_N & !old_date
	by panelid: replace   same_date=abs(start_date_f-start_date_f[_n+1])<732 if _n<_N & old_date
	
	by panelid:  replace new_instcod=instcod[_n+1] if same_date==1&_n<_N /// 
	&instcod[_n+1]!="999999" & instcod=="999999"
	
	keep panelid acad_spell_id new_instcod

	*STEP 1.1> CORRECT SPELL ID FOR EVERYBODY WITH SAME DATE AND INSTCOD
	by panelid: generate same_instcod=new_instcod==new_instcod[_n-1]
	sort panelid acad_spell_id
	generate spell_sum=0
	by panelid: replace  spell_sum=1 if _n>1
	by panelid: replace  spell_sum=0 if _n>1&same_instcod==1
	by panelid: generate new_spell_id=acad_spell_id if _n==1
	by panelid: replace new_spell_id=new_spell_id[_n-1]+spell_sum if _n>1
	
	save `remaining_missing'
restore

merge m:1 panelid acad_spell_id using `remaining_missing', 

replace instcod=new_instcod if ///
	instcod=="999999" & (new_instcod!=""&new_instcod!="999999")

replace acad_spell_id=new_spell_id if !missing(new_spell_id)

*I recompute the spell level variables
do "code/build_database/recompute_spell_level_variables.do"

do "code/build_database/update_observation_type.do"


*Final check of leaves and inconsistencies
do "code/build_database/flag_leave_episodes.do"

do "code/build_database/flag_spell_inconsistencies.do"

do "code/build_database/add_indicator_solved_id"

do "code/build_database/extract_spell_revision" manual_check_v1 to_solve ///
		pos_on_leave proper_leave inconsistent_instcod
		
merge 1:1 refid refyr using "data/raw/manual_check_v1_processed.dta", ///
	keepusing( correct_instcod correct_spell) keep(1 3)

drop if missing(acad_spell_id)

*Filter the unconnected institutions again
do "code/build_database/drop_unconnected_unis.do" "after_final_switch"

cap frame drop connected
frame copy default connected
	frame change connected
	
	keep instcod
	duplicates drop
	save "data/additional_processing/connected_set_after_final_switch", replace
	
frame change default
frame drop connected

save "data/temporary/switcher_file_fixed", replace

