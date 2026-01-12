*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	Garro-Marin, Kahn, and Lang
				
	Description: creates main table of summary statistics
	latest mods: condensed all panels to output them in only one table
*/
*===============================================================================



global texspace \hspace{3mm}


cap program drop create_summ_table 
program define create_summ_table
	syntax, sample(str)
	
	if "`sample'"=="raw" {
		local title_stub "including salary outliers"
	}
		
	*COLLECTION OF INFORMATION
	{
		*Getting individual level information
		{
			use "data/output/final_database_`sample'_with_dummies.dta", clear

			do "code/build_database/update_observation_type.do"
			
			summ panelid

			*Number of people years
			local n_obs=`r(N)'


			*Number of people
			unique panelid
			local n_people=`r(unique)'


			*Number of observations for movers
			summ panelid if observation_type
			local n_obs_movers=`r(N)'

			*Number of people
			unique panelid if observation_type
			local n_movers=`r(unique)'

			xi i.faculty_rank_f, noomit

			*Number of moves
			unique panelid acad_spell_id if observation_type==1
			local n_moves=`r(unique)'


			*Calculating number moves per person (in case it needs updating)
			gegen n_moves=nunique(acad_spell_id), by(panelid)
			summ n_moves if observation_type

			local max_moves=`r(max)'
			local min_moves=`r(min)'


			*Calculation number of moves per university
			preserve
			keep panelid acad_spell_id instcod observation_type
			duplicates drop
			
			gegen temp=group(panelid acad_spell_id)
			gegen n_moves_uni=nunique(temp) if observation_type==1, by(instcod)
			summ n_moves_uni

			local max_moves_uni=`r(max)'
			local min_moves_uni=`r(min)'
			restore

			
			foreach variable in married  has_ch_6 has_ch_611 has_ch_1218 has_ch_19 {
				generate f_`variable'=female*`variable'
			}
			
			*Variable list
			local summary_list years_since_phd married tenured_f time_current_job_f female has_ch_6 has_ch_611 has_ch_1218 has_ch_19 _I* f_*
			foreach variable of varlist `summary_list' {
				summ `variable'
				local obs_`variable': display %9.0fc `r(N)'
				local mean_`variable': display %9.2fc  `r(mean)'
				local sd_`variable': display %9.2fc  `r(sd)'
				local min_`variable': display %9.2fc  `r(min)'
				local max_`variable': display %9.2fc  `r(max)'
			}


			*Number of moves
			unique instcod if observation_type==1
			local n_uni=`r(unique)'
		}
		
		*Getting university-level information
		{
			use "data/output/institution_level_database_`sample'", clear
