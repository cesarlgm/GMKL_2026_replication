/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	creates LaTeX table showing first-stage AKM regression results with time-varying covariates

*   Input: results/regressions/all_clust_raw*.ster
*          results/regressions/all_clust_clean*.ster
*   Output: results/tables/table_AKM_first_stage*.tex
					

*===============================================================================
*/

global texspace \hspace{3mm}

cap program drop create_AKM_table
program define create_AKM_table
	syntax, [NOsen]
	clear 

	if "`nosen'"!="" {
		local stub _nosen
		local varlab
		local keeptime
	}
	else {
		local varlab time_current_job_f "Time in current job"
		local keeptime time_current_job_f
	}
	
	estimates use "results/regressions/all_clust_raw`stub'"

	eststo akm_regression

	estimates use "results/regressions/all_clust_clean`stub'"

	eststo akm_regression_clean


	*Outputting tex table of university level stats
	local table_name	"results/tables/table_AKM_first_stage`stub'.tex"
	local table_key 	"tab:akm_fs"
	local table_title 	"Effect of time-varying variables"
	local coltitles		`""Excluding \\ outliers""Including \\ outliers""'
	local n_cols		2
	local table_notes 	"Standard errors in parenthesis. Column (1) uses the full sample. Column (2) excludes extreme within-institution wage changes"
	local models		akm_regression_clean  akm_regression
	local exhead
	local coeflabels1 	years_since_phd "Years since PhD" ///
						c.years_since_phd#c.years_since_phd "Years since PhD squared" ///
						1.tenured_f "Is tenured" `varlab'
	local coeflabels2 	1.faculty_rank_f "$texspace Lecturer" 2.faculty_rank_f "$texspace Instructor" ///
						4.faculty_rank_f "$texspace Associate professor" ///
						5.faculty_rank_f "$texspace Professor" ///
						6.faculty_rank_f "$texspace Other" ///
						1.married "Married" ///
						1.married#1.female_f "Married $ \times $ female" ///
						1.has_ch_6 "Children below 6" ///
						1.has_ch_6#1.female_f "Children below 6 $ \times $ female" ///
						1.has_ch_611 "Children between 6 and 11" ///
						1.has_ch_611#1.female_f "Children between 6 and 11$ \times $ female"  ///
						1.has_ch_1218 "Children between 12 and 18" ///
						1.has_ch_1218#1.female_f "Children between 12 and 18$ \times $ female"  ///
						1.has_ch_19 "Children between 19+" ///
						1.has_ch_19#1.female_f "Children between 19+$ \times $ female" 
										
						
	local keep1 		years_since_phd c.years_since_phd#c.years_since_phd 1.tenured_f `keeptime'
	local keep2			*faculty_rank_f *married* *has_ch*






	textablehead using `table_name', ncols(`n_cols') title(`table_title') ///
		coltitles(`coltitles') exhead(`exhead') f(`ftitle') ct(\scshape)

	leanesttab `models' using `table_name', keep(`keep1') append nobase noomit ///
		 format(4) nostar coeflabel( `coeflabels1') noobs nostar

	writeln `table_name' "\textit{Faculty rank (omitted=assistant professor)} \\"
	leanesttab `models' using `table_name', keep(`keep2')  append nobase noomit ///
		indicate("\midrule Individual FE=*.panelid" "Institution FE=*instcod*" "Year FE=*refyr", label("$ \checkmark $" "")) format(4) nostar coeflabel( `coeflabels2') noobs stats(N n_movers r2, label("\midrule Observations" "Number of movers" "$ R^2 $ ") ///
		fmt(%9.0fc %9.0fc %9.2fc ))
		
	textablefoot using `table_name', notes(`table_notes') nodate



						


end


create_AKM_table

create_AKM_table, nosen

