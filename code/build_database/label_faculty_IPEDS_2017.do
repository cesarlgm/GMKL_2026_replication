/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Imports the IPEDS 2017 fall staff (faculty) CSV, applies variable and value labels for academic rank categories, and saves the labeled dataset to data/temporary/.

*===============================================================================
*/
insheet using "data/raw/faculty_IPEDS_2017.csv", clear
label data STATA_RV_8162024_363
label variable unitid "UNITID"
label variable instnm "Institution Name"
label variable year "Survey year 2017"
label variable facstat "Faculty and tenure status"
label variable sistotl "All ranks"
label variable idx_hr "ID of institution where data are reported for the Human Resource component"

label define label_facstat 0 "All full-time instructional staff"
label define label_facstat 10 "With faculty status, total", add
label define label_facstat 20 "With faculty status, tenured", add
label define label_facstat 30 "With faculty status, on tenure track", add
label define label_facstat 40 "With faculty status not on tenure track/No tenure system, total", add
label define label_facstat 41 "With faculty status not on tenure track/No tenure system, multi-year and indefinite contracts", add
label define label_facstat 44 "With faculty status not on tenure track/No tenure system, multi-year contract", add
label define label_facstat 45 "With faculty status not on tenure track/No tenure system, indefinite contract", add
label define label_facstat 42 "With faculty status not on tenure track/No tenure system, annual contract", add
label define label_facstat 43 "With faculty status not on tenure track/No tenure system, less-than-annual contract", add
label define label_facstat 50 "Without faculty status", add
label values facstat label_facstat

tab facstat

summarize sistotl
summarize idx_hr


save "data/temporary/labeled_faculty_IPEDS_2017.dta", replace