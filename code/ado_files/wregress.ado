/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Defines the wregress program, which implements a two-step
*					feasible GLS estimator. In the first step an OLS regression is
*					run and residuals are obtained; in the second step those
*					squared residuals are regressed on the squared values of a
*					user-supplied standard-error variable to predict conditional
*					variance, and a final WLS regression is estimated using the
*					inverse of the predicted variance as analytic weights. All
*					three intermediate regressions are stored as estimates via
*					eststo.

*   Input: 	Current dataset in memory
*   Output: 	Stores three named estimates: <stub>fs (first-stage OLS),
*             <stub>resid (variance model), <stub>ss (WLS final regression);
*             creates temporary variables _in_sample, _u_fs, _var_fs,
*             _e_var_fs, weight


*===============================================================================
*/

*Program for weighting the regression
cap program drop wregress

program define wregress, eclass
	syntax anything [if], se(varlist) [stub(string)] [*]
	qui { 
	*First stage regression
	if "`if'"!=""{
	    local if `if'&!missing(`se')
	}
	eststo `stub'fs: regress `anything' `if'
	
	cap drop _in_sample
	generate _in_sample=e(sample)
	
	*Predict residuals
	cap drop _u_fs
	predict _u_fs if _in_sample, residuals
	
	cap drop  _var_fs
	generate _var_fs=_u_fs*_u_fs
	
	*Regress residuals on the estimated fixed 
	eststo `stub'resid: regress _var_fs c.`se'#c.`se' if _in_sample
	
	cap drop _e_var_fs 
	predict _e_var_fs if _in_sample
	
	cap drop weight
	generate weight=1/_e_var_fs if _in_sample
	}
	
	qui summ weight 
	
	if `r(min)'<0 { 
		display "There are negative weights", as error
	}
	qui eststo `stub'ss: regress `anything' [aw=weight] if _in_sample
end