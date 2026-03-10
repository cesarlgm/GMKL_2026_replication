/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Generic extract utility. Given a binary flag variable and an
*					output file name stem, pulls the full spell history for all
*					flagged panelids from file_with_sample_restrictions, applies
*					corrected institution codes (c_instcod) from the flagged
*					records, updates institution labels, and saves the result for
*					manual review.

*   Input: 		Argument 1  : output file name stem (local macro `name')
*				Argument 2  : name of binary reference/flag variable (`reference')
*				Remaining   : additional variables to carry through (`other_vars')
*				Frame       : dataset currently in memory (must contain refid,
*							  refyr, instcod, acad_spell_id, `reference')
*				data/temporary/file_with_sample_restrictions.dta
*				code/build_database/update_inst_labels.do

*   Output: 	data/temporary/<name>.dta — full spell history for flagged
*				panelids with corrected institution codes and updated labels	

*===============================================================================
*/


gettoken name 			0: 0
gettoken reference	 	0: 0
local other_vars 		`0'


preserve
	keep refid refyr instcod acad_spell_id `reference' `other_vars'
	keep if `reference'
	rename instcod c_instcod

	tempfile to_check
	save `to_check'

	use "data/temporary/file_with_sample_restrictions", clear
		merge 1:1 refid refyr using `to_check', nogen

		egen final_check=max(`reference'), by(panelid)

		keep if final_check==1
		
		order c_instcod, after(instcod)
		
		drop instcod_f
		
		replace instcod=c_instcod if c_instcod!=""
		
		drop c_instcod
		
		do "code/build_database/update_inst_labels.do"
		
		order panelid acad_spell_id instcod inst_name raw_instcod `other_vars', first
		
		drop if !in_wave

		sort panelid period
	save "data/temporary/`name'.dta", replace 
restore	
