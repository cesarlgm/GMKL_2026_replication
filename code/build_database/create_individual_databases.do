/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates final individual-level databases with cleaned wages and demographic variables

*   Input: data loaded in memory from previous pipeline steps
*   Output: data/output/individual_database_`database_type'.dta
*           data/output/final_institution_list.dta (when database_type=="raw")
					

*===============================================================================
*/

local database_type `1'


do "code/build_database/clean_wages.do" `database_type'


*Quick creation of some final variables
cap generate married=inlist(marst_f, 1)
cap generate has_ch_6=		ch6_f>0
cap generate has_ch_611=	ch611_f>0
cap generate has_ch_1218=	ch1218_f>0

*Transform everything to run it in logs
cap generate l_r_salary_f=log(r_salary_f)

do "code/build_database/remaining_filters"

do "code/build_database/add_individual_data.do"

do "code/build_database/drop_unconnected_unis" "final_database_filter_v3"

if "`database_type'"=="raw" {
	*Output institution list
	preserve
	keep instcod inst_name
	duplicates drop
	save "data/output/final_institution_list.dta", replace
	restore
}

label var time_current_job_f "Years in current job"

save "data/output/individual_database_`database_type'.dta", replace
