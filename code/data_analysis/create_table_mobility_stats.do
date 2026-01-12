*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	Garro-Marín, Kahn, and Lang
				
	Outputs:    creates summary stats depending on the type of the move
*/
*==============================================================================



*This program reshapes the dataset into transtions
cap program drop prepare_transition_dataset
program define prepare_transition_dataset
	local n_quant 3

	tempfile ranks
		use "data/output/institution_level_database_clean", clear 
		gegen rank_quantile=xtile(inst_ranking_p), nq(`n_quant') by(institution_type)
	save `ranks'
	

	use "data/output/final_database_clean_with_dummies.dta", clear
	merge m:1  instcod  using `ranks', keep(3) nogen
	
	sort panelid period 
	
	cap drop d_l_r_salary
	
	by panelid: generate move_period=instcod!=instcod[_n-1] if _n>1	
	
	foreach variable in instcod institution_type inst_ranking_p l_inst_ranking_p l_r_salary rank_quantile tenured_f faculty_rank_f age_f race_f  female_f {
		by panelid: generate o_`variable'=`variable'[_n-1] if move_period==1
		
		local varlabel: variable label `variable'
		label var `variable' "`varlabel'"
	}
	
	by panelid: generate d_l_r_salary=l_r_salary-l_r_salary[_n-1] if move_period==1

	
	keep panelid instcod move_period  acad_spell_id period o_instcod *tenured*  *l_r_salary *inst_ranking_p *institution_type *rank_quantile *faculty_rank* *age_f *race_f  *female_f

	keep if move_period==1 

	drop move_period 
	
	label values o_institution_type Ranking_type

	
	sort panelid period 
	
	order panelid period *instcod* *institution* *inst_* *salary* *rank_quantile

	
	generate uni_trans=rank_quantile
	generate coll_trans=rank_quantile
	replace uni_trans=`n_quant'+1 if institution_type==2&o_institution_type==1
	replace uni_trans=`n_quant'+2 if institution_type==3&o_institution_type==1
	replace coll_trans=`n_quant'+1 if institution_type==1&o_institution_type==2
	replace coll_trans=`n_quant'+2 if institution_type==3&o_institution_type==2
	
	
	label define o_rank_quantile 1 "Top" 2 "Middle" 3 "Bottom"
	label values o_rank_quantile

	label define uni_trans 1 "Top" 2 "Middle" 3 "Bottom" ///
		4 "Colleges" 5 "Unranked"
	label values uni_trans uni_trans

	label define coll_trans 1 "Top" 2 "Middle" 3 "Bottom" ///
		4 "Universities" 5 "Unranked"
	label values coll_trans coll_trans
end

