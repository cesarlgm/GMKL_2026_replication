/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Imports the IPEDS 2001 fall staff (faculty) CSV, applies variable and value labels for academic rank categories, and saves the labeled dataset to data/temporary/.

*===============================================================================
*/
insheet using "data/raw/faculty_IPEDS_2001.csv", clear
label data STATA_RV_8162024_722
label variable unitid "UNITID"
label variable instnm "Institution Name"
label variable year "Survey year 2001"
label variable arank "Academic rank and gender of faculty"
label variable staff24 "Grand total"
label variable idx_s "UNITID of parent institution reporting Fall Staff"

label define label_arank 22 "Total full-time faculty"
label define label_arank 7 "Total full-time faculty, Tenured total", add
label define label_arank 1 "Total full-time faculty, Tenured, Professors", add
label define label_arank 2 "Total full-time faculty, Tenured, Associate professors", add
label define label_arank 3 "Total full-time faculty, Tenured, Assistant professors", add
label define label_arank 4 "Total full-time faculty, Tenured, Instructors", add
label define label_arank 5 "Total full-time faculty, Tenured, Lecturers", add
label define label_arank 6 "Total full-time faculty, Tenured, No academic rank", add
label define label_arank 14 "Total full-time faculty, Non-tenured on tenure track total", add
label define label_arank 8 "Total full-time faculty, Non-tenured on tenure track, Professors", add
label define label_arank 9 "Total full-time faculty, Non-tenured on tenure track, Associate professors", add
label define label_arank 10 "Total full-time faculty, Non-tenured on tenure track, Assistant professors", add
label define label_arank 11 "Total full-time faculty, Non-tenured on tenure track, Instructors", add
label define label_arank 12 "Total full-time faculty, Non-tenured on tenure track, Lecturers", add
label define label_arank 13 "Total full-time faculty, Non-tenured on tenure track, No academic rank", add
label define label_arank 21 "Total full-time faculty, Non-tenured not on tenure track total", add
label define label_arank 15 "Total full-time faculty, Non-tenured not on tenure track, Professors", add
label define label_arank 16 "Total full-time faculty, Non-tenured not on tenure track, Associate professors", add
label define label_arank 17 "Total full-time faculty, Non-tenured not on tenure track, Assistant professors", add
label define label_arank 18 "Total full-time faculty, Non-tenured not on tenure track, Instructors", add
label define label_arank 19 "Total full-time faculty, Non-tenured not on tenure track, Lecturers", add
label define label_arank 20 "Total full-time faculty, Non-tenured not on tenure track, No academic rank", add
label values arank label_arank

tab arank

summarize staff24
summarize idx_s


save "data/temporary/labeled_faculty_IPEDS_2001", replace