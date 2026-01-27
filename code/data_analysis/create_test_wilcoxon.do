
/*
*===============================================================================
*Project: Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu) 
*
*Description: performs Wilcoxon signed-rank tests on faculty mobility patterns, testing symmetry in institutional ranking changes for faculty job transitions
*
*Input files:
*	- data/output/final_database_clean_with_dummies.dta
*	- data/output/institution_level_database_clean
*
*Output files:
*	- (Statistical test results displayed in console)
*===============================================================================
*/

cap program drop create_wilcoxon_data
program define create_wilcoxon_data
	local d_type clean
	use "data/output/final_database_`d_type'_with_dummies.dta", clear
	
	merge m:1  instcod  using "data/output/institution_level_database_`d_type'"
		

	*Basic specification
	local base_spec  ib3.institution_type ib3.institution_type#c.l_inst_ranking_p
	
	
	*I merge the institution level information
	*Creating estimation files
	eststo clear
	local controls 			years_since_phd 	///
							i.tenured_f ib3.faculty_rank_f 					///
							ib0.married##ib0.female							///
							ib0.has_ch_6##ib0.female						/// 
							ib0.has_ch_611##ib0.female						///
							ib0.has_ch_1218##ib0.female						///
							ib0.has_ch_19##ib0.female						///

	local full_controls 	`base_spec' `controls'
	
	*These are the controls I progressively add
	local add_control_list 	ib3.new_locale 		///
							l_enrollment_total_m  ///
							i.ug_only  i.control
	
	*I set the sample I need to create all the regressions
	qui cap reghdfe l_r_salary_f `full_controls' `add_control_list', vce(cl instcod) absorb(i.refyr i.panelid) keepsingletons
	generate in_regression=e(sample)
	
	keep if in_regression
	
	create_wilcoxon, sample(all)
	
	*create_summary_graphs, sample(tenured)	
	
end	


capture program drop create_wilcoxon
program define create_wilcoxon
	syntax, sample(str)
	
	tempfile torestore
	save `torestore'
	
	
	do "code/build_database/update_observation_type.do"
	
	keep if observation_type==1
	
	summ observation_type
	
	di as result "Observations used"
	
	local obs=`r(N)'
	di as result "Number of obs: `obs'"
	
	
	qui unique panelid if in_regression&individual_type
	di as result "Number of people: `r(unique)'"
	


	
	gcollapse (mean) l_r_salary_f inst_ranking_p l_inst_ranking_p, by(refid panelid acad_spell_id institution_type)

	sort refid acad_spell_id
	by refid: generate move_up=l_inst_ranking_p<=l_inst_ranking_p[_n-1] if _n>1
	foreach variable in l_r_salary_f l_inst_ranking_p inst_ranking_p {
		by refid: generate d_`variable'=`variable'-`variable'[_n-1] if _n>1
	}
	generate move_type=.
	
	by refid: replace move_type=1 if institution_type==institution_type[_n-1]==1&_n>1
	by refid: replace move_type=2 if institution_type!=institution_type[_n-1]&inlist(institution_type,1,2)&inlist(institution_type[_n-1],1,2)&_n>1
	generate down_move=0
	by refid: replace down_move=1 if institution_type!=institution_type[_n-1]&inlist(institution_type[_n-1],1)&_n>1
	
	label define move_type 1 "Within types" 2 "Between types"
	
	label values move_type move_type
	
	
	keep if !missing(d_l_r_salary_f)
	
	*Creating the histogram for all faculty

	gstats winsor d_l_inst_ranking_p if move_type==1, generate(w_d_l_inst_ranking_p) cut(1 99)

	unique panelid if !missing(d_l_inst_ranking_p) & move_type==1
	centile d_l_inst_ranking_p if move_type==1, normal
	
	
	summ d_l_inst_ranking_p
	
	generate sign=d_l_inst_ranking_p
	
	cap drop ch_quantile
	xtile ch_quantile=d_l_inst_ranking_p if move_type==1, nq(100)

	gcollapse (nunique) n_people=panelid (mean) mean_change=d_l_inst_ranking_p (count) observations=panelid (min) min_change=d_l_inst_ranking_p (max) max_change=d_l_inst_ranking_p, by(ch_quantile)
	
	
	summ n_people,
	
	di "Number of people: `r(sum)'"
	
	drop n_people
	
	drop if missing(ch_quantile)
	
	generate sign=sign(max_change)
	
	cap drop dist
	generate dist=abs(mean_change)
	
	cap drop bar_dist
	generate bar_dist=abs(_n-44)
	
	drop if ch_quantile==44
	replace sign=0 if sign<0
	drop max_change min_change ch_quantile dist
	reshape wide obs mean_change, i(bar_dist) j(sign)
	
	replace observations0=0 if missing(observations0)
	replace observations1=0 if missing(observations1)
	
	signrank observations0=observations1

end


create_wilcoxon_data