/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	imports and cleans THE university and college rankings data

*   Input: data/raw/THE_rankings.xlsx (multiple sheets)
*   Output: data/additional_processing/university_rankings.dta
*           data/additional_processing/college_rankings.dta
					

*===============================================================================
*/


*Clean institution rankings
*===============================================================================

*University ranking
foreach year in 2011 2017 {
	import excel "data/raw/THE_WUR.xlsx", ///
		sheet("THE_`year'") first clear

		
	rename *, lower
	
	drop if rank==""
	
	foreach variable in ///
		overall teaching research citations industryincome internationaloutlook {
			destring `variable', replace force
		}

	replace name=lower(name)

	generate year=`year'

	generate ranking_type=1
	label define ranking_type 1 "University ranking" 2 "College ranking"

	label values ranking_type ranking_type

	do "code/build_database/fix_university_ranking_names"
	
	tempfile university_`year'
	save `university_`year''
	
}


*College rankings
foreach year in 2017 2020 {
	
	import excel ///	
		"data/raw/THE_college.xlsx", ///
		sheet("THE_COLL_`year'") first clear

	rename *, lower
	
	generate data=rank!=""
	
	
	generate college_id=_n if rank!=""
	order college_id, after(rank)
	
	replace rank=rank[_n-1] if rank==""
	replace college_id=college_id[_n-1] if missing(college_id)
	
	*Getting the state
	drop if rank==""
	drop if name=="Explore"
	
	foreach variable in ///
		overall resources engagement outcomes environment {
			destring `variable', replace force
		}

	replace name=lower(name)

	*Getting the state
	gsort college_id -data
	order data, after(rank)

	*Extracting state from the college
	preserve
		by college_id: keep if _n==2
	

		tempfile state_names
		keep college_id name
		rename name state_name
		
		do "code/build_database/state_names_rankings.do"
		save `state_names'
	restore
	by college_id: keep if _n==1
	merge 1:1 college_id using `state_names', nogen 
	
	labmask state_rank, values(state_name)
	drop state_name
	order state_rank, after(college_id)
	
	generate year=`year'

	generate ranking_type=2
	label define ranking_type 1 "University ranking" 2 "College ranking"

	label values ranking_type ranking_type

		
	replace name=regexr(name, ",", "-")
	
	do "code/build_database/fix_college_ranking_names"
	
	replace name=regexr(name, ", ", "-")
	replace name=regexr(name, "a&m", "a & m")
	replace name=regexr(name, "^st *", "saint ")
	replace name=regexr(name, "^the college*", "college")
	replace name=regexr(name, "^the *", "")

	tempfile college_`year'
	save `college_`year''
	
}

clear
append using `university_2011'
append using `university_2017'
save "data/additional_processing/university_rankings", replace

clear
append using `college_2017'
append using `college_2020'
save "data/additional_processing/college_rankings", replace

*End of do file