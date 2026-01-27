*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Purpose: 	cleans and creates demographic variables
*/
*===============================================================================

*-------------------------------------------------------------------------------
*HANDLING OF MARITAL STATUS
*-------------------------------------------------------------------------------
*The coding of marital status changes across time
levelsof marsta
local nlevels: word count of `r(levels)'
local --nlevels 

cap assert inrange(`nlevels',5,6)

*Note: this is not the final variable that goes into the regression. Further coding
*happens down the line. Will check back on this later.
if `nlevels'==6 {
	g			marst_f=.
	replace		marst_f=1 if inlist(marsta,1,2)
	replace		marst_f=2 if marsta==3
	replace		marst_f=3 if inlist(marsta,4,5)
	replace		marst_f=0 if inlist(marsta,6)
}
else if `nlevels'==5 {
	g			marst_f=.
	replace		marst_f=1 if marsta==1
	replace		marst_f=2 if marsta==2
	replace		marst_f=3 if inlist(marsta,3,4)
	replace		marst_f=0 if inlist(marsta,5)
}
	

label define marst_f 0 "Never married" 1 "Married/cohabitation" 2 "Widowed" 3 "Divorced/separated" 

label values marst_f marst_f
label var marst_f	"Marital status"

local 	old_var marsta
local 	new_var marst_f
assert !(missing(`new_var')&!missing(`old_var'))
di "Marital status children recoded", as result


*-----------------------------------
g		female_f=.
replace female_f=0 if gender=="M"
replace female_f=1 if gender=="F"

local 	old_var gender
local 	new_var female_f
assert !(missing(`new_var')&!missing(`old_var'))
di "gender correctly recoded", as result

label var female "Is female"

*-------------------------------------------------------------------------------
*HANDLING OF RACE
*-------------------------------------------------------------------------------
cap rename race racem
levelsof racem
local nlevels: word count of `r(levels)'
local --nlevels 
di "`nlevels'"
cap assert inrange(`nlevels',5,6)

g		race_f=.
if `nlevels'==6 {
	replace race_f=1 if racem==4
	replace race_f=2 if racem==3
	replace race_f=3 if inlist(racem,1,5)
	replace race_f=4 if inlist(racem,2,6)
}
else if `nlevels'==5 {
	replace race_f=1 if racem==1
	replace race_f=2 if racem==2
	replace race_f=3 if racem==3
	replace race_f=4 if inlist(racem,4,5)
}

label define race_f 1 "White" 2 "Black" 3 "Asian/Pacific Islander" 4 "Others"
label values race_f race_f
label var race_f "Recoded race"

local 	old_var racem
local 	new_var race_f
cap assert !(missing(`new_var')&!missing(`old_var'))
di "race correctly recoded", as result

*-----------------------------------
g		foreign_f=.
replace foreign_f=1 if bthus==1
replace foreign_f=0 if bthus==0

label define foreign_f 0 "American" 1 "Foreigner"
label values foreign_f foreign_f
label var foreign_f "Is foreigner"

local 	old_var bthus
local 	new_var foreign_f
cap assert !(missing(`new_var')&!missing(`old_var'))
di "birth place correctly recoded", as result


*-------------------------------------------------------------------------------
*HANDLING OF BIRTHPLACE
*-------------------------------------------------------------------------------
g		bpl_f=.
replace bpl_f=0 if !foreign_f
replace bpl_f=1 if fncrgn==10
replace bpl_f=2 if fncrgn==20
replace bpl_f=3 if fncrgn==30
replace bpl_f=4 if inlist(fncrgn, 31,33,37)
replace bpl_f=5 if inlist(fncrgn, 40)
replace bpl_f=6 if inlist(fncrgn, 50,55)

label define bpl_f 0 "US" 1 "Europe" 2 "Asia" 3 "North America" ///
	4 "Central/South America and the Caribbean" 5 "Africa" 6 "Other"

label values bpl_f bpl_f

label var bpl_f "Birthplace (region)"

local 	old_var fncrgn
local 	new_var bpl_f
cap assert !(missing(`new_var')&!missing(`old_var'))
di "Region of birth scorrectly recoded", as result


*-------------------------------------------------------------------------------
*HANDLING OF CURRENT CITIZENSHIP STATUS
*-------------------------------------------------------------------------------
g 			citizen_f=.
forvalues j=1/6 {
	replace citizen_f=`j' if ctzn==`j'
}

label define citizen_f 1 "Native US citizen" 2 "Naturalized US citizen" ///
	3 "Permanent resident" 4 "Temporary resident" 5 "Non-US citizen living abroad" ///
	6 "Non-US citizen, unspecified"
label values citizen_f citizen_f

label var citizen_f "Current citizenship status"

local 	old_var ctzn
local 	new_var citizen_f
cap assert !(missing(`new_var')&!missing(`old_var'))
di "Citizenship correctly recoded", as result
*-----------------------------------


g			with_children_f=chlvin
label var with_children_f "Has children in household"

local 	old_var chlvin
local 	new_var with_children_f
cap assert !(missing(`new_var')&!missing(`old_var'))
di "With children recoded", as result

*-------------------------------------------------------------------------------
*HANDLING NUMBER OF CHILDREN
*-------------------------------------------------------------------------------
local children_variables ch6 ch611 ch1218 ch19

cap rename ch1217 ch1218
cap rename ch18 ch19

foreach variable in `children_variables ' {
	replace `variable'=0 if with_children_f==0
	replace	`variable'=. if with_children_f==98
	g	`variable'_f=`variable'
}

label var ch6_f 		"Number of children below 6"
label var ch611_f 		"Number of children between 6 and 11"
label var ch1218_f 		"Number of children between 12 and 18"
label var ch19_f 		"Number of children 19 or older"

*-------------------------------------------------------------------------------
* HANDLING PARTNER WORKING
*-------------------------------------------------------------------------------
g		partner_working_f=.
replace	partner_working_f=1 if inlist(spowk,1,2)
replace partner_working_f=1 if inlist(spowk,3)

label define partner_working_f 0 "No" 1 "Yes"
label values partner_working_f partner_working_f  


local 	old_var spowk
local 	new_var partner_working_f
cap assert !(missing(`new_var')&!missing(`old_var'))
di "Partner working recoded", as result


*-----------------------------------
g	 	partner_emptype_f=.
replace partner_emptype_f=1 if spowk==2
replace partner_emptype_f=2 if spowk==1

label define partner_emptype_f 1 "Part-time" 2 "Full-time"
label values partner_emptype_f partner_emptype_f

di "Partner employment type recoded", as result

*-------------------------------------------------------------------------------
* YEARS SINCE PHD
*-------------------------------------------------------------------------------

g			yrs_sc_phd_f=refyr-dgryr
label var	yrs_sc_phd_f "Years since PhD"

cap assert 	yrs_sc_phd_f>=0

*===============================================================================
*AGE
*===============================================================================
rename age age_f

