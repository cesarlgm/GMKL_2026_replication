/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Flags spell-level data quality problems (missing start date,
*					wrong ordering, same date, unknown or repeated institution
*					codes) and identifies candidate leave episodes (spells
*					sandwiched between two appearances at the same institution).
*					Classifies whether each candidate leave is a proper
*					single-period gap or a year-gap hole.

*   Input: 		Default frame in memory. Required variables: panelid,
*				acad_spell_id, start_date_f, instcod, spell_location,
*				not_mainland, period, refyr.
*   Output: 	Modifies default frame in memory. New variables: problem_type,
*				any_problem, pos_on_leave, any_on_leave, last_period,
*				first_period, last_year, first_year, length_leave,
*				proper_leave, on_leave_hole.

*===============================================================================
*/



drop if missing(panelid)
preserve
	tempfile problem_flags
	
	keep panelid acad_spell_id start_date_f instcod spell_location not_mainland
	duplicates drop
	
	cap drop problem_type

	*Counting the number of spells that are within the US
	egen temp=count(acad_spell_id) if spell_location==1&not_mainland==0, by(panelid)
	egen n_spells_US=max(temp), by(panelid)
	drop temp
	
	generate problem_type=.
	replace	 problem_type=missing(start_date_f)


	sort panelid acad_spell_id
	
	*Flag> starting date is in the wrong order
	by panelid: generate wrong_order=start_date_f<start_date_f[_n-1] 	if _n>1
	
	*Flag> starting date is same even though they are different spells
	by panelid: generate same_date=start_date_f==start_date_f[_n-1] 	if _n>1
	
	
	replace problem_type=2 if wrong_order==1
	replace problem_type=3 if same_date==1
	

	drop wrong_order same_date
	
	cap label define problem_type 1 "Missing stating date" ///
		2 "Wrong oder start date"  3 "Same starting date" 
		
	label values problem_type problem_type

	*Flag> I don't know the institution
	generate unknown_institution=inlist(instcod, "999999", "777777")
	
	replace  	problem_type=4 if unknown_institution==1
	
	label 		define problem_type 4 "Unknown institution",  modify
	
	sort panelid acad_spell_id
	by panelid: generate same_instcod=instcod==instcod[_n-1]
	replace  	problem_type=5 if same_instcod==1
	
	label define problem_type 5 "Same instcod",  modify
	
	egen any_problem=max(problem_type), by(panelid)
	
	drop unknown_institution same_instcod 
	
	*---------------------------------------------------------------------------
	*IDENTIFYING PEOPLE ON LEAVE
	*---------------------------------------------------------------------------
	generate temp=1
	egen times_inst=	sum(temp), by(panelid instcod)
	
	sort panelid 		acad_spell_id
	
	by panelid: 		generate pos_on_leave=(times_inst[_n-1]>1& ///
		times_inst[_n+1]>1) if _n>1&_n<_N
	replace 	pos_on_leave=0 	if missing(pos_on_leave)
	egen 		any_on_leave=	max(pos_on_leave), by(panelid)
	replace 	any_on_leave=0 	if missing(any_on_leave)
	
	save `problem_flags'
restore

merge m:1 panelid acad_spell_id using `problem_flags', nogen update replace

cap drop last_period
cap drop first_period
cap drop first_year
cap drop last_year
cap drop length_leave
cap drop proper_leave
cap drop on_leave_hole

sort panelid period
egen last_period=	max(period), 	by(panelid acad_spell_id)
egen first_period=	min(period), 	by(panelid acad_spell_id)
egen last_year=		max(refyr), 	by(panelid acad_spell_id)
egen first_year=	min(refyr), 	by(panelid acad_spell_id)
egen length_leave=	count(refyr) if pos_on_leave==1, by(panelid)
by panelid: generate proper_leave=	first_period[_n+1]-	last_period[_n-1]==2 	///	
	if pos_on_leave
by panelid: generate on_leave_hole=	first_year[_n+1]-	last_year[_n-1] 		///
	if pos_on_leave

replace proper_leave=0 if length_leave>1
