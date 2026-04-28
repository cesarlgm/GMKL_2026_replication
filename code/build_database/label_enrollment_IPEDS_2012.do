/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Imports the IPEDS 2012 enrollment CSV, applies variable and value labels for enrollment level categories, and saves the labeled dataset to data/temporary/.

*===============================================================================
*/
insheet using "data/raw/enrollment_IPEDS_2012.csv", clear
label data STATA_RV_8192024_801
label variable unitid "UNITID"
label variable instnm "Institution Name"
label variable year "Survey year 2012"
label variable eflevel "Level of student"
label variable eftotal "Grand total"
label variable idx_ef "ID of institution where data are reported for the Fall enrollment component"

label define label_eflevel 10 "All students total"
label define label_eflevel 20 "All students, Undergraduate total", add
label define label_eflevel 50 "All students, Graduate", add
label values eflevel label_eflevel

tab eflevel

summarize eftotal
summarize idx_ef


save "data/temporary/labeled_enrollment_IPEDS_2012", replace