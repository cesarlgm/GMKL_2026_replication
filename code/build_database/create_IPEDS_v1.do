/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Orchestrates the construction of a pooled IPEDS institution-level
*					dataset spanning 2001, 2005, 2012, and 2017. Runs sub-scripts to
*					label enrollment, faculty, and institutional characteristics CSV
*					files; reshapes and merges the three data sources for each survey
*					year; and appends them into a single cross-year dataset saved to
*					data/temporary/IPEDS_v2.

*   NOTE:           the NORC code uses IPEDS_v2 as input. Place the file produced by
*                   this script in data/raw/ to ensure the NORC code runs correctly.

*===============================================================================
*/

*Labelling enrollment files when needed
clear all
do "code/build_database/label_enrollment_IPEDS_2001.do"

clear all
do "code/build_database/label_enrollment_IPEDS_2005.do"

clear all
do "code/build_database/label_enrollment_IPEDS_2012.do"

clear all
do "code/build_database/label_enrollment_IPEDS_2017.do"

*First I label the files with faculty data
clear all
do "code/build_database/label_faculty_IPEDS_2001.do"

clear all
do "code/build_database/label_faculty_IPEDS_2005.do"

clear all 
do "code/build_database/label_faculty_IPEDS_2012.do"

clear all 
do "code/build_database/label_faculty_IPEDS_2017.do"


*Next I label the files with all other data
clear all 
do "code/build_database/label_IPEDS_2001.do"

clear all 
do "code/build_database/label_IPEDS_2005.do"

clear all 
do "code/build_database/label_IPEDS_2012.do"

clear all
do "code/build_database/label_IPEDS_2017.do"

*Fixing enrollment files
*================================================================
use "data/temporary/labeled_enrollment_IPEDS_2001", clear
keep if inlist(eflevel,10, 20, 50)
keep unitid eftotal eflevel
reshape wide eftotal, i(unitid) j(eflevel)
rename (eftotal10 eftotal20 eftotal50) (enrollment_total enrollment_undergrad enrollment_graduate) 
foreach variable in  enrollment_undergrad enrollment_graduate {
    replace `variable'=0 if missing(`variable')
}
tempfile enrollment_2001
save `enrollment_2001'

use "data/temporary/labeled_enrollment_IPEDS_2005", clear
keep if inlist(eflevel,10, 20, 50)
keep unitid eftotal eflevel
reshape wide eftotal, i(unitid) j(eflevel)
rename (eftotal10 eftotal20 eftotal50) (enrollment_total enrollment_undergrad enrollment_graduate) 
foreach variable in  enrollment_undergrad enrollment_graduate {
    replace `variable'=0 if missing(`variable')
}
tempfile enrollment_2005
save `enrollment_2005'

use "data/temporary/labeled_enrollment_IPEDS_2012", clear
keep if inlist(eflevel,10, 20, 50)
keep unitid eftotal eflevel
reshape wide eftotal, i(unitid) j(eflevel)
rename (eftotal10 eftotal20 eftotal50) (enrollment_total enrollment_undergrad enrollment_graduate) 
foreach variable in  enrollment_undergrad enrollment_graduate {
    replace `variable'=0 if missing(`variable')
}
tempfile enrollment_2012
save `enrollment_2012'


use "data/temporary/labeled_enrollment_IPEDS_2017", clear
keep if inlist(eflevel,10, 20, 50)
keep unitid eftotal eflevel
reshape wide eftotal, i(unitid) j(eflevel)
rename (eftotal10 eftotal20 eftotal50) (enrollment_total enrollment_undergrad enrollment_graduate) 
foreach variable in  enrollment_undergrad enrollment_graduate {
    replace `variable'=0 if missing(`variable')
}
tempfile enrollment_2017
save `enrollment_2017'

*Fixing faculty files 
*================================================================
use "data/temporary/labeled_faculty_IPEDS_2001", clear
keep if arank==22
rename staff24 total_faculty
keep unitid total_faculty
tempfile faculty_2001
save `faculty_2001'

use "data/temporary/labeled_faculty_IPEDS_2005", clear
keep if arank==22
rename staff24 total_faculty
keep unitid total_faculty
tempfile faculty_2005
save `faculty_2005'

use "data/temporary/labeled_faculty_IPEDS_2012", clear
keep if facstat==10
rename sistotl total_faculty
keep unitid total_faculty
tempfile faculty_2012
save `faculty_2012'

