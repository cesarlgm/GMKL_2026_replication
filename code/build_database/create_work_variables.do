*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Purpose: 	creates work related variables
*/

local year `1'
*===============================================================================
*EMPLOYMENT STATUS
*===============================================================================
g		employed_f=.
replace employed_f=(lfstat==1)

label var 		employed_f "Is employed"
label define 	employed_f 0 "No" 1 "Yes"
label values 	employed_f employed_f 

g				unemployed_f=.
replace 		unemployed_f=(lfstat==2)

label var 		unemployed_f "Is unemployed"
label define 	unemployed_f 0 "No" 1 "Yes"
label values 	unemployed_f unemployed_f 

*===============================================================================
*CURRENTLY IN POST-DOC
*===============================================================================
g in_postdoc_f=.
label var in_postdoc_f "Currently in a postdoc"
if `year'!=1995 {
	replace in_postdoc_f=pdix
}
else {
	replace in_postdoc_f=pd1ey95==0
}

*===============================================================================
*TIME WITH CURRENT EMPLOYER
*===============================================================================
*Computation of reference data of the survey. Reference date differs across waves.
cap drop 	current_date_f
g 			current_date_f=.
replace		current_date_f=mdy(4,1,refyr) 	if inrange(refyr, 1993,2002)|refyr==2006
replace		current_date_f=mdy(10,1,refyr) 	if inrange(refyr, 2007,2010)|refyr==2003
replace		current_date_f=mdy(10,1,refyr) 	if refyr>=2013
replace 	current_date_f=mdy(2,1,refyr) 	if refyr==2019 

	
format current_date_f %tdMonth_dd,_CCYY

*I think I can discard this. I don't think I ever used this.
if `year' > 1993 {
	g		start_date_f=	mdy(strtmn,1,strtyr)
	format 	start_date_f 	%tdMonth_dd,_CCYY

	g			time_current_job_f=(current_date - start_date)/365
	label var  	time_current_job_f "Years with current employer"
}
else {
	g start_date_f=.
	g time_current_job_f=	yrs_sc_phd_f if emsmi88==1 & yrs_sc > 5
	
	*This assumes that the person got the job right after the last reference week
	replace time_current_job_f= 3 if emsmi88==0 & yrs_sc >5
	* this changes 5229 
	replace time_current_job_f=	yrs_sc_phd_f if emsmi88==0 & yrs_sc <=5
	** this changes 5226 !!!
	replace time_current_job_f = expft if expft < yrs_sc_phd & time_current_job_f == yrs_sc_phd 
}

*===============================================================================
*TYPE OF EMPLOYER
*===============================================================================
*Here I am just labelling the type of employer. Selection / cleaning happens further
*down the line.

g			employer_type_f=.
foreach code in 1 2 3 4 5 6 10 11 12 13 14 15 16 17 18 19 {
	replace employer_type_f=`code' if emtp==`code'
}

label define employer_type_f 	1 "Elementary, middle, or secondary school" ///
								2 "2-year college, junior college, or technical institute" ///
								3 "4-year college or university" ///
								4 "Medical school" ///
								5 "University research institute" ///
								6 "Other [Educational Institution]" ///
								10 "Private-for-profit [non-educational institution]" ///
								11 "Private-for-non-profit [non-educational institution]" ///
								12 "Self-employed, not incorporated [non-educational institu" ///
								13 "Self-employed, incorporated [non-educational institution" ///
								14 "Local government [non-educational institution]" ///
								15 "State government [non-educational institution]" ///
								16 "U.S. military [non-educational institution]" ///
								17 "U.S. government [non-educational institution]" ///
								18 "Other [non-educational institution]" ///
								19 "Other [nonUS] government" 


label values employer_type_f employer_type_f

