
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	cleans institution codes and start dates by replacing missing/unknown IPEDS codes and fixing inconsistent dates

*   Input: data/temporary/file_with_sample_restrictions.dta
*          data/raw/inst_labels.dta
*   Output: data/temporary/file_cleaned_dates.dta
					

*===============================================================================
*/



clear all


set seed 100

use panelid refid period refyr instcod emsmi employed_f in_sample_f in_wave in_tenure_track_f  ///
	employer_type_f start_date_f tensta tenure_status_f dgryr emus full_time using ///
	"data/temporary/file_with_sample_restrictions", replace
	
drop if !in_wave
drop if !employed_f

*This select the relevant institution types + people that worked full time.
g	in_academia_f=	inlist(employer_type_f,3,4,5,6)&full_time



order panelid period refyr, first

*STEP 1: I REPLACE UNKNOWN INSTCODS THAT APPEAR TO BE IN THE SAME INSTITUTION
*===============================================================================
g 	same_employer=(inlist(emsmi,1,2)|missing(emsmi))

sort panelid period
by panelid: g 		consecutive=	period==period[_n-1]+1
by panelid: replace consecutive=1 	if _n==1

*I replace these codes if:
*1- the emsmi indicates that it is the same employer
*2- the start date is the same
*3- employer type is the sameº
g     raw_instcod=instcod

replace instcod="999999" if inlist(instcod,"LLLLLL","L","000000","MMMMMM")|substr(instcod,1,4)=="9999"


*Looping to replace all the missing codes in a period. I made sure that I stopped
*replacing eventually.
forvalues j=1/7 {
	rename instcod iped
	cap drop inst_name
	cap drop unknown_code
	cap drop temp*
	
	*Add institution labels
	merge m:1 iped using "data/raw/inst_labels", keepusing(inst_name) keep(1 3) nogen
	rename iped instcod
	
	sort panelid period
	*Check if code is unknown
	by panelid: g unknown_code=inlist(instcod,"LLLLLL","L","000000","MMMMMM")|substr(instcod,1,4)=="9999"| ///
		inst_name==""
		
	*Condition 1: same employer and I don't know the code
	by panelid: g temp_rep_1=consecutive&same_employer& (unknown_code & !unknown_code[_n-1]) | ///
		(!unknown_code & unknown_code[_n-1])
		
	*Condition 2: starting date is within 1 year
	by panelid: g temp_rep_2=abs(start_date_f-start_date_f[_n-1])<=366
	
	*Condition 3: same employer type
	by panelid: g temp_rep_3=employer_type_f==employer_type_f[_n-1]

	*Check it complies with the three conditions.
	generate  	j_temp`j'=temp_rep_1==1&temp_rep_2==1&temp_rep_3==1
	
	cap g instcod_rep=1 		if j_temp`j'==1
	cap replace instcod_rep=1 	if j_temp`j'==1
	
	sort panelid period
	by panelid: replace instcod=instcod[_n+1] if unknown_code & instcod_rep[_n+1]==1
	by panelid: replace instcod=instcod[_n-1] if unknown_code & instcod_rep==1
}

*I checked this fir the new SDR dataset
drop j_*

label define instcod_rep 1 "Unknown code replaced"
label values instcod_rep instcod_rep


*STEP 2: REPLACE MISSING DATE IF START DATE IS MISSING AND REFYR IS LARGER THAN 
*STARTING YEAR
*===============================================================================
generate date_year=year(start_date_f)

sort panelid period
g		assumed_start_date=missing(start_date_f)& date_year[_n+1]<=refyr& ///
	instcod==instcod[_n+1]

by panelid: replace start_date_f=start_date_f[_n+1] if assumed_start_date

*Replace labels of unknown codes
replace inst_name="" if unknown_code


*STEP 2: FILL UP THE START DATE IF THE INSTITUTION CODE IS THE SAME
sort panelid period
replace start_date_f=start_date_f[_n-1] if missing(start_date_f) ///
	&instcod==instcod[_n-1] & inst_name!="" & inst_name[_n-1]!="" 
replace start_date_f=start_date_f[_n+1] if missing(start_date_f) ///
	&instcod==instcod[_n+1] & inst_name!="" & inst_name[_n+1]!="" 
	

*STEP 2: I CHECK TYPES OF EMPLOYERS I AM SURE THEY ARE MOVES / STAYED WITH THE 
*SAME EMPLOYER
*===============================================================================
sort panelid period

by panelid: generate		same_date=abs(start_date_f-start_date_f[_n-1])<=366
by panelid: generate		same_code=instcod==instcod[_n-1]

g start_year=year(start_date_f)


*FROM HERE ON IS WHERE THE ACTUAL REPLAMENTES HAPPEN
*===============================================================================
egen 			temp_spells=		group(start_year instcod panelid), missing
egen 			modal_instcod=		mode(instcod) if inst_name!="", by(temp_spells) minmode missing

replace 		instcod_rep=2 if	instcod !=modal_instcod & modal_instcod!=""
replace 		instcod=modal_instcod	if instcod_rep==2
label define 	instcod_rep 2 "Replace with modal institution by start date", modify
	
cap drop _merge

drop inst_name

rename instcod iped	

*Add institution labels
merge m:1 iped using "data/raw/inst_labels", keepusing(inst_name) keep(1 3) nogen
rename iped instcod


*Fixing starting date
egen 		instcod_spell=group(instcod same_employer panelid) 	///
	if instcod!="999999"
egen 		modal_start_date=mode(start_date_f),				///
	by(instcod_spell) minmode missing
generate 	possible_date_pr=start_date_f!=modal_start_date 	///
	if !missing(modal_start_date)
format 		modal_start_date %tdMonth_dd,_CCYY

generate date_deviation=abs(modal_start_date-start_date_f)/365 if possible_date_pr


g 			raw_start_date_f=	start_date_f
replace 	start_date_f=		modal_start_date if possible_date_pr==1
format 		raw_start_date_f %tdMonth_dd,_CCYY

cap drop _merge


replace instcod="999999" if inlist(instcod,"LLLLLL","L","000000","MMMMMM")|substr(instcod,1,4)=="9999"
replace inst_name="" if instcod=="999999"


*br if panelid==4426
	
* Here I do a first round of cleaning of institution codes and starting dates
save "data/temporary/file_cleaned_dates", replace