******************************************** NOTE TO ANYONE REPLICATING THIS CODE.  REPLACE ???? WITH THE BEST RANKED SCHOOL 
******************************************** BE CONSISTENT ACROSS PROGRAMS

			replace inst_fe=0 if instcod=="????"
			replace inst_fe_trim=0 if instcod=="????"
			
			replace se_inst_fe=0 if instcod=="????"

				
			merge m:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3) 

			cap drop _merge


			drop if todrop==1

			*============================================================
			*First I set the estimation sample
			*============================================================
			*Regression with no additional controls
			local base_spec  ib3.institution_type ib3.institution_type#c.l_inst_ranking_p

			*Dummies of offering undergrad degree only, private/public university
			qui wregress inst_fe `base_spec'  ///
				ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
				l_faculty_per_student i.ug_only i.control, ///
				se(se_inst_fe) stub(m6)
				
			estimates restore m6ss
				
			cap drop in_sample
			generate in_sample=e(sample)

			


			*Continuous variables
			local summary_list_uni l_enrollment_total_m l_r_endowment l_faculty_total_m l_faculty_per_student l_r_endowment_per_student
			foreach variable of varlist `summary_list_uni' {
				summ `variable' if in_sample
				local obs_`variable': display %9.0fc `r(N)'
				local mean_`variable': display %9.2fc `r(mean)'
				local sd_`variable': display %9.2fc `r(sd)'
				local min_`variable': display %9.2fc `r(min)'
				local max_`variable': display %9.2fc `r(max)'
			}

			forvalues type=1/3 {
				foreach variable of varlist inst_ranking_p{
					summ `variable'							if institution_type==`type'&in_sample
					local obs_`variable'_`type': display %9.0fc `r(N)'  	
					local mean_`variable'_`type': display %9.0fc `r(mean)' 	
					local sd_`variable'_`type': display %9.0fc `r(sd)'  	
					local min_`variable'_`type': display %9.0fc `r(min)'  	
					local max_`variable'_`type': display %9.0fc `r(max)'  	
				}
			}




			*Share private
			generate private=control==2

			xi i.new_locale, noomit


			*Continuous variables
			local summary_list_uni private ug_only _Inew_local_1 _Inew_local_2 _Inew_local_3 
			foreach variable of varlist `summary_list_uni' {
				summ `variable' if in_sample
				local obs_`variable': display %9.0fc `r(N)'
				local mean_`variable': display %9.2fc `r(mean)'
				local sd_`variable': display %9.2fc `r(sd)'
				local min_`variable': display %9.2fc `r(min)'
				local max_`variable': display %9.2fc `r(max)'
			}


			*Latex table with number of moves
			{
				
				local obs_all: display %9.0fc `n_obs'
				local obs_movers: display %9.0fc `n_obs_movers'
				local obs_share_movers=`n_obs_movers'/`n_obs'
				local obs_share_movers: display %9.2fc `obs_share_movers'
				
				local p_all: display %9.0fc `n_people'
				local p_movers: display %9.0fc `n_movers'
				local p_share_movers=`n_movers'/`n_people'
				local p_share_movers: display %9.2fc `p_share_movers'

				local avg_all=`n_obs'/`n_people'
				local avg_all: display %9.2fc `avg_all'
				
				local avg_movers=`n_obs_movers'/`n_movers'
				local avg_movers: display %9.2fc `avg_movers'
				
				
			}


			*Latex table with number of transitions
			{
				local n_transitions=`n_moves'-`n_movers' 
				local n_transitions: display %9.0fc `n_transitions'

				local movers: display %9.0fc `n_movers'
				local universities: display %9.0fc `n_uni'

				local t_mover=(`n_moves'-`n_movers')/`n_movers'
				local t_mover: display %9.2fc `t_mover'
				local min_mover=`min_moves'-1
				local min_mover: display %9.0fc `min_mover'
				local max_mover=`max_moves'-1
				local max_mover: display %9.0fc `max_mover' 
				

				local t_uni=(`n_moves'-`n_movers')/`n_uni'
				local t_uni: display %9.2fc `t_uni'
				local min_uni: display %9.0fc `min_moves_uni'
				local max_uni: display %9.0fc `max_moves_uni'
			}
		}
	}
		
	*Writing of the table
	local table_name	"results/tables/table_summary_stats_`sample'.tex"
	local table_key 	"tab:summary_`sample'"
	local table_title 	"Summary statistics `title_stub'"
	local coltitles		`""All""Movers""Share of \\ total""""""Total""Min""Max""'
	local n_cols		8
	local exhead		"\multicolumn{4}{c}{\scshape A: Number of movers in the sample}& \multicolumn{5}{c}{\scshape B. Number of transitions in the sample} \\"
	local table_notes 	"There are `obs_inst_ranking_p_1' research universities and `obs_inst_ranking_p_2' colleges. `obs_inst_ranking_p_3' institutions are unranked and not classified as colleges or universities. $^*$ Suppressed for confidentiality"
	
	textablehead using `table_name', ncols(`n_cols') title(`table_title') ///
		coltitles(`coltitles')  exhead(`exhead') adjust(1) ct(\scshape) drop  col(r)
	
	*Writing panels A and B
	writeln  `table_name' "Total observations& `obs_all' & `obs_movers' & `obs_share_movers' & Transitions&& `n_transitions'\\"
	writeln  `table_name' "Number of people& `p_all' & `p_movers' & `p_share_movers' & Number of movers&& `movers'\\"
	writeln  `table_name' "Average observation per person& `avg_all' & `avg_movers'& & Number of universities&& `universities' \\"
	writeln  `table_name' "&&&&Transitions per mover&& `t_mover' & `min_mover' & $ * $ \\"
	writeln  `table_name' "&&&&Transitions per university&& `t_uni' & `min_uni' & `max_uni' \\ \midrule \\"
	writeln  `table_name' "\multicolumn{4}{c}{\scshape C: Individual characteristics}&\multicolumn{5}{c}{\scshape C: University characteristics} \\"
	
	*Writing panels C and D
	writeln  `table_name' " & {\scshape Observations} & {\scshape Mean }&{\scshape SD }& &{\scshape Mean }&{\scshape SD }&{\scshape Min }&{\scshape Max }\\"
	
	
	*First line
	local var_line years_since_phd
