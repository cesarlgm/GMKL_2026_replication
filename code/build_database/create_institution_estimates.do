/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	estimates AKM institution fixed effects and individual pay premiums

*   Input: data/temporary/final_database_*_with_dummies.dta (if source=="temporary")
*          data/output/final_database_*_with_dummies.dta (if source=="final")
*          data/temporary/institution_dummy_crosswalk_*.dta or data/additional_processing/institution_dummy_crosswalk_*.dta
*   Output: data/temporary/dummy_estimates_file_*.dta or data/additional_processing/dummy_estimates_file_*.dta
*           data/temporary/indiv_fe_estimates_*.dta or data/additional_processing/indiv_fe_estimates_*.dta
*           results/regressions/*_*.ster (regression estimates)
					

*===============================================================================
*/
*/

local source `1'

do "code/build_database/regression_programs.do"

cap program drop estimate_fe 
program define estimate_fe
	syntax, output(str) d_type(str) spec(str) reg_output(str) cw_file(str) [ NOsen ]
	
	di "`nosen'"
	
	get_spec, type(fs:main) `nosen'

	foreach spec in unife controls allcontrol sscontrol base {
		local `spec' `r(`spec')'
	}
	


	local model all_clust


	if "`nosen'"!="" {
		local stub _nosen
	}

		
	*In this bit I am getting estimates of the fe without se.
	eststo `model': cap reghdfe l_r_salary_f  `unife' `controls', ///
			absorb(indiv_fe=panelid refyr, savefe) nocons ///
			keepsingleton vce(cl instcod)
	
	estfe . *
	
	do "code/build_database/update_observation_type.do"
	
	unique panelid if observation_type==1
	
	local n_movers=`r(unique)'
	
	estadd scalar n_movers=`n_movers'
	
	log using "results/log_files/corr_inst_ind_fe_`d_type'.txt", text replace
	corr indiv_fe 
	log close
	
	estimates save "`reg_output'/`model'_`d_type'`stub'", replace

	
	

	preserve
		keep panelid indiv_fe
		duplicates drop
		save "data/`output'/indiv_fe_estimates_`d_type'`stub'.dta", replace
	restore

	local estimation_list all_clust

	foreach estimation in `estimation_list' {
		estimates use "`reg_output'/`estimation'_`d_type'`stub'"
		tempfile `estimation'_fe		
		
		parmest, saving(``estimation'_fe', replace)

		use ``estimation'_fe', clear 
		
		generate to_keep=regexm(parm, "u_instcod")
		drop if !to_keep
		
		split parm, parse("_")
		
		rename parm3 inst_number
		destring inst_number, replace
		
		rename estimate `estimation'
		rename stderr 	se_`estimation'
		rename p		p_`estimation'
		*I do this because ???? is the ??? institution
		keep 		inst_number `estimation' se_`estimation' p_`estimation'
		save 		``estimation'_fe', replace
	}

	clear

	use  `all_clust_fe'

	merge 1:1 inst_number using "`cw_file'", ///
		nogen keep(1 3)
		
	drop u_instcod*
	
	

	save "data/`output'/dummy_estimates_file_`d_type'`stub'", replace
end



if "`source'"=="temporary" {
	local output "temporary"
	local reg_output "data/temporary"
}
else {
	local output "additional_processing"
	local reg_output "results/regressions"
}

foreach d_type in  raw clean {
	if "`source'"=="temporary" { 
		local use_file "data/temporary/final_database_`d_type'_with_dummies.dta"
		local cw_file  "data/temporary/institution_dummy_crosswalk_`d_type'"
	}
	else {
		local use_file "data/output/final_database_`d_type'_with_dummies.dta"
		local cw_file  "data/additional_processing/institution_dummy_crosswalk_`d_type'"
	}
		
	use "`use_file'", clear
	
	estimate_fe, spec(fs:main) d_type(`d_type') output(`output') reg_output(`reg_output') cw_file(`cw_file')

	use "`use_file'", clear
	if "`source'"!="temporary" {
		estimate_fe, spec(fs:main) d_type(`d_type') output(`output')  reg_output(`reg_output') cw_file(`cw_file') nosen
	}
	
}
