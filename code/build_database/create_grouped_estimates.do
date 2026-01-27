/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates AKM estimates by grouping institutions with similar rankings to ensure at least 5 movers per group

*   Input: data/output/final_database_clean_with_dummies.dta
*          data/output/institution_level_database_clean.dta
*   Output: data/output/dummy_estimates_file_*_grouped*.dta
*           data/output/indiv_fe_estimates_*_grouped*.dta
*           results/regressions/*_*_grouped*.ster
					

*===============================================================================
*/
*/

local source `1'

*FIRST I COMPUTE THE NUMBER OF MOVERS PER INSTITUTION
*===============================================================================

do "code/build_database/regression_programs.do"

cap program drop create_grouped_estimates
program define create_grouped_estimates
	syntax, [NOsen]

	if "`nosen'"!="" {
		local stub _nosen
	}
	
	{
		use "data/output/final_database_clean_with_dummies.dta", clear

		do "code/build_database/update_observation_type.do"

		keep if observation_type==1

		duplicates drop panelid instcod acad_spell_id, force

		order refid acad_spell_id instcod, first

		sort panelid refyr

		gcollapse (count) panelid, by(instcod)

		rename panelid n_movers

		tempfile n_movers
		save `n_movers'
	}


	*NEXT I ADD THE RANKINGS
	{
		use `n_movers'
		merge 1:1 instcod using "data/output/institution_level_database_clean", keepusing(institution_type l_inst_ranking_p inst_name) nogen
		
		order n_movers, last
		
		gsort institution_type -l_inst_ranking_p instcod
		
		generate add=0

		
		replace add=1 if _n==1
		
		replace add=1 if n_movers>=5
		
		
		replace add=1 if institution_type!=institution_type[_n-1]&_n>1
		generate grouped_code=sum(add)
		
		
		egen move_number=sum(grouped_code)

		keep instcod grouped_code move_number

		save "data/additional_processing/agg_instcods", replace
	}

	*COMPUTE THE  AVERAGE RANKINGS RANKINGS
	{
		use "data/output/institution_level_database_clean", clear
		
		merge 1:1 instcod using  "data/additional_processing/agg_instcods"
		
		keep instcod grouped_code inst_ranking_p l_inst_ranking_p institution_type move_number
		
		gcollapse (mean) inst_ranking_p l_inst_ranking_p move_number, by(grouped_code institution_type)
		
		tempfile avg_rankings
		save `avg_rankings'
	}


	*NEXT I UPDATE THE SPELL COUNTERS
	*===============================================================================
	{
		use "data/output/final_database_clean_with_dummies.dta", clear
		
		merge m:1 instcod using "data/additional_processing/agg_instcods", keep(1 3) nogen
		
		keep refid acad_spell_id instcod grouped_code
		
		duplicates drop
			
		sort refid acad_spell_id grouped_code

		cap drop add
		generate add=0
		by refid: replace add=1 if _n==1
		by refid: replace add=1 if _n>1&grouped_code[_n]!=grouped_code[_n-1]
		
		by refid: generate group_acad_count=sum(add)
		
		drop add
		
		tempfile updated_acad_count
		save `updated_acad_count'
	}

	*NEXT I RECOMPUTE THE FIXED-EFFECTS

	{
		local d_type "clean"
		local use_file "data/output/final_database_`d_type'_with_dummies.dta"
		
		use "`use_file'", clear

		*I update the spell counters
		merge m:1 refid acad_spell_id instcod using  `updated_acad_count'
		drop acad_spell_id
		
		rename group_acad_count acad_spell_id
		
		order grouped_code, after(instcod)
		
		
		
		order acad_spell_id, after(refid)
		
		do "code/build_database/update_observation_type.do"
		
		*Note that all this grouped codes are still connected. If the most disaggregated
		*network is connected, the aggregated one must be too.
		
		drop u_instcod*
		
		rename instcod or_instcode
		
		rename grouped_code instcod
		
		xi i.instcod, pre(u_)
		*********************************************************************************************************************************************
		drop XXXX
			
		
		*Creating estimation files
		eststo clear

		get_spec, type(fs:main) `nosen'
		foreach spec in unife controls allcontrol sscontrol base {
			local `spec' `r(`spec')'
		}
		 
								 

		local model all_clust


			
		*In this bit I am getting estimates of the fe without se.
		eststo `model': cap reghdfe l_r_salary_f  `unife' `controls', ///
				absorb(indiv_fe=panelid refyr, savefe) nocons ///
				keepsingleton vce(cl panelid)
		
		estfe . *
		

		preserve
		{
			gcollapse (nunique) n_people=panelid, by(instcod)
			
			rename instcod grouped_code
			tempfile n_people
			save `n_people'
		}
		
		restore
		
		unique panelid if observation_type==1
		
		local n_movers=`r(unique)'
		
		estadd scalar n_movers=`n_movers'
		
		log using "results/log_files/corr_inst_ind_fe_`d_type'.txt", text replace
		corr indiv_fe 
		log close
		
		estimates save "results/regressions/`model'_`d_type'_grouped`stub'", replace


		preserve
			keep panelid indiv_fe
			duplicates drop
			save "data/output/indiv_fe_estimates_`d_type'_grouped`stub'.dta", replace
		restore

		local estimation_list all_clust

		foreach estimation in `estimation_list' {
			estimates use "results/regressions/`estimation'_`d_type'_grouped`stub'"
			tempfile `estimation'_fe		
			
			parmest, saving(``estimation'_fe', replace)

			use ``estimation'_fe', clear 
			
			generate to_keep=regexm(parm, "u_instcod")
			drop if !to_keep
			
			split parm, parse("_")
			
			rename parm3 inst_number
			destring inst_number, replace
			
			rename estimate `estimation'
			rename stderr 	se_`estimation'
			rename p		p_`estimation'
			*I do this because harvard is the 271th institution
			keep 		inst_number `estimation' se_`estimation' p_`estimation'
			save 		``estimation'_fe', replace
		}

		clear

		use  `all_clust_fe'
		rename inst_number grouped_code
		merge 1:1 grouped_code using   `avg_rankings'

		replace all_clust=0 if grouped_code==127
		
		drop if missing(all_clust)
		
		cap drop _merge
		
		merge 1:1 grouped_code using `n_people', keep(1 3) nogen

		save "data/output/dummy_estimates_file_`d_type'_grouped`stub'", replace
	}
end


create_grouped_estimates

create_grouped_estimates, nosen


