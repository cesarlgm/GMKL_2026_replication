/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Consolidates correction flags from four manual correction
*					rounds (t, t2, t3, t4) into unified new_spell and new_instcod
*					variables, with t4 taking highest priority. Merges with the
*					reintroduced_schools crosswalk to identify medical-center
*					drops, then assigns a check_priority label (1=New person,
*					2=Medical, 3=Review exclusions, 4=Old person solved) for
*					downstream quality-control review.

*   Input: 		In-memory dataset (expects t_corrected through t4_corrected
*				variables and associated t*_new_spell / t*_new_instcod fields)
*				data/raw/reintroduced_schools.dta
*   Output: 	In-memory update — adds new_spell, new_instcod,
*				manually_corrected, any_medical_drop, any_exclusion,
*				check_priority


*===============================================================================
*/

cap drop new_spell
cap drop new_instcod 

generate new_spell=		acad_spell_id
generate new_instcod=	instcod

replace new_spell=t4_new_spell if ///
	t4_corrected==1
replace new_instcod=t4_new_instcod if ///
	t4_corrected==1

replace new_spell=t3_new_spell if ///
	!t4_corrected==1&t3_corrected==1
replace new_instcod=t3_new_instcod if ///
	!t4_corrected==1&t3_corrected==1

replace new_spell=t2_new_spell if ///
	!t4_corrected==1&!t3_corrected==1&t2_corrected==1
replace new_instcod=t2_new_instcod if ///
	!t4_corrected==1&t3_corrected==1&t2_corrected==1

replace new_spell=t_new_spell if ///
	!t4_corrected==1&!t3_corrected==1&!t2_corrected==1&t_corrected==1
replace new_instcod=t_new_instcod if ///
	!t4_corrected==1&!t3_corrected==1&!t2_corrected==1&t_corrected==1

cap drop manually_corrected
cap drop any_medical_school
egen t_manually_corrected=rowmax(t*corrected)
egen manually_corrected=max(t_manually_corrected), by(panelid)
drop t_manually_corrected

cap drop medical*
cap drop any*
cap drop _merge


merge m:1 instcod using "data/raw/reintroduced_schools", keep(1 3)

egen any_medical_drop=max(_merge==3), by(panelid)
egen any_exclusion=max(!missing(acad_spell_id)&missing(new_spell)&!any_medical_drop), by(panelid)

*New people on the bag
cap drop check_priority
generate 	check_priority=1 if to_check==1&!manually_corrected
replace 	check_priority=2 if any_medical_drop
replace 	check_priority=3 if ///
	missing(check_priority)&manually_corrected&any_exclusion
replace 	check_priority=4 if missing(check_priority)&manually_corrected



label define check_priority 1 "New person" 2 "Medical" 3 "Review exclusions" ///
	4 "Old person solved"
label values check_priority check_priority

