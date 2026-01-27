
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	restricts the sample we use for the work history

*   Input: 	data/temporary/non_switcher_file.dta.dta
*			data/temporary/non_switcher_file_part2.data

*   Output: data/temporary/non_switcher_file_fixed.dta
					

*===============================================================================
*/




clear 
use panelid refid in_wave emtp period refyr employed_f pdix ///
	using "data/temporary/file_with_sample_restrictions", replace
merge m:1 refid refyr using "data/temporary/file_cleaned_dates", ///
	nogen keep(1 3)

keep if in_wave

drop if pdix==1


replace instcod="999999" 	if !employed_f
replace instcod_rep=3 		if !employed_f

label define instcod_rep 3 "Replaced with 999999 (unemployed)", modify


*Merge instcods from some institutions
do "code/build_database/global_instcod_merge.do"

replace in_tenure_track_f=0 	if 	!in_wave
replace in_academia_f=0 		if 	!in_wave

*Is professor is an indicator equal to 1 for any individual that is in a tenure
*track position, working for a research/educational institution.
g		is_professor_f=in_tenure_track_f&in_academia_f
replace is_professor_f=0 if !employed_f

label define employment_status_f ///
	1 "Same employer and same job" ///
	2 "Same employer but different job" ///
	3 "Different employer but same job" ///
	4 "Different employer and different job" /// 
	.b "Logical skip"
label values emsmi employment_status_f


*Initializing the panel
xtset panelid period

*===============================================================================
*Some preliminary fixes  / variable creation
*===============================================================================
replace tenure_status_f=	tensta 	if tensta==.b
replace in_academia_f=		.b 		if emtp==.b

*===============================================================================
*CREATION OF EMPLOYMENT SPELL ID
*===============================================================================
sort panelid period
*This line creates the spell indicator
by panelid: gen  spell_number=1 if _n==1

g temp_sum=0
*This line increases the spell indicator if:
*	1. The institution code changes across waves.
*	2. OR the individual moves out of / into academia
by panelid: replace temp_sum=1 if instcod!=instcod[_n-1] | is_professor_f!=is_professor_f[_n-1]
by panelid: replace spell_number=spell_number[_n-1]+temp_sum if _n>1

order panelid in_wave employed_f instcod spell_number, first


*Here I create an spell counter for ALL employment spells
preserve
	tempfile  employment_spells
	keep if in_wave & employed_f
	keep panelid spell_number
	duplicates drop
	sort panelid spell_number
	by panelid: g emp_spell_id=_n
	save `employment_spells'
restore

merge m:1 panelid spell_number using `employment_spells', nogen

*Here I create an spell counter for employment spells within academia
preserve
	tempfile academic_spells
	keep if in_wave & employed_f & is_professor_f
	keep panelid spell_number
	duplicates drop
	sort panelid spell_number
	by panelid: g acad_spell_id=_n
	save `academic_spells'
restore 

merge m:1 panelid spell_number using `academic_spells', nogen

egen n_spells_acad=max(acad_spell_id), by(panelid)


label var spell_number 		"Number of employment history spell"
label var emp_spell_id 		"Employment spell indicator"
label var acad_spell_id 	"Employment spell in academia indicator"




*===============================================================================
*CODED SPELL CLEANING
*===============================================================================


*From here onwards, I focus on academic employment spell ids (acad_spell_id)

*refyr in which a new period starts
sort		panelid acad_spell_id period
by 			panelid acad_spell_id: generate start_refyr=refyr[1] if !missing(acad_spell_id)
order start_refyr, after(start_date_f)



*===============================================================================
*FIX 1: ELIMINATING WITHIN SPELL VARIATION IN THE STARTING DATE
*===============================================================================
*Employment spells are built based on insitution codes. Thus there might be 
*inconsistencies between the employment spell number and the starting date. For 
*example, a person might give different starting dates within the same spell.
cap drop start_date_ok
cap drop var_start_date
gegen 	var_start_date=var(start_date_f) if !missing(acad_spell_id), ///
											by(panelid acad_spell_id)

