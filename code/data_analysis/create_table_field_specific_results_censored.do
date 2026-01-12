*===============================================================================
*Project AKM-SDR
*=============================================================================
/*
	Author: 	Garro-Marín, Kahn, Lang
	Purpose: 	creates tables with field specific results
*/
*===============================================================================




*This program creates the files to run the field-specific results
* - It estimates the premiums
* - And then creates the file for the second stage regressions
cap program drop prepare_field_file
program define prepare_field_file, rclass
	syntax, ranking(str) [NOsen]

	if "`nosen'"!="" {
		local stub _nosen
	}
	else {
		local keeptime time_current_job_f
	}
	
	local d_type clean
	*===========================================================================
	*UNCOLLAPSED ESTIMATION
	*===========================================================================
	use "data/output/final_database_`d_type'_with_dummies.dta", clear
	
	merge m:1  instcod  using "data/output/institution_level_database_`d_type'", keep(3)
	
	merge m:1  panelid  using "data/additional_processing/indiv_fe_estimates_`d_type'.dta", nogen keep(3)
	
	*Fixing minor fields 
	gen minorfield=ndgmeng
	replace minorfield= dgrmeng if minorfield==. & dgrmeng !=.
	replace minorfield = 61 if minorfield>60 & minorfield!=.

	
	label define minorfield 11 " Computer and information sciences" ///
	12 " Mathematics and statistics" ///
	21 " Agricultural and food sciences" ///
	22 " Biological sciences" ///
	23 " Environmental life sciences" ///
	31 " Chemistry, except biochemistry" ///
	32 " Earth, atmospheric and ocean sciences" ///
	33 " Physics and astronomy" ///
	34 " Other physical sciences" ///
	41 " Economics" ///
	42 " Political and related sciences" ///
	43 " Psychology" ///
	44 " Sociology and anthropology" ///
	45 " Other social sciences" ///
	51 " Aerospace, aeronautical and astronautical engineering" ///
	52 " Chemical engineering" ///
	53 " Civil and architectural engineering" ///
	54 " Electrical and computer engineering" ///
	55 " Industrial engineering" ///
	56 " Mechanical engineering" ///
	57 " Other engineering" ///
	61 " Health" ///
	71 " Management and administration fields" ///
	72 " Education, except science and math teacher education" ///
	73 " Social service and related fields" ///
	75 " Art and Humanities Fields", modify
	label values minorfield minorfield


	
	misstable summ minorfield
	table minorfield observation_type	

	if "`ranking'"=="bio" {
		*Biological sciences
		keep if minorfield==22
	}
	else {
		*Engineering fields
		keep if inlist(minorfield,51,52,53,54,55,56,57)
	}
		
	do "code/build_database/update_observation_type.do" 1

	summ panelid if observation_type
	
	do "code/build_database/update_acad_spell_id.do"
	
	*Next I need to compute the connected set
	do "code/build_database/output_connected_set.do" `ranking'_field_filter
	
	summ panelid
	unique panelid
	unique panelid if observation_type==1
	
	cap drop u_instcod_1-network
	
	xi i.instcod, prefix(u_) noomit
	
	local cw_file  "data/temporary/institution_dummy_crosswalk_`ranking'_field_size_`d_type'"
	preserve
		*Here I create create a dummy-label index
		collapse (mean) u_*, by(instcod inst_name)
		unique instcod

		*Note: stata is assigning dummies using the order of instcod
		generate inst_number=_n
		order inst_number, after(inst_name)
		
		save `cw_file', replace
	restore

	*** NOTE TO DUPLICATORS: REPLACE ???? WITH THE SAME UNIVERSITY NUMBER THAT ??? REFERS TO IN OUR OTHER PROGRAMS, SO THE BASE CATEGORY=0 IS CONSISTENT 
	if "`ranking'"=="bio" {
		*Using ???? as baseline
		drop u_instcod_94
	}
	else {
		drop u_instcod_66
	}
	
	
	egen check=rowtotal(u_instcod*)
	
	*** NOTE TO DUPLICATORS: REPLACE ???? WITH THE SAME UNIVERSITY NUMBER THAT ??? REFERS TO IN OUR OTHER PROGRAMS, SO THE BASE CATEGORY=0 IS CONSISTENT 
	assert check==0 if instcod=="????"
	
	cap drop check
	
	*I compute the institution estimates with the restricted of institutions.
	*===========================================================================

	*Creating estimation files
	
	local controls 			u_instcod*  `keeptime'	years_since_phd ///
							c.years_since_phd#c.years_since_phd  			///
							i.tenured_f ib3.faculty_rank_f 					///
							ib0.married##ib0.female							///
							ib0.has_ch_6##ib0.female						/// 
							ib0.has_ch_611##ib0.female						///
							ib0.has_ch_1218##ib0.female						///
							ib0.has_ch_19##ib0.female
							 

	local model all_clust



	*In this bit I am getting estimates of the fe without se.
	eststo field: cap reghdfe l_r_salary  `controls', ///
			absorb(indiv_fe=panelid refyr, savefe) nocons ///
			keepsingleton vce(cl instcod)
	
	cap drop in_sample
	generate in_sample=e(sample)
	
	
	estfe . *
	

	summ in_sample if  in_sample==1
	return scalar `ranking'_obs=`r(N)'
	
	unique panelid if in_sample
	return scalar `ranking'_people=`r(unique)'
	unique panelid if in_sample&observation_type==1
	return scalar `ranking'_movers=`r(unique)'
	unique instcod if in_sample
	return scalar `ranking'_all_uni=`r(unique)'

	

	preserve
		*Create file with person counts
		gcollapse (count) n_obs=panelid (nunique) n_people=panelid if in_sample==1, by(instcod) 
		tempfile n_people
		save `n_people'
	restore 

	
	estimates save "results/regressions/field_`d_type'`stub'", replace
	
	local estimation_list field

	foreach estimation in `estimation_list' {
		estimates use "results/regressions/`estimation'_`d_type'`stub'"
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
*** NOTE TO DUPLICATORS: REPLACE ???? WITH THE SAME UNIVERSITY NUMBER THAT ??? REFERS TO IN OUR OTHER PROGRAMS

		*I do this because ???? is the 271th institution
		keep 		inst_number `estimation' se_`estimation' p_`estimation'
		save 		``estimation'_fe', replace
	}

	clear

	use  `field_fe'

	merge 1:1 inst_number using "`cw_file'", ///
		nogen keep(1 3)
		
	drop u_instcod*
	
	
	merge 1:1 instcod using "data/output/institution_level_database_`d_type'"	
		*** NOTE TO DUPLICATORS: REPLACE ???? WITH THE SAME UNIVERSITY NUMBER THAT ??? REFERS TO IN OUR OTHER PROGRAMS, SO THE BASE CATEGORY=0 IS CONSISTENT 
	keep if _merge==3 | instcod=="????"
	cap drop _merge
	
	merge 1:1 instcod using `n_people', keep(3) nogen 
	
	*Getting counts used in the regressions
		
	unique instcod if institution_type==1
	return scalar `ranking'_res_uni=`r(unique)'
	
		
	unique instcod if institution_type==2
	return scalar `ranking'_colleges=`r(unique)'
	
	unique instcod if institution_type==3
	return scalar `ranking'_unranked=`r(unique)'

		*** NOTE TO DUPLICATORS: REPLACE ???? WITH THE SAME UNIVERSITY NUMBER THAT ??? REFERS TO IN OUR OTHER PROGRAMS, SO THE BASE CATEGORY=0 IS CONSISTENT 
	replace field=0 if instcod=="????"
	replace se_field=0 if instcod=="????"
	
	merge 1:1 instcod using "data/temporary/USNWR_`ranking'_rankings_clean"
	
	cap drop inst_fe se_inst_fe
	
	rename field inst_fe
	rename se_field se_inst_fe

	
	local texspace \hspace{3mm}
	*Relabelling variables to make the table prettier
	label define 	new_type 		1 "`texspace'Research university" 2 "`texspace'College", modify
	label define	control			2 "`texspace'Private institution", modify
	label define	new_locale		1 "`texspace'Large city" 2 "`texspace'Medium city" 3 "`texspace'Small city", modify
	label var 		ug_only 		"`texspace'Offers only undergraduate degree"
		
	label var 	l_inst_ranking_p 	"log of university ranking"
	label var 	inst_ranking_p 		"university ranking"
	label var 	l_enrollment_total_m "`texspace'Log of total enrollment" 
	label var 	l_r_endowment_per_student "`texspace'Log of endowment per student"
	label var 	l_faculty_per_student "`texspace'Log of faculty per student" 
	label define ug_only 1 "`texspace'Undergrad only", modify