use "data/temporary/labeled_faculty_IPEDS_2017", clear
keep if facstat==10
rename sistotl total_faculty
keep unitid total_faculty
tempfile faculty_2017
save `faculty_2017'


*Renaming and filtering other year files
*================================================================
use "data/temporary/labeled_IPEDS_2001", clear
keep instnm city unitid sector iclevel control hloffer ugoffer groffer hbcu hospital medical locale  year h011 h012 h021 h022 f2b05 f2b07 f3b05 f3b06
*Generate endowment variable 
generate endowment_value=.
egen temp1=rowmean(h012 h022)
egen temp2=rowmean(f2b05 f2b07)
egen temp3=rowmean(f2b05 f2b07)
replace endowment=temp1
replace endowment_value=temp2 if missing(endowment_value)
replace endowment_value=temp3 if missing(endowment_value)

replace hbcu=0 if hbcu==2 

tempfile ipeds_2001
save `ipeds_2001'

use "data/temporary/labeled_IPEDS_2005", clear
keep instnm city unitid sector iclevel control hloffer ugoffer groffer hbcu hospital medical locale  year f2h01 f2h02 f3b06 f3b08 f1h01 f1h02

generate endowment_value=.
egen temp1=rowmean(f1h01 f1h02)
egen temp2=rowmean(f2h01 f2h02)
egen temp3=rowmean(f3b06 f3b08)
replace endowment=temp1
replace endowment_value=temp2 if missing(endowment_value)
replace endowment_value=temp3 if missing(endowment_value)


replace hbcu=0 if hbcu==2 


tempfile ipeds_2005
save `ipeds_2005'

use "data/temporary/labeled_IPEDS_2012", clear
keep instnm city unitid sector iclevel control hloffer ugoffer groffer hbcu hospital medical locale  year f2h01 f2h02 f3b06 f3b08 f1h01 f1h02

generate endowment_value=.
egen temp1=rowmean(f1h01 f1h02)
egen temp2=rowmean(f2h01 f2h02)
egen temp3=rowmean(f3b06 f3b08)
replace endowment=temp1
replace endowment_value=temp2 if missing(endowment_value)
replace endowment_value=temp3 if missing(endowment_value)

replace hbcu=0 if hbcu==2 


tempfile ipeds_2012
save `ipeds_2012'

use "data/temporary/labeled_IPEDS_2017", clear
keep instnm city unitid sector iclevel control hloffer ugoffer groffer hbcu hospital medical locale  year f2h01 f2h02 f3b06 f3b08 f1h01 f1h02

generate endowment_value=.
egen temp1=rowmean(f1h01 f1h02)
egen temp2=rowmean(f2h01 f2h02)
egen temp3=rowmean(f3b06 f3b08)
replace endowment=temp1
replace endowment_value=temp2 if missing(endowment_value)
replace endowment_value=temp3 if missing(endowment_value)

replace hbcu=0 if hbcu==2 

tempfile ipeds_2017
save `ipeds_2017'


*Next I start merging all the files and selecting the appropriate variables
foreach year in 2001 2005 2012 2017  {
    di "`year'"
    use `ipeds_`year'', clear
    merge 1:1 unitid using  `faculty_`year'', nogen   
    merge 1:1 unitid using  `enrollment_`year'', nogen   
    
    drop temp* 
    foreach variable in  f2h01 f2h02 f3b06 f3b08 f1h01 f1h02 h011 h012 h021 h022 f2b05 f2b07 f3b05{
        cap drop `variable'
    }
    
    tempfile fixed_`year'
    save `fixed_`year''
}

clear
foreach year in 2001 2005 2012 2017 {
    append using `fixed_`year''
}


foreach variable in hloffer ugoffer groffer hbcu hospital medical locale {
    tab `variable' year 
}

rename unitid instcod

label var endowment_value "Nominal value of endowment"
label var enrollment_total "Total enrollment"
label var enrollment_undergrad "Undergraduate enrollment"
label var enrollment_graduate "Graduate enrollment"
label var total_faculty "Total full-time faculty"

save "data/temporary/IPEDS_v2", replace

