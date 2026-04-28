/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Imports the IPEDS 2001 enrollment CSV, applies variable and value labels for enrollment level categories, and saves the labeled dataset to data/temporary/.

*===============================================================================
*/
insheet using "data/raw/enrollment_IPEDS_2001.csv", clear
label data STATA_RV_8192024_432
label variable unitid "UNITID"
label variable instnm "Institution Name"
label variable year "Survey year 2001"
label variable eflevel "Level of student"
label variable eftotal "Grand total"
label variable idx_ef "UNITID of parent institution reporting Enrollment"

label define label_eflevel 10 "All students total"
label define label_eflevel 20 "All students, Undergraduate total", add
label define label_eflevel 30 "All students, Undergraduate, Degree/certificate-seeking total", add
label define label_eflevel 31 "All students, Undergraduate, Degree/certificate-seeking, First-time", add
label define label_eflevel 34 "All students, Undergraduate, Other degree/certificate-seeking", add
label define label_eflevel 40 "All students, Undergraduate, Non-degree/certificate-seeking", add
label define label_eflevel 50 "All students, Graduate and First professional", add
label define label_eflevel 60 "All students, Graduate", add
label define label_eflevel 70 "All students, First professional", add
label values eflevel label_eflevel

tab eflevel

summarize eftotal
summarize idx_ef


save "data/temporary/labeled_enrollment_IPEDS_2001", replace