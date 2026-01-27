
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	restricts the sample we use for the work history

*   Input: data/temporary/cleaned_final_database.dta
*   Output: data/temporary/file_with_sample_restrictions.dta
					

*===============================================================================
*/

use  "data/temporary/cleaned_final_database", clear


do "code/build_database/add_iped_codes.do" //REQUESTED



sort refid refyr
egen period=group(refyr)

xtset panelid period


*I am selecting all people that ever worked in a tenure track position in the US
egen t_in_sample=		max(in_tenure_track_f&in_academia_f&employed_us_f) ///
						if in_wave, by(panelid)

*This computes the number of years I observe them in academia
egen n_years_sample_f=sum(t_in_sample), by(panelid)

*I put people in the sample only if I observe them in at least two waves.
g	 in_sample_f=n_years_sample_f>=2

save "data/temporary/file_with_sample_restrictions", replace

