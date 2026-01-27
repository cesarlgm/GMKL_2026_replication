*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Purpose:	converts osep to iped + adds institution labels
*/
*==============================================================================

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