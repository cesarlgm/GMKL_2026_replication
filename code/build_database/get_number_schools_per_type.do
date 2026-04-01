/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Diagnostic utility script. Isolates the set of institutions
*					that appear in the leave-one-out check dataset and tabulates
*					their count by institution type. Results are displayed in the
*					Stata results window only; no files are saved.

*   Input: 	data/additional_processing/leave_one_out_check.csv
*			data/output/institution_level_database_clean.dta
*   Output: 	None (table displayed in results window only)


*===============================================================================
*/

import delimited "data/additional_processing/leave_one_out_check.csv", stringcols(3) clear 


keep instcod 

duplicates drop 

merge 1:1 instcod using "data/output/institution_level_database_clean.dta", keep(3)

table institution_type