*I say the date is ok if the all the years within the spell give the same 
*starting date
g 		start_date_ok=		(var_start_date==0)  if !missing(acad_spell_id)
replace start_date_ok=	1 if missing(var_start_date) & !missing(acad_spell_id)


*REPLACING STEP
*----------------------------------
*Here I replace the problematic starting dates with the modal date.
cap drop modal_start_date
egen modal_start_date=mode(start_date_f) if !missing(acad_spell_id),	///
	by(panelid acad_spell_id) minmode missing
	
replace start_date_f=modal_start_date 	if !start_date_ok


*It is possible that after the replacement I did above, I end up replacing it with
*a wrong date. Here the date being wrong means that the spell starts AFTER the reference
*date of the first survey wave in the spell. If I have this problem, I go back to
*the original raw dates the responder gave, recompute the mode, and replace the starting
*date whenever this new modal date works.
g date_not_kosher=	year(start_date_f)>start_refyr
order 				date_not_kosher, after(start_date_f)
	
cap drop modal_raw_start_date
egen 		modal_raw_start_date=mode(raw_start_date_f) if !missing(acad_spell_id), ///
	by(panelid acad_spell_id) minmode missing

order 		modal_raw_start_date, after(start_date_f)
format 		modal_raw_start_date %tdMonth_dd,_CCYY

g kosher_replacement=year(modal_raw_start_date)<=start_refyr
order kosher_replacement, after(modal_raw_start_date)

replace start_date_f=modal_raw_start_date if date_not_kosher==0 ///
	& kosher_replacement==1 & !missing(acad_spell_id)
	
cap drop _merge 

drop start_date_ok modal_raw_start_date modal_start_date date_not_kosher  ///
	kosher_replacement var_start_date


*I add the description of the raw institution codes to aide me in the manual check
preserve
	tempfile instnames
	use "data/raw/inst_labels", clear
	rename iped raw_instcod
	rename inst_name raw_inst_name
	save `instnames'
restore

merge m:1 raw_instcod using `instnames', keepusing(raw_inst_name) keep(1 3) nogen
order inst_name raw_instcod raw_inst_name, after(instcod)


*===============================================================================
*FIX 2: MERGING CONSECUTIVE SPELLS WITH THE SAME STARTING DATE AND INSTCOD
*===============================================================================
*Note on the procedure: in principle if there is a non-employment / private sector stint
*in the middle, my academic spell numbering would be fine. 

preserve
	tempfile modify_spells
	keep 					if !missing(acad_spell_id)
	keep panelid acad_spell_id start_date_f instcod 
	duplicates drop
	sort 					panelid acad_spell_id
	
	*I am ignoring the spells with missing starting date (mostly 1993 for now)
	drop if missing(start_date_f)

	egen n_spells=max(acad_spell_id), by(panelid)
	
	*This modification is relevant only for people with two spells or more.
	keep if n_spells>1
	
	egen spell_group=group(instcod start_date_f panelid)
	
	by panelid: generate fix_spell=spell_group[_n]==spell_group[_n-1] if _n>1
	
	sort panelid acad_spell_id
	
	by panelid: generate 	fixed_acad_spell=acad_spell_id if _n==1
	by panelid: replace 	fixed_acad_spell=fixed_acad_spell[_n-1]+1 if _n>1 & !fix_spell
	by panelid: replace 	fixed_acad_spell=fixed_acad_spell[_n-1] if _n>1 & fix_spell
	keep panelid acad_spell_id fixed_acad_spell
	save `modify_spells'
restore

merge m:1 panelid acad_spell_id using `modify_spells', nogen

gen raw_acad_spell=		acad_spell_id
replace acad_spell_id=	fixed_acad_spell if !missing(fixed_acad_spell)
cap drop fixed_acad_spell