local var_line2 inst_ranking_p_1
	local addline "Research universities & `mean_`var_line2''& `sd_`var_line2'' & `min_`var_line2'' & `max_`var_line2''"
	writeln `table_name' "\midrule Years since Ph.D. & `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline' \\"

	*Second line
	local var_line inst_ranking_p_2
	local addline  "Colleges & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	local var_line tenured_f
	writeln `table_name' "Has tenure & `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline' \\"
	
	*Third line
	local var_line l_enrollment_total_m
	local addline "Log of total enrollment & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	local var_line time_current_job_f
	writeln `table_name' "Time in current job& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline' \\"
	
	
	*Fourth line
	local var_line l_r_endowment
	local addline  "Log of total endowment (2020 USD) & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	writeln `table_name' "\textit{Faculty rank} &&&& `addline' \\"

	
	*Fifth line
	local var_line l_r_endowment_per_student
	local addline "Log of endowment per student (2020 USD) & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	local var_line _Ifaculty_r_3
	writeln `table_name' "$texspace Assistant professor& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline' \\"

	*Sixth line
	local var_line l_faculty_total_m
	local addline "Log of faculty size  & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	local var_line _Ifaculty_r_4
	writeln `table_name' "$texspace Associate professor& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline' \\"

	*Seventh line
	local var_line l_faculty_per_student
	local addline "Log of faculty per student  & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	local var_line _Ifaculty_r_5
	writeln `table_name' "$texspace Professor& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline' \\"

	*Eighth line	
	local var_line _Inew_local_1
	local addline "Share in large city  & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	local var_line _Ifaculty_r_1
	writeln `table_name' "$texspace Lecturer& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline' \\"
	
	*Ninth line
	local var_line _Inew_local_2
	local addline "Share in medium city  & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	local var_line _Ifaculty_r_2
	writeln `table_name' "$texspace Instructor& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline' \\"


	*Ninth line
	local var_line _Inew_local_3
	local addline "Share in small city & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	local var_line _Ifaculty_r_6
	writeln `table_name' "$texspace Other& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline' \\"

	*Tenth line
	local var_line private
	local addline "Share private & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	local var_line female_f
	writeln `table_name' "Female& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline' \\"

	*Eleventh line
	local var_line ug_only
	local addline "Share undergraduate &  `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line''"
	local var_line married
	writeln `table_name' "Married& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' & `addline'  \\"
	
	local var_line has_ch_6
	writeln `table_name' "Has child under 6& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

	local var_line has_ch_611
	writeln `table_name' "Has child aged 6-11& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

	local var_line has_ch_1218
	writeln `table_name' "Has child aged 12-18& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

	local var_line has_ch_19
	writeln `table_name' "Has child aged 19+& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"
	

	textablefoot using `table_name', notes(`table_notes') nodate 
end

create_summ_table, sample(raw)
create_summ_table, sample(clean)


