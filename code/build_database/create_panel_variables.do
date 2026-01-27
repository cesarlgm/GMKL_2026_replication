*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Purpose: 	creates some panel level variables
*/
*===============================================================================

use "data/temporary/appended_database", clear

*SUPER HUGE WARNING PANELID DOES NOT PRODUCE THE SAME RESULT VERY TIME
sort 		refid refyr
egen 		panelid=group(refid)
label 		var panelid "Created panel id"


xtset panelid refyr

g			in_wave=1

*First and last wave wave that the person is observed
egen		first_wave=	min(refyr), by(panelid)
egen		last_wave=	max(refyr), by(panelid)
egen 		waves_insample=count(refyr), by(panelid)


*Setting not time varying characteristics to most recent wave
local fixed_list female_f race_f foreign_f bpl_f
foreach variable in `fixed_list' {
	by panelid: g t_`variable'=		`variable' if refyr==last_wave
	
	egen 	   	`variable'_final=	max(t_`variable'), by(panelid)
	replace 	`variable'=			`variable'_final
	drop 		t_`variable' `variable'_final
}

order refid refyr panelid in_wave first_wave last_wave waves_insample, first

tempfile cleaned_database
save `cleaned_database'
*-------------------------------------------------------------------------------

*===============================================================================
*CREATING COMPLETE PANEL DATASET
*===============================================================================
* To avoid possible mistakes I create a panel where all individuals have an 
* observation per each survey wave, irrespective of whether I actually have data
* for them


*STEP 1: I create a balanced panel for observations
fillin refid refyr
replace in_wave=0 if missing(in_wave)

drop panelid
egen panelid=	group(refid)
order panelid, 	after(refid)

*-------------------------------------------------------------------------------
*STEP 2
*-------------------------------------------------------------------------------
*I complete data for person-level information
foreach variable in first_wave last_wave  waves_insample{
	egen temp=max(`variable'), by(panelid)
	replace `variable'=temp
	drop temp
}


*-------------------------------------------------------------------------------
*STEP 3
*-------------------------------------------------------------------------------
*I create indicator of whether there is a "hole" in the individual's participation
*in the survey
sort 		panelid refyr
by panelid: g t_max_part=		inrange(refyr,first_wave, last_wave)
egen		max_waves=			sum(t_max_part), by(panelid)
drop 		t_max_part
order 		max_waves, 			after(in_wave)
g			hole_in_participation=waves_insample<max_waves
order 		max_waves waves_insample hole, after(in_wave)

label var max_waves 		"Maximum number of waves the person could have been surveyed"
label var waves_insample 	"Actual number of waves the person was surveyed"
label var hole 				"Indicates that there is hole in the survey participation"


*============================END OF DO FILE=====================================
