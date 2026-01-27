/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates figures summarizing mobility patterns and salary changes around job moves

*   Input: data/output/final_database_*_with_dummies.dta
*          data/output/institution_level_database_*.dta
*   Output: results/figures/figure_hist_l_change_ranking_within*.png
*           results/figures/figure_binscat_d_salary_vs_d_rankings*.png
*           results/figures/figure_hist_l_change_ranking_within*_count.csv
*           results/figures/figure_binscat_d_salary_vs_d_rankings*_count.csv
					

*===============================================================================
*/



grscheme, ncolor(7) palette(tableau)

cap program drop create_mobility_graphs 
program define create_mobility_graphs
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
	
	create_summary_graphs, sample(all)
	
	create_summary_graphs, sample(tenured)	
	
end	


capture program drop create_summary_graphs
program define create_summary_graphs
	syntax, sample(str)
	
	tempfile torestore
	save `torestore'
	
	
	if "`sample'"=="tenured" {
		keep if tenured==1
		local stub _tenured
		local h_bin bins(20)
		local c_bin bin(20)
		local nquantiles nq(15)
		
	}
	
	do "code/build_database/update_observation_type.do"
	
	keep if observation_type==1
	
	summ observation_type
	
	di as result "Observations used"
	
	local obs=`r(N)'
	di as result "Number of obs: `obs'"
	
	
	qui unique panelid if in_regression&individual_type
	di as result "Number of people: `r(unique)'"
	
	local obs_dot=`obs'/40
	
	di as result "`obs_dot'"

	qui {
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
		{
			gstats winsor d_l_inst_ranking_p if move_type==1, generate(w_d_l_inst_ranking_p) cut(1 99)
			
			local graph_options  percent fcolor("ebblue") lcolor("eltblue") `h_bin'
			noi hist w_d_l_inst_ranking_p if move_type==1,  ///
				xtitle("Change in log of ranking percentile") `graph_options'
			graph export "results/figures/figure_hist_l_change_ranking_within`stub'.png", replace 
			
			local count_name "results/figures/figure_hist_l_change_ranking_within`stub'_count.csv"
			create_hist_obs w_d_l_inst_ranking_p if move_type==1, countname(`count_name') `c_bin'
		}
		
		*Creating binscatter and count file
		{
			cap drop gquantile
			local graph_options  mcolor(black gold) lcolor(black gold) msymbol( o d) ///
				xtitle("Change in log of ranking percentile") ///
				ytitle("Change in log of salary") yscale(range(0 .5)) ///
				ylab(0(.1).5)  line(qfit) legend(order(1 "Research Universities" 2 "Colleges") ///
				pos(11) ring(0) col(1) region(lcolor(none))) ///
				xline(0, lpattern(dash)) genxq(gquantile) `nquantiles'
			binscatter  d_l_r_salary_f d_l_inst_ranking_p if move_type==1&institution_type!=3, by(institution_type) `graph_options' 
			graph export "results/figures/figure_binscat_d_salary_vs_d_rankings`stub'.png", replace
			
			
			preserve
				gcollapse (nunique) n_people=panelid if institution_type!=3, by(institution_type gquantile) 
				drop if missing(gquantile)
				label define new_type 1 "Research universities" 2 "Colleges", modify
				local count_name "results/figures/figure_binscat_d_salary_vs_d_rankings`stub'_count.csv"
				export delimited "`count_name'", replace
			restore
		}
	}
	
	use `torestore', clear
end


capture program drop create_hist_obs 
program define create_hist_obs, 
	syntax varname [if],[ generate(str)  bin(str) countname(str)]
	
	if "`generate'"=="" {
		local generate h_bin
	}
	
	cap drop `generate'
	if "`if'"!="" {
		local ifexp `if'
	}
	else {
		local ifexp 
	}
	
	qui summ `varlist' `ifexp'
	
	local v_min=`r(min)'
	local v_N=`r(N)'
	local v_max=`r(max)'
	
	if "`bin'"=="" {
		local k=floor(min(sqrt(`v_N'),10*ln(`v_N')/ln(10)))
	}
	else {
		local k=`bin'
	}

	
	local width=(`v_max'-`v_min')/`k'
	
	di "`k' `width'"
	
	generate `generate'=max(ceil((`varlist'-`v_min')/`width'),1) `ifexp'
	
	preserve 
		gcollapse (nunique) panelid (count) observations=panelid, by(`generate')
		rename `generate' bar_number
		rename panelid n_people
		
		drop if missing(bar_number)
		export delimited using  "`countname'", replace
	restore
end


create_mobility_graphs



