/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	computes elasticity of wages to institutional rankings

*   Input: data/output/final_database_clean_with_dummies.dta
*          data/output/institution_level_database_clean.dta
*          data/additional_processing/final_institution_list_medical.dta
*   Output: Regression results (displayed)
					

*===============================================================================
*/


use "data/output/final_database_clean_with_dummies.dta", clear 

gcollapse (mean) l_r_salary, by(instcod)

merge 1:1 instcod using "data/output/institution_level_database_clean", keep(3)

******************************************** NOTE TO ANYONE REPLICATING THIS CODE.  REPLACE ???? WITH THE BEST RANKED SCHOOL 
******************************************** BE CONSISTENT ACROSS PROGRAMS

replace inst_fe=0 if instcod=="????"
replace inst_fe_trim=0 if instcod=="????"

replace se_inst_fe=0 if instcod=="????"

merge 1:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3)  nogen

drop if todrop==1

regress l_r_salary ib3.institution_type i.institution_type#c.l_inst_ranking_p, vce(r)

*End of do file
