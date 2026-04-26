/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Defines and calls the cr_t_matrix program, which produces
*					LaTeX transition matrix tables showing faculty mobility between
*					institution ranking quantiles. Generates six tables crossing
*					type (salary change, transition probability, or headcount) with
*					sample (all faculty or tenured only). This is the censored
*					replication version: the best-ranked institution identifier
*					is replaced with ???? throughout; replicators must substitute
*					the correct institution code before running.

*   Input: 	data/output/institution_level_database_clean.dta
*			data/output/final_database_clean_with_dummies.dta
*			data/output/final_database_clean_tenured_only.dta
*			data/additional_processing/final_institution_list_medical.dta

*   Output: 	results/tables/table_transition_salary_all.tex
*				results/tables/table_transition_salary_tenured.tex
*				results/tables/table_transition_probability_all.tex
*				results/tables/table_transition_probability_tenured.tex
*				results/tables/table_transition_people_all.tex
*				results/tables/table_transition_people_tenured.tex


*===============================================================================
*/


cap program drop cr_t_matrix
program define cr_t_matrix
	syntax, type(str) n_quant(str) sample(str)
	
	ret_base_instcod
	local base_instcod `r(base_code)'

	local database="clean"

	
	*Assigning quantiles
	if "`sample'"=="all" {
		{
			use "data/output/institution_level_database_`database'", clear
******************************************** NOTE TO ANYONE REPLICATING THIS CODE.  REPLACE ???? WITH THE BEST RANKED SCHOOL 
******************************************** BE CONSISTENT ACROSS PROGRAMS

			replace inst_fe=0 if instcod=="`base_instcod'"
			replace inst_fe_trim=0 if instcod=="`base_instcod'"
			
			replace se_inst_fe=0 if instcod=="`base_instcod'"

			merge 1:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3)  nogen

			drop if todrop==1
			
			
		}
	}
	else if "`sample'"=="tenured" {
		use "data/output/final_database_clean_tenured_only", clear
		keep instcod
		duplicates drop 
		merge 1:1 instcod using "data/output/institution_level_database_`database'", keep(3) nogen
	}
	
	generate university=institution_type==1
	generate college=institution_type==2
	generate unranked=institution_type==3
	
	xtile uni_rank_q=inst_ranking_p if university, nq(5)
	xtile coll_rank_q=inst_ranking_p if college, nq(5)
	
	generate all_rank=uni_rank_q
	replace all_rank=coll_rank_q+`n_quant' if college
	replace all_rank=11 		if unranked
	
	
	keep instcod institution_type uni_rank_q all_rank
	
	tempfile quantiles
	save `quantiles'
	

	if "`type'"=="salary" {
		if "`sample'"=="all" {
			use "data/output/final_database_`database'_with_dummies", clear	
		} 
		else if "`sample'"=="tenured" {
			use "data/output/final_database_clean_tenured_only", clear
		}
		
		gcollapse (mean) l_r_salary, by(panelid acad_spell_id instcod)
		
		merge m:1 instcod using `quantiles', keep(1 3) nogen

		
		sort panelid acad_spell_id
		by panelid: generate spell=_n
		by panelid: generate origin_id=spell
		by panelid: generate destination_id=spell-1

		tempfile to_restore
		save `to_restore'
			
		tempfile origin_list
			keep panelid spell instcod *rank l_r_salary
			rename instcod instcod_origin
			rename all_rank all_origin
			rename l_r_salary salary_origin
		save `origin_list'

		use `to_restore', clear
		keep 	destination_id instcod panelid *rank l_r_salary
		rename 	instcod instcod_dest
		drop 	if destination_id==0
		rename 	destination_id spell
		rename 	all_rank all_dest
		rename l_r_salary salary_dest


		merge 1:1 panelid spell using `origin_list', keep(1 3) nogen

		generate d_salary=salary_dest-salary_origin

		gcollapse (mean) d_salary (nunique) n_people=panelid, by(all_origin all_dest)

		
		*Getting data
		local tot=`n_quant'*2+1
		forvalues o=1/`tot' {
			local origin_`o' 
			forvalues d=1/`tot' {
				summ d_salary if all_origin==`o'&all_dest==`d'
				local t_`o'_`d': display %9.3fc `r(mean)'
				summ n_people if all_origin==`o'&all_dest==`d'
				if "`r(mean)'"!="" {
					if `r(mean)'<=5 { 
						local t_`o'_`d' N.D.
					}
				}
				if "`t_`o'_`d''"=="" {
					local t_`o'_`d' N.D.
				}
				
				local origin_`o' `origin_`o'' & `t_`o'_`d''
			}
		}
		
	}
	else if "`type'"=="probability" {
		if "`sample'"=="all" {
			use "data/output/final_database_`database'_with_dummies", clear	
		} 
		else if "`sample'"=="tenured" {
			use "data/output/final_database_clean_tenured_only", clear
		}
		
		keep panelid acad_spell_id instcod 
		duplicates drop	

		merge m:1 instcod using `quantiles', keep(1 3) nogen


		sort panelid acad_spell_id
		by panelid: generate spell=_n
		by panelid: generate origin_id=spell
		by panelid: generate destination_id=spell-1

		tempfile to_restore
		save `to_restore'
			
		tempfile origin_list
			keep panelid spell instcod *rank 
			rename instcod instcod_origin
			rename all_rank all_origin
		save `origin_list'

		use `to_restore', clear
		keep 	destination_id instcod panelid *rank
		rename 	instcod instcod_dest
		drop 	if destination_id==0
		rename 	destination_id spell
		rename 	all_rank all_dest

		merge 1:1 panelid spell using `origin_list', keep(1 3) nogen

		*preserve
		*University transition matrix
		xi i.all_dest, noomit prefix(d_)
		
		if `n_quant'==5 {
			local counts c_1=d_all_dest_1 c_2=d_all_dest_2 c_3=d_all_dest_3 c_4=d_all_dest_4 c_5=d_all_dest_5 c_6=d_all_dest_6 c_7=d_all_dest_7 c_8=d_all_dest_8 c_9=d_all_dest_9 c_10=d_all_dest_10 c_11=d_all_dest_11	
		}
		else if `n_quant'==4 {
			local counts c_1=d_all_dest_1 c_2=d_all_dest_2 c_3=d_all_dest_3 c_4=d_all_dest_4 c_5=d_all_dest_5 c_6=d_all_dest_6 c_7=d_all_dest_7 c_8=d_all_dest_8 c_9=d_all_dest_9
		}
		
		collapse (mean) d_* (sum) `counts', by(all_origin)

		local tot=`n_quant'*2+1
		forvalues o=1/`tot' {
			local origin_`o' 
			forvalues d=1/`tot' {
				summ d_all_dest_`d' if all_origin==`o'
				local t_`o'_`d': display %9.3fc `r(mean)'
				
				summ c_`d' if all_origin==`o'
				if "`r(mean)'"!="" {
					if `r(mean)' <5 {
						local t_`o'_`d' N.D.
					}
				}
				if "`t_`o'_`d''"=="" {
					local t_`o'_`d' N.D.
				}
				local origin_`o' `origin_`o'' & `t_`o'_`d''
			}
		}
	}
	else if "`type'"=="people" {
		if "`sample'"=="all" {
			use "data/output/final_database_`database'_with_dummies", clear	
		} 
		else if "`sample'"=="tenured" {
			use "data/output/final_database_clean_tenured_only", clear
		}
		
		gcollapse (mean) l_r_salary, by(panelid acad_spell_id instcod)
		
		merge m:1 instcod using `quantiles', keep(1 3) nogen

		
		sort panelid acad_spell_id
		by panelid: generate spell=_n
		by panelid: generate origin_id=spell
		by panelid: generate destination_id=spell-1

		tempfile to_restore
		save `to_restore'
			
		tempfile origin_list
			keep panelid spell instcod *rank l_r_salary
			rename instcod instcod_origin
			rename all_rank all_origin
			rename l_r_salary salary_origin
		save `origin_list'

		use `to_restore', clear
		keep 	destination_id instcod panelid *rank l_r_salary
		rename 	instcod instcod_dest
		drop 	if destination_id==0
		rename 	destination_id spell
		rename 	all_rank all_dest
		rename l_r_salary salary_dest


		merge 1:1 panelid spell using `origin_list', keep(1 3) nogen

		generate d_salary=salary_dest-salary_origin

		gcollapse (nunique) people=panelid, by(all_origin all_dest)
	
		
		*Getting data
		local tot=`n_quant'*2+1
		forvalues o=1/`tot' {
			local origin_`o' 
			forvalues d=1/`tot' {
				summ people if all_origin==`o'&all_dest==`d'
				local t_`o'_`d': display %9.0fc `r(mean)'
				summ people if all_origin==`o'&all_dest==`d'
				if "`r(mean)'"!="" {
					if `r(mean)'<=5 { 
						local t_`o'_`d' N.D.
					}
				}
				if "`t_`o'_`d''"=="" {
					local t_`o'_`d' N.D.
				}
				
				local origin_`o' `origin_`o'' & `t_`o'_`d''
			}
		}
	}
	
	if "`sample'"=="tenured" {
		local stub ", tenured faculty only"
	}
	
	if `n_quant'==5 {
		local qname quintile
	}
	else if `n_quant'==4 {
		local qname quartile
	}
	
	if "`type'"=="salary" {
		local table_title	"Changes in log salary by ranking `qname' and transition type`stub'"
	}
	else if "`type'"=="probability" {
		local table_title "Transition probability by ranking `qname' and institution type`stub'"
	}
	else if "`type'"=="people" {
		local table_title "Number of people by ranking `qname' and institution type`stub'"
	}
		
	{
		local table_name   "results/tables/table_transition_`type'_`sample'.tex"
		local table_key		"tab:table_`type'"
		local ftitle		"Origin"
		if `n_quant'==5 {
			local coltitles		Best 2 3 4 Worst Best 2 3 4 Worst Unranked
			local exhead "&\multicolumn{11}{c}{\scshape Destination}\\ \cmidrule(lr){2-12}  & \multicolumn{5}{c}{\scshape Universities} & \multicolumn{5}{c}{\scshape Colleges}  \\ \cmidrule(lr){2-6} \cmidrule(lr){7-11}"
		}
		else if `n_quant'==4{
			local coltitles		Best 2 3 Worst Best 2 3 Worst Unranked
		}
		local total=2*`n_quant'+1
		local ctotal=2*`n_quant'+2
		local n_cols `total'
		local end1=`n_quant'+1
		local end2=`total'
		local start2=`end1'+1
		local exhead "&\multicolumn{`total'}{c}{\scshape Destination}\\ \cmidrule(lr){2-`ctotal'}  & \multicolumn{`n_quant'}{c}{\scshape Universities} & \multicolumn{`n_quant'}{c}{\scshape Colleges}  \\ \cmidrule(lr){2-`end1'} \cmidrule(lr){`start2'-`end2'}"
		local table_notes   "ADD NOTES"
		
		textablehead using `table_name', f(`ftitle') ncols(`n_cols') title(`table_title') ///
				coltitles(`coltitles') exhead(`exhead') land ct(\scshape) adjust(1.3)
		writeln `table_name' "Universities \\"
		writeln `table_name' "$texspace Best   `origin_1' \\"
		writeln `table_name' "$texspace 2  `origin_2' \\"
		writeln `table_name' "$texspace 3  `origin_3' \\"
		if `n_quant'==5{
			writeln `table_name' "$texspace 4  `origin_4' \\"
			writeln `table_name' "$texspace Worst  `origin_5' \\"
		}
		else if `n_quant'==4 {
			writeln `table_name' "$texspace Worst  `origin_4' \\"
		}
		writeln `table_name' "Colleges \\"
		writeln `table_name' "$texspace  Best   `origin_6' \\"
		writeln `table_name' "$texspace 2  `origin_7' \\"
		writeln `table_name' "$texspace 3  `origin_8' \\"
		if `n_quant'==5 {
			writeln `table_name' "$texspace 4  `origin_9' \\"
			writeln `table_name' "$texspace Worst  `origin_10' \\"
		}
		else if `n_quant'==4 {
			writeln `table_name' "$texspace Worst  `origin_9' \\"
		}
		
		writeln `table_name' "$texspace Unranked  `origin_7' \\"
		textablefoot using `table_name', notes(`table_notes') land nodate 	
	}
end 

cr_t_matrix, type(salary) n_quant(5) sample(all)
cr_t_matrix, type(salary) n_quant(4) sample(tenured)

cr_t_matrix, type(probability) n_quant(5) sample(all)
cr_t_matrix, type(probability) n_quant(4) sample(tenured)

cr_t_matrix, type(people) n_quant(5) sample(all)
cr_t_matrix, type(people) n_quant(4) sample(tenured)
