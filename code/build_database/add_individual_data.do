/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Adds and harmonizes individual-level demographic variables. Merges
*				sample-restriction flags, then constructs race_f and grouped_race
*				(bridging pre/post-2001 raceth/racethm coding changes), phd_field
*				(bridging pre/post-2001 dgrmeng/ndgmeng coding), citizenship label,
*				birth_year, age_at_phd (with cohort-modal imputation for outliers),
*				time_bc_phd (capped at 0), and has_ch_19.

*   Input: 	data/temporary/file_with_sample_restrictions (merged 1:1 on panelid period);
*			default frame already loaded in memory
*   Output: 	Modifies default frame in memory; adds variables: race_f, grouped_race,
*			phd_field, citizen, birth_year, age_at_phd, time_bc_phd, has_ch_19
					

*===============================================================================
*/



cap drop _merge 
merge 1:1 panelid period using "data/temporary/file_with_sample_restrictions", nogen keep(1 3)

cap drop race_f

generate race_f=.

*Coding mistake correction
*=================================================================
*Coding of these variables changes across years
replace race_f=0 if inlist(racethm,5)&refyr>2001
replace race_f=1 if inlist(racethm,3)&refyr>2001
replace race_f=2 if inlist(racethm,1)&refyr>2001
replace race_f=3 if inlist(racethm,4)&refyr>2001
replace race_f=4 if inlist(racethm,2,6,7)&refyr>2001

replace race_f=0 if inlist(raceth,2)&refyr<=2001
replace race_f=1 if inlist(raceth,3)&refyr<=2001
replace race_f=2 if inlist(raceth,4)&refyr<=2001
replace race_f=3 if inlist(raceth,1)&refyr<=2001
replace race_f=4 if inlist(raceth,5,6)&refyr<=2001

cap label drop race_f
label define race_f 0 "Non-hispanic white" ///
	1 "Non-hispanic black" ///
	2 "Asian" ///
	3 "Hispanic" ///
	4 "Other"
	
cap drop grouped_race
generate grouped_race=race_f

replace  grouped_race=3 if grouped_race==4

cap label drop grouped_race
label define grouped_race 0 "Non-hispanic white" ///
	1 "Non-hispanic black" ///
	2 "Asian" ///
	3 "Other"

label values race_f race_f
label values grouped_race grouped_race 


*Field of highest degree
cap label drop phd_field
label define phd_field ///
	11 "Computer and information sciences" ///
	12 "Mathematics and statistics" ///
	21 "Agricultural and food sciences" ///
	22 "Biological sciences" ///
	23 "Environmental life sciences" ///
	31 "Chemistry, except biochemistry" ///
	32 "Earth, atmospheric and ocean sciences" ///
	33 "Physics and astronomy" ///
	34 "Other physical sciences" ///
	41 "Economics" ///
	42 "Political and related sciences" ///
	43 "Psychology" ///
	44 "Sociology and anthropology" ///
	45 "Other social sciences" ///
	51 "Aerospace, aeronautical and astronautical engineering" ///
	52 "Chemical engineering" ///
	53 "Civil and architectural engineering" ///
	54 "Electrical and computer engineering" ///
	55 "Industrial engineering" ///
	56 "Mechanical engineering" ///
	57 "Other engineering" ///
	61 "Health and NEC"



cap drop phd_field

cap replace 	dgrmeng=71 if dgrmeng==61
cap replace 	dgrmeng=73 if dgrmeng==65
cap replace 	dgrmeng=75 if dgrmeng==68
cap replace 	dgrmeng=76 if dgrmeng==69


generate phd_field=.
replace  phd_field=ndgmeng 		if refyr>2001
replace  phd_field=dgrmeng		if refyr<=2001

replace  phd_field=61 			if inrange(phd_field, 61, 76)

label values phd_field phd_field

rename ctzn citizen
cap label drop citizen
label define citizen ///
	1 "native" ///
	2 "naturalized" ///
	3 "permanent resident" ///
	4 "temporary resident" ///
	5 "non-citizen, outside US"
	
label values citizen citizen 

replace citizen=. if inlist(citizen,6,7)

/*
rename edmom mother_education
cap label drop mother_education
label define mother_education ///
	1 "HS dropout" ///
	2 "HS graduate" ///
	3 "Some college" ///
	4 "Bachelors'" ///
	5 "Masters" ///
	6 "Professional degree" ///
	7 "Doctorate"
	
label values mother_education mother_education

replace mother_education=. if inlist(mother_education, 8)

generate college_mom=inrange(mother_education,4,7)

rename eddad father_education
cap label drop father_education
label define father_education ///
	1 "HS dropout" ///
	2 "HS graduate" ///
	3 "Some college" ///
	4 "Bachelors'" ///
	5 "Masters" ///
	6 "Professional degree" ///
	7 "Doctorate"
	
label values father_education father_education

replace father_education=. if inlist(father_education, 8)

generate college_dad=inrange(father_education,4,7)



label define college_mom ///
	0 "Non-college"  ///
	1 "College-mom/dad"
	
label values college_mom college_mom
label values college_dad college_mom
*/

replace bayr=. if bayr==9998
 
*Age at phd
generate birth_year=	refyr-age_f
generate age_at_phd= 	dgryr-birth_year


*Time between bachelor's and PhD
generate 	time_bc_phd=	dgryr-bayr
label var 	time_bc_phd "Time between bachelor's and PhD"


*Some people have time_bc_phd<0. I replace them to zero
replace time_bc_phd=0 if time_bc_phd<0


*For people with very small ages at PhD I replace them with the modes for those ages.

gegen modal_age_phd=mean(age_at_phd), by(dgryr)

qui summ age_at_phd, d

replace age_at_phd=modal_age_phd if age_at_phd<`r(p1)'

cap drop modal_age_phd


*I had forgotten to add the number of children 19 years or older
generate has_ch_19=ch19_f>0

