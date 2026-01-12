*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	Garro-Marin, Kahn, and Lang
	Purpose: 	creates plots for grouped institutions and weighted by number 
				of movers
*/
*===============================================================================


cap program drop cr_binscatter_add
program define cr_binscatter_add
	syntax, panel(str)
	
	*Setting graph styles
	grstyle init
	grstyle set plain
	grstyle set symbol pplain
	grstyle set legend 6
	grstyle set color tableau, n(7)

	local common_options yscale(range(-.2 .3)) ylab(-.2(.1).3)  ///
				ytitle("Institution FE") colors(black gold) msymbol(D O) ///
				lcolors(black gold) legend(order(1 "Research university" 2 "Colleges") ///
				ring(0) pos(2) col(2) region(lstyle(none)))	linetype(qfit) ///
				xtitle("THE institution ranking (1=best schools)") genxq(quantile)
	
	if "`panel'"=="movers" {
		{
			use "data/output/final_database_clean_with_dummies.dta", clear

			do "code/build_database/update_observation_type.do"

			duplicates drop panelid instcod acad_spell_id, force

			order refid acad_spell_id instcod, first

			sort panelid refyr
			
		
			generate mover=panelid if observation_type==1

			gcollapse (nunique) n_movers=mover (nunique)  panelid , by(instcod)

			rename panelid n_people

			tempfile n_movers
			save `n_movers'
		}
		
		use "data/output/institution_level_database_clean", clear

		merge 1:1 instcod using "data/additional_processing/final_institution_list_medical", keep(1 3) nogen

		drop if todrop==1

		merge m:1 instcod using `n_movers', nogen keep(1 3)

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

		*Weighted binscatters, number of movers weight
		{
			local x_var l_inst_ranking_p
			local weight [aw=n_movers]
			local x_var inst_ranking_p

			*Linear ranking
			binscatter inst_fe `x_var' if inlist(institution_type,1,2) & in_sample `weight', ///
				by(institution_type) ///
				xtitle("THE institution ranking (1=best schools)") `common_options' 				
			graph export "results/figures/figure_binscatter_weighted_movers.png", replace
		}
		
		gcollapse (sum) n_people, by(institution_type quantile)
		
		keep if !missing(quantile)
		
		keep n_people institution_type quantile 
		
		export excel "results/figures/figure_fe_ranking_wmovers_people_counts.xlsx", ///
			first(variable) replace
	}
	else if "`panel'"=="grouped" {
		use "data/output/dummy_estimates_file_clean_grouped", clear
	
		rename all_clust inst_fe

		local x_var l_inst_ranking_p
		local weight [aw=move_number]
			
		local x_var inst_ranking_p

		*Linear ranking
		binscatter inst_fe `x_var' if inlist(institution_type,1,2) `weight', ///
			by(institution_type) ///
			`common_options' 
		graph export "results/figures/figure_binscatter_grouped.png", replace

		gcollapse (sum) n_people, by(institution_type quantile)
		
		keep if !missing(quantile)
		
		keep n_people institution_type quantile 
		
		export excel "results/figures/figure_fe_ranking_grouped_people_counts.xlsx", ///
			first(variable) replace
	}
end

cr_binscatter_add, panel(movers)

cr_binscatter_add, panel(grouped)

