
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates institution dummy variables for AKM estimation with Harvard as reference

*   Input: data/output/individual_database_raw.dta
*          data/output/individual_database_clean.dta
*          data/additional_processing/estimation_sample_*_key.dta (if database_type=="final")
*   Output: data/temporary/final_database_*_with_dummies.dta (if database_type=="temporary")
*           data/output/final_database_*_with_dummies.dta (if database_type=="final")
*           data/temporary/institution_dummy_crosswalk_*.dta or data/additional_processing/institution_dummy_crosswalk_*.dta
					

*===============================================================================
*/

*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Purpose: 	adds institution dummies to the dataset
*/
*===============================================================================
local database_type `1'


*I execute this chunk of code if this is the first pass at estimation
if "`database_type'"=="temporary" {
	local ?????
	local ????? 

	foreach d_type in raw clean {
	use "data/output/individual_database_`d_type'", clear

	

	*Making sure there is no person with unknown universities
	drop if instcod=="999999"

	*Create institution dummies
	sort panelid acad_spell_id

	*Creates full set of university fixed effects.
	xi i.instcod, noomit prefix(u_)

	preserve
		*Here I create create a dummy-label index
		collapse (mean) u_*, by(instcod inst_name)
		unique instcod

		*Note: stata is assigning dummies using the order of instcod
		generate inst_number=_n
		order inst_number, after(inst_name)
		
		save "data/temporary/institution_dummy_crosswalk_`d_type'", replace
	restore

	*Make sure that harvard is the reference institution
	*Setting harvard as reference institution
	drop u_instcod_`harvard_index_`d_type''

	*Getting individual level premiums
	cap drop l_r_salary_f
	generate l_r_salary_f=log(r_salary_f)
	
	egen check=rowtotal(u_instcod*)
	assert check==0 if instcod=="166027"

	save "data/temporary/final_database_`d_type'_with_dummies.dta", replace
}
}
else {
	*Else I just read the dummies and rewrite the institution cross walk
	local ????
	local ????
		
	foreach d_type in raw  clean {	
		use "data/output/individual_database_`d_type'", clear
		merge 1:1 panelid period using "data/additional_processing/estimation_sample_`d_type'_key", keep(3) nogen
		
		*I verify that all institutions are appropriately connected
		do "code/build_database/drop_unconnected_unis" "estimation_sample_filter_`d_type'"
		
		*Creates full set of university fixed effects.
		xi i.instcod, noomit prefix(u_)

		preserve
			*Here I create create a dummy-label index
			collapse (mean) u_*, by(instcod inst_name)
			unique instcod

			*Note: stata is assigning dummies using the order of instcod
			generate inst_number=_n
			order inst_number, after(inst_name)
			
			save "data/additional_processing/institution_dummy_crosswalk_`d_type'", replace
		restore
		
		drop u_instcod_`harvard_index_`d_type''

		*Getting individual level premiums
		cap drop l_r_salary_f
		generate l_r_salary_f=log(r_salary_f)
		
		egen check=rowtotal(u_instcod*)
		assert check==0 if instcod==????
		

		save "data/output/final_database_`d_type'_with_dummies.dta", replace
	}
}

