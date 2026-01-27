*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Purpose: 	destrings numeric variables
*/
*===============================================================================

use "data/temporary/variables_left_handle", clear

ds *

*Here I just convert missing values to a numeric code so that I can destring 
*everything
foreach variable in `r(varlist)' {
	if !inlist("`variable'","refid", "gender", "eddad", "edmom","instcod") {
		cap replace `variable'="-3" if `variable'=="L"
		cap replace `variable'="-2" if `variable'=="M"
		cap replace `variable'="-1" if `variable'=="F"
		
		*Here I destring the variables
		cap destring `variable', replace
		
		cap replace `variable'="-3" if `variable'=="L"
		cap replace `variable'="-2" if `variable'=="M"
		cap replace `variable'="-1" if `variable'=="F"
		
		cap replace `variable'=. 		if `variable'==-2
		cap replace `variable'=.b 		if `variable'==-3
		cap replace `variable'=.c 		if `variable'==-1
		
		*Here I assign labels to the missing types
		cap label define `variable' .b "Logical skip" .c "Don't know"
		cap label values `variable' `variable'
	}
	
	
	if inlist("`variable'","eddad", "edmom") {
	
		cap replace `variable'= "1" if `variable'=="I"
		cap replace `variable'="-3" if `variable'=="L"
		cap replace `variable'="-2" if `variable'=="M"
		cap replace `variable'="-1" if `variable'=="F"
		cap replace `variable'="4" if `variable'=="E"
		cap replace `variable'="" if `variable'=="8"
		
		*Here I destring the variables
		cap destring `variable', replace
		
		cap label values `variable' `variable'
		
		cap replace `variable'=. if `variable'<0
	}

}


cap replace strtmn=. if strtmn==98
cap replace strtyr=. if strtmn==9998

cap rename 	strtmn95 strtmn
cap rename 	strtyr95 strtyr


*Here I merge with the variables
merge 1:1 refid using "data/temporary/recoded_dummies_file", nogen

save  "data/temporary/converted_variables", replace

cap rm "data/temporary/recoded_dummies_file.dta"
cap rm "data/temporary/variables_left_handle.dta"
