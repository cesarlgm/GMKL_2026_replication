/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Drops wage outliers from the in-memory faculty panel using one
*					of three exclusion methods selected by the argument `1':
*					(1) drops spells with 2 observations where deviation from
*					expected wage exceeds 0.4 in absolute value (Exclusion A in
*					Appendix); (2) drops isolated wage outliers identified via
*					minimum pairwise deviation > 0.2 across the full employment
*					history; (3) drops observations with deviation > 0.4, with
*					exceptions for "solved" outliers whose next-period wage change
*					is consistent with the direction of the deviation.
*					Call as: do exclude_outliers.do [1|2|3]

*   Input: 	In-memory dataset (faculty panel with dev_from_expected,
*			l_r_salary, l_salary_nofe, panelid, acad_spell_id, period, n_obs)
*   Output: 	In-memory dataset with outlier observations dropped.
*				Types 1 and 3 additionally source recompute_wage_changes.do.
*				Type 1 also sources recompute_spell_level_variables.do and
*				update_observation_type.do.
*				Type 1 writes results/log_files/share_above_40.txt and
*				results/log_files/share_above_20.txt.


*===============================================================================
*/

local exclusion_type `1'

if "`exclusion_type'"=="1" { 
	by panelid acad_spell_id: generate temp=abs(dev_from_expected)>.4 if _n>1 & ///
		n_obs==2
		
	cap log close
	log using "results/log_files/share_above_40.txt", replace text
	
	cap drop share40
	by panelid acad_spell_id: generate share40=abs(dev_from_expected)>.4 if _n>1
	summ share40
	
	cap drop share40
	log close
	
	cap log close
	log using "results/log_files/share_above_20.txt", replace text
	
	cap drop share20
	by panelid acad_spell_id: generate share20=abs(dev_from_expected)>.2 if _n>1
	summ share20
	
	cap drop share20
	log close
		
	*THIS IS EXCLUSION A IN THE APPENDIX
	egen to_drop=max(temp), by(panelid acad_spell_id)

	drop if to_drop==1
	

	
	cap drop temp
	cap drop to_drop
	
	do "code/build_database/recompute_wage_changes.do"
	
	do "code/build_database/recompute_spell_level_variables.do"
	
	do "code/build_database/update_observation_type.do"
	
	cap drop n_obs
	egen n_obs=count(period), by(panelid)
}
else if "`exclusion_type'"=="2" {
	
	cap drop temp
	
	sort panelid acad_spell_id period

	*temp flags observations with deviation above .4 and at least three observations
	by panelid acad_spell_id: generate temp=_n if abs(dev_from_expected)>.4 & _n>1 & ///
		n_obs>2

	replace temp=0 if missing(temp)

	*temp_any flags individuals with temp=1 in any observation.
	egen 		temp_any=max(temp>0), by(panelid)

	tempfile whole_database
	save  `whole_database'


	*This computes the minimum deviation from any other wage in the employment history
	tempfile min_deviation
		keep if temp_any==1

		order panelid acad_spell_id period l_salary_nofe

		preserve
			tempfile wages
			keep panelid l_r_salary l_salary_nofe
			rename l_r_salary l_r_salary_
			rename l_salary_nofe l_salary_nofe_

			by panelid: generate id=_n

			reshape wide l_r_salary_ l_salary_nofe_, i(panelid) j(id)
			
			order l_r_salary_* l_salary_nofe_*, last
			save `wages'
		restore 
		

		merge m:1 panelid using `wages'
		
		*Here I am getting observations with temp=1 and computing minimum deviation from any
		*other observation
		keep if temp>0

		local counter=1
		foreach variable of varlist l_r_salary_* {
			generate temp_`counter'=`variable'-l_r_salary
			generate temp_exp_`counter'=l_salary_nofe_`counter'-l_salary_nofe
			generate deviation_`counter'=abs(temp_`counter'-temp_exp_`counter')
			replace deviation_`counter'=. if  temp_`counter'==0
			local ++counter
		}
		
		order temp_* temp_exp* deviation*, last

		gegen min_deviation=rowmin(deviation_*)
		keep panelid period min_deviation

	save `min_deviation'

	use `whole_database', clear
	merge 1:1 panelid period using `min_deviation', nogen
	
	generate wage_outlier= temp>0 & min_deviation>.2
	generate to_classify=   temp>0 & min_deviation<=.2
	

	sort panelid acad_spell_id period

	*I do a second check of possible outliers. The issue is that the criteria I have uses 
	*wage growth beween t and t+1. Either t or t+1 could be the problem here. The 
	*previous code looks at t+1 as the problem. The following code looks at t as the problem
	by panelid acad_spell_id: generate to_recheck=temp[_n+1]>0&wage_outlier[_n+1]==0&wage_outlier==0

	order to_recheck, first

	egen to_recheck_any=max(to_recheck), by(panelid)


	tempfile whole_database
	save  `whole_database'

	tempfile min_deviation
		*This is selecting individuals that have any observation with deviation > .4
		*but mininum deviation less than .2
		keep if to_recheck_any==1

		order panelid acad_spell_id period l_salary_nofe

		preserve
			tempfile wages
			keep panelid l_r_salary l_salary_nofe
			rename l_r_salary l_r_salary_
			rename l_salary_nofe l_salary_nofe_

			by panelid: generate id=_n

			reshape wide l_r_salary_ l_salary_nofe_, i(panelid) j(id)
			
			order l_r_salary_* l_salary_nofe_*, last
			save `wages'
		restore 
		

		merge m:1 panelid using `wages'
		keep if to_recheck>0

		local counter=1
		foreach variable of varlist l_r_salary_* {
			generate temp_`counter'=`variable'-l_r_salary
			generate temp_exp_`counter'=l_salary_nofe_`counter'-l_salary_nofe
			generate deviation_`counter'=abs(temp_`counter'-temp_exp_`counter')
			replace deviation_`counter'=. if  temp_`counter'==0
			local ++counter
		}
		
		order temp_* temp_exp* deviation*, last

		gegen min_deviation2=rowmin(deviation_*)
		keep panelid period min_deviation2

	save `min_deviation'

	use `whole_database', clear
	merge 1:1 panelid period using `min_deviation', nogen

	replace wage_outlier=1 if to_recheck& min_deviation2>.2
	
	egen n_outliers=sum(wage_outlier), by(panelid)
	
	drop if wage_outlier==1 & n_outliers==1
	
	drop wage_outlier
}
else if "`exclusion_type'"=="3" {
	
	do "code/build_database/recompute_wage_changes.do"

	cap drop to_classify
	
	generate to_classify=abs(dev_from_expected)>.4&!missing(dev_from_expected)
	
	drop if to_classify & observation_type==0


	sort panelid acad_spell_id period
	cap drop solved
	cap drop temp_drop
	cap drop temp_increase
	by panelid acad_spell_id: generate temp_drop=to_classify&dev_from_expected[_n-1]<-.2&dev_from_expected[_n+1]>.2
	by panelid acad_spell_id: generate temp_increase=to_classify&dev_from_expected[_n-1]<-.2&dev_from_expected[_n+1]>.2
	
	
	*I declare an outlier as solved if:
		*the increase at the outlier is positive
		*the wage change in the next period is small or positive.
	
	sort panelid acad_spell_id period
	cap drop solved
	by panelid acad_spell_id: generate solved= ///
		to_classify&dev_from_expected>0& ///
		(abs(dev_from_expected[_n+1])<.08 |(dev_from_expected[_n+1]>0&!missing(dev_from_expected[_n+1])))
	order solved, after(to_classify)
	
	replace to_classify=0 if solved==1
	
	order to_classify, after(dev_from_expected)
	
	*Analogously, I declare an outlier as solved if
		*the change at the outlier is negative
		*the wage change in the next period is small or negative.
	cap drop solved
	by panelid acad_spell_id: generate solved= ///
		to_classify&dev_from_expected<0& ///
		(abs(dev_from_expected[_n+1])<.08 |dev_from_expected[_n+1]<0)
	order solved, after(to_classify)


	replace to_classify=0 if solved==1
	
	drop if to_classify // here I drop only 14 observations
}