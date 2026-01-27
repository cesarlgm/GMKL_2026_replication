/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates one-step estimates that directly regress wages on rankings and institutional characteristics with individual fixed effects

*   Input: data/output/final_database_*_with_dummies.dta
*          data/output/institution_level_database_*.dta
*   Output: results/regressions/one_step_*_*.ster
*           results/regressions/one_step_nofe_*_*.ster
*           results/regressions/one_step_endowment_*_*.ster
*           results/regressions/one_step_twc_endowment_*_*.ster
					

*===============================================================================
*/



cap program drop get_onestep
program define get_onestep 
	syntax, d_type(str) [NOsen]

	if "`nosen'"!="" {
		local stub _nosen
	}
	
	use "data/output/final_database_`d_type'_with_dummies.dta", clear
	
	merge m:1  instcod  using "data/output/institution_level_database_`d_type'"
	
	*Basic specification
	local base_spec  ib3.institution_type ib3.institution_type#c.l_inst_ranking_p
	

	get_spec, type(fs:main) `nosen'
	
	foreach spec in unife controls allcontrol sscontrol base {
		local `spec' `r(`spec')'
	}
								
	
	*I set the sample I need to create all the regressions
	cap reghdfe l_r_salary_f `base' `controls' `sscontrol', vce(cl instcod) absorb(i.refyr i.panelid) keepsingletons
	generate in_regression=e(sample)
	
	*I relabel the variables to have a nice table
	do "code/data_analysis/regression_var_relabel.do"
		
		
		
	cap drop indivfe
		
	qui eststo m1: cap reghdfe l_r_salary_f `base' `controls' if in_regression, ///
		vce(cl instcod) absorb(i.refyr indivfe=i.panelid, savefe) keepsingletons
	
	corr indivfe l_inst_ranking_p if institution_type==1

	estadd scalar rho_uni=`r(rho)'
	
	corr indivfe l_inst_ranking_p if institution_type==2
	
	estadd scalar rho_coll=`r(rho)'

	eststo  m1	
	
	cap drop indivfe
	qui eststo n1: cap reghdfe l_r_salary_f `base' `controls' if in_regression, ///
		vce(cl instcod) absorb(i.refyr, savefe) keepsingletons
	
	cap drop indivfe
	qui eststo mc1: cap reghdfe l_r_salary_f `base' `controls' if in_regression, ///
		vce(cl instcod panelid) absorb(i.refyr indivfe=i.panelid, savefe) keepsingletons
	
	corr indivfe l_inst_ranking_p if institution_type==1

	estadd scalar rho_uni=`r(rho)'
	
	corr indivfe l_inst_ranking_p if institution_type==2
	
	estadd scalar rho_coll=`r(rho)'

	eststo  mc1	
	
	local full_controls `base' `controls'
		
	local counter=2
	foreach variable in `sscontrol' { 
		local full_controls `full_controls' `variable'
		
		cap drop indivfe
			
		qui eststo m`counter':  cap reghdfe l_r_salary_f `full_controls' if in_regression, ///
			vce(cl instcod) absorb(i.refyr indivfe=i.panelid, savefe) keepsingletons
		
		corr indivfe l_inst_ranking_p if institution_type==1
	
		estadd scalar rho_uni=`r(rho)'
		
		corr indivfe l_inst_ranking_p if institution_type==2
		
		estadd scalar rho_coll=`r(rho)'
	
		eststo  m`counter'
		
		cap drop indivfe
		qui eststo n`counter':  cap reghdfe l_r_salary_f `full_controls' if in_regression, ///
			vce(cl instcod) absorb(i.refyr , savefe) keepsingletons
		
		
		local full_controls `full_controls' `variable'
		
		cap drop indivfe
			
		qui eststo mc`counter': cap reghdfe l_r_salary_f `full_controls' if in_regression, ///
			vce(cl instcod panelid) absorb(i.refyr indivfe=i.panelid, savefe) keepsingletons
		
		corr indivfe l_inst_ranking_p if institution_type==1
	
		estadd scalar rho_uni=`r(rho)'
		
		corr indivfe l_inst_ranking_p if institution_type==2
		
		estadd scalar rho_coll=`r(rho)'
	
		eststo  mc`counter'
		
		
		local ++counter
		
		
		
	}
	
	foreach j in 1 2 3 4 5 {
		estimates restore m`j'
		test  1.institution_type 1.institution_type#l_inst_ranking_p 
		
		estadd scalar	uni_F=r(F)
		estadd scalar 	uni_p=r(p)
	
		
		test  2.institution_type 2.institution_type#l_inst_ranking_p 
		
		estadd scalar	coll_F=r(F)
		estadd scalar 	coll_p=r(p)
		
		test 1.institution_type 1.institution_type#l_inst_ranking_p 2.institution_type 2.institution_type#l_inst_ranking_p 
		estadd scalar	all_F=r(F)
		estadd scalar 	all_p=r(p)

		test 1.institution_type#l_inst_ranking_p 2.institution_type#l_inst_ranking_p

		estadd scalar 	rank_F=r(F)
		estadd scalar 	rank_p=r(p)
		
		eststo  m`j'
		
		estimates save "results/regressions/one_step_`j'_`d_type'`stub'", replace
	}
	
	
	foreach j in 1 2 3 4 5 {
		estimates restore n`j'
		estimates save "results/regressions/one_step_nofe_`j'_`d_type'`stub'", replace
	}
		
		
		
		
	foreach j in 1 2 3 4  5 {
		estimates restore mc`j'
		test  1.institution_type 1.institution_type#l_inst_ranking_p 
		
		estadd scalar	uni_F=r(F)
		estadd scalar 	uni_p=r(p)
	
		
		test  2.institution_type 2.institution_type#l_inst_ranking_p 
		
		estadd scalar	coll_F=r(F)
		estadd scalar 	coll_p=r(p)
		
		test 1.institution_type 1.institution_type#l_inst_ranking_p 2.institution_type 2.institution_type#l_inst_ranking_p 
		estadd scalar	all_F=r(F)
		estadd scalar 	all_p=r(p)

		test 1.institution_type#l_inst_ranking_p 2.institution_type#l_inst_ranking_p

		estadd scalar 	rank_F=r(F)
		estadd scalar 	rank_p=r(p)
		
		eststo  mc`j'
		
		estimates save "results/regressions/one_step_twc_`j'_`d_type'`stub'", replace
	}
		
	*ENDOWMENT REGRESSIONS
	get_spec, type(fs:endowment) `nosen'
	
		
	foreach spec in unife controls allcontrol sscontrol base {
		local `spec' `r(`spec')'
	}
	
	*Basic specification
	local base_spec  ib3.institution_type 
	


	local full_controls `base' `controls'
	
	eststo clear
	cap drop indivfe
	qui eststo e1: cap reghdfe l_r_salary_f l_r_endowment_per_student `full_controls' if in_regression, ///
		vce(cl instcod) absorb(i.refyr indivfe=i.panelid, savefe) keepsingletons

	cap drop indivfe
	qui eststo e2: cap reghdfe l_r_salary_f l_r_endowment_per_student `full_controls' ib3.new_locale if in_regression, ///
		vce(cl instcod) absorb(i.refyr indivfe=i.panelid, savefe) keepsingletons

	cap drop indivfe
	qui eststo e3: cap reghdfe l_r_salary_f l_r_endowment_per_student `full_controls' ib3.new_locale l_enrollment_total_m i.ug_only i.control if in_regression, ///
		vce(cl instcod) absorb(i.refyr indivfe=i.panelid, savefe) keepsingletons

		
	forvalues j=1/3 {
		estimates restore e`j'
		estimates save  "results/regressions/one_step_endowment_`j'_`d_type'`stub'", replace
	}

	eststo clear
	cap drop indivfe
	qui eststo e1: cap reghdfe l_r_salary_f l_r_endowment_per_student `full_controls' if in_regression, ///
		vce(cl instcod panelid) absorb(i.refyr indivfe=i.panelid, savefe) keepsingletons

	cap drop indivfe
	qui eststo e2: cap reghdfe l_r_salary_f l_r_endowment_per_student `full_controls' ib3.new_locale if in_regression, ///
		vce(cl instcod panelid) absorb(i.refyr indivfe=i.panelid, savefe) keepsingletons

	cap drop indivfe
	qui eststo e3: cap reghdfe l_r_salary_f l_r_endowment_per_student `full_controls' ib3.new_locale l_enrollment_total_m i.ug_only i.control if in_regression, ///
		vce(cl instcod panelid) absorb(i.refyr indivfe=i.panelid, savefe) keepsingletons
	
		
	forvalues j=1/3 {
		estimates restore e`j'
		estimates save  "results/regressions/one_step_twc_endowment_`j'_`d_type'`stub'", replace
	}
end


foreach d_type in raw  clean {

	*I merge the institution level information
	*Creating estimation files
	get_onestep, d_type(`d_type')
	
	get_onestep, d_type(`d_type') nosen	
}
