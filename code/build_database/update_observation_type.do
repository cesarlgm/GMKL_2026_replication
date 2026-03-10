/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	solves issues with institution codes in the database 

*   Input: 
*   Output: 
					

*===============================================================================
*/

local plus `1'

cap drop n_spells

gegen n_spells=nunique(acad_spell_id), by(panelid)

cap drop observation_type
generate observation_type=(n_spells>1)

cap label drop observation_type
label define observation_type 0 "Non-switcher" 1 "Switcher"
label values observation_type observation_type


if "`plus'"=="1" {
	*9/13/23 I noticed a small mistake in my classification of movers vs non
	*Keep people who only moved once
	tempvar schoolcode
	egen `schoolcode'=group(instcod)
	gegen n_schools=nunique(`schoolcode'), by(panelid)
	
	replace observation_type=0 if n_schools==1
}