*===============================================================================
*Project AKM-SDR
*=============================================================================
/*
	Author: 	César Garro-Maín
	Purpose: 	creates transition matrix based on coworker's salaries
*/
*===============================================================================


cap program drop cr_transit_coworker
program define cr_transit_coworker
	syntax, n_quant(str) type(str)
	
	local d_type clean
	
	*Getting school type information
	{
		use "data/output/institution_level_database_`d_type'", clear
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
	
	{	
		use "data/output/final_database_`d_type'_with_dummies.dta", clear

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
		
		xi i.dest_quant, noomit prefix(d_)
		
		forvalues j=1/`n_quant' {
			generate panelid_`j'=panelid if d_dest_quan_`j'==1
		}
		
		local counts c_1=panelid_1 c_2=panelid_2 c_3=panelid_3 c_4=panelid_4 c_5=panelid_5 
		
	}

	if "`type'"=="probability"{
	
		gcollapse (mean) d_dest* (nunique) `counts', by(origin_quant)
		
		local tot=`n_quant'
		forvalues o=1/`tot' {
			local origin_`o' 
			forvalues d=1/`tot' {
				summ d_dest_quan_`d' if origin_quant==`o'
				local t_`o'_`d': display %9.3fc `r(mean)'
				
				summ c_`d' if origin_quant==`o'
				if `r(mean)' <5 {
					local t_`o'_`d' "N.D."
				}
				
				local origin_`o' `origin_`o'' & `t_`o'_`d''
			}
		}
	}
	else if "`type'"=="salary" {
		gcollapse (mean) l_r_salary, by(panelid acad_spell_id instcod origin_quant dest_quant)
		
		xtset panelid acad_spell_id
		
		generate d_salary=d.l_r_salary
		
		gcollapse (mean) d_salary (nunique) n_people=panelid, by(origin_quant dest_quant)
		
		
		local tot=`n_quant'
		forvalues o=1/`tot' {
			local origin_`o' 
			forvalues d=1/`tot' {
				summ d_salary if origin_quant==`o'&dest_quant==`d'
				local t_`o'_`d': display %9.3fc `r(mean)'
				
				summ n_people if origin_quant==`o'&dest_quant==`d'
				if `r(mean)' <5 {
					local t_`o'_`d' "N.D."
				}
				
				local origin_`o' `origin_`o'' & `t_`o'_`d''
			}
			di "`origin_`o''"
		}
	}
	else if "`type'"=="people" {
		gcollapse (mean) l_r_salary, by(panelid acad_spell_id instcod origin_quant dest_quant)
		
		xtset panelid acad_spell_id
		
		generate d_salary=d.l_r_salary
		
		gcollapse (mean) d_salary (nunique) n_people=panelid, by(origin_quant dest_quant)
		
		
		local tot=`n_quant'
		forvalues o=1/`tot' {
			local origin_`o' 
			forvalues d=1/`tot' {
				summ n_people if origin_quant==`o'&dest_quant==`d'
				local t_`o'_`d': display %9.0fc `r(mean)'
				
				summ n_people if origin_quant==`o'&dest_quant==`d'
				if `r(mean)' <5 {
					local t_`o'_`d' "N.D."
				}
				
				local origin_`o' `origin_`o'' & `t_`o'_`d''
			}
			di "`origin_`o''"
		}
	}
	
	
	if "`type'"=="probability" {
		local table_title "Transition probability by rank quintile of coworkers' salaries"
		local table_key		"tab:transition_pr_all"
	}
	else if "`type'"=="salary" {
		local table_title "Salary changes by rank quintile of coworkers' salaries"
		local table_key		"tab:transition_sal_all"
	}
	else if "`type'"=="people"{
		local table_title 	"Number of people by rank quintile of coworkers' salaries"
		local table_key		"tab:transition_peo_all"
	}
	
	local table_name   "results/tables/transitions_table_`type'_coworker.tex"
	local ftitle		"Origin"
	local coltitles		Best 2 3 4 Worst
	local n_cols			5
	local table_notes "ADD NOTES"
	local exhead "&\multicolumn{5}{c}{\scshape Destination} \\ \cmidrule(lr){2-6}"
	
	textablehead using `table_name', f(`ftitle') ncols(`n_cols') title(`table_title') ///
			coltitles(`coltitles') exhead(`exhead') ct(\scshape) adjust(1)


	writeln `table_name' "Best   `origin_1' \\"
	writeln `table_name' "2  `origin_2' \\"
	writeln `table_name' "3  `origin_3' \\"
	writeln `table_name' "4  `origin_4' \\"
	writeln `table_name' "Worst  `origin_5' \\"

	
	textablefoot using `table_name', notes(`table_notes_`database'') ///
		font(`notefont') 
		
end 

cr_transit_coworker, n_quant(5) type(probability)

cr_transit_coworker, n_quant(5) type(salary)

cr_transit_coworker, n_quant(5) type(people)

