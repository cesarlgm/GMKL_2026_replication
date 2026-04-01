/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Utility snippet that applies LaTeX-friendly variable labels
*					and value labels to in-memory variables for display in
*					regression output tables. Sets the $texspace global for
*					consistent LaTeX spacing and relabels institution type,
*					control status, locale, and key continuous variables.

*   Input: 	None (operates on in-memory dataset labels)
*   Output: 	None (modifies in-memory variable/value labels only)


*===============================================================================
*/
global texspace \hspace{3mm}
*Relabelling variables to make the table prettier
label define 	new_type 		1 "$texspace Research university" 2 "$texspace College", modify
label define	control			2 "$texspace Private institution", modify
label define	new_locale		1 "$texspace Large city" 2 "$texspace 'Medium city" 3 "$texspace Small city", modify
label var 		ug_only 		"$texspace Offers only undergraduate degree"
	
label var 	l_inst_ranking_p 	"log of university ranking"
label var 	inst_ranking_p 		"university ranking"
label var 	l_enrollment_total_m "$texspace Log of total enrollment" 
label var 	l_r_endowment_per_student "$texspace Log of endowment per student"
label var 	l_faculty_per_student "$texspace Log of faculty per student" 
label define ug_only 1 "$texspace Undergrad only", modify