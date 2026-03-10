/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Consolidates academic spell IDs by collapsing consecutive spells
*					at the same institution (same_instcod==1) into a single spell.
*					Replaces acad_spell_id with the updated identifier new_spell_id.

*   Input: 		Default frame in memory (requires panelid, acad_spell_id, instcod)
*   Output: 	Modifies default frame in place: acad_spell_id replaced with
*				consolidated spell IDs derived from new_spell_id
					

*===============================================================================
*/

preserve
	tempfile new_acad_spells
	
	keep panelid acad_spell_id instcod
	duplicates drop
	
	sort panelid acad_spell_id
	by panelid: generate same_instcod= instcod==instcod[_n-1] if _n>1
	
	
	sort panelid acad_spell_id
	generate spell_sum=0
	by panelid: replace  spell_sum=1 if _n>1
	by panelid: replace  spell_sum=0 if _n>1&same_instcod==1
	by panelid: generate new_spell_id=1 if _n==1
	by panelid: replace  new_spell_id=new_spell_id[_n-1]+spell_sum if _n>1
	
	duplicates examples panelid acad_spell_id
	
	save `new_acad_spells'
restore

cap drop new_spell_id 
cap drop _merge
merge m:1 panelid acad_spell_id using `new_acad_spells'
replace acad_spell_id=new_spell_id