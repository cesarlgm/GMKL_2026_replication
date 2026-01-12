*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Inputs:		93-17 waves of Survey of Doctorate Recipients.
				
	Outputs:	dataset for second_stage regressions.
*/
*===============================================================================

local source  "additional_processing"

 
foreach database in  clean {
	use  "data/`source'/dummy_estimates_file_`database'", clear 
	
	replace inst_name="univ southern ca san diego" if instcod=="124821"
	replace inst_name="univ southern ca sacramento" if instcod=="124742"
	
	replace inst_name="harvard university" if instcod=="166027"

	order instcod inst_name, first

	merge 1:1 instcod using "data/output/iped_university_rank_cw", nogen

	merge 1:1 instcod using "data/output/iped_college_rank_cw", nogen


	*Now I add the cleaned iped database
	merge 1:1 instcod using "data/output/clean_ipeds" ,nogen keep(1 2 3)
	
	replace inst_name="harvard university" if instcod=="166027"
	
	****  NOTE TO PEOPLE REPLICATING.  REPLACE ??? WITH THE CODE OF THE BEST RANKED UNIVERSITY
	drop if missing(all_clust)&instcod!="????"


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
	replace rank_uni= . 		if inst_name == "indiana university of pennsylvania-main campus"
	replace institution_type=3 	if inst_name == "indiana university of pennsylvania-main campus"
	replace rank_uni = 225 		if inst_name== "cuny system office"
	replace rank_uni = 150 		if inst_name == "indiana university bloomington"
	replace institution_type=1  if inst_name == "indiana university bloomington"
	replace rank_uni = 225 		if inst_name== "cuny graduate school and university center"
	replace institution_type=1  if inst_name== "cuny graduate school and university center"
	replace rank_uni = 41  		if inst_name=="scripps research institute"
	replace institution_type=1  if inst_name=="scripps research institute"
	replace rank_uni = 141		if inst_name=="robert wood johnson univ diagnostic lab"
	replace institution_type=1  if inst_name=="robert wood johnson univ diagnostic lab"


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

	replace state="ca" if inst_name=="uc merced"

	*No unranked institution appears in the midwest_colleges rankings
	merge 1:1 inst_name state using `us_news_rankings'

	sort inst_name


	replace the_rank=inst_rank if missing(the_rank)&!missing(rank_uni)
	replace the_rank=rank_coll if missing(the_rank)&!missing(rank_coll)

	replace us_rank=. if us_rank==-1

	rename r_endowment_per_student endowment_per_student

	
	*RANKINGS TO USE FOR IMPUTATION
	local r_type national liberal north south midwest west north_colleges  south_colleges west_colleges midwest_colleges


	replace rank_coll=the_rank if !missing(the_rank)&missing(rank_coll)&institution_type!=1
	replace institution_type=2 if !missing(rank_coll)&institution_type!=1


	generate rank_uni_w=rank_uni
	generate rank_coll_w=rank_coll
	foreach ranking in `r_type' {
	if "`ranking'"=="national" {
			local yvar rank_uni
		}
		else {
			local yvar rank_coll
		}
		
		*OLS
		eststo `ranking': reg `yvar' us_rank if rank_type=="`ranking'"
		cap drop r_`ranking'
		predict r_`ranking' if rank_type=="`ranking'"
		replace `yvar'=r_`ranking' if institution_type==3&!missing(r_`ranking')
		
		*WEIGHTED OLS
		eststo `ranking'_w: reg `yvar' us_rank [aw=us_rank] if rank_type=="`ranking'"
		cap drop r_`ranking'
		predict r_`ranking' if rank_type=="`ranking'"
		replace `yvar'_w=r_`ranking' if institution_type==3&!missing(r_`ranking')
	}

	*OUTPUTTING REGRESSION TABLES
	*===============================================================================
	esttab national liberal north south midwest west north_colleges south_colleges midwest_colleges ///
		west_colleges using "results/tables/table_A3.csv", label  ///
		mtitles(National Liberal North South Midwest West North South Midwest West) ///
		nostar stats(r2 F N) coeflab(us_rank `"US News ranking"') par se(%9.3fc) ///
		replace
		
	cap drop r_*
	*===============================================================================


	cap drop new_type
	cap drop inst_rank
	generate 	new_type=3
	replace 	new_type=1 	if institution_type==1|(institution_type==3&!missing(rank_uni))
	replace		new_type=2 	if institution_type==2|(institution_type==3&!missing(rank_coll))


	generate imputed_ranking=institution_type!=new_type

	label define imputed_ranking 0 "Not imputed" 1 "Imputed ranking`'"

	label define new_type 1 "Research university" 2 "Colleges" 3 "No ranking"
	label values new_type new_type



	*TABLE WITH HOW MANY SCHOOLS WAS I ABLE TO IMPUTE
	*===============================================================================
	*Here I output the number of schools I imputing
	generate rank_type_o=.
	replace rank_type_o=1 if rank_type=="national"
	replace rank_type_o=2 if rank_type=="liberal"
	replace rank_type_o=3 if rank_type=="north"
	replace rank_type_o=4 if rank_type=="south"
	replace rank_type_o=5 if rank_type=="west"
	replace rank_type_o=6 if rank_type=="midwest"
	replace rank_type_o=7 if rank_type=="north_colleges"
	replace rank_type_o=8 if rank_type=="south_colleges"
	replace rank_type_o=9 if rank_type=="west_colleges"
	replace rank_type_o=10 if rank_type=="midwest_colleges"

	labmask rank_type_o, values(rank_type)

	estpost tabulate rank_type_o if  !missing(us_rank)&missing(the_rank)&!missing(inst_fe)

	esttab . using "results/tables/table_imputed_institutions.csv", ///
		cells("b(f(0)) pct(f(2))") replace
}