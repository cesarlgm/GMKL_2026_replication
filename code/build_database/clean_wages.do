/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Assembles switcher and non-switcher files, applies wage cleaning
*					(top-code removal, $53,760 salary floor), drops post-docs (pdix==1),
*					harmonizes faculty rank and tenure variables, and (unless type=="raw")
*					removes wage outliers based on deviations from experience-adjusted
*					wage growth across three passes.

*   Input: 		Argument 1: cleaning type ("raw" skips outlier exclusion)
*				data/temporary/non_switcher_file_fixed
*				data/temporary/switcher_file_fixed
*				data/temporary/file_with_sample_restrictions
*				Called: code/build_database/add_final_code_drops.do,
*				        output_connected_set.do,
*				        exclude_outliers.do (x3, if type!="raw")
*   Output: 	In-memory cleaned wage dataset; connected-set diagnostics
*				written by output_connected_set.do

*===============================================================================
*/

local type  `1' 

di "Executing first part of clean wages", as result
use "data/temporary/non_switcher_file_fixed", clear

append using "data/temporary/switcher_file_fixed"


do "code/build_database/add_final_code_drops.do"


merge 1:1 	panelid period using ///
	"data/temporary/file_with_sample_restrictions",  keep(1 3) nogen

*Correcting individual type
cap drop n_spells
cap drop individual_type
	
*I drop top-coded or non-valid wages
replace 	r_salary_f=. if salary>=999999

cap drop 	fixed_phd_yr
egen 		fixed_phd_yr=mode(dgryr), by(panelid) minmode



*===============================================================================
*FORCE STARTING DATE TO BE NO EARLIER THAN THE PHD YEAR
*note: this was done before, but only for switchers.
*===============================================================================
cap drop to_fix_phd
generate to_fix_phd= year(start_date_f)<dgryr 
replace  start_date_f=mdy(9,1,fixed_phd_yr) if to_fix_phd

generate years_since_phd=max((current_date_f-mdy(7,1,fixed_phd_yr))/365,0)

cap drop faculty_rank_f
generate faculty_rank_f=.
replace  faculty_rank_f=1 if facrank==7
replace  faculty_rank_f=2 if facrank==6
replace  faculty_rank_f=3 if facrank==5
replace  faculty_rank_f=4 if facrank==4
replace  faculty_rank_f=5 if facrank==3
replace  faculty_rank_f=6 if inlist(facrank,1,2,8)

cap label drop faculty_rank_f
label define faculty_rank_f 1 "Lecturer" 2 "Instructor" 3 "Assistant professor" ///
	4 "Associate professor" 5 "Professor" 6 "Other"
	
label values faculty_rank_f faculty_rank_f

generate 	tenured_f=tenure_status_f==3
label 		define tenured_f 0 "Not tenured" 1 "Tenured"
label 		values tenured_f tenured_f

*===============================================================================
*DROP OBSERVATIONS WITH A POST DOC
*===============================================================================
drop if pdix==1



*VARIABLE FILTERING
keep 	refid refyr panelid age_f in_wave start_date_f is_professor_f  ///
		employed_f period acad_spell_id r_salary_f instcod inst_name ///
		employer_type_f fixed_phd_yr years_since_phd faculty_rank ///
		faculty_rank_f tenured_f  female_f ///
		ch6_f ch611_f ch1218_f ch19_f marst_f medical_school wabrsh wadev watea
		
replace medical_school=0 if missing(medical_school)
	
drop if missing(r_salary_f)

cap drop n_spells
cap drop individual_type

cap drop n_spells
gegen 		n_spells=nunique(acad_spell_id), by(panelid)
generate 	individual_type=0 if n_spells==1
replace 	individual_type=1 if n_spells>1

label values individual_type individual_type

*===============================================================================
*WAGE CLEANING
*===============================================================================
*I drop observations with missing wages
drop if missing(r_salary_f)

*I drop wages below 53k. This a bit below the first percentile of the wage 
*distribution
drop if r_salary_f<53760

do "code/build_database/output_connected_set.do" after_wage_clean
	
*Computing number of observations per spell
cap drop n_obs
gegen n_obs=count(period), by(panelid)

*Computing changes in the salary	
sort panelid acad_spell_id period
generate l_r_salary=	log(r_salary_f)

if "`type'"!="raw" {
	cap drop d_l_r_salary

	*This creates de log-change in the real salary
	by	panelid acad_spell_id: generate d_l_r_salary=l_r_salary -l_r_salary[_n-1] 


	*I regress real change in the salary on potential experience and its square
	regress l_r_salary years_since_phd c.years_since_phd#c.years_since_phd 

	cap drop  l_salary_nofe

	sort panelid acad_spell_id period
	predict l_salary_nofe

	*I compute the expected wage growth, based on the regression above
	by panelid acad_spell_id: generate d_l_r_salary_exp=l_salary_nofe-l_salary_nofe[_n-1]


	*Deviations from expected wage growth
	sort 		panelid acad_spell_id period
	generate dev_from_expected=(d_l_r_salary-d_l_r_salary_exp)

	*===============================================================================
	*EXCLUSION OF WAGE OUTLIERS
	*Here I exclude wage observations for people for which either:
	*	- I only have two observations that both observations belong to the same spell OR
	*	- Deviation from expected wage growth is larger than .4 (absolute value)
	*===============================================================================

	*Excluding people with deviations above .4, with only two observations
	do "code/build_database/exclude_outliers.do" 1

	do "code/build_database/output_connected_set.do" after_first_wage
	
	*Dropping observations with minimum deviations above .2
	do "code/build_database/exclude_outliers.do" 2

	do "code/build_database/output_connected_set.do" after_second_wage
	
	*Dropping observations with minimum deviations above .2
	do "code/build_database/exclude_outliers.do" 3
}

