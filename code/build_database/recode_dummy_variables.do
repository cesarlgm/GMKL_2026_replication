*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Purpose: 	recodes dummy categorical variables into 0-1 variables fit for 
				regression analysis
*/
*===============================================================================

ds *

foreach variable in `r(varlist)' {
	*I trim empty spaces in all the variables
	cap replace `variable'=strtrim(`variable')
	
	local varlab :  var  label `variable'
	
	*here I recode the dummies
	g		`variable'_d=.
	cap replace `variable'_d=1 	if `variable'=="Y"
	cap replace `variable'_d=0 	if `variable'=="N"
	cap replace `variable'_d=. 	if inlist(`variable'=="M")
	cap replace `variable'_d=.b if inlist(`variable'=="L")
	cap replace `variable'_d=.c if inlist(`variable'=="F")
	cap replace `variable'_d=.a if `variable'=="D"
	
	label var `variable'_d "`varlab'"
	
	*This part checks whether the variable the `variable'_d is empty. If this 
	*variable is empty, then the original variable was not a dummy.
	g check=missing(`variable'_d)
	egen check_all=min(check)
	
	if  check_all[1]==1 {
		*I the variable was not a dummy, then nevermind
		drop `variable'_d check check_all
	}
	else {
		*If the variables was a dummy, then I keep the recoded variable.
		drop `variable' check check_all
		label define `variable'_d 0 "No" 1 "Yes" .a "Refused answer".b "Logical skip" ///
			.c "Don't know"
		label values `variable'_d `variable'_d
	}
	
}

preserve
*Here I save the recoded dummy variables in a separate file
ds  	refid *_d
keep 	`r(varlist)'

foreach variable of varlist *_d {
	local new_name = regexr("`variable'", "_d", "")
	rename `variable' `new_name'
}

save 	"data/temporary/recoded_dummies_file", replace
restore


drop *_d
*Then I save a file with numeric variables that I need to fix
save	"data/temporary/variables_left_handle", replace