*This program create the table of transitions by terciles of prestige
cap program drop create_transition_tables
program define create_transition_tables, rclass
	syntax
		summ d_l_r_salary if uni_trans==1|coll_trans==1
		local table_obs=`r(N)'
		
		preserve
			gcollapse (mean) d_l_r_salary (count) count=panelid (nunique) n_people=panelid if o_institution_type==1, by(o_institution_type o_rank_quantile uni_trans)
			keep o_institution_type o_rank_quantile uni_trans d_l_r_salary count n_people
			keep if o_institution_type==1
			reshape wide d_l_r_salary count n_people, i(o_institution_type o_rank_quantile) j(uni_trans)
		
			tempfile universities
			save `universities'
		restore
	
		preserve
			gcollapse (mean) d_l_r_salary (count) count=panelid (nunique) n_people=panelid if o_institution_type==2, by(o_institution_type o_rank_quantile coll_trans)
			keep o_institution_type o_rank_quantile coll_trans d_l_r_salary count n_people
			reshape wide d_l_r_salary count n_people, i(o_institution_type o_rank_quantile) j(coll_trans)
		
			tempfile colleges
			save `colleges'
		restore
		
		preserve
		
		clear 
		append using `universities'
		append using `colleges'
		
		egen cat_moves=rowtotal(count*)
		
		drop *5
		
		order o_* d_*
		
		
		*Writing the tables
		forvalues i=1/2 {
			forvalues q=1/3 {
				local q_`i'_`q'_sal_list 
				forvalues j=1/4 {
					qui summ d_l_r_salary`j' if o_institution_type==`i'&o_rank_quantile==`q'
					local change: di %9.2fc `r(mean)'
					
					local q_`i'_`q'_sal_list="`q_`i'_`q'_sal_list' & `change'"
				}
			}
		}

		forvalues i=1/2 {
			local q_`i'_1_sal_list="Top `q_`i'_1_sal_list'"
			local q_`i'_2_sal_list="Middle `q_`i'_2_sal_list'"
			local q_`i'_3_sal_list="Bottom `q_`i'_3_sal_list'"
		}
	
		
		*Transition count
		forvalues i=1/2 {
			forvalues q=1/3 {
				local q_`i'_`q'_count_list 
				forvalues j=1/4 {
					qui summ count`j' if o_institution_type==`i'&o_rank_quantile==`q'
					local change: di %9.0fc `r(mean)'
					
					local q_`i'_`q'_count_list="`q_`i'_`q'_count_list' & `change'"
				}
			}
		}

		forvalues i=1/2 {
			local q_`i'_1_count_list="Top `q_`i'_1_count_list'"
			local q_`i'_2_count_list="Middle `q_`i'_2_count_list'"
			local q_`i'_3_count_list="Bottom `q_`i'_3_count_list'"
		}
		
				
		*People count
		forvalues i=1/2 {
			forvalues q=1/3 {
				local q_`i'_`q'_people_list 
				forvalues j=1/4 {
					qui summ n_people`j' if o_institution_type==`i'&o_rank_quantile==`q'
					local change: di %9.0fc `r(mean)'
					
					local q_`i'_`q'_people_list="`q_`i'_`q'_people_list' & `change'"
				}
			}
		}

		forvalues i=1/2 {
			local q_`i'_1_people_list="Top `q_`i'_1_people_list'"
			local q_`i'_2_people_list="Middle `q_`i'_2_people_list'"
			local q_`i'_3_people_list="Bottom `q_`i'_3_people_list'"
		}
		
		

		
		local ncols=4
		local table_title_wage "Salary changes by type of transition"
		local table_title_count "Number of moves by type of transition"
		local table_title_people "Number of movers by type of transition"
		local table_name_people "results/tables/transition_people_terciles.tex"
		local table_name_count "results/tables/transition_count_terciles.tex"
		local table_name_wages "results/tables/transition_wages_terciles.tex"
		
		local coltitlesA `""Top""Middle""Bottom""Colleges""'
		local coltitlesB `""Top""Middle""Bottom""Universities""'
		local exhead "&\multicolumn{4}{c}{Destination}\\ \cline{2-5}"
		
		
		*Writing wage table
		{
			textablehead using "`table_name_wages'", f(A. Origin university tercile) ///
				title(`table_title_wage') coltitles(`coltitlesA')  exhead(`exhead') col(r)
			
			
			forvalues q=1/3 {
				writeln "`table_name_wages'" "`q_1_`q'_sal_list' \\"
			}
			
			leanesttab using "`table_name_wages'", ncols(`ncols')  midhead(`coltitlesB') append noest f(B. Origin college tercile)
					
			forvalues q=1/3 {
				writeln "`table_name_wages'" "`q_2_`q'_sal_list' \\"
			}
			
			textablefoot using "`table_name_wages'", nodate
		}
		
		*Writing transition count table
		{
			textablehead using "`table_name_count'", f(A. Origin university tercile) ///
				title(`table_title_count') coltitles(`coltitlesA')  exhead(`exhead') col(r)
		
		
			forvalues q=1/3 {
				writeln "`table_name_count'" "`q_1_`q'_count_list' \\"
			}
			
			leanesttab using "`table_name_count'", ncols(`ncols')  midhead(`coltitlesB') append noest f(B. Origin college tercile)
					
			forvalues q=1/3 {
				writeln "`table_name_count'" "`q_2_`q'_count_list' \\"
			}
			
			textablefoot using "`table_name_count'", nodate
		}
		
		*Writing people count table
		{
			local name="`table_name_people'"
			textablehead using "`name'", f(A. Origin university tercile) ///
				title(`table_title_people') coltitles(`coltitlesA')  exhead(`exhead') col(r) ct(\ctshape)
			
			
			forvalues q=1/3 {
				writeln "`name'" "`q_1_`q'_people_list' \\"
			}
			
			leanesttab using "`name'", ncols(`ncols')  midhead(`coltitlesB') append noest f(B. Origin college tercile)
					
			forvalues q=1/3 {
				writeln "`name'" "`q_2_`q'_people_list' \\"
			}
			
			textablefoot using "`name'", nodate
		}
		return local table_obs `table_obs'
		restore
end

*This produces a visualization of the flows by tercile of prestige
cap program drop  create_sankey_chart
program define create_sankey_chart, rclass
	syntax, type(str) [novalues]
	
	qui {
	if "`type'"=="uni" {
			summarize o_institution_type if o_institution_type==1
			local graph_obs=`r(N)'
		}
		else if  "`type'"=="coll"{
			summarize o_institution_type if o_institution_type==2
			local graph_obs=`r(N)'
	}
	
	preserve 
		gcollapse (nunique) n_people=panelid (count) count=panelid (mean) uni_trans coll_trans, by(institution_type o_institution_type rank_quantile o_rank_quantile)
		

		
		local graph_options sort1(name , reverse) sort2(order , reverse) labangle(90)  labprop labscale(.13) palette(tableau)

		drop if o_institution_type==3|institution_type==3
		
		if "`novalues'"=="" {
			local stub "no_numbers"
			local plot_var count
		}
		else {
			local plot_var n_people
		}
		
		if "`type'"=="uni" {
			
			local graph_name "results/figures/figure_sankey_universities`stub'.png"
			sankey `plot_var' if o_institution_type==1, from(o_rank_quantile) to(uni_trans) `graph_options' `novalues'
		}
		else if  "`type'"=="coll"{
			local graph_name "results/figures/figure_sankey_colleges`stub'.png"
			sankey  `plot_var' if o_institution_type==2, from(o_rank_quantile) to(coll_trans) `graph_options' `novalues'
		}
		
		graph export "`graph_name'", replace
		
		return local graph_obs=`graph_obs'

	restore
	}
	
	di as result "Graph created in `graph_name'"
	di as result "Graph observations: `graph_obs'"
end

*This program just makes creating the summary table below easier
cap program drop get_move_type_summary
program define get_move_type_summary, rclass
	syntax varname [if],  [Format(str) type(str) stat(str) label(str) FIle(str) ADDspace]

	if "`addspace'"!="" {
		local addspace "\hspace{3mm}"
	}
	
	if "`stat'"==""	{
		local stat mean
	}
	
	if "`format'"==""{
		local format %9.2fc
	}
	
	if "`if'"=="" {
		local ifexp ="if "
	}
	else {
		local ifexp="`if'&"
	}
	
	if "`varlist'"!="transition_type" {
		qui summarize `varlist'   `ifexp'`type'==2
		local lat: di `format' `r(`stat')'
	
		qui summarize `varlist'   `ifexp'`type'==1
		local first: di `format' `r(`stat')'
		
		qui summarize `varlist'  `ifexp'`type'==0
		local second: di `format' `r(`stat')'
	}
	else {
		if "`stat'"=="share" {
			qui summarize `varlist'   `ifexp'transition_type==2
			local clat=`r(N)'
		
			qui summarize `varlist'   `ifexp'transition_type==1
			local cfirst=`r(N)'
			
			qui summarize `varlist'  `ifexp'transition_type==0
			local csecond=`r(N)'
			
			
			local all=`clat'+`cfirst'+`csecond'
			foreach stats in lat first second {
				local `stats'=`c`stats''/`all'
				local `stats': di `format' ``stats''
			}
		}
		else if "`stat'"=="people" {
			unique panelid   `ifexp'transition_type==2
			local lat: di %9.0fc `r(unique)'
		
			unique panelid   `ifexp'transition_type==1
			local first: di %9.0fc `r(unique)'
			
			unique panelid   `ifexp'transition_type==0
			local second: di %9.0fc `r(unique)'

		}
		else {
			qui summarize `varlist'   `ifexp'`varlist'==2
			local lat: di `format' `r(`stat')'
			qui summarize `varlist'   `ifexp'`varlist'==1
			local first: di `format' `r(`stat')'
			qui summarize `varlist'   `ifexp'`varlist'==0
			local second: di `format' `r(`stat')'
		}
	}
	
	
	local varlabel: variable label `varlist'
	
	if "`label'"=="" {
		if "`varlabel'"=="" {
			local varlabel `varlist'
		}
	}
	else {
		local varlabel "`label'"
	}
	local table_line="`addspace'`varlabel' & `first' & `second' &`lat' \\"
	
	if "`file'"!="" {
		writeln "`file'" "`table_line'"
	}
	
	return local summary_line "`table_line'"
end

*Creates table summarizing characteristics of moves, dividing between move to 
*lower or higher prestige
cap program drop create_transition_summary_table
program define create_transition_summary_table
	syntax, [Format(str)] 
	
	cap drop transition_type
	generate transition_type=o_l_inst_ranking_p<l_inst_ranking_p if o_institution_type==institution_type&o_l_inst_ranking_p!=l_inst_ranking_p 
	replace transition_type=2 if o_institution_type==institution_type&o_l_inst_ranking_p==l_inst_ranking_p 

	cap drop o_non_white 
	generate o_non_white=o_race_f!=0
	
	label var o_female_f "Female"
	label var o_non_white "Non white"

	cap drop o_ap_move
	generate o_ap_move=o_faculty_rank_f==3 if o_institution_type==institution_type

	label var o_tenured_f "Was already tenured"
	label var o_ap_move "Was assistant professor"
	
	table o_institution_type if inlist(o_institution_type,1,2), stat(mean transition_type)



	local table_name "results/tables/table_transition_summary.tex"
	local table_title "Characteristics of moves within the same institution type"
	local coltitles `""More prestige""Less \\ prestige""Same \\ prestige""'
	local exhead "& \multicolumn{3}{c}{\scshape Move to:}\\ \cline{2-4}"
	local ncols 3
	local table_notes "ADD NOTES"

	textablehead using `table_name', ncols(`ncols') ///
		title(`table_title') coltitles(`coltitles') exhead(`exhead') ct(\scshape)

	get_move_type_summary transition_type if o_institution_type==institution_type&inlist(o_institution_type,1,2), ///
		stat(N) format(%9.0fc) label(Total moves) file(`table_name')
	get_move_type_summary transition_type if o_institution_type==institution_type&inlist(o_institution_type,1,2), ///
		stat(people) format(%9.0fc) label(Number of people) file(`table_name')
	writeln "`table_name'" "\textit{Share of moves} \\"
	get_move_type_summary transition_type if o_institution_type==1,  stat(share) format(`format') label(Research universities) add file(`table_name')
	get_move_type_summary transition_type if o_institution_type==2,  stat(share) format(`format') label(Colleges) add file(`table_name')

	writeln "`table_name'" "\textit{Mean change in log salary} \\"
	get_move_type_summary d_l_r_salary if o_institution_type==1, type(transition_type) stat(mean) format(`format') label(Research universities) add file(`table_name')
	get_move_type_summary d_l_r_salary if o_institution_type==2, type(transition_type) stat(mean) format(`format') label(Colleges) add file(`table_name')
	
	writeln "`table_name'" "\textit{Faculty characteristics at the time of the move} \\"
	foreach variable in  o_female_f o_non_white o_tenured_f o_ap_move {
		get_move_type_summary `variable' , type(transition_type) stat(mean) format(`format') file(`table_name') add
	}
	textablefoot using `table_name', nodate notes(`table_notes')

di as result "Table created in `table_name'"
end


*This makes the creation of edge summary table easier
cap program drop get_edge_summary
program define get_edge_summary, rclass
	syntax varname [if] [aw],  [Format(str) type(str)  stat(str) label(str) FIle(str) ADDspace]

	if "`addspace'"!="" {
		local addspace "\hspace{3mm}"
	}
	
	if "`stat'"==""	{
		local stat mean
	}
	
	if "`format'"==""{
		local format %9.2fc
	}
	
	if "`if'"=="" {
		local ifexp ="if "
	}
	else {
		local ifexp="`if'&"
	}
	
	if "`weight'"!="" {
		
		local weightexp [`weight'`exp']
	}
	
	if "`varlist'"!="uni_directional_move" {
		qui summarize `varlist'   `ifexp'!missing(`type')
		local all: di `format' `r(`stat')'
		
		qui summarize `varlist'   `ifexp'`type'==1
		local first: di `format' `r(`stat')'
		
		qui summarize `varlist'  `ifexp'`type'==0 `weightexp'
		local second: di `format' `r(`stat')'
	}
	else {
		
		if "`stat'"=="mean" {
		
			qui summarize `varlist'   `ifexp'`type'==1  `weightexp'
			local first: di `format' `r(`stat')'

			qui summarize `varlist'   `ifexp'`type'==0  `weightexp'
			local second: di `format' `second'
		}
		else {
			
			qui summarize `varlist'   `ifexp'!missing(`varlist')
			local all:  di `format' `r(`stat')'
			qui summarize `varlist'   `ifexp'`varlist'==1
			local first: di `format' `r(`stat')'
			qui summarize `varlist'   `ifexp'`varlist'==0
			local second: di `format' `r(`stat')'
			
			
		}
	}
	
	
	local varlabel: variable label `varlist'
	
	if "`label'"=="" {
		if "`varlabel'"=="" {
			local varlabel `varlist'
		}
	}
	else {
		local varlabel "`label'"
	}
	local table_line="`addspace'`varlabel' & `all' & `first' & `second' \\"
	
	if "`file'"!="" {
		writeln "`file'" "`table_line'"
	}
	
	return local summary_line "`table_line'"
end






*Creates dataset for studying direction of moves between pairs of institutions
cap program drop prepare_edge_direction_dataset
program define prepare_edge_direction_dataset
	use "data/output/final_database_clean_with_dummies.dta", clear
	merge m:1  instcod  using "data/output/institution_level_database_clean", keep(3) nogen
	
	sort panelid period 
	
	cap drop d_l_r_salary
	by panelid: generate move_period=instcod!=instcod[_n-1] if _n>1	
	by panelid: generate o_instcod=instcod[_n-1] if move_period==1
	by panelid: generate o_institution_type=institution_type[_n-1] if move_period==1
	by panelid: generate o_l_inst_ranking_p=l_inst_ranking_p[_n-1] if move_period==1
	by panelid: generate o_inst_ranking_p=inst_ranking_p[_n-1] if move_period==1
		
	by panelid: generate d_l_r_salary=l_r_salary-l_r_salary[_n-1] if move_period==1

	
	keep panelid instcod move_period  acad_spell_id period o_instcod d_l_r_salary  l_r_salary *inst_ranking_p  *institution_type

	
	keep if move_period==1 
	
	keep panelid instcod o_instcod d_l_r_salary *inst_ranking_p *institution_type
	
	generate d_l_inst_ranking_p=l_inst_ranking_p-o_l_inst_ranking_p
	
	
	local lateral_thresh=.10

	
	generate pair_instcod1=""
	generate pair_instcod2=""
	generate pair_institution_type1=.
	generate pair_institution_type2=.
	generate pair_inst_ranking_p1=.
	generate pair_inst_ranking_p2=.
	generate move_direction=d_l_inst_ranking_p>=0 if !missing(d_l_inst_ranking_p)

	foreach variable in instcod institution_type inst_ranking_p {
		replace pair_`variable'1=`variable' if l_inst_ranking_p<o_l_inst_ranking_p
		replace pair_`variable'2=o_`variable' if l_inst_ranking_p<o_l_inst_ranking_p
		
		replace pair_`variable'1=o_`variable' if l_inst_ranking_p>=o_l_inst_ranking_p
		replace pair_`variable'2=`variable' if l_inst_ranking_p>=o_l_inst_ranking_p
	}
	
	label define move_direction 1 "Towards more prestige" 0 "Towards less prestige"
	label values move_direction move_direction
	
	gcollapse (count) n_moves=panelid (mean) d_l_r_salary d_l_inst_ranking_p, by(pair_* move_direction)
end 


cap program drop create_edge_summary 
program define create_edge_summary

	local space \hspace{3mm}
	local table_name "results/tables/table_edge_summary.tex"
	local table_title "Summary statistics of institution network"
	local coltitles `""All""Towards higher\\ ranking""Towards lower \\ ranking ""'
	local exhead "& &\multicolumn{2}{c}{Edge direction}\\ \cline{3-4}"
	local ncols 3

	textablehead using `table_name', ncols(`ncols') ///
		title(`table_title') coltitles(`coltitles') exhead(`exhead') col(r)
	

	get_edge_summary d_l_r_salary, type(move_direction) stat(N) f(%9.0fc) file(`table_name') label(Number of edges)
	get_edge_summary n_moves, type(move_direction) stat(sum) f(%9.0fc) file(`table_name') label(Total number of movers)
	get_edge_summary n_moves, type(move_direction) stat(mean) f(%9.2fc) file(`table_name') label(Mean number of movers per edge)
	get_edge_summary d_l_r_salary [aw=n_moves], type(move_direction) stat(mean) f(%9.2fc) file(`table_name') label(Mean change in log salary)

	writeln "`table_name'" "\textit{Characteristics of institutions in the edge}\\"

	preserve
	{
		generate edgeid=_n
		reshape long pair_instcod pair_institution_type pair_l_inst_ranking_p, i(edgeid) j(edge_comp)
	
		*Number of unique institutions
		{	
			unique pair_instcod 
			local all: di %9.0fc `r(unique)'
			
			unique pair_instcod if move_direction==1
			local first: di %9.0fc `r(unique)'
			
			unique pair_instcod if move_direction==0
			local second: di %9.0fc `r(unique)'
			
			local table_line="`space'Number of distinct institutions& `all' & `first' & `second' \\"
			
			writeln "`table_name'" "`table_line'"
		}

		local common_options file(`table_name') type(move_direction) 
	
		
		*Share universities
		generate research_university=pair_institution_type==1
		generate college=pair_institution_type==2
		
		get_edge_summary research_university, `common_options' ///
		 label(`space'Share of research universities) 
		get_edge_summary college [aw=n_moves], `common_options' ///
		 label(`space'Share of colleges) 
		
	}
	
	restore
	
	generate cross_move=pair_institution_type1!=pair_institution_type2
	
	get_edge_summary cross_move,  `common_options' ///
		 label(`space'Share cross-type moves) 

	egen edge_mean_rank=rowmean(pair_inst_ranking_p1 pair_inst_ranking_p2)
		 
	get_edge_summary edge_mean_rank [aw=n_moves],  `common_options' ///
		 label(`space'Mean edge rank) 
	get_edge_summary pair_inst_ranking_p1 [aw=n_moves],  `common_options' ///
		 label(`space'Mean of lowest edge rank) 
	get_edge_summary pair_inst_ranking_p2 [aw=n_moves], `common_options' ///
		 label(`space'Mean of highest edge rank) 
	get_edge_summary d_l_inst_ranking_p [aw=n_moves], `common_options' ///
		 label(`space'Mean change of log of rank) 

	textablefoot using `table_name', nodate

	
end




*This makes the creation of edge summary table easier
cap program drop get_inflow_summary
program define get_inflow_summary, rclass
	syntax varname [if] [aw],  [Format(str) type(str)  stat(str) label(str) FIle(str) ADDspace]

	if "`addspace'"!="" {
		local addspace "\hspace{3mm}"
	}
	
	if "`stat'"==""	{
		local stat mean
	}
	
	if "`format'"==""{
		local format %9.2fc
	}
	
	if "`if'"=="" {
		local ifexp ="if "
	}
	else {
		local ifexp="`if'&"
	}
	
	if "`weight'"!="" {
		
		local weightexp [`weight'`exp']
	}
	
	if "`varlist'"!="uni_directional_move" {
		qui summarize `varlist'   `ifexp'!missing(`type')
		local all: di `format' `r(`stat')'
		
		qui summarize `varlist'   `ifexp'`type'==1  `weightexp'
		local first: di `format' `r(`stat')'
		
		qui summarize `varlist'  `ifexp'`type'==2 `weightexp'
		local second: di `format' `r(`stat')'
		
		qui summarize `varlist'  `ifexp'`type'==3 `weightexp'
		local third: di `format' `r(`stat')'
	}
	else {
		
		if "`stat'"=="mean" {
		
			qui summarize `varlist'   `ifexp'`type'==1  `weightexp'
			local first: di `format' `r(`stat')'

			qui summarize `varlist'   `ifexp'`type'==2  `weightexp'
			local second: di `format' `second'
			
			qui summarize `varlist'   `ifexp'`type'==3  `weightexp'
			local third: di `format' `second'
		}
		else {
			
			qui summarize `varlist'   `ifexp'!missing(`varlist')
			local all:  di `format' `r(`stat')'
			qui summarize `varlist'   `ifexp'`varlist'==1
			local first: di `format' `r(`stat')'
			qui summarize `varlist'   `ifexp'`varlist'==2
			local second: di `format' `r(`stat')'
			qui summarize `varlist'   `ifexp'`varlist'==3
			local second: di `format' `r(`stat')'
			
		}
	}
	
	
	local varlabel: variable label `varlist'
	
	if "`label'"=="" {
		if "`varlabel'"=="" {
			local varlabel `varlist'
		}
	}
	else {
		local varlabel "`label'"
	}
	local table_line="`addspace'`varlabel' & `all' & `first' & `second' & `third' \\"
	
	if "`file'"!="" {
		writeln "`file'" "`table_line'"
	}
	
	return local summary_line "`table_line'"
end



cap program drop create_inflows_table
program define create_inflows_table, rclass
	preserve 
	qui {
		local table_obs=_N
		
		local space \hspace{3mm}
		
		*First restructure the dataset to compute inflows and outflows to schools
		rename instcod instcod2
		rename o_instcod instcod1
		
		rename institution_type  institution_type2
		rename l_inst_ranking_p l_inst_ranking_p2
		rename inst_ranking_p inst_ranking_p2
		rename o_* *1
		generate transition_id=_n 
		
		keep transition_id instcod* institution_type* l_inst_ranking_p* inst_ranking_p* panelid
		
		reshape long instcod institution_type inst_ranking_p l_inst_ranking_p, i(transition_id) j(ori_dest)
		
		label define ori_dest 1 "Origin" 2 "Destination"
		label values ori_dest ori_dest
		
		generate inflow=ori_dest==2
		generate outflow=ori_dest==1
		
		
		gcollapse (nunique) n_people=transition_id (sum) inflow outflow (mean) l_inst_ranking_p inst_ranking_p, by(instcod institution_type)
		
		
		generate both=inflow>0&outflow>0
		generate inflow_only=outflow==0
		generate outflow_only=inflow==0
		
		generate research_university=institution_type==1
		generate college=institution_type==2
		
		generate school_type=3 if both==1
		replace school_type=1 if inflow_only==1
		replace school_type=2 if outflow_only==1
		
		label define school_type 3 "Both" 1 "Inflows only" 2 "Outflows only"
		label values school_type school_type
		
		return local table_obs=`table_obs'
		
		generate ranking=exp(l_inst_ranking_p)
		
		local space \hspace{3mm}
		local table_name "results/tables/table_inflow_outflow_summary.tex"
		local table_title "University of characteristics by type of transition"
		local coltitles `""All""Inflows \\ only""Outflows \\ only""Both""'
		local table_notes "ADD NOTES"
		local exhead "& &\multicolumn{3}{c}{\scshape School experienced}\\ \cline{3-5}"
		local ncols 4
		textablehead using `table_name', ncols(`ncols') ///
			title(`table_title') coltitles(`coltitles') exhead(`exhead') col(r) ///
			f(School level summary statistics) ct(\scshape)
	
		local common_options file(`table_name') type(school_type) 

		get_inflow_summary n_people,  stat(sum) f(%9.0fc) `common_options' ///
		 label(Number of people) 
		
		get_inflow_summary inflow,  stat(N) f(%9.0fc) `common_options' ///
		 label(Number of schools) 
		 
		get_inflow_summary inflow,  stat(mean) f(%9.2fc) `common_options' ///
		 label(Average inflows) 
		 
		get_inflow_summary outflow,  stat(mean) f(%9.2fc) `common_options' ///
		 label(Average outflows) 
		 
		get_inflow_summary research_university,  stat(mean) f(%9.2fc) `common_options' ///
		 label(Share of research universities) 
		 
		get_inflow_summary college,  stat(mean) f(%9.2fc) `common_options' ///
		 label(Share of colleges) 
		
		textablefoot using `table_name', nodate notes(`table_notes')
		
	}
	
	return local table_obs=`table_obs'
	di as result "Observations used in the table: `table_obs'"

	restore 
end

*Create the transition dataset
prepare_transition_dataset

create_transition_summary_table

create_inflows_table



/*
*This table summarizes the characteristics of moves within the sam category
create_transition_summary_table

*Create transition tercile tables
create_transition_tables


*CREATE FLOW GRAPHS
*====================================================
*University transitions with numbers
create_sankey_chart, type(uni) 


*University transitions without numbers
create_sankey_chart, type(uni) novalues 

*College transitions with numbers
create_sankey_chart, type(coll) 
*College transitions without numbers
create_sankey_chart, type(coll) novalues 

prepare_edge_direction_dataset

create_edge_summary


