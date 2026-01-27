/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates event study figures showing wage patterns around job moves by institution prestige and coworker salary

*   Input: data/output/institution_level_database_*.dta
*          data/output/final_database_*_with_dummies.dta
*          data/additional_processing/final_institution_list_medical.dta
*   Output: results/figures/figure_event_prestige_panel_A_universities.pdf
*           results/figures/figure_event_prestige_panel_B_colleges.pdf
*           results/figures/figure_event_coworker.pdf
*           results/figures/figure_event_prestige_people_counts.xlsx
*           results/figures/figure_event_coworker_people_counts.xlsx
					

*===============================================================================
*/





cap program drop cr_graph_event
program define cr_graph_event, 
	syntax, type(str) n_quant(str)
	local database clean

	grscheme, ncolor(7) palette(tableau)
	
	local common_options legend(region(lstyle(none)) pos(6) col(2))  ///
		yscale(range(11.2 12.2)) ylab(11.2(.2)12.2)
	
	if "`type'"=="prestige" {
		*Getting the quantiles
		{
			use "data/output/institution_level_database_`database'", clear

******************************************** NOTE TO ANYONE REPLICATING THIS CODE.  REPLACE ???? WITH THE BEST RANKED SCHOOL 
******************************************** BE CONSISTENT ACROSS PROGRAMS

			replace inst_fe=0 if instcod=="????"
			replace inst_fe_trim=0 if instcod=="????"
			
			replace se_inst_fe=0 if instcod=="????"

			merge 1:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3)  nogen

			drop if todrop==1
			
			generate university=institution_type==1
			generate college=institution_type==2
			generate unranked=institution_type==3
			
			xtile uni_rank_q=inst_ranking_p if university, nq(4)
			xtile coll_rank_q=inst_ranking_p if college, nq(4)
			
			generate all_rank=uni_rank_q
			replace all_rank=coll_rank_q+`n_quant' if college
			replace all_rank=11 		if unranked
			
			
			keep instcod institution_type uni_rank_q all_rank
			
			tempfile quantiles
			save `quantiles'
		}	
			
		{
			use "data/output/final_database_`database'_with_dummies", clear

			merge m:1 instcod using `quantiles', keep(1 3) nogen
			
			
			do "code/build_database/update_observation_type.do" 1

			summ panelid if observation_type
			
			do "code/build_database/update_acad_spell_id.do"
			
			egen max_spell=max(acad_spell_id), by(panelid)
			
			drop if max_spell>2
			
			
			*Keep movers only
			keep if individual_type==1
			
			
			*I keep those who changed schools only once
			keep if n_schools==2

			sort panelid period
			
			tempvar origin
			by panelid: generate `origin'=all_rank[_n-1] if instcod[_n-1]!=instcod
			egen origin_quant=max(`origin'), by(panelid)
			tempvar destination
			by panelid: generate `destination'=all_rank[_n] if instcod[_n-1]!=instcod
			egen dest_quant=max(`destination'), by(panelid)
			
			order all_rank origin_quant dest_quant, after(instcod)

			drop if origin_quant==.|dest_quant==.
			
				
			generate transition_type=string(origin_quant)+" to "+string(dest_quant)
			
			
			sort panelid period
			tempvar dummyvar
			by panelid: generate `dummyvar'=period if instcod[_n-1]!=instcod[_n]
			egen move_time=max(`dummyvar'), by(panelid)
			order move_time,after(instcod)
			
			generate time_to_move=period-move_time
			order time_to_move,after(instcod)
			
			*Checking minimum and maximum periods before move
			egen min_period=min(time_to_move), by(panelid)
			egen max_period=max(time_to_move), by(panelid)
			
			keep if min_period<=-1 & max_period>=1
			keep if inrange(time_to_move,-1,1)
		
		
			gcollapse (mean) l_r_salary_f* (count) number_units=l_r_salary_f ///
				(nunique) panelid, by(transition_type time_to_move)
			

		

		
			preserve
			keep if inlist(transition_type,"1 to 1","1 to 2","1 to 3")
			separate l_r_salary_f, by(transition_type) generate(salary)
			
			tw connected salary* time_to_move, ///
				legend(order(1 "Best to best" 2 "Best to 2" 3 "Best to 3" )) ///
				xtitle("Time relative to move") ///
				ytitle(Mean Log Wage of Movers) xlab(-1(1)1) xline(0, lcolor(red) lpattern(dash))  `common_options'
			graph export "results/figures/figure_event_prestige_panel_A_universities.pdf", replace
			
			restore
			
			preserve
			keep if inlist(transition_type,"6 to 6","6 to 7","6 to 8")
			separate l_r_salary_f, by(transition_type) generate(salary)
			
			tw connected salary* time_to_move, ///
				legend(order(1 "Best to best" 2 "Best to 2" 3 "Best to 3")) ///
				xtitle("Time relative to move") ///
				ytitle(Mean Log Wage of Movers) xlab(-1(1)1) xline(0, lcolor(red) lpattern(dash)) ///
				`common_options'
			graph export "results/figures/figure_event_prestige_panel_B_colleges.pdf", replace
			restore
			
			generate figure="Panel A" if  inlist(transition_type,"1 to 1","1 to 2","1 to 3")
			replace figure="Panel B" if inlist(transition_type,"6 to 6","6 to 7","6 to 8")
			
			keep if figure!=""
		
			rename panelid n_people
			
			export excel using "results/figures/figure_event_prestige_people_counts", ///
				firstrow(variables) replace
		}

	}
	else if "`type'"=="coworker" {
		{
			use "data/output/institution_level_database_`database'", clear
******************************************** NOTE TO ANYONE REPLICATING THIS CODE.  REPLACE ???? WITH THE BEST RANKED SCHOOL 
******************************************** BE CONSISTENT ACROSS PROGRAMS
			
			replace inst_fe=0 if instcod=="????"
			replace inst_fe_trim=0 if instcod=="????"
			
			replace se_inst_fe=0 if instcod=="????"

			merge 1:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3)  nogen

			drop if todrop==1
			
			keep instcod institution_type inst_ranking_p inst_name
			
			tempfile school_type
			save `school_type'
		}
		
		
		use "data/output/final_database_`database'_with_dummies.dta", clear

		do "code/build_database/update_observation_type.do" 1

		summ panelid if observation_type
		
		do "code/build_database/update_acad_spell_id.do"
		
		egen max_spell=max(acad_spell_id), by(panelid)
		

		
		regress l_r_salary_f i.period
		predict adjusted_salary, residuals
		
		
		egen school_wages=sum(l_r_salary_f), by(instcod period)
		egen n_coworkers=count(l_r_salary_f), by(instcod period)
		generate leave_out_salary=(school_wages-l_r_salary_f)/(n_coworkers-1)
		
		
		*Quantiles for all insitutions
		gegen inst_quantile=xtile(leave_out_salary), by(year) n(`n_quant')
		
		merge m:1 instcod using `school_type', nogen keep(3)
		*Quantiles by institution type
		gegen inst_quantile_type=xtile(leave_out_salary), by(year institution_type) n(`n_quant')
		replace inst_quantile_type=11 if institution_type==3
		replace inst_quantile_type=inst_quantile_type+5 if institution_type==2
		
		tab inst_quantile
		
		drop if max_spell>2
		
		
		*Keep movers only
		keep if individual_type==1
		
		
		*I keep those who changed schools only once
		keep if n_schools==2
		
		sort panelid period
		
		tempvar origin
		by panelid: generate `origin'=inst_quantile[_n-1] if instcod[_n-1]!=instcod
		egen origin_quant=max(`origin'), by(panelid)
		tempvar destination
		by panelid: generate `destination'=inst_quantile[_n] if instcod[_n-1]!=instcod
		egen dest_quant=max(`destination'), by(panelid)
		
		order inst_quantile origin_quant dest_quant, after(instcod)

		drop if origin_quant==.|dest_quant==.
		
			
		generate transition_type=string(origin_quant)+" to "+string(dest_quant)

		*STEP 2: VERSION WITH RANKS BY INSTITUTION
		{
		
			tempvar origin_type
			by panelid: generate `origin_type'=inst_quantile_type[_n-1] if instcod[_n-1]!=instcod
			egen origin_quant_type=max(`origin_type'), by(panelid)
			tempvar destination_type
			by panelid: generate `destination_type'=inst_quantile_type[_n] if instcod[_n-1]!=instcod
			egen dest_quant_type=max(`destination_type'), by(panelid)
			
			order inst_quantile origin_quant dest_quant inst_quantile_type origin_quant_type dest_quant_type, after(instcod)

			drop if origin_quant==.|dest_quant==.
			
				
			generate transition_type_inst=string(origin_quant_type)+" to "+string(dest_quant_type)
		
		}

		
		*STEP 2: VERSION WITH ACTUAL TIME PERIODS
		{
			*GRAPH FOR ALL INSTITUTIONS
			sort panelid period
			tempvar dummyvar
			by panelid: generate `dummyvar'=period if instcod[_n-1]!=instcod[_n]
			egen move_time=max(`dummyvar'), by(panelid)
			order move_time,after(instcod)
			
			generate time_to_move=period-move_time
			order time_to_move,after(instcod)
			
			
			*Checking minimum and maximum periods before move
			egen min_period=min(time_to_move), by(panelid)
			egen max_period=max(time_to_move), by(panelid)
			
			keep if min_period<=-1 & max_period>=1
			
			cap drop _merge
			merge m:1 instcod using `school_type', keep(3)
			
			keep if inrange(time_to_move,-1,1)
			
			gcollapse (mean) l_r_salary_f* leave_out_salary* (nunique) n_people=panelid, by(transition_type time_to_move)
			
			keep if inlist(transition_type,"1 to 1","1 to 2","1 to 3", "1 to 4")|inlist(transition_type,"4 to 3", "4 to 4")
			separate l_r_salary_f, by(transition_type) generate(salary)
			
			tw connected salary* time_to_move, ///
				legend(order(1 "Worst to Worst" 2 "Worst to 3" 3 "Worst to 2" 4 "Worst to Best"  5 "Best to 2" 6 "Best to Best")) ///
				xtitle("Time relative to move") ///
				ytitle(Mean Log Wage of Movers) xlabel(-1(1)1) xline(0, lcolor(red) lpattern(dash)) `common_options'
				
			graph export "results/figures/figure_event_coworker.pdf", replace
			
			keep transition_type time_to_move n_people
			
			export excel using "results/figures/figure_event_coworker_people_counts", ///
				firstrow(variables) replace
		}
	}
end 

cr_graph_event, type(coworker) n_quant(5)


cr_graph_event, type(prestige) n_quant(5)
