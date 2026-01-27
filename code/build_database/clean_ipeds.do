/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	cleans and processes IPEDS institutional characteristics data

*   Input: data/raw/IPEDS_v2.dta
*   Output: data/output/clean_ipeds.dta
					

*===============================================================================
*/

use "data/raw/IPEDS_v2",clear

rename total_faculty faculty_total

*Converts institution codes to strings (instcods are strings in the SDR dataset)
tostring instcod, replace

*Setting unknown control code to missing
replace control=. if control==-3


*Converting endowments to real figures
*Source for these figures: 1_build_dataset/input/CPIAUCSL.xls
generate cpi_deflator=.
replace  cpi_deflator=255.651/177.042 if year==2001
replace  cpi_deflator=255.651/195.267 if year==2005
replace  cpi_deflator=255.651/229.586 if year==2012
replace  cpi_deflator=255.651/245.121 if year==2017

foreach variable in faculty_total enrollment_total enrollment_undergrad enrollment_graduate {
	replace `variable'=0 if !missing(endowment_value)&missing(`variable')
}

replace endowment_value=0 if !missing(faculty_total)&faculty_total>0&missing(endowment_value)


*This variable indicates how many years do I see the instcod in the data
egen years_in_data=count(year), by(instcod)

*Computation of log of real endowment
generate l_r_endowment=				log(endowment_value*cpi_deflator)
generate r_endowment_per_student=	exp(l_r_endowment)/enrollment_total
generate l_r_endowment_per_student=	log(r_endowment_per_student)

generate faculty_per_student=	faculty_total/enrollment_total
generate l_faculty_per_student=	log(faculty_per_student)

*I average the enrollment totals and faculty totals across the four years
egen enrollment_grad_m=		mean(enrollment_graduate), by(instcod)
egen enrollment_ugrad_m=	mean(enrollment_undergrad), by(instcod)
egen enrollment_total_m=	mean(enrollment_total), by(instcod)
egen faculty_total_m=		mean(faculty_total), by(instcod)



*Converting variables into logs
foreach variable of varlist enrollment_*_m faculty_total_m*{
	generate l_`variable'=log(`variable')
}


generate offers_master=(hloffer==7)
generate offers_post_master=(hloffer==8)
generate offers_phd=(hloffer==9)

replace 	hospital=. if hospital<0
generate 	has_hospital=(hospital==1) if !missing(hospital)

replace 	medical=. if medical<0
generate 	grants_medical=(medical==1)

*I collapse all the dataset at the instcod level. I use the max of dummy variables.
*This means that the dummy variables should be interpreted as: did this university ever had ...
gcollapse (mean) *_m l_r_endowment* r_endowment_per_student l_fa*_st* years_in_data (max) offers_master ///
	offers_post_master offers_phd has_hospital grants_medical control hbcu locale, ///
	by(instcod)

egen post_grad=rowmax(offers_master offers_phd)

*This variable is one iff the institution doesn't offer a graduate degree
generate ug_only=1-post

*Labelling the location variable
label define locale ///
		11 "City: large" ///
		12 "City: midsize" ///
		13 "City: small" ///
		21 "Suburb: large" ///
		22 "Suburb: midsize" ///
		23 "Suburb: small" ///
		31 "Town: fringe" ///
		32 "Town: distant" ///
		33 "Town: remote" ///
		41 "Rural: fringe" ///
		42 "Rural: distant" ///
		43 "Rural: remote" ///
	   1 "Large city" ///
	   2 "Mid-size city" ///
	   3 "Urban fringe of large city" ///
	   4 "Urban fringe of mid-size city" ///
	   5 "Large town" ///
	   6 "Small town" ///
	   7 "Rural" ///
	   9 "Not assigned" 

	
label values locale locale

*I recode the location variable into a more meaningful variable
generate new_locale=.
replace new_locale=1 if inlist(locale,1,11)
replace new_locale=2 if inlist(locale,2,12)
replace new_locale=3 if inlist(locale,13)
replace new_locale=4 if inlist(locale,21,22,23)|inlist(locale,3,4)
replace new_locale=5 if inrange(locale,31,43)|inlist(locale,5,6,7)
replace new_locale=6 if inlist(locale,9)


label define new_locale ///
	1 "Large city" ///
	2 "Medium city" ///
	3 "Small city" ///
	4 "Suburb city" ///
	5 "Town / rural area" ///
	6 "Not assigned"
label values new_locale new_locale

table locale new_locale, mis

drop locale post_grad

*Variable labelling
label var instcod "Institution code"
label var enrollment_grad_m "Graduate enrollment"
label var enrollment_ugrad_m "Undergraduate enrollment"
label var enrollment_total_m "Total enrollment"
label var faculty_total_m "Total faculty"
label var l_enrollment_grad_m "Log of graduate enrollment"
label var l_enrollment_ugrad_m "Log of undergraduate enrollment"
label var l_enrollment_total_m "Log of total enrollment"
label var l_faculty_total_m "Log of total faculty"
label var l_r_endowment "Log of real endowment"
label var r_endowment_per_student "Endowment per student"
label var l_r_endowment_per_student "Log of real enrollment per student"
label var l_faculty_per_student "Log of faculty per student"
label var years_in_data "Number of years in ipeds"
label var offers_master "Offers master degree"
label var offers_post_master "Offers post-master degree"
label var offers_phd "Offers PhD degree"
label var has_hospital "Has hospital"
label var grants_medical "Grants medical degree"
label var control "Private / public"
label var hbcu "Minority school"
label var ug_only "Only offers undergraduate degree"
label var new_locale "School location"


save "data/output/clean_ipeds", replace