*===============================================================================
*FIX 3: FORCE VERY CLOSE DATES TO BE THE SAME. THIS ARE DATES THAT I DID NOT ///
*	CATCH BEFORE.
*	I REMERGE SPELLS IF THE MODIFIED DATE AND INSTCOD WARRANTS MERGING
*===============================================================================
preserve
	tempfile date_fixes
	
	keep if !missing(acad_spell_id)
	keep panelid acad_spell_id start_date_f instcod
	duplicates drop 
	drop if missing(start_date_f)

	sort panelid start_date_f

	g		   raw_date=start_date_f
	
	*I assume any date with 1 year or less is the same date.
	by panelid: g same_date=abs(start_date_f-start_date_f[_n-1])<366 if _n>1
	by panelid: replace start_date_f=start_date_f[_n-1] if  _n>1 & same_date==1 & ///
		start_date_f!=start_date_f[_n-1]
	format raw_date %tdMonth_dd,_CCYY

	drop raw_date same_date
	sort panelid acad_spell_id
	
	egen spell_grouping=group(panelid start_date_f instcod)
	
	*I remerge spells after the date fix.
	by panelid: g same_spell=spell_grouping==spell_grouping[_n-1] if _n>1
	
	sort panelid acad_spell_id
	generate 	new_acad_spell=.
	by panelid: replace new_acad_spell= acad_spell_id if _n==1
	by panelid: replace new_acad_spell= new_acad_spell[_n-1]+!same_spell if _n>1
	
	keep panelid acad_spell_id new_acad_spell
	
	save `date_fixes'
restore

merge m:1 panelid acad_spell_id using `date_fixes', nogen

replace acad_spell_id=new_acad_spell if !missing(new_acad_spell)


drop new_acad_spell   tem* date_deviation  ///
	possible_date_pr modal* same_date same_code instcod_spell

cap drop check
	
cap drop n_spells_acad


*===============================================================================
*CREATING FLAGS INDICATING SPELL QUALITY PROBLEMS
*===============================================================================
*===============================================================================
*HOW MANY PEOPLE GIVE A DIFFERENT STARTING DATE WHEN ANSWERING
*EMSMI==2
*==============================================================================
sort panelid period
by panelid: g same_date=abs(start_date_f-start_date_f[_n-1])<366 if _n>1
by panelid: g same_instcod=instcod==instcod[_n-1] if _n>1

table same_date if emsmi==4 & is_professor&consecutive==1

*===============================================================================
*ARE THERE SPELLS WITH STARTING DATES IN THE WRONG ORDER
*These are spells whose starting date is not in the right order.
*===============================================================================
	
preserve
	tempfile spell_ordering	
	keep if !missing(acad_spell_id)
	keep panelid acad_spell_id start_date_f
	duplicates drop
	drop if missing(start_date_f)

	sort panelid acad_spell_id
	by panelid: g right_order=start_date_f[_n]>start_date_f[_n-1] if _n>1
	
	gegen order_problem=max(right_order==0), by(panelid)
	gegen n_spells=max(acad_spell_id), by(panelid)
	
	keep if order_problem 
	keep panelid order_problem 
	duplicates drop
	save `spell_ordering'
restore

merge m:1 panelid using `spell_ordering', nogen


egen n_spells_acad=max(acad_spell_id), by(panelid)
replace order_problem=0 if !missing(acad_spell_id)&missing(order_problem)

order panelid period in_wave acad_spell_id start_date_f, first

merge 1:1 refid refyr  using "data/temporary/file_with_sample_restrictions", keep(3) ///
		keepusing(emst emtp tenyr salary ctzus  age_f dgryr facrank acad*) nogen

*===============================================================================
*FORCING VERY CLOSE STARTING DATES TO BE SAME STARTING DATE 
*(THIS IS REQUIRED BECAUSE I DID SOME DATES REPLAMENTS BEFORE. REPLAMENTES MIGHT
* BE CLOSE TO OTHER DATES)
*===============================================================================
preserve 
	tempfile start_date_fix
	sort panelid period
	keep if !missing(acad_spell_id)
	cap drop same_date
	by panelid: g same_date=abs(start_date_f-start_date_f[_n-1])<366 if _n>1 
	order same_date, after(start_date_f)

	by panelid: replace start_date_f=start_date_f[_n-1] if same_date==1&_n>1
	
	rename start_date_f start_date_f_rep
	keep panelid period start_date_f_rep
	save `start_date_fix'
restore 

merge 1:1 panelid period using `start_date_fix', nogen
replace start_date_f=start_date_f_rep if !missing(start_date_f_rep)