local 	old_var emtp
local 	new_var employer_type_f
assert !(missing(`new_var') & !missing(`old_var'))
di "Main employer sector recoded", as result

g	in_academia_f=	inlist(employer_type_f,3,4,5,6)


*===============================================================================
*COMPUTATION OF REAL WAGE
*===============================================================================
preserve
	*I convert CPI file from FRED
	*I am using the annual average.
	import 	excel "data/raw/CPIAUCSL.xls", sheet("FRED Graph") cellrange(A11:B41) ///
		firstrow clear
	rename *, lower
	rename cpiaucsl cpi

	g	refyr=year(observation_date)

	drop observation_date

	g	cpi_factor=255.65075/cpi
	label var cpi_factor "Converts to jan 1st 2020 dollars"

	tempfile cpi_file
	save `cpi_file'
restore

merge m:1 refyr using `cpi_file', nogen keep(3)

g	r_salary_f=salary*cpi_factor

label var r_salary_f "Annual salary in 2020 dollars"



*I think I do not require this
*================================================================================
*Hourly wage rate
*================================================================================

if refyr != 1993 {
	replace wkswk=. if wkswk==98
	replace hrswk=. if hrswk==98
}
else {
	gen wkswk= 52 if refyr==1993 & fptind==1 
	gen hrswk= 40 if refyr==1993 & fptind==1 
}


* For 1993, I am assuming tha that the individual worked 50 wks during a year

g 	r_hrwage_f=r_salary_f/(hrswk*wkswk)
label var r_hrwage_f "Real hourly wage"


*================================================================================
*Total earned income -- none in 1993
*================================================================================
cap gen			earn_f=		earn*cpi_factor
cap label var 	earn_f 		"Total earned income in 2020 dollars"


*================================================================================
*FULL TIME EMPLOYMENT
*================================================================================
g full_time_f=(hrswk>=35)&(wkswk>=40)
label var full_time_f "Worked more than 35 hrs a week and more than 40 wks per year in the previous yr"



*===============================================================================
*TYPE OF ACADEMIC POSITION
*===============================================================================
*Here I am assuming a ranking to the position type
*I do not think I ever use this variables
cap {
	local position_list acadadjf acadadmn acadna acadothp acadpdoc acadrchf acadtchf

	local counter=1

	replace acadothp	=2 if acadothp==1
	replace acadpdoc	=3 if acadpdoc==1
	replace acadpdoc	=4 if acadadjf==1
	replace acadrchf	=5 if acadrchf==1
	replace acadtchf	=5 if acadtchf==1
	replace acadadmn	=6 if acadadmn==1

	egen 	academic_pos_f=rowmax(`position_list')

	label define academic_pos_f 1 "NA" 2 "Other" 3 "Post doc" 4 "Adjunct faculty" ///
		5 "Research / teaching faculty" 6 "Dean or president"

	label values academic_pos_f academic_pos_f
}

*===============================================================================
*FACULTY RANK AND TYPE OF POSITION
g		faculty_rank_f=.
replace	faculty_rank_f=0 if inlist(facrank, 1,2)
replace	faculty_rank_f=1 if facrank==8 | facrank == 9
replace	faculty_rank_f=2 if facrank==7 
replace	faculty_rank_f=3 if facrank==6
replace	faculty_rank_f=4 if facrank==5
replace	faculty_rank_f=5 if facrank==4
replace	faculty_rank_f=6 if facrank==3

lab define faculty_rank_f 0 "Not applicable" 1 "Other" 2 "Lecturer" 3 "Instructor" ///
	4 "Assistant professor" 5 "Associate professor" 6 "Professor"

label values faculty_rank_f faculty_rank_f

local 	old_var facrank
local 	new_var faculty_rank_f
assert !(missing(`new_var')&!missing(`old_var'))
di "Faculty rank recoded", as result

g 	prof_rank_f=faculty_rank_f>=4&!missing(faculty_rank_f)

label var prof_rank_f "Individual has a professor rank"

*===============================================================================
*TENURE STATUS
*===============================================================================
g		tenure_status_f=.

forvalues j=1/5 {
	replace tenure_status_f=`j' if tensta==`j'
}

label define tenure_status_f 1 "NA: no tenure institution" 2 "NA: no tenure position" ///
	3 "Tenured" 4 "On tenure track but not tenured" 5 "Not on tenure track"

label values tenure_status_f tenure_status_f
local 	old_var tensta
local 	new_var tenure_status_f


*Indicator for being in a tenure track position
g	in_tenure_track_f=inlist(tenure_status_f, 3,4)


cap assert !(missing(`new_var')&!missing(`old_var'))


*===============================================================================
*DOCTORAL FIELD
*===============================================================================
cap rename dgrmed ndgrmed 



g			employed_us_f=emus
label var 	employed_us_f "Employer located in the US"

*===============================================================================
*EMPLOYER CODE
*===============================================================================
g			instcod_f=instcod
replace 	instcod_f="" if inlist(instcod, "999998","999999")



*=============================END OF DO FILE====================================


