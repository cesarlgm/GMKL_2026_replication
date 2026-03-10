/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	converts OSEP institution codes to IPEDS codes for the 1993
*					and 1995 waves using the NSF crosswalk; adds institution name
*					labels; renames instcod to raw_instcod and iped to instcod

*   Input: 		Default frame in memory (requires panelid, refyr, instcod)
*				data/raw/osep_to_iped_rev2014  (OSEP-to-IPEDS crosswalk)
*				data/raw/inst_labels           (NSF institution name labels)
*   Output: 	Modifies default frame: instcod converted to IPEDS format;
*				inst_name added; raw_instcod preserves original OSEP/instcod

*===============================================================================
*/

preserve
	tempfile cross_walk	

	keep 	panelid refyr instcod

	rename 	instcod osep

	keep if inlist(refyr, 1993, 1995)
	keep if !inlist(osep,"","L")

	merge m:1 osep using "data/raw/osep_to_iped_rev2014", keep(1 3) nogen
	
	keep panelid refyr osep iped
	
	save 	`cross_walk'
restore

merge m:1 panelid refyr using `cross_walk', nogen 

replace iped=instcod if iped==""

*Now I add the labels. This the official file supplied by the NSF
merge m:1 iped using "data/raw/inst_labels", keepusing(inst_name) keep(1 3) nogen

rename instcod 	raw_instcod
rename iped 	instcod

drop osep