/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Flags institution-code inconsistencies in the panel: identifies
*					consecutive observations where the respondent reports the same
*					employer (emsmi in {1,2}) but instcod changes, then recomputes
*					spell-level variables and reclassifies observation type.

*   Input: 		Default frame in memory (requires panelid, period, emsmi, instcod);
*				called do-files: recompute_spell_level_variables.do,
*				update_observation_type.do
*   Output: 	Modifies default frame: adds consecutive, inconsistent_instcod,
*				any_inconsistency; spell-level variables and observation_type
*				updated via called do-files

*===============================================================================
*/



cap drop consecutive 
cap drop inconsistent_instcod
cap drop any_inconsistency
sort 		panelid period
by panelid: generate consecutive=period==period[_n-1]+1 if _n>1
by panelid: generate inconsistent_instcod=inlist(emsmi,1,2)& ///
	instcod[_n]!=instcod[_n-1]&consecutive&_n>1

	
egen any_inconsistency=max(inconsistent_instcod), by(panelid)

*I recompute the spell level variables
do "code/build_database/recompute_spell_level_variables.do"

do "code/build_database/update_observation_type.do"

