/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Diagnostic check. Counts the number of movers (panelids with
*				more than one unique acad_spell_id) and spell-to-spell transitions
*				in the full sample, then repeats both counts excluding refyr==2019,
*				and displays the two sets of figures side-by-side in the console.
*				No data are written to disk.

*   Input: 	Default frame in memory (requires variables: panelid, acad_spell_id, refyr)
*   Output: 	None (displays counts to console only; no files written)
					

*===============================================================================
*/


*Checks number of movers
qui { 
preserve 
	cap drop n_spells
	gegen n_spells=nunique(acad_spell_id), by(panelid)
	drop if n_spells==1
	duplicates drop panelid acad_spell_id, force
	unique panelid 
	local n_movers=`r(unique)'
	sort panelid acad_spell_id
	by panelid: drop if _n==1
	unique panelid acad_spell_id
	local new_transitions=`r(unique)'
restore

preserve
	drop if refyr==2019
	cap drop n_spells
	gegen n_spells=nunique(acad_spell_id), by(panelid)
	drop if n_spells==1
	duplicates drop panelid acad_spell_id, force
	unique panelid 
	local old_n_movers=`r(unique)'
	sort panelid acad_spell_id
	by panelid: drop if _n==1
	unique panelid acad_spell_id
	local old_transitions=`r(unique)'
restore
}
display "new movers: `n_movers', old movers: `old_n_movers'", as result
display "new transitions: `new_transitions', old transitions: `old_transitions'", as result