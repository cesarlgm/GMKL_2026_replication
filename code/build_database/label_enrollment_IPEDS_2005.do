/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Imports the IPEDS 2005 enrollment CSV, applies variable and value labels for enrollment level categories, and saves the labeled dataset to data/temporary/.

*===============================================================================
*/
insheet using "data/raw/enrollment_IPEDS_2005.csv", clear
label data STATA_RV_8192024_385
label variable unitid "UNITID"
label variable instnm "Institution Name"
label variable year "Survey year 2005"
label variable eflevel "Level of student"
label variable eftotal "Grand total"
label variable idx_ef "ID number of parent institution Fall enrollment"

label define label_eflevel 10 "All students total"
label define label_eflevel 20 "All students, Undergraduate total", add
label define label_eflevel 50 "All students, Graduate and First professional", add
label values eflevel label_eflevel

tab eflevel

summarize eftotal
summarize idx_ef


save "data/temporary/labeled_enrollment_IPEDS_2005", replace