*Code below is discarded after creating new versions of all the tables
/*
foreach database in clean  {
	use "data/output/final_database_`database'_with_dummies.dta", clear

	do "code/build_database/update_observation_type.do"

	*Individual level observations
	*===============================================================================

	summ panelid

	*Number of people years
	local n_obs=`r(N)'


	*Number of people
	unique panelid
	local n_people=`r(unique)'


	*Number of observations for movers
	summ panelid if observation_type
	local n_obs_movers=`r(N)'

	*Number of people
	unique panelid if observation_type
	local n_movers=`r(unique)'

	xi i.faculty_rank_f, noomit

	*Number of moves
	unique panelid acad_spell_id if observation_type==1
	local n_moves=`r(unique)'


	*Calculating number moves per person (in case it needs updating)
	gegen n_moves=nunique(acad_spell_id), by(panelid)
	summ n_moves if observation_type

	local max_moves=`r(max)'
	local min_moves=`r(min)'


	*Calculation number of moves per university
	preserve
	keep panelid acad_spell_id instcod observation_type
	duplicates drop
	
	gegen temp=group(panelid acad_spell_id)
	gegen n_moves_uni=nunique(temp) if observation_type==1, by(instcod)
	summ n_moves_uni

	local max_moves_uni=`r(max)'
	local min_moves_uni=`r(min)'
	restore

	
	foreach variable in married  has_ch_6 has_ch_611 has_ch_1218 has_ch_19 {
		generate f_`variable'=female*`variable'
	}
	
	*Variable list
	local summary_list years_since_phd married tenured_f time_current_job_f female has_ch_6 has_ch_611 has_ch_1218 has_ch_19 _I* f_*
	foreach variable of varlist `summary_list' {
		summ `variable'
		local obs_`variable': display %9.0fc `r(N)'
		local mean_`variable': display %9.2fc  `r(mean)'
		local sd_`variable': display %9.2fc  `r(sd)'
		local min_`variable': display %9.2fc  `r(min)'
		local max_`variable': display %9.2fc  `r(max)'
	}


	*Number of moves
	unique instcod if observation_type==1
	local n_uni=`r(unique)'


	*UNIVERSITY LEVEL VARIABLES
	*===============================================================================
	use "data/output/institution_level_database_`database'", clear
	
	******************************************** NOTE TO ANYONE REPLICATING THIS CODE.  REPLACE ???? WITH THE BEST RANKED SCHOOL 
******************************************** BE CONSISTENT ACROSS PROGRAMS
	
	replace inst_fe=0 if instcod=="????"
	replace inst_fe_trim=0 if instcod=="????"
	
	replace se_inst_fe=0 if instcod=="????"

		
	merge m:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3) 

	cap drop _merge


	drop if todrop==1

	*============================================================
	*First I set the estimation sample
	*============================================================
	*Regression with no additional controls
	local base_spec  ib3.institution_type ib3.institution_type#c.l_inst_ranking_p

	*Dummies of offering undergrad degree only, private/public university
	qui wregress inst_fe `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control, ///
		se(se_inst_fe) stub(m6)
		
	estimates restore m6ss
		
	cap drop in_sample
	generate in_sample=e(sample)

	


	*Continuous variables
	local summary_list_uni l_enrollment_total_m l_r_endowment l_faculty_total_m l_faculty_per_student l_r_endowment_per_student
	foreach variable of varlist `summary_list_uni' {
		summ `variable' if in_sample
		local obs_`variable': display %9.0fc `r(N)'
		local mean_`variable': display %9.2fc `r(mean)'
		local sd_`variable': display %9.2fc `r(sd)'
		local min_`variable': display %9.2fc `r(min)'
		local max_`variable': display %9.2fc `r(max)'
	}

	forvalues type=1/3 {
		foreach variable of varlist inst_ranking_p{
			summ `variable'							if institution_type==`type'&in_sample
			local obs_`variable'_`type': display %9.0fc `r(N)'  	
			local mean_`variable'_`type': display %9.0fc `r(mean)' 	
			local sd_`variable'_`type': display %9.0fc `r(sd)'  	
			local min_`variable'_`type': display %9.0fc `r(min)'  	
			local max_`variable'_`type': display %9.0fc `r(max)'  	
		}
	}




	*Share private
	generate private=control==2

	xi i.new_locale, noomit


	*Continuous variables
	local summary_list_uni private ug_only _Inew_local_1 _Inew_local_2 _Inew_local_3 
	foreach variable of varlist `summary_list_uni' {
		summ `variable' if in_sample
		local obs_`variable': display %9.0fc `r(N)'
		local mean_`variable': display %9.2fc `r(mean)'
		local sd_`variable': display %9.2fc `r(sd)'
		local min_`variable': display %9.2fc `r(min)'
		local max_`variable': display %9.2fc `r(max)'
	}


	*Latex table with number of moves
	{
		
		local obs_all: display %9.0fc `n_obs'
		local obs_movers: display %9.0fc `n_obs_movers'
		local obs_share_movers=`n_obs_movers'/`n_obs'
		local obs_share_movers: display %9.2fc `obs_share_movers'
		
		local p_all: display %9.0fc `n_people'
		local p_movers: display %9.0fc `n_movers'
		local p_share_movers=`n_movers'/`n_people'
		local p_share_movers: display %9.2fc `p_share_movers'

		local avg_all=`n_obs'/`n_people'
		local avg_all: display %9.2fc `avg_all'
		
		local avg_movers=`n_obs_movers'/`n_movers'
		local avg_movers: display %9.2fc `avg_movers'
		
		
	}


	*Latex table with number of transitions
	{
		local n_transitions=`n_moves'-`n_movers' 
		local n_transitions: display %9.0fc `n_transitions'

		local movers: display %9.0fc `n_movers'
		local universities: display %9.0fc `n_uni'

		local t_mover=(`n_moves'-`n_movers')/`n_movers'
		local t_mover: display %9.2fc `t_mover'
		local min_mover=`min_moves'-1
		local min_mover: display %9.0fc `min_mover'
		local max_mover=`max_moves'-1
		local max_mover: display %9.0fc `max_mover' 
		

		local t_uni=(`n_moves'-`n_movers')/`n_uni'
		local t_uni: display %9.2fc `t_uni'
		local min_uni: display %9.0fc `min_moves_uni'
		local max_uni: display %9.0fc `max_moves_uni'

	}
}

*===============================================================================
*OUTPUTTING THE TABLE
*===============================================================================

*Each panel of the table is outputted as a separate latex table_key

*TABLE 1 PANEL A
local table_name	"results/tables/table_1_panel_A.tex"
local table_key 	"tab:table_1_panel_A"
local table_title 	"Number of movers in the sample"
local coltitles		`""All""Movers""Share of total""'
local n_cols		3	
local fontsize		
local models
local exhead
local ftitle		


textablehead using `table_name', ncols(`n_cols') title(`table_title') ///
	coltitles(`coltitles')  exhead(`exhead')

writeln  `table_name' "Total observations& `obs_all' & `obs_movers' & `obs_share_movers' \\"

writeln  `table_name' "Number of people& `p_all' & `p_movers' & `p_share_movers' \\"

writeln  `table_name' "Average observation per person& `avg_all' & `avg_movers' \\"


textablefoot using `table_name', notes(`table_notes_`database'')

*TABLE 1 PANEL B


{
	*Outputting tex table of university level stats
	local table_name	"results/tables/table_1_panel_B.tex"
	local table_key 	"tab:table_1_panel_B"
	local table_title 	"Number of transitions in the sample"
	local coltitles		`""Total""Min""Max""'
	local n_cols		3	
	local table_notes_raw 		"table shows statistics for sample that includes wage outliers. Maximum of transitions per mover suppresed to preserve confidentiality"
	local table_notes_clean 	"table shows statistics for sample that excludes wage outliers. Maximum of transitions per mover suppresed to preserve confidentiality"
	local fontsize		
	local notefont 		\tiny
	local models
	local exhead
	local ftitle		


	textablehead using `table_name', ncols(`n_cols') title(`table_title') ///
		coltitles(`coltitles') exhead(`exhead')
	
	writeln  `table_name' "Transitions& `n_transitions' \\"
	writeln  `table_name' "Number of movers& `movers' \\"
	writeln  `table_name' "Number of universities& `universities' \\"
	writeln  `table_name' "Transitions per mover& `t_mover' & `min_mover' & $ > 4 $ \\"
	writeln  `table_name' "Transitions per university& `t_uni' & `min_uni' & `max_uni' \\"

	
	textablefoot using `table_name', notes(`table_notes_`database'')
}

*TABLE 1 PANEL C

{
	*Outputting tex table of university level stats
	local table_name	"results/tables/table_1_panel_C.tex"
	local table_key 	"tab:table_1_panel_C"
	local table_title 	"Summary statistics"
	local coltitles		`""N""Mean""Std""Min""Max""'
	local n_cols		5
	local table_notes_raw 	 
	local table_notes_clean 	 
	local fontsize		
	local notefont 		\tiny
	local models
	local exhead
	local ftitle		University-level variables


	textablehead using `table_name', ncols(`n_cols') title(`table_title') ///
		coltitles(`coltitles')  exhead(`exhead')
	writeln `table_name' "\textbf{Individual-level characteristics} \\"
	
	local var_line years_since_phd
	writeln `table_name' "$texspace Years since Ph.D. & `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' \\"

	local var_line tenured_f
	writeln `table_name' "$texspace Has tenure & `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' \\"
	
	local var_line time_current_job_f
	writeln `table_name' "$texspace Time in current job& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' \\"

	writeln `table_name' "$texspace \textit{Faculty rank} \\"

	local var_line _Ifaculty_r_3
	writeln `table_name' "$texspace $texspace Assistant professor& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' \\"

	local var_line _Ifaculty_r_4
	writeln `table_name' "$texspace $texspace Associate professor& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' \\"


	local var_line _Ifaculty_r_5
	writeln `table_name' "$texspace $texspace Professor& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' \\"

	
	local var_line _Ifaculty_r_1
	writeln `table_name' "$texspace $texspace Lecturer& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' \\"

	local var_line _Ifaculty_r_2
	writeln `table_name' "$texspace $texspace Instructor& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line'' \\"


	local var_line _Ifaculty_r_6
	writeln `table_name' "$texspace $texspace Other& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"


	local var_line female_f
	writeln `table_name' "$texspace Female& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

	local var_line married
	writeln `table_name' "$texspace Married& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"
	
	local var_line has_ch_6
	writeln `table_name' "$texspace Has child under 6& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

	local var_line has_ch_611
	writeln `table_name' "$texspace Has child aged 6-11& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

	local var_line has_ch_1218
	writeln `table_name' "$texspace Has child aged 12-18& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

	local var_line has_ch_19
	writeln `table_name' "$texspace Has child aged 19+& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"
	
	local var_line f_married
	writeln `table_name' "$texspace Female $ \times $ married& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"
	
	local var_line f_has_ch_6
	writeln `table_name' "$texspace Female $ \times $ has child under 6& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

	local var_line f_has_ch_611
	writeln `table_name' "$texspace Female $ \times $ has child aged 6-11& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

	local var_line f_has_ch_1218
	writeln `table_name' "$texspace Female $ \times $ has child aged 12-18& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

	local var_line f_has_ch_19
	writeln `table_name' "$texspace Female $ \times $ has child aged 19+& `obs_`var_line'' & `mean_`var_line'' &`sd_`var_line''  \\"

			

	textablefoot using `table_name', notes(`table_notes_`database'') 
}



*TABLE 1 PANEL D

{
	*Outputting tex table of university level stats
	local table_name	"results/tables/table_1_panel_D.tex"
	local table_key 	"tab:table_1_panel_D"
	local table_title 	"Summary statistics"
	local coltitles		`""N""Mean""Std""Min""Max""'
	local n_cols		5
	local table_notes_raw 	 
	local table_notes_clean 	 
	local fontsize		
	local notefont 		\tiny
	local models
	local exhead
	local ftitle		University-level variables


	textablehead using `table_name', ncols(`n_cols') title(`table_title') ///
		coltitles(`coltitles')  exhead(`exhead')
		writeln `table_name' "\midrule \textbf{University-level characteristics} \\"
		
	writeln `table_name' "\midrule   \textit{Times Higher Education Rankings} \\"

	local var_line inst_ranking_p_1
	writeln `table_name' "$texspace Research universities & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"


	local var_line inst_ranking_p_2
	writeln `table_name' "$texspace Colleges & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"

	local var_line inst_ranking_p_3
	writeln `table_name' "$texspace Unranked institutions & `obs_`var_line'' \\"

	writeln `table_name' "\textit{Other institution characteristics} \\"

	local var_line l_enrollment_total_m
	writeln `table_name' "$texspace Log of total enrollment & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"
	
	local var_line l_r_endowment
	writeln `table_name' "$texspace Log of total endowment (2020 USD) & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"

	local var_line l_r_endowment_per_student
	writeln `table_name' "$texspace Log of endowment per student (2020 USD) & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"


	local var_line l_faculty_total_m
	writeln `table_name' "$texspace Log of faculty size & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"

	local var_line l_faculty_per_student
	writeln `table_name' "$texspace Log of faculty per student & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"

	local var_line _Inew_local_1
	writeln `table_name' "$texspace Share in large city & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"

	local var_line _Inew_local_2
	writeln `table_name' "$texspace Share in medium city  & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"

	local var_line _Inew_local_3
	writeln `table_name' "$texspace Share in small city & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"


	local var_line private
	writeln `table_name' "$texspace Share private & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"

	local var_line ug_only
	writeln `table_name' "$texspace Share undergraduate & `obs_`var_line'' & `mean_`var_line''& `sd_`var_line'' & `min_`var_line'' & `max_`var_line'' \\"


	textablefoot using `table_name', notes(`table_notes_`database'')
}





