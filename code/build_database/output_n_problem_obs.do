/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Diagnostic script: counts observations where the respondent
*				reports the same employer (emsmi in {1,2} or missing) but
*				instcod changes across consecutive periods; writes the
*				formatted count to a text file for in-paper reference.

*   Input: 	Default frame in memory (requires panelid, period, emsmi, instcod)
*   Output: 	results/text/n_problem_obs.txt — formatted count of problem
*				observations; default frame is unchanged (preserve/restore)
					

*===============================================================================
*/


*===============================================================================
*OUTPUTS NUMBER OF PROBLEM OBSERVATIONS 
*===============================================================================

preserve

cap drop same_employer
cap drop same_instcod


g 	same_employer=(inlist(emsmi,1,2)|missing(emsmi))

sort panelid period
by panelid: g same_instcod=instcod==instcod[_n-1] if _n>1

tab same_employer same_instcod, 

summ if same_employer & !same_instcod

local n_problem: display %9.0fc  `r(N)'
writeln "results/text/n_problem_obs.txt" "`n_problem'"


restore