
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (garromar@bu.edu)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu) 
*
*Description: creates one-step AKM estimates comparing current versus origin institution effects, controlling for both current and previous institution characteristics to analyze faculty mobility patterns
*
*Input files:
*	- data/output/final_database_clean_with_dummies.dta
*	- data/output/institution_level_database_clean
*
*Output files:
*	- results/tables/table_p_vineay_results.tex
*	- results/tables/table_p_vineay_results.csv
*===============================================================================
*/


capture program drop clean_origin_database
program define clean_origin_database 
	*First I drop people with missing time in current job
	
	drop if missing(time_current_job_f)
	
	do "code/build_database/update_observation_type.do" 1

	summ panelid if observation_type
	
	do "code/build_database/update_acad_spell_id.do"
	
	*Next I need to compute the connected set
	do "code/build_database/output_connected_set.do" time_job_filter

	
	
	summ panelid
	unique panelid
	unique panelid if observation_type==1
	
	cap drop u_instcod_1-network
	
	xi i.instcod, prefix(u_) noomit
	
	local cw_file  "data/temporary/institution_dummy_crosswalk_time_job_filter"
	preserve
		*Here I create create a dummy-label index
		collapse (mean) u_*, by(instcod inst_name)
		unique instcod

		*Note: stata is assigning dummies using the order of instcod
		generate inst_number=_n
		order inst_number, after(inst_name)
		
		save `cw_file', replace
	restore
	
	drop u_instcod_253
	egen check=rowtotal(u_instcod*)
		
******************************************** NOTE TO ANYONE REPLICATING THIS CODE.  REPLACE ???? WITH THE BEST RANKED SCHOOL 
******************************************** BE CONSISTENT ACROSS PROGRAMS

	assert check==0 if instcod=="????"
	
	cap drop check
end

cap program drop create_p_vinay_regressions
program define create_p_vinay_regressions 
	*Basic specification
	local base_spec  ib3.institution_type ib3.institution_type#c.l_inst_ranking_p  time_current_job_f
	
	local origin_spec ib3.o_institution_type ib3.o_institution_type#c.o_l_inst_ranking_p  
	
	*I merge the institution level information
	*Creating estimation files
	eststo clear
	local controls 			i.tenured_f ib3.faculty_rank_f 

	local baseline_controls `base_spec' `controls'
	local full_controls 	`base_spec' `origin_spec' `controls'
	
	*These are the controls I progressively add
	local add_control_list 	ib3.new_locale 		///
							l_enrollment_total_m  ///
							i.ug_only  i.control
							
	*These are the controls I progressively add
	local add_o_control_list 	ib3.o_new_locale 		///
							o_l_enrollment_total_m  ///
							i.o_ug_only  i.o_control
	
	*I set the sample I need to create all the regressions
	regress l_r_salary `full_controls' `add_control_list' `add_o_control_list', vce(cl instcod) 
	cap drop in_regression
	generate in_regression=e(sample)
		
	
	cap drop indivfe
	
	local fe year
	
	unique panelid 
	local n_people=`r(unique)'
	
	*These regressions use all individual data
	eststo m0: cap reghdfe l_r_salary `baseline_controls' if in_regression, ///
		vce(cl instcod ) absorb(`fe') keepsingletons
	estadd scalar n_people=`n_people'
	eststo m1: cap reghdfe l_r_salary `full_controls' if in_regression, ///
		vce(cl instcod ) absorb(`fe') keepsingletons
	estadd scalar n_people=`n_people'	
	eststo m2: cap reghdfe l_r_salary `full_controls' `add_control_list' if in_regression, ///
		vce(cl instcod ) absorb(`fe') keepsingletons
	estadd scalar n_people=`n_people'	
	eststo m3: cap reghdfe l_r_salary `full_controls'  `add_control_list' `add_o_control_list' if in_regression, ///
		vce(cl instcod ) absorb(`fe') keepsingletons
	estadd scalar n_people=`n_people'
	
		
	*These regressions use only the first salary
	sort refid acad_spell_id refyr
	cap drop first_year
	by refid acad_spell_id: generate first_year=_n==1
	
	
	eststo f0: reghdfe l_r_salary `baseline_controls' if in_regression&first_year, ///
		vce(cl instcod ) absorb(`fe') keepsingletons
	estadd scalar n_people=`n_people'
	eststo f1: reghdfe l_r_salary `full_controls' if in_regression&first_year, ///
		vce(cl instcod ) absorb(`fe') keepsingletons
	estadd scalar n_people=`n_people'	
	eststo f2: reghdfe l_r_salary `full_controls' `add_control_list' if in_regression&first_year, ///
		vce(cl instcod ) absorb(`fe') keepsingletons
	estadd scalar n_people=`n_people'
	eststo f3: reghdfe l_r_salary `full_controls'  `add_control_list' `add_o_control_list' if in_regression&first_year, ///
		vce(cl instcod ) absorb(`fe') keepsingletons
	estadd scalar n_people=`n_people'
end

capture program drop create_p_vinay_table
program define create_p_vinay_table 


	local origin_list 		*o_new_locale 		///
							o_l_enrollment_total_m  ///
							*o_ug_only  *o_control

	local destination_list 		*.new_locale 		///
							l_enrollment_total_m  ///
							*.ug_only  *.control

	local subtitles  1.institution_type#c.l_inst_ranking_p "\textit{Current: institution type $ \times $ log of rank}" ///
	 1.o_institution_type#c.o_l_inst_ranking_p "\textit{Origin: institution type $ \times $ log of rank}", nolabel
	
	
	local stats stats(N n_people r2 r2_within, ///
		label("\midrule Observations" "Number of people" "$ R^2$" "Within $ R^2$" ) fmt(%9.0fc %9.0fc  %9.3fc   %9.3fc))
	
	local table_title	"Current vs origin university effects"
	local name  table_p_vineay_results
	local root "results/tables/"
	local csv_table_name="`root'"+"`name'"+".csv"
	local tex_table_name="`root'"+"`name'"+".tex"
	local table_notes "ADD NOTES"

	local coltitles		

	local relabel coeflabel(  1.institution_type#c.l_inst_ranking_p `"${texspace}Research university"' ///
		  2.institution_type#c.l_inst_ranking_p `"${texspace}College"' ///
		  1.o_institution_type#c.o_l_inst_ranking_p `"${texspace}Research university"' ///
		  2.o_institution_type#c.o_l_inst_ranking_p `"${texspace}College"' )
	local  common_options  keep(*l*ranking* *time*) ///
			order(*l*ranking* *time*)  ///
			nomtitles noomit nobase nostar ///
			`stats' ///
			indicate("Destination university characteristics=`destination_list'" "Origin institution characteristics=`origin_list'", label("$\checkmark$" "") ) ///
			refcat(`subtitles') ///
			par se(4) b(4) label `relabel'
		
	
	*Writing tex table 
	textablehead using `tex_table_name', ncols(4) title(`table_title') ct(\scshape)
	esttab m* using `tex_table_name',  f collabels(none)  `common_options' ///
		append tex  plain 
	textablefoot  using `tex_table_name', notes(`table_notes') nodate
			

end


local d_type clean

*I prepare the dataset to add institution chars
use "data/output/institution_level_database_`d_type'", clear
keep instcod institution_type l_inst_ranking_p new_locale l_enrollment_total_m  ///
						ug_only  control
tempfile current
save `current'

*I prepare the dataset to add institution chars
use "data/output/institution_level_database_`d_type'", clear
keep instcod institution_type l_inst_ranking_p l_inst_ranking_p new_locale l_enrollment_total_m  ///
						ug_only  control

rename * o_*
tempfile origin
save `origin'


use "data/output/final_database_`d_type'_with_dummies.dta", clear

*Clean all the database
clean_origin_database
	
preserve
	*First I get the instcod of origin
	keep refid acad_spell_id instcod
	
	duplicates drop
	
	sort refid acad_spell_id
	
	by refid: generate o_instcod=instcod[_n-1]
	keep if o_instcod!=""
	
	drop instcod
	
	tempfile o_instcod
	save `o_instcod'
restore 

merge m:1 refid acad_spell_id using `o_instcod', keep(3) nogen 
merge m:1 instcod using `current', keep(3) nogen 
merge m:1 o_instcod using `origin', keep(3) nogen 

qui create_p_vinay_regressions


label var time_current_job_f "Years in current job"

create_p_vinay_table

	