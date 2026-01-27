/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates crosswalk between IPEDS codes and THE rankings (university and college)

*   Input: data/output/individual_database_raw.dta
*          data/temporary/file_with_sample_restrictions.dta
*          data/additional_processing/university_rankings.dta
*          data/additional_processing/college_rankings.dta
*   Output: data/output/iped_university_rank_cw.dta
*           data/output/iped_college_rank_cw.dta
					

*===============================================================================
*/
*Adding university rankings to IPEDS
*---------------------------------------------
use "data/output/individual_database_raw", clear

*Manual modification of university names
replace inst_name=XXXX



keep instcod inst_name 
duplicates drop

rename inst_name name
recast str name

joinby name using "data/additional_processing/university_rankings",   unmatched(both)


drop if instcod==""


keep if year==2017

*Assigning midpoint
replace overall=(50.4+46.3)/2 if rank=="201-250"&year==2017
replace overall=(43.5+46.2)/2 if rank=="251-300"&year==2017
replace overall=(43.3+40.7)/2 if rank=="301-350"&year==2017
replace overall=(40.6+37.6)/2 if rank=="351-400"&year==2017
replace overall=(37.5+32.6)/2 if rank=="401-500"&year==2017
replace overall=(32.5+27.6)/2 if rank=="501-600"&year==2017
replace overall=(27.5+18.6)/2 if rank=="601-800"&year==2017
replace overall=(18.5+8.3)/2 if rank=="801+"&year==2017

replace rank="225" if rank=="201-250"&year==2017
replace rank="275" if rank=="251-300"&year==2017
replace rank="325" if rank=="301-350"&year==2017
replace rank="375" if rank=="351-400"&year==2017
replace rank="425" if rank=="401-500"&year==2017
replace rank="555" if rank=="501-600"&year==2017
replace rank="700" if rank=="601-800"&year==2017
replace rank="801" if rank=="801+"&year==2017

destring rank, replace

keep rank overall instcod name

rename rank rank_uni
rename overall score_uni

save "data/output/iped_university_rank_cw", replace




*Adding college rankings to IPEDS
*---------------------------------------------
use "data/output/individual_database_raw", clear
merge 1:1 panelid period using 	"data/temporary/file_with_sample_restrictions",  keep(1 3) nogen

keep instcod inst_name emst

*Manual modifications to the names
replace inst_name="university at buffalo" if inlist(inst_name, "suny at buffalo", "suny college at buffalo")


replace inst_name=regexr(inst_name, ", ", "-")
replace inst_name=regexr(inst_name, "a&m", "a & m")
replace inst_name=regexr(inst_name, "^st *", "saint ")
replace inst_name=regexr(inst_name, "^the college*", "college")
replace inst_name=regexr(inst_name, "^the *", "")


egen modal_st=mode(emst), by(instcod)
drop emst
duplicates drop

rename inst_name name
recast str name


joinby name using "data/additional_processing/college_rankings",   unmatched(both)


generate good_match=modal_st==state_rank if _merge==3
order good_match, after(modal_st)

keep if inlist(_merge,1,3)

generate matched=_merge
cap drop _merge
label define matched 1 "Not matched" 3 "Matched"
label values matched matched 

drop college_id

drop modal_st state_rank data good_match

rename name inst_name

keep if year==2017

replace overall=(42.7+42.5)/2 if rank=="501-600"&year==2017
replace overall=(32.5+42.4)/2 if rank=="601-800"&year==2017
replace overall=(23.5+37.4)/2 if rank=="> 800"&year==2017

*Assigning midpoint
replace rank="550" if rank=="501-600"&year==2017
replace rank="700" if rank=="601-800"&year==2017
replace rank="801" if rank=="> 800"&year==2017

destring rank, replace 
egen new_rank=min(rank), by(instcod)
egen new_overall=max(overall), by(instcod)


rename new_rank rank_coll
rename new_overall score_coll

keep instcod rank_coll score_coll inst_name
duplicates drop

save "data/output/iped_college_rank_cw", replace
*-------------------------------------------------------------------------------