end
	

*This program creates regression tables that separate by field.
cap program drop create_field_tables
program define create_field_tables 
	syntax, ranking(str) [NOsen]
	
	if "`nosen'"!="" {
		local stub _nosen
	}
	
	*Regression with no additional controls
	local base_spec   ib3.institution_type#c.l_inst_ranking_p ib3.institution_type

	*Dummies of offering undergrad degree only, private/public university
	qui wregress inst_fe `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control, ///
		se(se_inst_fe) stub(m6)
		
	estimates restore m6ss
		
	cap drop in_sample
	generate in_sample=e(sample)

	qui wregress inst_fe `base_spec' if in_sample, ///
		se(se_inst_fe) stub(m1)

	qui wregress inst_fe `base_spec' if in_sample, ///
		se(se_inst_fe) stub(m1)
		
		qui wregress inst_fe `base_spec'  ///
		ib3.new_locale if in_sample, ///
		se(se_inst_fe) stub(m2)

		
	*Endowment per student
	qui wregress inst_fe `base_spec' ///
		ib3.new_locale   l_enrollment_total_m ///
		 i.ug_only i.control  if in_sample, ///
		se(se_inst_fe) stub(m3)	
		
	forvalues j=1/3 {
		estimates restore m`j'ss
		test  1.institution_type 1.institution_type#l_inst_ranking_p 
		
		estadd scalar	uni_F=r(F)
		estadd scalar 	uni_p=r(p)
	
	
	
		estimates restore m`j'ss
		test  2.institution_type 2.institution_type#l_inst_ranking_p 
		
		estadd scalar	coll_F=r(F)
		estadd scalar 	coll_p=r(p)
		
		eststo m`j'ss
		
		estimates restore m`j'ss
		test 1.institution_type#l_inst_ranking_p 2.institution_type#l_inst_ranking_p

		estadd scalar 	rank_F=r(F)
		estadd scalar 	rank_p=r(p)
		
		estimates restore m`j'ss
		test  1.institution_type 1.institution_type#l_inst_ranking_p  2.institution_type 2.institution_type#l_inst_ranking_p 

		estadd scalar 	all_F=r(F)
		estadd scalar 	all_p=r(p)
	}
	
	*Regression with no additional controls
	local base_spec l_`ranking'_raking_p
	
	qui wregress inst_fe `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control, ///
		se(se_inst_fe) stub(f6)
	
	cap drop in_sample
	generate in_sample=e(sample)

	qui wregress inst_fe `base_spec' if in_sample, ///
		se(se_inst_fe) stub(f1)
		
		qui wregress inst_fe `base_spec'  ///
		ib3.new_locale if in_sample, ///
		se(se_inst_fe) stub(f2)

	
	*Endowment per student
	qui wregress inst_fe `base_spec' ///
		ib3.new_locale   l_enrollment_total_m ///
		 i.ug_only i.control  if in_sample, ///
		se(se_inst_fe) stub(f3)	
		
	label var l_`ranking'_raking_p "log of USNWR field ranking"
	
	
	
	if "`ranking'"=="bio" {
		local table_title	"Institution pay premiums and rankings for faculty with biological sciences Ph.Ds"
		local table_notes  "The table shows results from a two-step estimation. In the first step, we limit the sample to people with a Ph.D. in Biological Sciences and estimate an AKM model controlling for time-varying individual controls. In a second step, we regress the institution FE on institution characteristics using FGLS. Researh universities are mainly R1 but include some R2 schools. Colleges include all remaining post-secondary institutions granting four-year degrees. Large, medium, and small cities have populations above 250k, between 100k and 250k, and under 100k respectively. Institution rank ranges from 1 (best) to 100. Standard errors in parenthesis."
	}
	else {
		local table_title	"Institution pay premiums and rankings for faculty with engineering Ph.Ds"
		local table_notes   "The table shows results from a two-step estimation. In the first step, we limit the sample to people with a Ph.D. in Engineering and estimate an AKM model controlling for time-varying individual controls. In a second step, we regress the institution FE on institution characteristics using FGLS. Researh universities are mainly R1 but include some R2 schools. Colleges include all remaining post-secondary institutions granting four-year degrees. Large, medium, and small cities have populations above 250k, between 100k and 250k, and under 100k respectively. Institution rank ranges from 1 (best) to 100. Standard errors in parenthesis."
	}
	
	{
		local name  table_field_specific_results_`ranking'`stub'
		local root "results/tables/"
		local csv_table_name="`root'"+"`name'"+".csv"
		local tex_table_name="`root'"+"`name'"+".tex"
	
		local coltitles		
		local n_cols			9

		local keepvar *locale*  *control *ug_*   *enrollment*
		local models m1ss m2ss m3ss f1ss f2ss f3ss 
		
		local subtitles 1.institution_type "\textit{Institution type (omitted=unranked)}" ///
			1.institution_type#c.l_inst_ranking_p "\textit{Institution type $ \times $ log of rank (low ranks best)}" ///
			1.new_locale "\textit{Institution characteristics}", nolabel
		local relabel coeflabel(  1.institution_type#c.l_inst_ranking_p `"${texspace}Research university"' ///
		  2.institution_type#c.l_inst_ranking_p `"${texspace}College"' ///
		  1.o_institution_type#c.o_l_inst_ranking_p `"${texspace}Research university"' ///
		  2.o_institution_type#c.o_l_inst_ranking_p `"${texspace}College"' )
			
		local stats stats(N r2 f_title rank_F rank_p  t_title all_F all_p , ///
			label("\midrule Observations" "$ R^2$"  "\midrule \textit{Joint significance of 2 rank variables}" "${texspace} F statistic" "${texspace} p-value"  "\textit{Joint significance of university type and rank variables}" "${texspace} F statistic" "${texspace} p-value"  ) fmt(%9.0fc  %9.3fc  %9.3fc %9.3fc  %9.3fc  %9.3fc %9.3fc  %9.3fc %9.3fc  %9.3fc  %9.3fc  )) `relabel'
		 

		*Writing csv table 
		esttab `models' using `csv_table_name', keep( *institution_type#c.l_* l_`ranking'_raking_p *institution_type `keepvar') ///
		order( *institution_type#c.l_*  *institution_type l_`ranking'_raking_p `keepvar') ///
		nomtitles label noomit nobase nostar ///
			`stats' ///
			refcat(`subtitles') ///
			title(`table_title') note(`table_notes_`database'') csv replace se(4) b(4) par
		
		
		*Writing tex table 
		textablehead using `tex_table_name', ncols(6) title(`table_title') land adjust(1.3)
		
		esttab `models' using `tex_table_name', keep( *institution_type#c.l_* l_`ranking'_raking_p *institution_type `keepvar') ///
		order( *institution_type#c.l_*  *institution_type l_`ranking'_raking_p `keepvar') ///
		nomtitles  f collabels(none) label noomit nobase nostar ///
		`stats' ///
			refcat(`subtitles') ///
			 tex append se(4) b(4) plain par
		
		
		textablefoot  using `tex_table_name', notes(`table_notes') nodate land
			
		di as result "Tables written to `tex_table_name' and `csv_table_name'"
	}	

end


*This program saves the regressions for the condensed table
cap program drop save_field_estimates
program define save_field_estimates
	syntax, ranking(str) [NOsen]

	if "`nosen'"!="" {
		local stub _nosen
	}
	
	*Regression with no additional controls
	local base_spec   ib3.institution_type#c.l_inst_ranking_p ib3.institution_type

	*Dummies of offering undergrad degree only, private/public university
	qui wregress inst_fe `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control, ///
		se(se_inst_fe) stub(m6)
		
	estimates restore m6ss
		
	cap drop in_sample
	generate in_sample=e(sample)


	qui wregress inst_fe `base_spec' if in_sample, ///
		se(se_inst_fe) stub(`ranking'1)
		
		qui wregress inst_fe `base_spec'  ///
		ib3.new_locale if in_sample, ///
		se(se_inst_fe) stub(`ranking'2)

		
	*Endowment per student
	qui wregress inst_fe `base_spec' ///
		ib3.new_locale   l_enrollment_total_m ///
		 i.ug_only i.control  if in_sample, ///
		se(se_inst_fe) stub(`ranking'3)	
		
	forvalues j=1/3 {
		estimates restore `ranking'`j'ss
		test  1.institution_type 1.institution_type#l_inst_ranking_p 
		
		estadd scalar	uni_F=r(F)
		estadd scalar 	uni_p=r(p)
	
	
	
		estimates restore `ranking'`j'ss
		test  2.institution_type 2.institution_type#l_inst_ranking_p 
		
		estadd scalar	coll_F=r(F)
		estadd scalar 	coll_p=r(p)
		
		eststo m`j'ss
		
		estimates restore `ranking'`j'ss
		test 1.institution_type#l_inst_ranking_p 2.institution_type#l_inst_ranking_p

		estadd scalar 	rank_F=r(F)
		estadd scalar 	rank_p=r(p)
		
		estimates restore `ranking'`j'ss
		test  1.institution_type 1.institution_type#l_inst_ranking_p  2.institution_type 2.institution_type#l_inst_ranking_p 

		estadd scalar 	all_F=r(F)
		estadd scalar 	all_p=r(p)
	}
	
	*Regression with no additional controls
	local base_spec l_`ranking'_raking_p
	
	qui wregress inst_fe `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control, ///
		se(se_inst_fe) stub(`ranking'f6)
	
	cap drop in_sample
	generate in_sample=e(sample)

	qui wregress inst_fe `base_spec' if in_sample, ///
		se(se_inst_fe) stub(`ranking'f1)
		
		qui wregress inst_fe `base_spec'  ///
		ib3.new_locale if in_sample, ///
		se(se_inst_fe) stub(`ranking'f2)

	
	*Endowment per student
	qui wregress inst_fe `base_spec' ///
		ib3.new_locale   l_enrollment_total_m ///
		 i.ug_only i.control  if in_sample, ///
		se(se_inst_fe) stub(`ranking'f3)	
		
	label var l_`ranking'_raking_p "log of USNWR field ranking"
	
end


*This program creates a condensed table with the field results.
cap program drop create_condensed_table
program define create_condensed_table
	syntax,  [NOsen]

	
	if "`nosen'"!="" {
		local stub _nosen
	}
	
	eststo clear
	
	prepare_field_file, ranking(bio) `nosen'
	
	save_field_estimates, ranking(bio) `nosen'
	
	prepare_field_file, ranking(eng) `nosen'
	
	save_field_estimates, ranking(eng) `nosen'
	
	{
		local name  table_field_specific_results_condensed`stub'
		local root "results/tables/"
		local csv_table_name="`root'"+"`name'"+".csv"
		local table_title "Institution pay premiums and rankings by Ph.D. field"
		local tex_table_name="`root'"+"`name'"+".tex"
		local exhead  "&\multicolumn{2}{c}{\scshape Biological Sciences}&\multicolumn{2}{c}{\scshape Engineering}\\ \cmidrule(lr){2-3}\cmidrule(lr){4-5}"
		local coltitles		
		local n_cols			4

		local keepvar *locale*  *control *ug_*   *enrollment*
		local models bio3ss biof3ss eng3ss engf3ss 
		
		local subtitles 1.institution_type "\textit{Institution type (omitted=unranked)}" ///
			1.institution_type#c.l_inst_ranking_p "\textit{Institution type $ \times $ log of rank (low ranks best)}" ///
			1.new_locale "\textit{Institution characteristics}", nolabel
		local relabel coeflabel(  1.institution_type#c.l_inst_ranking_p `"${texspace}Research university"' ///
		  2.institution_type#c.l_inst_ranking_p `"${texspace}College"' ///
		  1.o_institution_type#c.o_l_inst_ranking_p `"${texspace}Research university"' ///
		  2.o_institution_type#c.o_l_inst_ranking_p `"${texspace}College"' l_raking_p "log of UNSWR field ranking")
			
		local stats stats(N r2 f_title rank_F rank_p  t_title all_F all_p , ///
			label("\midrule Observations" "$ R^2$"  "\midrule \textit{Joint significance of 2 rank variables}" "${texspace} F statistic" "${texspace} p-value"  "\textit{Joint significance of university type and rank variables}" "${texspace} F statistic" "${texspace} p-value"  ) fmt(%9.0fc  %9.3fc  %9.3fc %9.3fc  %9.3fc  %9.3fc %9.3fc  %9.3fc %9.3fc  %9.3fc  %9.3fc  )) `relabel'
		 

		
		*Writing tex table 
		textablehead using `tex_table_name', ncols(4) title(`table_title') adjust(1) ///
			exhead(`exhead')
		
		esttab `models' using `tex_table_name', rename(l_eng_raking_p l_raking_p l_bio_raking_p l_raking_p) keep( *institution_type#c.l_* l_raking_p *institution_type `keepvar') ///
		order( *institution_type#c.l_*  *institution_type l_raking_p `keepvar') ///
		nomtitles  f collabels(none) label noomit nobase nostar ///
		`stats' ///
			refcat(`subtitles') ///
			 tex append se(4) b(4) plain par
		
		
		textablefoot  using `tex_table_name', notes(`table_notes') nodate
	}
end



cap program drop create_graphs 
program define create_graphs
	syntax varlist, type(str)
	
	grscheme, ncolor(7) palette(tableau)
	
	if "`type'"=="all:bio" {
		local file_name "results/figures/binscatter_uw_field_all_bio"
		local type_options if ///
		inlist(institution_type,1,2), by(institution_type) ///
		xtitle("THE institution ranking (1=best schools)") ///
		ytitle("Institution FE") ///
		legend(order(1 "Research university" 2 "Colleges") ring(0) pos(2) cols(1) region(lstyle(none)))
	}
	else  if "`type'"=="all:eng" {
		local file_name "results/figures/binscatter_uw_field_all_eng"
		local type_options if ///
		inlist(institution_type,1,2), by(institution_type) ///
		xtitle("THE institution ranking (1=best schools)") ///
		ytitle("Institution FE") ///
		legend(order(1 "Research university" 2 "Colleges") ring(0) pos(2) cols(1) region(lstyle(none)))
	}
	else if "`type'"=="bio" {
		local file_name "results/figures/binscatter_uw_field_bio"
		local type_options , xtitle("USNWR biological science schools ranking (1=best schools)") ///
		legend(off)
	}
	else if "`type'"=="eng" {
		local file_name "results/figures/binscatter_uw_field_eng"
		local type_options , xtitle("USNWR engineering schools ranking (1=best schools)") ///
		legend(off)
	}
	
	cap drop gquantile
	
	local common_opts colors(black gold) msymbol(D O)  /// 
		lcolors(black gold) line(qfit) ytitle("Institution FE") ///
		yscale(range(-.2 .3)) ylab(-.2(.1).3) ///
		genxq(gquantile) nq(11)
	binscatter	`varlist'  `type_options' ///
		`common_opts'
	
	local graph_name="`file_name'"+".png"
	local count_name="`file_name'"+"_count.csv"
	graph export `graph_name', replace
	
	preserve
		if inlist("`type'", "all:bio", "all:eng") {
			gcollapse (sum) n_people n_obs if institution_type!=3, by(institution_type gquantile)
			drop if n_people==0
			label define new_type 1 "Research universities" 2 "Colleges", modify
			*replace n_people=7 if n_people<5
		}
		else {
			gcollapse (sum) n_people n_obs, by(gquantile)
			drop if n_people==0
			*replace n_people=7 if n_people<5
		}
		export delimited using  "`count_name'", replace
	restore 
	
	cap drop gquantile
	di as result "Graph saved to `graph_name'"
	di as result "People count saved to `count_name'"
end


cap program drop create_table_f_counts
program define create_table_f_counts
	foreach field in bio eng {
		prepare_field_file, ranking(`field')

		foreach stat in obs people movers all_uni res_uni colleges unranked {
			local `field'_`stat'=`r(`field'_`stat')'	
		}
	}

	*Outputting tex table of university level stats
	local table_name	"results/tables/table_field_summstats.tex"
	local table_key 	"tab:table_field_summ"
	local table_title 	"Summary statistics for biological sciences and engineering Ph.Ds"
	local coltitles		`""Biological \\ sciences""Engineering""'
	local n_cols		2	
	local table_notes   "ADD NOTES" 	

	textablehead using `table_name', ncols(`n_cols') title(`table_title') ///
		coltitles(`coltitles') ct(\scshape)
	
	writeln  `table_name' "\textit{Observations}& `bio_obs' & `eng_obs' \\"
	writeln  `table_name' "\hspace{3mm}Number of people& `bio_people' & `eng_people' \\"
	writeln  `table_name' "\hspace{3mm}Number of movers& `bio_movers' & `eng_movers' \\"
	writeln  `table_name' "\textit{Number of universities}& `bio_all_uni' & `eng_all_uni' \\"
	writeln  `table_name' "\hspace{3mm}Universities& `bio_res_uni' & `eng_res_uni' \\"
	writeln  `table_name' "\hspace{3mm}Colleges& `bio_colleges' & `eng_colleges' \\"
	writeln  `table_name' "\hspace{3mm}Unranked& `bio_unranked' & `eng_unranked' \\"

	textablefoot using `table_name', notes(`table_notes')  ///
		nodate

end

create_condensed_table

create_condensed_table, nosen


*Preparing the file for biological sciences, including seniority
prepare_field_file, ranking(bio)

gegen dm_inst_fe=demean(inst_fe) if !missing(l_inst_ranking_p), by(institution_type)

create_graphs dm_inst_fe inst_ranking_p, type(all:bio)

create_graphs dm_inst_fe inst_ranking_p, type(bio)

create_field_tables, ranking(bio)


*Preparing the file for biological sciences, with no seniority
prepare_field_file, ranking(bio) nosen

create_field_tables, ranking(bio) nosen



*Preparing the file for engineering 
prepare_field_file, ranking(eng)

gegen dm_inst_fe=demean(inst_fe) if !missing(l_inst_ranking_p)

*Graph using the THE rankings
create_graphs dm_inst_fe inst_ranking_p, type(all:eng)

*Graph using the USNWR rankings
create_graphs dm_inst_fe inst_ranking_p, type(eng)

create_field_tables, ranking(eng)


prepare_field_file, ranking(eng) nosen

create_field_tables, ranking(eng) nosen


*Writing table with field counts
create_table_f_counts

