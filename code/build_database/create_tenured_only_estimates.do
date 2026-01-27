/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates AKM estimates restricted to tenured faculty only

*   Input: data/output/final_database_*_with_dummies.dta
*   Output: data/output/final_database_clean_tenured_only*.dta
*           data/output/tenured_only_estimates_*.dta
*           results/regressions/AKM_faculty_only*.ster
*           data/temporary/tenured_only_R_*.csv (for R connectedness analysis)
					

*===============================================================================
*/

*Creating estimates based on tenured faculty only.

do "code/build_database/regression_programs.do"


cap program drop get_tenured_est
program define get_tenured_est
	syntax, d_type(str) [NOsen]
	
	if "`nosen'"!="" {
		local stub _nosen
	}
	
	use "data/output/final_database_`d_type'_with_dummies.dta", clear
		
	*I keep tenured faculty only
	keep if tenured_f==1
	
	
	tab observation_type
	
	*I update the person class
	do "code/build_database/update_observation_type.do" 1
	
	tab observation_type
	
	drop if missing(l_r_salary)
	
	tempfile to_restore_faculty
	save `to_restore_faculty'
	
	{
		*Next I need to recompute the connected set
		keep panelid acad_spell_id instcod l_r_salary
			

		
		
		*Now I compute output the file to compute the connected set
		
		keep panelid acad_spell_id instcod 
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
			keep panelid spell instcod 
			rename instcod instcod_origin
		save `origin_list'

		use `to_restore', clear
		keep 	destination_id instcod panelid  
		rename 	instcod instcod_dest
		drop 	if destination_id==0
		rename 	destination_id spell

		merge 1:1 panelid spell using `origin_list', keep(1 3) nogen

		export delimited "data/temporary/tenured_only_R_`d_type'.csv", replace  delimiter(";") quote 
		
		rscript using "code/build_database/connectedness_tenured_faculty.R"
		
		import delimited "data\temporary\tenured_only_R_`d_type'_connectedness.csv", clear ///
			 stringcols(2) 
		
		tempfile connected_set_file 
		save `connected_set_file'
	}
	
	use `to_restore_faculty'
	drop network
	merge m:1  instcod using `connected_set_file', keep(3)
	
	keep if network==1
	
	unique instcod 
	
	*Note we are left with 450 institutions when I limit my sample to only tenured faculty

	*Add institution dummies
	cap drop u_instcod*
	
	*Create institution dummies
	sort panelid acad_spell_id

	destring instcod, generate(n_instcod)
	
	*Now I run the AKM regressions
	keep panelid acad_spell_id years_since_phd tenured_f faculty_rank_f married female /// 
		l_r_salary has_ch* refyr instcod n_instcod time_current_job_f

	
	
	
	get_spec, type(fs:tenured) `nosen'
	foreach spec in unife controls allcontrol sscontrol base {
		local `spec' `r(`spec')'
	}
	 

	local model all_clust

	rename l_r_salary l_r_salary_f

	
	summ panelid
	unique panelid
	
	*In this bit I am getting estimates of the fe without se.
	eststo tenured_only: cap reghdfe l_r_salary_f  `unife' `controls', ///
			absorb(indiv_fe=panelid refyr, savefe) nocons ///
			keepsingleton vce(cl instcod)
	
	
	save "data/output/final_database_clean_tenured_only`stub'", replace
	
	estimates save "results/regressions/AKM_faculty_only`stub'", replace
	
	est restore tenured_only
	
	*Finally I recover the estimates
	regsave
	
	split var, parse(".")
	
	keep if var2=="n_instcod"
	
	rename var1 instcod
	*********************************************************************************************************************************************
	replace instcod="????" if instcod=="????b"
	
	keep instcod coef stderr
	
	rename coef tenured_only_premium
	rename stderr stderr_tenured
	
	save "data/output/tenured_only_estimates_`d_type'`stub'", replace	
end 


foreach d_type in  clean {
	get_tenured_est, d_type(`d_type')
	
	get_tenured_est, d_type(`d_type') nosen
	
}