/*
*===============================================================================
*Project: Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu) 
*
*Description: creates tables analyzing pay premiums and rankings specifically for tenured faculty, comparing results with all faculty
*
*Input files:
*	- data/output/institution_level_database_*
*	- data/additional_processing/final_institution_list_medical
*	- data/output/tenured_only_estimates_*[_nosen]
*
*Output files:
*	- results/tables/table_tenured_*[_nosen].tex
*	- results/tables/table_tenured.csv
*===============================================================================
*/


cap program drop create_tab_tenured
program define create_tab_tenured
	syntax, sample(str) [NOsen]

	if "`nosen'"=="" {
		local stub _nosen
	}
	
	use "data/output/institution_level_database_`sample'", clear
	
******************************************** NOTE TO ANYONE REPLICATING THIS CODE.  REPLACE ???? WITH THE BEST RANKED SCHOOL 
******************************************** BE CONSISTENT ACROSS PROGRAMS

	replace inst_fe=0 if instcod=="????"
	replace inst_fe`stub'=0 if instcod=="????"
	replace inst_fe_trim=0 if instcod=="????"
	
	replace se_inst_fe=0 if instcod=="????"
	replace se_inst_fe`stub'=0 if instcod=="????"

	merge 1:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3)  nogen

	drop if todrop==1

	merge 1:1 instcod using "data/output/tenured_only_estimates_`sample'`stub'", keep(3)  nogen
	
	
	eststo clear 
	
	local texspace \hspace{3mm}
	*Relabelling variables to make the table prettier
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
		
	
	

	*Regression with no additional controls
	local base_spec  ib3.institution_type#c.l_inst_ranking_p ib3.institution_type 

	*Dummies of offering undergrad degree only, private/public university
	qui wregress tenured_only_premium `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control, ///
		se(se_inst_fe) stub(m6)
		
	estimates restore m6ss
		
	cap drop in_sample
	generate in_sample=e(sample)

	
	*Dummies of offering undergrad degree only, private/public university
	qui wregress inst_fe`stub' `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control if in_sample, ///
		se(se_inst_fe`stub') stub(m6)
	
	*Dummies of offering undergrad degree only, private/public university
	qui wregress tenured_only_premium `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control if in_sample, ///
		se(stderr_tenured) stub(f6)
	
	
		*===============================================================================	
	*COMPUTATION OF F-TESTS
	*===============================================================================
	foreach model in m6 f6 {
		estimates restore `model'ss

		estimates restore `model'ss
		test  1.institution_type 1.institution_type#l_inst_ranking_p  2.institution_type 2.institution_type#l_inst_ranking_p 

		estadd scalar 	all_F=r(F)
		estadd scalar 	all_p=r(p)
		
		estimates restore `model'ss
		test 1.institution_type#l_inst_ranking_p 2.institution_type#l_inst_ranking_p

		estadd scalar 	rank_F=r(F)
		estadd scalar 	rank_p=r(p)
		
		eststo `model'ss
	}
	
	{
		local table_name   "results/tables/table_tenured_`sample'`stub'.tex"
		local table_title	"Pay premiumns and rankings for tenured faculty"
		local table_key 	"tab:tenured"
		local coltitles		`""All faculty""Tenured \\ faculty""'
		local n_cols			2
		local table_notes 	"ADD NOTES"
		local keepvar *locale*  *control *ug_*   *enrollment*
		local models m6ss f6ss
		
		textablehead using `table_name', ncols(`n_cols') title(`table_title') ///
			coltitles(`coltitles')  exhead(`exhead') adjust(1) ct(\scshape) key(`table_key')
		leanesttab `models' using `table_name', keep(*institution_type `keepvar' *institution_type#c.l_*) ///
		nomtitles noomit nobase nostar ///
		stats(f_title rank_F rank_p  t_title all_F all_p N r2, ///
			label("Joint significance of 2 rank variables" "${texspace} F statistic" "${texspace} p-value"  "Joint significance of university type and rank variables" "${texspace} F statistic" "${texspace} p-value"   "\midrule Observations" "$ R^2$") fmt(%9.3fc  %9.3fc  %9.3fc %9.3fc  %9.3fc  %9.3fc  %9.0fc  %9.3fc  )) ///
			refcat(1.institution_type "\textit{Institution type (omitted=unranked)}" ///
			1.institution_type#c.l_inst_ranking_p "\textit{Institution type $ \times $ ln of rank (low ranks best)}" ///
			1.new_locale "\textit{Institution characteristics}", nolabel) ///
			format(4) append
		textablefoot using `table_name', notes(`table_notes') nodate 
	}	
end 

create_tab_tenured, sample(clean)

create_tab_tenured, sample(clean) nosen

/*
foreach database in clean {
	use "data/output/institution_level_database_`database'", clear
******************************************** NOTE TO ANYONE REPLICATING THIS CODE.  REPLACE ???? WITH THE BEST RANKED SCHOOL 
******************************************** BE CONSISTENT ACROSS PROGRAMS
	
	replace inst_fe=0 if instcod=="????"
	replace inst_fe_trim=0 if instcod=="????"
	
	replace se_inst_fe=0 if instcod=="????"

	merge 1:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3)  nogen

	drop if todrop==1

	merge 1:1 instcod using "data/output/tenured_only_estimates_`database'", keep(3)  nogen
	
	
	eststo clear 
	
	local texspace \hspace{3mm}
	*Relabelling variables to make the table prettier
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
		
	
	

	*Regression with no additional controls
	local base_spec  ib3.institution_type ib3.institution_type#c.l_inst_ranking_p

	*Dummies of offering undergrad degree only, private/public university
	qui wregress tenured_only_premium `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control, ///
		se(se_inst_fe) stub(m6)
		
	estimates restore m6ss
		
	cap drop in_sample
	generate in_sample=e(sample)

	
	*Dummies of offering undergrad degree only, private/public university
	qui wregress inst_fe `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control if in_sample, ///
		se(stderr_tenured) stub(m6)
	
	*Dummies of offering undergrad degree only, private/public university
	qui wregress tenured_only_premium `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control if in_sample, ///
		se(stderr_tenured) stub(f6)
	
	
		*===============================================================================	
	*COMPUTATION OF F-TESTS
	*===============================================================================
	foreach model in m6 f6 {
		estimates restore `model'ss

		estimates restore `model'ss
		test  1.institution_type 1.institution_type#l_inst_ranking_p  2.institution_type 2.institution_type#l_inst_ranking_p 

		estadd scalar 	all_F=r(F)
		estadd scalar 	all_p=r(p)
		
		estimates restore `model'ss
		test 1.institution_type#l_inst_ranking_p 2.institution_type#l_inst_ranking_p

		estadd scalar 	rank_F=r(F)
		estadd scalar 	rank_p=r(p)
		
		eststo `model'ss
	}
	
	
	
	
	*Write csv tables
	{
		local table_name   "results/tables/table_tenured.csv"
		local table_title	"Pay premiumns and rankings for tenured faculty"
		local ftitle		"Dependent variable: log earnings"
		local coltitles		
		local n_cols			2
		local table_notes_raw 		"standard errors in parenthesis. We normalized one institution fixed-effect to zero"
		local table_notes_clean 		"excludes extreme within-institution wage changes. Standard errors in parenthesis. We normalized one institution fixed-effect to zero"
		local keepvar *locale*  *control *ug_*   *enrollment*
		local models m6ss f6ss
		
		esttab `models' using `table_name', keep(*institution_type `keepvar' *institution_type#c.l_*) ///
		nomtitles label noomit nobase nostar ///
		stats(t_title all_F all_p f_title rank_F rank_p c_title rho_uni rho_coll   N r2, ///
			label("Joint significance of university type and ranking interactions" "${texspace} F statistic" "${texspace} p-value"  "Joint significance of ranking interactions" "${texspace} F statistic" "${texspace} p-value"  "\midrule Observations" "$ R^2$") fmt(%9.3fc  %9.3fc  %9.3fc %9.3fc  %9.3fc  %9.3fc %9.3fc  %9.3fc  %9.3fc  )) ///
			refcat(1.institution_type "Institution type (omitted=unranked)" ///
			1.institution_type#c.l_inst_ranking_p "Institution type $ \times $ ranking" ///
			1.new_locale "Institution characteristics", nolabel) ///
			title(`table_title') note(`table_notes_`database'') csv replace se(4) b(4)
	}	
		
}
	