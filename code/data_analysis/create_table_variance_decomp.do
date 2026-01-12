*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	Garro-Marin, Kahn, and Lang
				
	Description: creates tables of FE variances 
*/
*===============================================================================

cap program drop cr_variance_decomp
program define cr_variance_decomp
	syntax, database(str) [NOsen]
	
	use "data/output/final_database_`database'_with_dummies.dta", clear

	summ l_r_salary, d

	local v_salary: display %9.3fc `r(Var)'


	import delimited "data\temporary\file_for_R_regression_collapsed_`database'.csv", clear

	summ l_r_salary, d

	local v_salary_c: display %9.3fc `r(Var)'

	import delimited "results\tables\corr_net_field_uncollapsed.csv", clear 

	local format %9.3fc
	summ corr  
	local u_net_corr: display `format' `r(mean)'

	
	import delimited "results\tables\corr_net_field_collapsed.csv", clear 

	local format %9.3fc
	summ c_corr  
	local c_net_corr: display `format' `r(mean)'




	import delimited "results\tables\uncorrected_variances_`database'.csv", clear 

	local format %9.3fc
	summ instcod if _n==1
	local uni_u: display `format' `r(mean)'

	summ panelid if _n==2
	local indiv_u: display `format' `r(mean)'

	summ panelid if _n==1
	local corr_u=`r(mean)'/sqrt(`uni_u'*`indiv_u')
	local corr_u:  display `format' `corr_u'


	import delimited "results\tables\corrected_variances_`database'.csv", clear 

	local format %9.3fc
	summ instcod if _n==1
	local uni_u_c: display `format' `r(mean)'

	summ panelid if _n==2
	local indiv_u_c: display `format' `r(mean)'

	summ panelid if _n==1
	local corr_u_c=`r(mean)'/sqrt(`uni_u_c'*`indiv_u_c')
	local corr_u_c:  display `format' `corr_u_c'

	import delimited "results\tables\collapsed_uncorrected_variances_`database'.csv", clear 

	local format %9.3fc
	summ instcod if _n==1
	local uni_c: display `format' `r(mean)'

	summ panelid if _n==2
	local indiv_c: display `format' `r(mean)'

	summ panelid if _n==1
	local corr_c=`r(mean)'/sqrt(`uni_c'*`indiv_c')
	local corr_c:  display `format' `corr_c'


	import delimited "results\tables\collapsed_corrected_variances_`database'.csv", clear 

	local format %9.3fc
	summ instcod if _n==1
	local uni_c_c: display `format' `r(mean)'

	summ panelid if _n==2
	local indiv_c_c: display `format' `r(mean)'

	summ panelid if _n==1
	local corr_c_c=`r(mean)'/sqrt(`uni_c_c'*`indiv_c_c')
	local corr_c_c:  display `format' `corr_c_c'

	if "`database'"!="clean" {
		local stub="with wage outliers"
	}

	{
		local table_name   "results/tables/table_variance_decomp_`database'.tex"
		local table_key		"tab:table_variance_`database'"
		local table_title	"Fixed effect variance estimates in AKM model `stub'"
		local coltitles		`""Uncorrected""Corrected \\ Andrews et al method""'
		local n_cols		2
		local table_notes   "ADD NOTES"

		textablehead using `table_name',  f(`ftitle') ncols(`n_cols') title(`table_title') ///
				coltitles(`coltitles') exhead(`exhead') ct(\scshape)
		writeln `table_name'  "\textbf{Individual by year level} \\"
		writeln `table_name' "\midrule Variance $ \log(salary) $ &`v_salary' & `v_salary' \\"
		writeln `table_name'  " \textit{Variance of Fixed-effects} \\"
		writeln `table_name'  "$texspace Individual & `indiv_u' & `indiv_u_c'\\"
		writeln `table_name'  "$texspace Institution & `uni_u' & `uni_u_c' \\"
		writeln `table_name'  "Correlation & `corr_u' & `corr_u_c' \\"
		writeln `table_name'  "Correlation net of field & `u_net_corr' \\"
		writeln `table_name'  "\midrule\textbf{Collapsed at the spell level} \\"
		writeln `table_name' "\midrule Variance $ \log(salary) $ &`v_salary_c' & `v_salary_c' \\"
		writeln `table_name'  " \textit{Variance of Fixed-effects} \\"
		writeln `table_name'  "$texspace Individual & `indiv_c' & `indiv_c_c' \\"
		writeln `table_name'  "$texspace Institution & `uni_c' & `uni_c_c' \\"
		writeln `table_name'  "Correlation & `corr_c' & `corr_c_c' \\"
		writeln `table_name'  "Correlation net of field & `c_net_corr' \\"
		textablefoot using `table_name', notes(`table_notes')
	}	
end

cr_variance_decomp, database(clean)

cr_variance_decomp, database(raw)
