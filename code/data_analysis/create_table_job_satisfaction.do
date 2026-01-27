/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (garromar@bu.edu)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu) 
*
*Description: creates LaTeX tables analyzing the relationship between institution rankings and faculty job satisfaction using both two-step and one-step AKM estimates
*
*Input files:
*	- results/regressions/regression_satisfaction_ts[1-3][sat_vsat/sat_sat][_nosen]
*	- results/regressions/regression_satisfaction_os[1-3][sat_vsat/sat_sat][_nosen]
*
*Output files:
*	- results/tables/table_jobsat_rankings_sat_vsat.tex (very satisfied)
*	- results/tables/table_jobsat_rankings_sat_sat.tex (satisfied)
*	- results/tables/table_jobsat_rankings_sat_vsat_nosen.tex
*	- results/tables/table_jobsat_rankings_sat_sat_nosen.tex
*	- results/tables/table_jobsat_rankings_sat_vsat_mixed.tex
*	- results/tables/table_jobsat_rankings_sat_sat_mixed.tex
*===============================================================================
*/


cap program drop create_tjobsat
program define create_tjobsat
	syntax, [ttype(str)]
	
	*Setting the type of specification of be used
	*stub gives the file name extension
	*fe_stub gives the file name extension for the two-step FE
	*os_stub gives the file name extension for the one-step estimates
	if "`ttype'"=="" {
		local stub 
		local fe_stub
		local os_stub
		local timevar time_current_job_f
	}
	else if "`ttype'"=="nosen" {
		local stub _nosen
		local fe_stub _nosen
		local os_stub _nosen
		local timevar 
	}
	else if "`ttype'"=="mixed" {
		local fe_stub _nosen
		local os_stub 
		local stub _mixed
		local timevar time_current_job_f
	}
	
	eststo clear
	foreach yvar in sat_vsat sat_sat  {
		forvalues j=1/3 {
			estimates use "results/regressions/regression_satisfaction_ts`j'`yvar'`fe_stub'"
			eststo ts`j'`yvar'
			
			estimates use "results/regressions/regression_satisfaction_os`j'`yvar'`os_stub'"
			eststo os`j'`yvar'
		}
	}
	
	local title_stub 
	foreach yvar in sat_vsat sat_sat {
		if "`yvar'"=="sat_vsat" {
			local title_stub "(very satisfied)"
		}
		else if "`yvar'"=="sat_sat" {
			local title_stub "(satisfied)"
		}
		
		local table_name "results/tables/table_jobsat_rankings_`yvar'`stub'.tex"
		local table_title "Do rankings increase job satisfaction? `title_stub'"
		local table_key "tab:jobsat_`yvar'"
		local n_cols	6
		local exhead "&\multicolumn{3}{c}{\scshape Two-step estimates}&\multicolumn{3}{c}{\scshape One-step estimates}\\ \cmidrule(lr){2-4} \cmidrule(lr){5-7}"
		local table_notes "ADD NOTES"
		local coltitles
		local models ts1`yvar' ts2`yvar' ts3`yvar' os1`yvar' os2`yvar' os3`yvar'
		
		local keepvar  *locale*  *control *ug_*   *enrollment*
		
		
		textablehead using `table_name', ncols(`n_cols') title(`table_title') ///
			coltitles(`coltitles')  exhead(`exhead') adjust(1) ct(\scshape) 

		leanesttab `models' using `table_name', format(4) ///
		keep(*institution_type `keepvar' *institution_type#c.l_* `timevar' l_r_salary) ///
		nomtitles nostar nobase noomit ///
		coeflabel(time_current_job_f  "Time in current job"  l_r_salary "Log of salary") ///
		stats(N r2, ///
			label("\midrule Observations" "$ R^2$") fmt( %9.0fc  %9.3fc  )) ///
			refcat(1.institution_type "\textit{Institution type (omitted=unranked)}" ///
			1.institution_type#c.l_inst_ranking_p "\textit{Institution type $ \times $ ln of ranking}" ///
			1.new_locale "\textit{Institution characteristics}", nolabel) append 
		textablefoot using `table_name', notes(`table_notes') nodate 
	}
end

create_tjobsat

create_tjobsat, ttype(nosen)

create_tjobsat, ttype(mixed)