*===============================================================================
*FLAGGING UNKNOWN INSTITUTION CODES
*===============================================================================
*Note to self: same employer is based on emsmi (weeeeeeee)
cap drop unknown_code
generate unknown_code=inlist(instcod,"999999","") if !missing(acad_spell_id)
egen some_unknown=max(unknown_code) if !missing(acad_spell_id), by(panelid) 


*I replace people with unknown instcods from whom I have information from emsmi
sort panelid period
by panelid: replace instcod=instcod[_n-1] if same_date & consecutive &  ///
	same_employer & 	unknown_code &! unknown_code[_n-1]

	
*I fill up information from 1993 whenever possible_date_pr
cap drop replace93date
by panelid: generate replace93date=1 if period==1&same_employer[_n+1]==1 & ///	
	!missing(start_date_f[_n+1])&year(start_date_f[_n+1])<=1993
order replace93date, after(start_date_f)
by panelid: replace start_date_f=start_date_f[_n+1] if replace93date==1

cap drop replace93date


*I do a second round of replacements of the institution codes
sort panelid period
cap drop same_date
by panelid: g same_date=abs(start_date_f-start_date_f[_n-1])<366 if _n>1
by panelid: replace instcod=instcod[_n-1] if same_date & consecutive &  ///
	same_employer & 	unknown_code &! unknown_code[_n-1]

cap drop unknown_code
cap drop some_unknown
generate unknown_code=inlist(instcod,"999999","") if !missing(acad_spell_id)
egen some_unknown=max(unknown_code) if !missing(acad_spell_id), by(panelid) 


*I replace people with unknown instcods from whom I have information from emsmi
sort panelid period
by panelid: replace instcod=instcod[_n+1] if same_date[_n+1]==1 & consecutive[_n+1]==1 &  ///
	same_employer[_n+1]==1 & 	unknown_code &! unknown_code[_n+1]
	
	
*Finally I replace unknown code whenever the starting date is exactly the same
egen 	date_group=group(start_date_f panelid)
order 	date_group, after(start_date_f)


cap drop temp
egen temp=mode(instcod) if unknown==0, minmode by(date_group)
order temp, after(instcod)
cap drop instcode_date
egen instcode_date=mode(temp) , by(date_group) minmode
order instcode_date, after(instcod)

replace instcod=instcode_date if unknown_code & instcode_date!=""
cap drop temp instcode_date

keep if !missing(acad_spell_id)

*===============================================================================
*SOME SALARY QUALITY FLAGS. MAYBE I SHOULD MOVE THIS BIT TO OTHER DO FILE
*===============================================================================

sort panelid period

replace salary=. if salary>999996
cap drop salary_change
cap drop salary_flag

generate salary_change=salary[_n]/salary[_n-1]-1  if !missing(acad_spell_id)&consecutive
generate salary_flag=abs(salary_change)>1/3 if !missing(acad_spell_id)&consecutive

merge 1:1 refid refyr using "data/temporary/file_with_sample_restrictions", keep(3) ///
		keepusing(emst emtp tenyr salary ctzus  age_f ///
		dgryr facrank acad* full_time) nogen
		
*===============================================================================
*FORCE STARTING DATE TO BE NO EARLIER THAN THE PHD YEAR
*===============================================================================
generate to_fix_phd=year(start_date_f)<dgryr if !missing(acad_spell_id)

replace  start_date_f=mdy(9,1,dgryr) if to_fix_phd


*===============================================================================
*EXCLUSION OF PEOPLE I CANNOT USE
*===============================================================================

*===============================================================================
*EXCLUSION 1: OFF WITH PEOPLE WHOSE ONLY EXPERIENCE IS OUTSIDE THE US
*===============================================================================

*I am conservative in the exclusion. I exclude only if they are all the time out
*side the US

egen spell_location=max(emus) if !missing(acad_spell_id), by(panelid acad_spell_id)
label define spell_location 0 "Outside US" 1 "In US"
label values spell_location spell_location

