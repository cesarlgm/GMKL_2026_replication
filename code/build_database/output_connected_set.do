/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Thin wrapper around drop_unconnected_unis.do. Restricts the
*					default frame to the largest connected institution network,
*					then saves a snapshot of the connected-set institution codes
*					for a given pipeline checkpoint.

*   Input: 		Argument 1 (name): file name stem used in the output filename
*				Default frame in memory
*				Called: code/build_database/drop_unconnected_unis.do
*   Output: 	Default frame restricted to connected-set institutions
*				data/additional_processing/connected_set_<name>.dta — unique
*				list of instcod values in the connected set	

*===============================================================================
*/


local name `1'

do "code/build_database/drop_unconnected_unis.do" "`name'"

cap frame drop connected
frame copy default connected
	frame change connected
	
	keep instcod
	duplicates drop
	save "data/additional_processing/connected_set_`name'", replace
	
	frame change default
frame drop connected