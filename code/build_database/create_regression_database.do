/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates institution-level database for second-stage regressions by merging AKM estimates with institutional characteristics and rankings

*   Input: data/temporary/dummy_estimates_file_*.dta or data/additional_processing/dummy_estimates_file_*.dta
*          data/additional_processing/dummy_estimates_file_*_nosen.dta (if source!="temporary")
*          data/output/iped_university_rank_cw.dta
*          data/output/iped_college_rank_cw.dta
*          data/output/clean_ipeds.dta
*   Output: data/temporary/institution_level_database_*.dta or data/output/institution_level_database_*.dta
					

*===============================================================================
*/

local source  `1'

if "`source'"=="temporary" {
	local output "temporary"
}
else {
	local output "output"
}

foreach database in raw   clean {
	
	if "`source'"!="temporary" {
		local keepvars  inst_fe_nosen se_inst_fe_nosen 
	
		use "data/`source'/dummy_estimates_file_`database'_nosen", clear
		
		keep all_clust se_all_clust instcod
		
		rename all_clust inst_fe_nosen
		rename se_all_clust se_inst_fe_nosen
		
		tempfile nosen
		save `nosen'
	}
	
	use  "data/`source'/dummy_estimates_file_`database'", clear 
	
	if "`source'"!="temporary" {
		merge 1:1 instcod using  `nosen', keep(1 3) nogen
	}
	
	cap drop _merge
	XXXX
	
	order instcod inst_name, first

	merge 1:1 instcod using "data/output/iped_university_rank_cw", nogen
	merge 1:1 instcod using "data/output/iped_college_rank_cw", nogen


	*Now I add the cleaned iped database
	merge 1:1 instcod using "data/output/clean_ipeds" ,nogen keep(1 2 3)
	
	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
	drop if missing(all_clust)&instcod!=????


	*FINAL CLEANING OF INSTITUTION VARIABLES
	*==================================================================
	*There is only a for profit college, thus it doesn't really make sense to have a separate category
	replace control=2 if control==3
	label drop label_control
	label define control 1 "Public" 2 "Private"
	label values control control

	*Harvard is clasified as being in a medium city
	replace new_locale=6 if missing(new_locale)

	*Here I reclassify new locale
	replace new_locale=2 if new_locale==4
	replace new_locale=3 if inlist(new_locale,3,5,6)
	label drop new_locale
	label define new_locale 1 "Large city" 2 "Medium city/suburb" 3 "Small city"
	label values new_locale new_locale


	cap generate l_faculty_total_m=log(faculty_total_m)

	*Windsorizing institution fixed effects
	gstats winsor all_clust, trim cuts(2.5 99)
	rename all_clust_tr all_clust_w

	*Institution fixed-effects
	label variable all_clust "Institution fixed-effect"
	rename all_clust inst_fe

	label variable all_clust_w "Trimmed instituition fixed-effect"
	rename all_clust_w inst_fe_trim


	*Handling of the ranking variables
	*==================================================================
	cap generate institution_type=.
	cap generate inst_ranking=.

	replace institution_type=1 if !missing(score_uni)
	replace institution_type=2 if !missing(score_coll)&missing(score_uni)
	replace institution_type=3 if missing(score_coll)&missing(score_uni)

	label define institution_type 1 "Research university" 2 "College" 3 "No ranking"
	label values institution_type institution_type

		
	replace inst_ranking=rank_uni 	if institution_type==1
	replace inst_ranking=rank_coll 	if institution_type==2
	replace inst_ranking=0 			if institution_type==3


	*Manual correction to institution rankings
	XXXX

	*Labelling variables
	rename se_all_clust se_inst_fe
	label var se_inst_fe "Standard error from inst f.e."
	rename score_uni raw_score_uni
	rename score_coll raw_score_coll
	label variable raw_score_uni 			"Raw university score"
	label variable raw_score_coll 			"Raw university score"
	label variable	l_r_endowment_per_student "Log of endowment per student"
	label variable	l_enrollment_total 		"Log of total enrollment"
	label variable	l_enrollment_grad_m 	"Log of graduate enrollment"
	label variable	l_enrollment_ugrad_m 	"Log of undergraduate enrollment"
	label variable 	grants_medical 			"Grants medical degree"
	label variable control 					"Whether public or private"
	label variable hbcu 					"Historically black college or university"
	label variable new_locale 				"Whether in small, medium, large city"
	label variable ug_only 					"Offers only undergrad degree"
	label variable offers_master 			"Highest offering is a master degree"
	label variable institution_type 				"Indicates type of ranking the instituition has"
	label variable l_faculty_per_student 		"Log of faculty per student"
	label variable l_faculty_total_m 		"Log of total faculty"
	label variable l_r_endowment 			"Log of total endowment"
	label variable instcod 					"IPED code"
	label variable offers_phd 				"Highest offering is a PHD"
	label variable has_hospital 			"Institution has a hospital"
	label var 		years_in_data 			"Number of years I see the school in IPEDs"
	label variable 	rank_uni  				"Position in THE university  ranking(lower means better)"
	label variable 	rank_coll 				"Position in THE college  ranking(lower means better)"



	order instcod inst_name inst_fe*, first

	label define grants_medical 0 "No medical degree" 1 "Medical degree"

	label define ug_only 1 "Undergrad only"
	label define offers_master 1 "Offers up to master only"

	label values ug_only ug_only
	label values offers_master offers_master

	drop if inst_name==""
	preserve

		
	tempfile name_cw
		import excel "data/raw/unranked_list.xlsx", sheet("cw_sheet") firstrow clear
	save `name_cw'

	tempfile state
	use "data/raw/inst_labels", clear
	rename iped instcod
	keep instcod inst_state
	save `state'

	restore

	compress

	merge 1:1 instcod using `state', nogen  keep(1 3)

	sort institution_type

	merge 1:1 inst_name using  `name_cw', nogen  keep(1 3)
	replace inst_name=link_name if link_name!=""

	cap drop link_name 


	rename inst_state state
	replace state=strtrim(lower(state))
	drop if instcod==""
	

	*Fixing instution names for the merging
	do "code/build_database/fix_ranking_fe_names.do"



	preserve
		use "data/raw/us_news_rankings_v2.dta", clear
		
		*Fixing instution names for the merging
		do "code/build_database/fix_ranking_database_names.do"


		duplicates drop inst_name, force
		
		drop if rank==""

		tempfile us_news_rankings
		save `us_news_rankings'
	restore

	drop if instcod==""
***************************************************************************************
	replace state="ca" if inst_name==XXXX 

	*No unranked institution appears in the midwest_colleges rankings
	merge 1:1 inst_name state using `us_news_rankings'

	sort inst_name


	replace the_rank=inst_rank if missing(the_rank)&!missing(rank_uni)
	replace the_rank=rank_coll if missing(the_rank)&!missing(rank_coll)

	replace us_rank=. if us_rank==-1

	rename r_endowment_per_student endowment_per_student

	*IMPUTE RANKINGS 
	do "code/build_database/impute_rankings"
	
	
	drop if missing(inst_fe)&instcod!=????

	cap drop inst_ranking

	generate 	inst_ranking=0
	replace 	inst_ranking=rank_uni if new_type==1
	replace 	inst_ranking=rank_coll if new_type==2

	generate inst_ranking_r= -inst_ranking


	generate  inst_ranking_p=0

	generate  inst_ranking_p_r=0

	forvalues j=1/2 {
		xtile temp`j'=inst_ranking if new_type==`j', nq(100)
		replace inst_ranking_p=temp`j' if new_type==`j'
		
		replace inst_ranking_p_r=100-inst_ranking_p if new_type==`j'
	}
	
	drop temp*

	generate 	l_inst_ranking_p=inst_ranking_p
	replace 	l_inst_ranking_p=log(inst_ranking_p) if new_type!=3


	label var inst_ranking "raw ranking pos, 1=best school, linear imputation"
	label var l_inst_ranking_p "log of rank, 1=best school, linear imputation"
	label var inst_ranking_r "raw ranking pos, -1=best school, linear imputation"
	label var l_inst_ranking_p "log of rank, 1=best school, linear imputation"


	*Excluding variables I don´t need
	keep instcod inst_name inst_fe inst_fe_trim se_inst_fe `keepvars' ///
		enrollment_grad_m enrollment_ugrad_m enrollment_total_m ///
		l_enrollment_grad_m l_enrollment_ugrad_m l_enrollment_total_m ///
		faculty_total_m l_r_endowment years_in_data has_hospital grants_medical ///
		control hbcu ug_only new_locale l_faculty_total_m l_faculty_per_student ///
		endowment_per_student l_r_endowment_per_student institution_type state ///
		new_type imputed_ranking ///
		inst_ranking inst_ranking_r inst_ranking_p inst_ranking_p_r l_inst_ranking_p ///
		imputed_ranking
	drop institution_type

	rename new_type institution_type


	*Final labelling
	label var inst_name "Institution name"
	label var enrollment_grad_m "Graduate enrollment"
	label var enrollment_ugrad_m "Undergraduate enrollment"
	label var enrollment_total_m "Total enrollment"
	label var faculty_total_m 	"Total faculty"
	label var state "State"
	label var institution_type "Ranking type"
	label var inst_ranking "Institution ranking, includes imputations"
	label var inst_ranking_p "Institution ranking, percentile, 1=best"
	label var  inst_ranking_p_r "Institution rankin, percentile, 1=worst"
	label var  imputed_ranking "Indicates wether ranking was imputed"

	order instcod inst_name inst_fe* institution_type imputed_ranking inst_ranking ///
		inst_ranking_r inst_ranking_p inst_ranking_p_r l_inst_ranking_p enrollment_grad_m enrollment_ugrad_m  ///
		enrollment_total_m faculty_total_m l_enrollment_grad_m l_enrollment_ugrad_m ///
		l_enrollment_total_m l_r_endowment l_enrollment_grad_m l_enrollment_ugrad_m ///
		l_enrollment_total_m l_r_endowment, first

	save "data/`output'/institution_level_database_`database'", replace	
}