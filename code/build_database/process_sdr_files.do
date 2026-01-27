/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description:  basic processing of raw SDR files

*   Output: data/temporary/cleaned_final_database.dta
					
*===============================================================================
*/

local SDR_list `0'

local wave_list 1993 1995 1997 1999 2001 2003 2006 2008 2010 2013 2015 2017 2019


display "Processing all wages of the SDR"

foreach file in `SDR_list' {
	di "Processing SDR `file'",  as result
	use `file', clear
	rename *, lower
	
	local year=refyr[1]
	
	*This just labels variables
	qui do "code/build_database/relabel_restricted_file.do"  //REQUESTED
	
	*This recodes dummy variables, properly assigning missing values
	qui do "code/build_database/recode_dummy_variables.do"  //REQUESTED
	
	*This bit coverts all the non-dummy variables to numberic variables
	qui do "code/build_database/destring_numeric_variables.do"  //REQUESTED
	
	*Creating demographic variables
	qui do "code/build_database/create_demographics.do" //REQUESTED

	*Creating work-related variables (here I also convert salaries to real wages)
	qui do "code/build_database/create_work_variables.do" `year' //REQUESTED
	
	
	order refid refyr, first	
	*keep refid refyr *_f
	qui save "data/temporary/cleaned_wave`year'", replace
}


*Fixing wapri wasec variables
qui foreach file in `wave_list' {
	use  "data/temporary/cleaned_wave`file'", clear
	destring wapri, replace force
	destring wasec, replace force
	save  "data/temporary/cleaned_wave`file'", replace 
}


display "Appending processed SDR files"
clear
di "Appending datasets", as result
qui foreach file in  `wave_list' {
	qui append using "data/temporary/cleaned_wave`file'", force
}

save  "data/temporary/appended_database", replace


display "Creating panel variables"

qui do "code/build_database/create_panel_variables.do"

save "data/temporary/cleaned_final_database", replace


/*
*===============================================================================
*Tidying up the temporary files folder
cap rm  "data/temporary/appended_database.dta"

cap rm "data/temporary/converted_variables.dta"

foreach file in `wave_list' {
	rm "data/temporary/cleaned_`file'.dta"
}
