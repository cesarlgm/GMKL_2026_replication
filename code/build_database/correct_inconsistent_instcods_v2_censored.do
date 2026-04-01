/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Applies a second round of institution-code corrections for
*					inconsistent movers. Loads the manually reviewed correction
*					list, drops observations associated with medical centers
*					(institution identifiers censored for public release), and
*					merges the corrected spell/institution codes (shuinstcod,
*					shu_spell) into the in-memory dataset on refid-period.

*   Input: 	data/raw/inconsistent_movers_shu.dta
*   Output: 	In-memory update — adds shuinstcod and shu_spell via m:1 merge
*				on refid period


*===============================================================================
*/

*Correcting second round of inconsistent movers

preserve
{
	use "data/raw/inconsistent_movers_processed.dta", clear
	
	*I am ignoring the corrections on medical centers. Shu was quite inconsistent in her decisions.
	generate medical_center=inlist(instcod, "XXXXXXXXXXX", "216366", "228653")
	
	egen any_medical=max(medical_center), by(panelid)
	
	drop if any_medical==1
	
	keep refid period shuinstcod shu_spell
	
	tempfile correct_movers
	save `correct_movers'
}

restore

cap drop _merge
merge m:1 refid period using `correct_movers', keep(1 3)
