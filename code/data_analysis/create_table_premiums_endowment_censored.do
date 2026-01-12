*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	Garro-Marin, Kahn and Lang
	Purpose: 	creates table relating premiums/salary to endowments
*/
*===============================================================================


cap program drop label_regvars
program define label_regvars 
	*Relabelling variables to make the table prettier
	local texspace="\hspace{3mm}"
	
	label define 	new_type 		1 "`texspace'Research university" 2 "`texspace'College", modify
	label define	control			2 "`texspace'Private institution", modify
	label define	new_locale		1 "`texspace'Large city" 2 "`texspace'Medium city" 3 "`texspace'Small city", modify
	label var 		ug_only 		"`texspace'Offers only undergraduate degree"
		
	label var 	l_inst_ranking_p 	"log of university ranking"
	label var 	inst_ranking_p 		"university ranking"
	label var 	l_enrollment_total_m "`texspace'Log of total enrollment" 
	label var 	l_r_endowment_per_student "`texspace'Log of endowment per student"
	label var 	l_faculty_per_student "`texspace'Log of faculty per student" 
	label define ug_only 1 "`texspace'Undergrad only", modify
end 


*This program creates the table relating premiums/salary to endowments 
cap program drop create_endo_tab
program define create_endo_tab
	syntax, sample(str) [ttype(str)]

		
	*Setting the type of specification of be used
	*stub gives the file name extension
	*fe_stub gives the file name extension for the two-step FE
	*os_stub gives the file name extension for the one-step estimates
	if "`ttype'"=="" {
		local stub 
		local fe_stub
		local os_stub
		local y_var inst_fe
		local se_var se_inst_fe
		local timevar time_current_job_f
		local coeflab time_current_job_f  "Time in current job"
	}
	else if "`ttype'"=="nosen" {
		local stub _nosen
		local fe_stub _nosen
		local os_stub _nosen
		local y_var inst_fe_nosen
		local se_var se_inst_fe_nosen
		local timevar 
		local coeflab
	}
	else if "`ttype'"=="mixed" {
		local fe_stub _nosen
		local y_var inst_fe_nosen
		local se_var se_inst_fe_nosen
		local os_stub
		local stub _mixed
		local timevar time_current_job_f
		local coeflab time_current_job_f  "Time in current job"
	}
	
	
	
	if "`sample'"=="raw" {
		local title_stub "(including salary outliers)"
	}
	
	use "data/output/institution_level_database_`sample'", clear
******************************************** NOTE TO ANYONE REPLICATING THIS CODE.  REPLACE ???? WITH THE BEST RANKED SCHOOL 
******************************************** BE CONSISTENT ACROSS PROGRAMS
	
	replace inst_fe=0 if instcod=="????"
	replace inst_fe_trim=0 if instcod=="????"
	replace inst_fe_nosen=0 if instcod=="????"
	
	replace se_inst_fe=0 if instcod=="????"
	replace se_inst_fe_nosen=0 if instcod=="????"


	merge 1:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3)  nogen

	drop if todrop==1

	*Label variables for the output
	label_regvars
	
	eststo clear 
	
	*Regression with no additional controls
	local base_spec  l_r_endowment_per_student ib3.institution_type 

	*Dummies of offering undergrad degree only, private/public university
	qui wregress `y_var' `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control, ///
		se(`se_var') stub(m6)
		
	estimates restore m6ss
		
	cap drop in_sample
	generate in_sample=e(sample)


	*Baseline
	qui wregress `y_var' `base_spec' if in_sample, ///
		se(`se_var') stub(m1)
		

	*Location
	qui wregress `y_var' `base_spec'  ///
		ib3.new_locale if in_sample, ///
		se(`se_var') stub(m2)

		
	*Enrollment
	qui wregress `y_var' `base_spec' ///
		ib3.new_locale   l_enrollment_total_m ///
		 i.ug_only i.control  if in_sample, ///
		se(`se_var') stub(m3)
		
	*===============================================================================	
	*ONE STEP ESTIMATES
	*===============================================================================
	
	use panelid instcod using "data/output/final_database_`sample'_with_dummies.dta", clear
	
	merge m:1 panelid using "data/additional_processing/indiv_fe_estimates_`sample'`fe_stub'.dta", nogen
	
	merge m:1 instcod using "data/output/institution_level_database_`sample'", nogen
	
	forvalues j=1/3 {
		estimates restore m`j'ss
		
		corr indiv_fe l_inst_ranking_p if institution_type==1

		estadd scalar rho_uni=`r(rho)'
		
		corr indiv_fe l_inst_ranking_p if institution_type==2
		
		estadd scalar rho_coll=`r(rho)'
	}
	
	*Reading one step estimates
	{
		forvalues j=1/3{ 
			estimates use "results/regressions/one_step_endowment_`j'_`sample'`os_stub'"
					
			eststo os`j'
		}
	}
	
	
	
	*Writing tex tables
	{
		local table_name "results/tables/table_premiums_endowment_`sample'`stub'.tex"
		local table_title "Does endowment increase institution premiums? `title_stub'"
		local table_key "tab:premiums_endo_`sample'"
		local n_cols	6
		local exhead "&\multicolumn{3}{c}{\scshape Two-step estimates}&\multicolumn{3}{c}{\scshape One-step estimates}\\ \cmidrule(lr){2-4} \cmidrule(lr){5-7}"
		local table_notes "ADD NOTES"
		local coltitles
		local models m1ss m2ss m3ss os1 os2 os3
		
		local keepvar  *locale*  *control *ug_*   *enrollment* `timevar'
		
		textablehead using `table_name', ncols(`n_cols') title(`table_title') ///
			coltitles(`coltitles')  exhead(`exhead') adjust(1) ct(\scshape) 
	
		leanesttab `models' using `table_name', format(4) ///
		keep(l_r_endowment_per_student *institution_type `keepvar')  ///
		nomtitles nostar nobase noomit ///
		coeflabel(`coeflab' l_r_endowment_per_student "ln(endowment per student)" ) ///
		stats(N r2, ///
			label( "\midrule Observations" "$ R^2$") fmt( %9.0fc  %9.3fc  )) ///
			refcat(1.institution_type "\textit{Institution type (omitted=unranked)}" ///
			1.new_locale "\textit{Institution characteristics}", nolabel) append 
	
		textablefoot using `table_name', notes(`table_notes') nodate 
	}
end 

create_endo_tab, sample(raw)

create_endo_tab, sample(clean)



create_endo_tab, sample(raw) ttype(nosen)

create_endo_tab, sample(clean) ttype(nosen)


*Two-step: no seniority
*One-step: seniority
create_endo_tab, sample(raw) ttype(mixed)

create_endo_tab, sample(clean) ttype(mixed)