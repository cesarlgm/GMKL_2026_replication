

/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	computes correlations between individual fixed effects (net of field) and institution fixed effects

*   Input: data/output/final_database_*_with_dummies.dta
*          data/output/institution_level_database_*.dta
*          data/additional_processing/indiv_fe_estimates_*.dta
*   Output: results/tables/corr_net_field_collapsed*.csv
					

*===============================================================================
*/


cap program drop residualize_field
program define residualize_field
	syntax, d_type(str) [NOsen]

	if "`nosen'"!="" {
		local stub _nosen
	}
	
	*===========================================================================
	*UNCOLLAPSED ESTIMATION
	*===========================================================================
	use "data/output/final_database_`d_type'_with_dummies.dta", clear
	
	merge m:1  instcod  using "data/output/institution_level_database_`d_type'", keep(3)
	
	merge m:1  panelid  using "data/additional_processing/indiv_fe_estimates_`d_type'`stub'.dta", nogen keep(3)
		
	*Fixing minor fields 
	gen minorfield=ndgmeng
	replace minorfield= dgrmeng if minorfield==. & dgrmeng !=.
	replace minorfield = 61 if minorfield>60 & minorfield!=.

	
	label define minorfield 11 " Computer and information sciences" ///
	12 " Mathematics and statistics" ///
	21 " Agricultural and food sciences" ///
	22 " Biological sciences" ///
	23 " Environmental life sciences" ///
	31 " Chemistry, except biochemistry" ///
	32 " Earth, atmospheric and ocean sciences" ///
	33 " Physics and astronomy" ///
	34 " Other physical sciences" ///
	41 " Economics" ///
	42 " Political and related sciences" ///
	43 " Psychology" ///
	44 " Sociology and anthropology" ///
	45 " Other social sciences" ///
	51 " Aerospace, aeronautical and astronautical engineering" ///
	52 " Chemical engineering" ///
	53 " Civil and architectural engineering" ///
	54 " Electrical and computer engineering" ///
	55 " Industrial engineering" ///
	56 " Mechanical engineering" ///
	57 " Other engineering" ///
	61 " Health" ///
	71 " Management and administration fields" ///
	72 " Education, except science and math teacher education" ///
	73 " Social service and related fields" ///
	75 " Art and Humanities Fields", modify
	label values minorfield minorfield


	
	misstable summ minorfield
	table minorfield
	
	regress indiv_fe i.minorfield
	
	predict r_indiv_fe, residuals

		
	pwcorr indiv_fe l_inst_ranking_p
	pwcorr r_indiv_fe l_inst_ranking_p
	

	pwcorr indiv_fe l_inst_ranking_p if institution_type==1

	pwcorr indiv_fe l_inst_ranking_p if institution_type==2
	
	pwcorr r_indiv_fe l_inst_ranking_p if institution_type==1
	
	pwcorr r_indiv_fe l_inst_ranking_p if institution_type==2
	
	pwcorr r_indiv_fe inst_fe`stub'
	
	local uc_corr: display %9.3fc `r(rho)'
	
	preserve
	clear
	set obs 1
	generate corr=`uc_corr'
	export delimited using "results/tables/corr_net_field_uncollapsed`stub'.csv", replace
	restore 
	

	*===========================================================================
	*COLLAPSED ESTIMATION	
	*===========================================================================
	use "data/output/final_database_`d_type'_with_dummies.dta", clear

	
	*Fixing minor fields 
	gen minorfield=ndgmeng
	replace minorfield= dgrmeng if minorfield==. & dgrmeng !=.
	replace minorfield = 61 if minorfield>60 & minorfield!=.

	gcollapse (mean) u_instcod* years_since_phd l_r_salary_f (max) has*  married ///
		female tenured_f faculty_rank_f minorfield time_current_job, fast by(panelid acad_spell_id instcod)
	
	generate years_since_phd_sq=years_since_phd*years_since_phd
	
	eststo clear
	
	get_spec, type(fs:main) `nosen'

	foreach spec in unife controls allcontrol sscontrol base {
		local `spec' `r(`spec')'
	}

	local model all_clust
	
	*In this bit I am getting estimates of the fe without se.
	eststo `model': cap reghdfe l_r_salary_f  `unife' `controls', ///
			absorb(indiv_fe=panelid, savefe) nocons ///
			keepsingleton vce(cl instcod)
	
	estfe . *
	
	preserve
	tempfile `model'_fe		
		
	parmest, saving(``model'_fe', replace)

	use ``model'_fe', clear 
	
	generate to_keep=regexm(parm, "u_instcod")
	drop if !to_keep
	
	split parm, parse("_")
	
	rename parm3 inst_number
	destring inst_number, replace
	
	rename estimate `model'
	rename stderr 	se_`model'
	rename p		p_`model'
	*********************************************************************************************************************************************
	*I do this because ???? is the 271th institution
	keep 		inst_number `model' se_`model' p_`model'
	
	save ``model'_fe', replace
	restore
	
	
	merge m:1 instcod using "data/additional_processing/institution_dummy_crosswalk_clean", ///
		nogen keep(1 3)
	merge m:1 inst_number using ``model'_fe'

	replace all_clust=0 if instcod=="166027"
	
	cap drop indiv_fe
	*Creating estimation files
	eststo clear
				
				

	local model all_clust

	get_spec, type(fs:main)  `nosen'
		
	
	foreach spec in unife controls allcontrol sscontrol base {
		local `spec' `r(`spec')'
	}

		
	*In this bit I am getting estimates of the fe without se.
	eststo raw: cap reghdfe l_r_salary_f  `unife' `controls', ///
			absorb(indiv_fe=panelid, savefe) nocons ///
			keepsingleton vce(cl instcod)
		
	
	cap drop r_indiv_fe
	regress indiv_fe i.minorfield
	predict r_indiv_fe, residuals
	
	merge m:1  instcod  using "data/output/institution_level_database_`d_type'", keep(3) nogen keepusing(l_inst_ranking_p institution_type)


	pwcorr r_indiv_fe all_clust
	
	local c_corr: display %9.3fc `r(rho)'
	
	preserve
	clear
	set obs 1
	generate c_corr=`c_corr'
	export delimited using "results/tables/corr_net_field_collapsed`stub'.csv", replace
	restore 

	
	di as result "Correlations with log of rankings, without residualizing"
	pwcorr indiv_fe l_inst_ranking_p if institution_type==1
	
	pwcorr indiv_fe l_inst_ranking_p if institution_type==2
	

	
	di as result "Correlations with log of rankings, net of field"	
	pwcorr r_indiv_fe l_inst_ranking_p if institution_type==1
	
	pwcorr r_indiv_fe l_inst_ranking_p if institution_type==2


end 


foreach d_type in raw  clean {
	residualize_field, d_type(`d_type')
	
	residualize_field, d_type(`d_type') nosen
	
}
