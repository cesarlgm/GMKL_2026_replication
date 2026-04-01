/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Defines and calls output_kss_datasets, which prepares the
*					analysis dataset for KSS leave-one-out variance correction.
*					The "full" variant exports observation-level data; the
*					"collapsed" variant collapses to the spell level via gcollapse.

*   Input: 		data/output/final_database_clean_with_dummies.dta
*   Output: 	data/temporary/file_KSS_connected_clean.csv
*				data/temporary/file_KSS_connected_clean_collapsed.csv


*===============================================================================
*/
cap program drop output_kss_datasets
program define output_kss_datasets
	syntax, dbase(str)

	
	local d_type clean 
	
	if "`dbase'"=="full" {
		use "data/output/final_database_`d_type'_with_dummies.dta", clear
		
		gegen n_periods=nunique(period), by(panelid)
		
		drop if n_periods==1
		
		keep panelid acad_spell_id years_since_phd tenured_f faculty_rank_f married female /// 
			l_r_salary has_ch* refyr instcod

		
		generate years_since_phd_sq=years_since_phd*years_since_phd

		foreach variable of varlist has_ch* married { 
			generate int_`variable'=female*`variable'
		}
		
		
		export delimited "data/temporary/file_KSS_connected_`d_type'.csv", replace  delimiter(";") quote 
	}
	else if "`dbase'"=="collapsed" {
		
		use "data/output/final_database_`d_type'_with_dummies.dta", clear
		
		gegen n_periods=nunique(period), by(panelid)
		
		drop if n_periods==1
		
		keep panelid acad_spell_id years_since_phd tenured_f faculty_rank_f married female /// 
			l_r_salary has_ch* refyr instcod
		

		gcollapse (mean) years_since_phd l_r_salary (max) female_f faculty_rank_f tenured_f married has_ch_6 has_ch_611 has_ch_1218 has_ch_19, by(panelid acad_spell_id instcod)
		
		generate years_since_phd_sq=years_since_phd*years_since_phd

		foreach variable of varlist has_ch* married { 
			generate int_`variable'=female*`variable'
		}
		
		
		export delimited "data/temporary/file_KSS_connected_`d_type'_collapsed.csv", replace  delimiter(";") quote 
	}

end 

output_kss_datasets, dbase(full)

output_kss_datasets, dbase(collapsed)