/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates LaTeX table showing compensating wage differentials simulation results

*   Input: results/regressions/cwd_sim_*_nosen.ster
*          data/output/compensation_diff_file.dta
*          results/tables/simul_uncorrected_variances_*_nosen.csv
*          results/tables/simul_corrected_variances_*_nosen.csv
*   Output: results/tables/table_cwd_results.tex
					

*===============================================================================
*/



cap program drop cr_table_cwd
program define cr_table_cwd
	syntax, simlist(str)
	
	eststo clear
	
	local mlist
	local nmodels=0
	foreach sim in `simlist' {
		estimates use "results/regressions/cwd_sim_`sim'_nosen"
		eststo m`sim'
		local mlist `mlist' m`sim'
		local ++nmodels
	}
	
	local table_name "results/tables/table_cwd_results.tex"
	local table_key "tab:cwd"
	local table_notes "ADD NOTE"
	local table_title "Total compensation and rankings"
	local ncols `nmodels'
	local models `mlist'
	
	
	local uncorrected_list \hspace{3mm}Uncorrected
	local corrected_list \hspace{3mm}Corrected
	local var_list		\midrule Total compensation variance
	
	

	
	*Reading the corrected variance estimates
	foreach sim in `simlist' {
		use  "data/output/compensation_diff_file", clear
		summ total_compensation`sim' 
		local var`sim': di %9.3fc `r(Var)'
	
		import delimited "results/tables/simul_uncorrected_variances_`sim'_nosen.csv", clear
		
		summ instcod if _n==1
		local unc`sim': di %9.3fc `r(mean)'
		
		import delimited "results/tables/simul_corrected_variances_`sim'_nosen.csv", clear
		
		summ instcod if _n==1
		local cor`sim': di %9.3fc `r(mean)'
		
		local var_list `var_list' & `var`sim''
		local uncorrected_list `uncorrected_list' & `unc`sim''
		local corrected_list `corrected_list' & `cor`sim''
	}
	

	textablehead using "`table_name'", ncols(`ncols') ///
		title("`table_title'") f("Interaction with log of rank") ct(\scshape)
	leanesttab `models' using "`table_name'", ///
		keep(*institution_type#c.l_inst*) noomit nobase ///
		append format(4) ///
		coeflabel(1.institution_type#c.l_inst_ranking_p "Research universities" ///
		2.institution_type#c.l_inst_ranking_p "Colleges" ) noobs ///
		stat(slope impuni impcoll N n_people n_movers, label("\midrule Assumed non-salary compensation share" "\textit{Implied top-bottom gap}\\ \hspace{3mm} Research universities" "\hspace{3mm} Colleges" "\midrule Observations" "Number of people" "Number of movers") fmt(%9.2fc %9.4fc %9.4fc %9.0fc %9.0fc %9.0fc)) 
		writeln `table_name' "`var_list' \\"
		writeln `table_name' "\textit{Variance of institution FE}\\"
		writeln `table_name' "`uncorrected_list' \\"
		writeln `table_name' "`corrected_list' \\"
		
	textablefoot using "`table_name'", notes(`table_notes')

end

cr_table_cwd, simlist(1 3 6 9)