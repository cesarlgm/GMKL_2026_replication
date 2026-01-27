/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	exports datasets for variance correction estimation in R

*   Input: data/output/final_database_*_with_dummies.dta
*   Output: data/temporary/file_for_R_regression_*.csv
*           data/temporary/file_for_R_regression_collapsed_*.csv
					

*===============================================================================
*/

*Generating dataset for estimation in R

foreach database in raw clean {
	use "data/output/final_database_`database'_with_dummies.dta", clear


	keep panelid acad_spell_id u_instcod* years_since_phd tenured_f faculty_rank_f married female /// 
		l_r_salary has_ch* refyr instcod time_current_job_f
		
	generate years_since_phd_sq=years_since_phd*years_since_phd

	foreach variable of varlist has_ch* married { 
		generate int_`variable'=female*`variable'
	}


	export delimited "data/temporary/file_for_R_regression_`database'.csv", replace


	gcollapse (mean) u_instcod* years_since_phd l_r_salary time_current_job_f (max) has* int* married ///
		female tenured_f faculty_rank_f, fast by(panelid acad_spell_id instcod)


	generate years_since_phd_sq=years_since_phd*years_since_phd

	export delimited "data/temporary/file_for_R_regression_collapsed_`database'.csv", replace
}
