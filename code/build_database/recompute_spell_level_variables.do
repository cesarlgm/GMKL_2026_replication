/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Re-aggregates spell-level variables to their modal/min/max value
*				within each spell (panelid x acad_spell_id) after corrections have
*				been applied; refreshes institution labels via update_inst_labels.do
*				and drops stale intermediate variables.

*   Input: 		Default frame in memory (requires panelid, acad_spell_id,
*				start_date_f, instcod, spell_location, not_mainland);
*				called: code/build_database/update_inst_labels.do
*   Output: 	Modifies default frame: updates start_date_f, instcod,
*				spell_location, not_mainland, inst_name to spell-level aggregates;
*				drops any*, spell_sum, times_inst, last_period, first_period,
*				last_year, first_year, problem_type
					

*===============================================================================
*/



*STEP 4: RECOMPUTE SPELL-LEVEL VARIABLES
cap drop modal_date
cap drop tempfile
cap drop modal_instcod


*Starting date
egen modal_date=		mode(start_date_f), by(panelid acad_spell_id) minmode missing
replace start_date_f=	modal_date if !missing(modal_date)&start_date_f!=modal_date
						drop modal_date
						
*Institution code					
cap drop 					modal_instcod
egen 	modal_instcod=		mode(instcod), by(panelid acad_spell_id) minmode missing
replace instcod=			modal_instcod if modal_instcod!=""&instcod!=modal_instcod
drop 	modal_instcod						
	
cap drop temp
*Spell location
cap egen 	temp=			min(spell_location), by(panelid acad_spell_id)
cap replace spell_location=	temp

*Mainland / not mainland location
cap drop temp
cap egen temp=				max(not_mainland), by(panelid acad_spell_id)
cap replace 				not_mainland=temp
cap drop temp

cap drop inst_name


do "code/build_database/update_inst_labels.do"

cap drop any* spell_sum times_inst last_period first_period ///
	last_year first_year problem_type 