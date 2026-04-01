/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Restricts the dataset to the largest connected set of institutions.
*					Exports a mover transition list (origin→destination institution pairs)
*					to a CSV file, calls an R script to identify the connected network,
*					merges the network indicator back, and keeps only observations linked
*					to that network (network==1). Reclassifies individuals as switchers
*					(observation_type==1) or non-switchers (observation_type==0) and
*					recomputes n_spells after the restriction.

*   Input: 		Argument 1: file name stem used for intermediate CSV files
*				Default frame in memory (requires panelid, acad_spell_id, instcod, inst_name)
*				code/build_database/connected_set_execute.R (called via rscript)
*				data/temporary/<file_name>_executed.csv (produced by R script)
*   Output: 	data/temporary/<file_name>.csv (mover transition list, input to R script)
*				Default frame restricted to connected-set institutions; adds observation_type
*				(0=non-switcher, 1=switcher) and recomputes n_spells
					

*===============================================================================
*/





local file_name `1'

preserve
	keep panelid acad_spell_id instcod inst_name
	duplicates drop

	cap drop n_spells
	*Here I count how many times do I see the person
	egen n_spells=	count(acad_spell_id), by(panelid)
	drop if 		n_spells==1
	drop 			n_spells


	sort panelid acad_spell_id
	by panelid: generate spell=_n
	by panelid: generate origin_id=spell
	by panelid: generate destination_id=spell-1

	tempfile to_restore
	save `to_restore'
		
	tempfile origin_list
		keep panelid spell instcod inst_name
		rename instcod instcod_origin
		rename inst_name origin_name
	save `origin_list'

	use `to_restore', clear
	keep 	destination_id instcod panelid inst_name 
	rename 	instcod instcod_dest
	drop 	if destination_id==0
	rename 	destination_id spell

	merge 1:1 panelid spell using `origin_list', keep(1 3) nogen

	export delimited using "data/temporary/`file_name'.csv", replace delimiter(";") quote
restore

*Execute R part, for now this does not work
local input_file "data/temporary/`file_name'.csv"
local output_file "data/temporary/`file_name'_executed.csv"


rscript using "code/build_database/connected_set_execute.R", ///
	args(`input_file' `output_file')

preserve
	tempfile institution_filter
	import delimited using `output_file', clear
	tostring instcod, replace
	save `institution_filter', replace
restore

cap drop _merge
cap drop network
merge m:1 instcod using `institution_filter', nogen

table network
keep if network==1

cap drop n_spells
gegen n_spells=nunique(acad_spell_id), by(panelid)

cap drop observation_type
generate observation_type=n_spells>1

cap label define observation_type 0 "Non-switcher" 1 "Switcher"

label values observation_type observation_type