egen temp=max(spell_location), by(panelid)
g to_exclude_country=temp==0

drop if to_exclude_country==1
drop temp to_exclude_country


*===============================================================================
*EXCLUSION 2: PEOPLE WHOSE INSTITUTION IS UNKNOWN ALL THE TIME
*===============================================================================

cap drop unknown_institution
generate 	unknown_institution=inlist(instcod,"999999")
egen 		unknown_spell_inst=min(unknown_institution) if !missing(acad_spell_id), ///
	by(panelid acad_spell_id)
	
egen 		all_unknown=min(unknown_spell_inst)  if !missing(acad_spell_id), ///
	by(panelid)

drop if all_unknown==1
drop unknown_institution unknown_spell_inst all_unknown

*===============================================================================
*EXCLUSION 3: ADDED FLAG FOR BEING IN US TERRITORY
*===============================================================================
generate not_mainland=		inrange(emst, 66,96)
egen always_not_mainland=	min(not_mainland) if !missing(acad_spell_id), by(panelid)

*I drop all the people that stay in US territories all the time
drop if always_not_mainland==1

*===============================================================================
*ADDITIONAL SPELL INFORMATION COMPLETION
*===============================================================================
*FLAGGING UNKNOWN LAST INSTITUTION IN THE LAST ACADEMIC SPELL
*===============================================================================
cap drop 	n_spells_acad
egen 		n_spells_acad=	max(acad_spell_id), by(panelid)
generate 	last_spell=		(acad_spell_id==n_spells_acad)
generate	last_unknown=	last_spell	&		inlist(instcod,"999999")

egen 		has_last_unknown=max(last_unknown), by(panelid)

*===============================================================================
*MAKING POSSIBLE REPLACEMENTS OF INSTITUTION
*===============================================================================
*using other instcods
generate temp=last_unknown==1&inlist(emsmi,1,2) if has_last_unknown
egen 	possible_replacement=max(temp), by(panelid)

*If they are consecutive I replace them.
sort panelid period
by panelid: generate replaced_unknown=consecutive&last_unknown==1& ///
	!inlist(instcod[_n-1],"999999") & inlist(emsmi,1,2) if has_last_unknown==1
by panelid: replace  instcod=instcod[_n-1] if replaced_unknown==1

drop possible_replacement temp

label define replaced_unknown 1 "Replaced using emsmi information" ///
	2 "Replaced using start date information" 0 "No replacement"
	
label values replaced_unknown replaced_unknown

* using starting dates
* updating flag after replacements
cap drop last_unknown has_last_unknown
generate	last_unknown=	last_spell	&		inlist(instcod,"999999")
egen 		has_last_unknown=max(last_unknown), by(panelid)


cap drop temp possible_replacement
sort panelid period
by panelid: generate temp=last_unknown==1&abs((start_date_f-start_date_f[_n-1]))<366 ///
	if has_last_unknown
egen 		possible_replacement=max(temp), by(panelid)

replace replaced_unknown=2 if temp==1
sort 			panelid period
by panelid: 	replace instcod=instcod[_n-1] if temp==1


* Recomputed the unknown instcod variables after last replacements
cap drop last_unknown has_last_unknown
generate	last_unknown=	last_spell	&		inlist(instcod,"999999")
egen 		has_last_unknown=max(last_unknown), by(panelid)

*I drop spells with unknown institution whenever the person has only two spells information
*academia
drop if last_unknown==1 & n_spells_acad==2

cap drop 	n_spells_acad
egen 		n_spells_acad=	max(acad_spell_id), by(panelid)


*===============================================================================
*ADDITION 4: COMPUTING TIME SINCE START DATE
*===============================================================================
generate time_since_start=	(refyr-start_refyr)
generate long_time=			time_since_start>10



do "code/build_database/output_n_problem_obs.do"

*Here I separate the file into>
*	people with several academic spells (the focus)
*	people with only one academic employment spell
preserve
	keep if n_spells_acad==1
	save "data/temporary/non_switcher_file", replace
restore	

keep if	n_spells_acad>1

save "data/temporary/switcher_file", replace


	
	