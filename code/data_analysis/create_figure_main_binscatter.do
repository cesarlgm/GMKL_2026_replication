*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Purpose: 	creates binscatter plots for the paper
*/
*===============================================================================





cap program drop cr_figure_main
program define cr_figure_main
	syntax, panel(str) [NOsen]
	
	if "`nosen'"!=""{
		local stub _nosen
	}
	
	*Unweighted binscatter
	local common_options yscale(range(-.2 .3)) ylab(-.2(.1).3)  ///
			 colors(black gold) msymbol(D O) lcolors(black gold) ///
			 legend(order(1 "Research university" 2 "Colleges")  ///
			 ring(0) pos(2) col(1) region(lstyle(none))) linetype(qfit) nq(11)

	*Setting graph styles
	grstyle init
	grstyle set plain
	grstyle set symbol pplain
	grstyle set legend 6
	grstyle set color tableau, n(7)

	*===============================================
	use "data/output/final_database_clean_with_dummies.dta", clear

	do "code/build_database/update_observation_type.do"
	
	gcollapse (nunique) panelid (mean) l_r_salary, by(instcod)

	rename panelid n_people

	tempfile n_people
	save `n_people'


	use "data/output/institution_level_database_clean", clear

	merge 1:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3) nogen

	drop if todrop==1

	merge m:1 instcod using `n_people', nogen keep(1 3)

	eststo clear 


	*Relabelling variables to make the table prettier
	label define 	new_type 		2 "College", modify
	label define	control			2 "Private institution", modify
	label var 		ug_only 		"Offers only undergraduate degree"
		
	label var 	l_inst_ranking_p 	"log of university ranking"
	label var 	inst_ranking_p 		"university ranking"


	*Regression with no additional controls
	local base_spec  ib3.institution_type ib3.institution_type#c.l_inst_ranking_p

	*Dummies of offering undergrad degree only, private/public university
	qui wregress inst_fe_trim `base_spec'  ///
		ib3.new_locale l_enrollment_total_m l_r_endowment_per_student ///
		l_faculty_per_student i.ug_only i.control, ///
		se(se_inst_fe) stub(m6)
		
	estimates restore m6ss
		
	cap drop in_sample
	generate in_sample=e(sample)


	if "`panel'"=="A" {
		*Add number of movers
		
	

		{
			local x_var inst_ranking_p
			*Linear ranking
			binscatter inst_fe`stub' `x_var' if inlist(institution_type,1,2) & in_sample, ///
				by(institution_type) ///
				xtitle("THE institution ranking (1=best schools)") `common_options'  ///
				ytitle("Institution FE") genxq(quantile) 
			graph export "results/figures/figure_fe_ranking`stub'.png", replace
		}

		
		gcollapse (sum) n_people, by(institution_type quantile)
		drop if institution_type==3
		drop if missing(quantile)
		
		summ n_people
		
		export excel using "results/figures/figure_fe_ranking_people_counts`stub'", ///
			firstrow(variables) replace
		
	}
	else if "`panel'"=="B" {
		
		gegen l_r_salary_nomean=demean(l_r_salary), by(institution_type)
		
		{
			local x_var inst_ranking_p
			*Linear ranking
			binscatter l_r_salary_nomean `x_var' if inlist(institution_type,1,2) & in_sample, ///
				by(institution_type) ///
				xtitle("THE institution ranking (1=best schools)") `common_options'  ///
				ytitle("Average log salary")  genxq(quantile) 
			graph export "results/figures/figure_salary_ranking.png", replace
		}
		
		gcollapse (sum) n_people, by(institution_type quantile)
		drop if institution_type==3
		drop if missing(quantile)
		
		summ n_people
		
		export excel using "results/figures/figure_salary_ranking_people_counts", ///
			firstrow(variables) replace
			
		summ n_people
		
	}
end

*This creates binscatter of FE vs rankings
cr_figure_main, panel(A)

*This creates binscatter of FE, with no seniority
cr_figure_main, panel(A) nosen


*This creates binscatter of average salary vs rankings
cr_figure_main, panel(B)


