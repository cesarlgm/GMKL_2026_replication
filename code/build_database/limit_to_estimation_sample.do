/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	applies sample restrictions to create the estimation sample
					

*===============================================================================
*/





do "code/build_database/regression_programs.do" //REQUESTED

foreach database in raw clean {
	use "data/temporary/final_database_`database'_with_dummies.dta", clear
	
	merge m:1  instcod  using "data/temporary/institution_level_database_`database'", keep(3) nogen
	merge m:1 instcod using "data/raw/final_institution_list_medical", keep(1 3) 

	cap drop _merge
	drop if todrop==1

	cap drop _merge


	*Basic specification
	local base_spec  ib3.institution_type ib3.institution_type#c.l_inst_ranking_p


	*I merge the institution level information
	*Creating estimation files
	
	
	get_spec, type(fs:main)
	
	
	foreach spec in unife controls allcontrol sscontrol base {
		local `spec' `r(`spec')'
	}

	*I set the sample I need to create all the regressions
	cap reghdfe l_r_salary_f `base' `controls' `allcontrol', vce(cl instcod) absorb(i.refyr i.panelid) keepsingletons
	generate in_regression=e(sample)


	drop if !in_regression
	
	keep panelid period
	
	save "data/additional_processing/estimation_sample_`database'_key", replace

}