/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	estimates institution fixed effects using job satisfaction as dependent variable and creates second-stage regressions

*   Input: data/output/final_database_clean_with_dummies.dta
*          data/output/institution_level_database_clean.dta
*          SDR job satisfaction data (extracted from multiple survey years)
*   Output: data/temporary/job_satisfaction.dta
*           data/temporary/estimates_jobsat_fe_*.dta
*           results/regressions/regression_satisfaction_ts*.ster
					

*===============================================================================
*/



do "code/build_database/regression_programs.do"

cap program drop update_connected_set
program define update_connected_set
	
	tempfile torestore
	save `torestore'
	{
		*Next I need to recompute the connected set
		keep panelid acad_spell_id instcod jobsatis
			

		
		
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

		export delimited "data/temporary/job_satisfaction_R_clean.csv", replace  delimiter(";") quote 
		
		rscript using "code/build_database/connectedness_job_satisfaction.R"
		
		import delimited "data/temporary/job_satisfaction_R_clean_connectedness.csv", clear ///
			 stringcols(2) 
		
		tempfile connected_set_file 
		save `connected_set_file'
	}
	
	use `torestore'
	drop network
	merge m:1  instcod using `connected_set_file', keep(3)
	
	keep if network==1


end 





cap program drop get_jobsat_data_yr
program define get_jobsat_data_yr
	syntax, year(str)

	use ${sdr`year'} , clear

	di "`year'"
	rename *, lower

	descr *sat*
	
	keep refid refyr jobsatis
	
	destring jobsatis, replace  force
	

	
	label define jobsatis 1 "Very satisfied" 2 "Somewhat satisfied" 3 "Somewhat dissatisfied" 4 "Very dissatisfied"
	
	label values jobsatis jobsatis
	
	generate sat_vsat=jobsatis==1 if !missing(jobsatis)
	generate sat_sat=jobsatis<=2 if !missing(jobsatis)
end

cap program drop get_jobsat_data 
program define get_jobsat_data 
	local year_list 97  03 06 08 10 13 15 17 19
	foreach year in `year_list' {
		get_jobsat_data_yr, year(`year')
		
		tempfile sat`year'
		save `sat`year''
	}

	clear
	foreach year in `year_list' {
		append using `sat`year''
		
		drop if missing(jobsatis)
	}
	
	save "data/temporary/job_satisfaction", replace
end



cap program drop get_jobsat_estimates
program define get_jobsat_estimates
	syntax, [NOsen]
	
	if "`nosen'"!=""{
		local stub _nosen
	}
	
	use "data/output/final_database_clean_with_dummies.dta", clear

	merge 1:1 refid refyr using "data/temporary/job_satisfaction",  keep(3) /// 
		nogen
		
	merge m:1  instcod  using "data/output/institution_level_database_clean", keep(3) ///
		nogen
	
	update_connected_set 
	
	*Basic specification
	local base_spec  ib3.institution_type#c.l_inst_ranking_p ib3.institution_type 
	 
	
	get_spec, type(fs:jobsat) `nosen'

	foreach spec in unife controls allcontrol sscontrol base {
		local `spec' `r(`spec')'
	}
	
	
	*These are the controls I progressively add
	local add_control_list 	ib3.new_locale 		///
							l_enrollment_total_m  ///
							i.ug_only  i.control
	
	*I set the sample I need to create all the regressions
	cap reghdfe sat_vsat  `controls' `sscontrol' ,  ///
		vce(cl instcod) absorb(	i.panelid) keepsingletons
	generate in_regression=e(sample)
	
	keep if in_sample==1
	
	eststo clear
	*I start by estimating the one-step estimates
	foreach yvar in sat_vsat sat_sat {
		eststo os1`yvar': areg `yvar' `base' `controls' ib3.new_locale  , vce(cl instcod) absorb(panelid) 
		unique panelid if e(sample)
		estadd scalar n_people=`r(unique)'
		
		est save "results/regressions/regression_satisfaction_os1`yvar'`stub'", replace
		
		eststo os2`yvar': areg `yvar' `base' `controls' ib3.new_locale l_enrollment_total_m , vce(cl instcod) absorb( panelid) 
		unique panelid if e(sample)
		estadd scalar n_people=`r(unique)'

		est save "results/regressions/regression_satisfaction_os2`yvar'`stub'", replace
		
		
		eststo os3`yvar': areg `yvar' `base' `controls' ib3.new_locale l_enrollment_total_m i.ug_only  i.control, vce(cl instcod) absorb(panelid) 
		unique panelid if e(sample)
		estadd scalar n_people=`r(unique)'
		
		estimates save  "results/regressions/regression_satisfaction_os3`yvar'`stub'", replace
	
		*Add institution dummies
		cap drop u_instcod*
		
		*Create institution dummies
		sort panelid acad_spell_id

		cap drop n_instcod
		destring instcod, generate(n_instcod)
	
		eststo ts`yvar': areg `yvar' `unife' `controls' , ///
			absorb(panelid) vce(cl instcod)	
			
		*Finally I recover the estimates
		preserve
			regsave
			
			split var, parse(".")
			
			keep if var2=="n_instcod"
			
			rename var1 instcod
*******************************************************************************************************
			replace instcod=???? if instcod==????b
			
			keep instcod coef stderr
			
			rename coef e`yvar'`sub'
			rename stderr se`yvar'`sub'
		
			save "data/temporary/estimates_jobsat_fe_`yvar'`stub'", replace
		restore
	}

	*Next I produce the second stage estimates
	use "data/output/institution_level_database_clean", clear
	cap drop _merge
	merge 1:1 instcod using "data/temporary/estimates_jobsat_fe_sat_vsat`stub'", keep(3) nogen 
	merge 1:1 instcod using "data/temporary/estimates_jobsat_fe_sat_sat`stub'", keep(3) nogen 

	
	foreach yvar in sat_vsat sat_sat {
		*No controls
		qui wregress e`yvar' `base'  , ///
			se(se`yvar') stub(m1)
		estimates restore m1ss
		estimates save  "results/regressions/regression_satisfaction_ts1`yvar'`stub'", replace
		
		*add location
		qui wregress e`yvar' `base'  ///
			ib3.new_locale , ///
			se(se`yvar') stub(m2)
		estimates restore m2ss
		estimates save  "results/regressions/regression_satisfaction_ts2`yvar'`stub'", replace
			
		*add enrollment and university type
		qui wregress  e`yvar' `base' ///
			ib3.new_locale   l_enrollment_total_m ///
			 i.ug_only i.control, ///
			se(se`yvar') stub(m3)
		estimates restore m3ss
		estimates save  "results/regressions/regression_satisfaction_ts3`yvar'`stub'", replace
	}
end



get_jobsat_data

get_jobsat_estimates

get_jobsat_estimates, nosen

