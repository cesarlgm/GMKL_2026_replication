/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Imports the IPEDS 2001 institutional characteristics CSV, applies variable and value labels for key categorical fields (sector, control, Carnegie classification, locale, endowment, etc.), and saves the labeled dataset to data/temporary/.

*===============================================================================
*/
insheet using "data/raw/IPEDS_2001.csv", clear
label data STATA_RV_8162024_794
label variable unitid "UNITID"
label variable instnm "Institution Name"
label variable year "Survey year 2001"
label variable instnm "Institution (entity) name"
label variable addr "Street address or post office box"
label variable city "City location of institution"
label variable stabbr "Post Office State abbreviation code"
label variable zip "ZIP + four"
label variable fips "FIPS State code"
label variable obereg "Bureau of Economic Analysis Code (OBE) Region"
label variable chfnm "Name of Chief Administrator"
label variable chftitle "Title of Chief Administrator"
label variable gentele "General information telephone number"
label variable fintele "Financial Aid Office telephone number"
label variable admtele "Admissions office telephone number"
label variable ein "Employer Identification Number"
label variable duns "Dunn and Bradstreet identification numbe"
label variable opeid "Office of Postsecondary Education ID Number"
label variable opeflag "OPE Title IV eligibility indicator code"
label variable webaddr "Institution's internet website address"
label variable sector "Sector of institution"
label variable iclevel "Level of institution"
label variable control "Control of institution"
label variable affil "Affiliation of institution"
label variable hloffer "Highest level of offering"
label variable ugoffer "Undergraduate offering"
label variable groffer "Graduate offering"
label variable fpoffer "First-professional offering"
label variable hdegoffr "Highest Degree offered"
label variable deggrant "Degree granting status"
label variable pctmin1 "Percent Black, non-Hispanic"
label variable pctmin2 "Percent American Indian/Alaskan Native"
label variable pctmin3 "Percent Asian/Pacific Islander"
label variable pctmin4 "Percent Hispanic"
label variable hbcu "Historically Black College or University"
label variable hospital "Institution has hospital"
label variable medical "Institution grants a medical degree"
label variable tribal "Tribal college"
label variable carnegie "Carnegie Classification Code"
label variable locale "Degree of Urbanization"
label variable openpubl "Institution open to the general public"
label variable act "Status of institution"
label variable newid "UNITID for merged schools"
label variable deathyr "Year institution was deleted from IPEDS"
label variable closedat "Date institution closed"
label variable cyactive "Institution is active in current year"
label variable pseflag "Postsecondary institution indicator"
label variable pset4flg "Postsecondary and Title IV institution indicator"
label variable ocrmsi "Minority Serving Institution"
label variable ocrhsi "Hispanic Serving Institution"
label variable h011 "Beginning value of endowment assets-book"
label variable h012 "Beginning value of endowment assets-market"
label variable h021 "Ending value of endowment assets-book"
label variable h022 "Ending value of endowment assets-market"
label variable f2b05 "Net assets, beginning of the year"
label variable f2b07 "Net assets, end of the year"
label variable f3b05 "Other changes in equity"
label variable f3b06 "Equity, beginning of year"

/* label define label_stabbr AK "Alaska"
label values stabbr label_stabbr
label define label_stabbr AL "Alabama", add
label values stabbr label_stabbr
label define label_stabbr AR "Arkansas", add
label values stabbr label_stabbr
label define label_stabbr AS "American Samoa", add
label values stabbr label_stabbr
label define label_stabbr AZ "Arizona", add
label values stabbr label_stabbr
label define label_stabbr CA "California", add
label values stabbr label_stabbr
label define label_stabbr CO "Colorado", add
label values stabbr label_stabbr
label define label_stabbr CT "Connecticut", add
label values stabbr label_stabbr
label define label_stabbr DC "District of Columbia", add
label values stabbr label_stabbr
label define label_stabbr DE "Delaware", add
label values stabbr label_stabbr
label define label_stabbr FL "Florida", add
label values stabbr label_stabbr
label define label_stabbr FM "Federated States of Micronesia", add
label values stabbr label_stabbr
label define label_stabbr GA "Georgia", add
label values stabbr label_stabbr
label define label_stabbr GU "Guam", add
label values stabbr label_stabbr
label define label_stabbr HI "Hawaii", add
label values stabbr label_stabbr
label define label_stabbr IA "Iowa", add
label values stabbr label_stabbr
label define label_stabbr ID "Idaho", add
label values stabbr label_stabbr
label define label_stabbr IL "Illinois", add
label values stabbr label_stabbr
label define label_stabbr IN "Indiana", add
label values stabbr label_stabbr
label define label_stabbr KS "Kansas", add
label values stabbr label_stabbr
label define label_stabbr KY "Kentucky", add
label values stabbr label_stabbr
label define label_stabbr LA "Louisiana", add
label values stabbr label_stabbr
label define label_stabbr MA "Massachusetts", add
label values stabbr label_stabbr
label define label_stabbr MD "Maryland", add
label values stabbr label_stabbr
label define label_stabbr ME "Maine", add
label values stabbr label_stabbr
label define label_stabbr MH "Marshall Islands", add
label values stabbr label_stabbr
label define label_stabbr MI "Michigan", add
label values stabbr label_stabbr
label define label_stabbr MN "Minnesota", add
label values stabbr label_stabbr
label define label_stabbr MO "Missouri", add
label values stabbr label_stabbr
label define label_stabbr MP "Northern Marianas", add
label values stabbr label_stabbr
label define label_stabbr MS "Mississippi", add
label values stabbr label_stabbr
label define label_stabbr MT "Montana", add
label values stabbr label_stabbr
label define label_stabbr NC "North Carolina", add
label values stabbr label_stabbr
label define label_stabbr ND "North Dakota", add
label values stabbr label_stabbr
label define label_stabbr NE "Nebraska", add
label values stabbr label_stabbr
label define label_stabbr NH "New Hampshire", add
label values stabbr label_stabbr
label define label_stabbr NJ "New Jersey", add
label values stabbr label_stabbr
label define label_stabbr NM "New Mexico", add
label values stabbr label_stabbr
label define label_stabbr NV "Nevada", add
label values stabbr label_stabbr
label define label_stabbr NY "New York", add
label values stabbr label_stabbr
label define label_stabbr OH "Ohio", add
label values stabbr label_stabbr
label define label_stabbr OK "Oklahoma", add
label values stabbr label_stabbr
label define label_stabbr OR "Oregon", add
label values stabbr label_stabbr
label define label_stabbr PA "Pennsylvania", add
label values stabbr label_stabbr
label define label_stabbr PR "Puerto Rico", add
label values stabbr label_stabbr
label define label_stabbr PW "Palau", add
label values stabbr label_stabbr
label define label_stabbr RI "Rhode Island", add
label values stabbr label_stabbr
label define label_stabbr SC "South Carolina", add
label values stabbr label_stabbr
label define label_stabbr SD "South Dakota", add
label values stabbr label_stabbr
label define label_stabbr TN "Tennessee", add
label values stabbr label_stabbr
label define label_stabbr TX "Texas", add
label values stabbr label_stabbr
label define label_stabbr UT "Utah", add
label values stabbr label_stabbr
label define label_stabbr VA "Virginia", add
label values stabbr label_stabbr
label define label_stabbr VI "Virgin Islands", add
label values stabbr label_stabbr
label define label_stabbr VT "Vermont", add
label values stabbr label_stabbr
label define label_stabbr WA "Washington", add
label values stabbr label_stabbr
label define label_stabbr WI "Wisconsin", add
label values stabbr label_stabbr
label define label_stabbr WV "West Virginia", add
label values stabbr label_stabbr
label define label_stabbr WY "Wyoming", add
label values stabbr label_stabbr
 */
label define label_fips 1 "Alabama"
label values fips label_fips
label define label_fips 2 "Alaska", add
label values fips label_fips
label define label_fips 4 "Arizona", add
label values fips label_fips
label define label_fips 5 "Arkansas", add
label values fips label_fips
label define label_fips 6 "California", add
label values fips label_fips
label define label_fips 8 "Colorado", add
label values fips label_fips
label define label_fips 9 "Connecticut", add
label values fips label_fips
label define label_fips 10 "Delaware", add
label values fips label_fips
label define label_fips 11 "District of Columbia", add
label values fips label_fips
label define label_fips 12 "Florida", add
label values fips label_fips
label define label_fips 13 "Georgia", add
label values fips label_fips
label define label_fips 15 "Hawaii", add
label values fips label_fips
label define label_fips 16 "Idaho", add
label values fips label_fips
label define label_fips 17 "Illinois", add
label values fips label_fips
label define label_fips 18 "Indiana", add
label values fips label_fips
label define label_fips 19 "Iowa", add
label values fips label_fips
label define label_fips 20 "Kansas", add
label values fips label_fips
label define label_fips 21 "Kentucky", add
label values fips label_fips
label define label_fips 22 "Louisiana", add
label values fips label_fips
label define label_fips 23 "Maine", add
label values fips label_fips
label define label_fips 24 "Maryland", add
label values fips label_fips
label define label_fips 25 "Massachusetts", add
label values fips label_fips
label define label_fips 26 "Michigan", add
label values fips label_fips
label define label_fips 27 "Minnesota", add
label values fips label_fips
label define label_fips 28 "Mississippi", add
label values fips label_fips
label define label_fips 29 "Missouri", add
label values fips label_fips
label define label_fips 30 "Montana", add
label values fips label_fips
label define label_fips 31 "Nebraska", add
label values fips label_fips
label define label_fips 32 "Nevada", add
label values fips label_fips
label define label_fips 33 "New Hampshire", add
label values fips label_fips
label define label_fips 34 "New Jersey", add
label values fips label_fips
label define label_fips 35 "New Mexico", add
label values fips label_fips
label define label_fips 36 "New York", add
label values fips label_fips
label define label_fips 37 "North Carolina", add
label values fips label_fips
label define label_fips 38 "North Dakota", add
label values fips label_fips
label define label_fips 39 "Ohio", add
label values fips label_fips
label define label_fips 40 "Oklahoma", add
label values fips label_fips
label define label_fips 41 "Oregon", add
label values fips label_fips
label define label_fips 42 "Pennsylvania", add
label values fips label_fips
label define label_fips 44 "Rhode Island", add
label values fips label_fips
label define label_fips 45 "South Carolina", add
label values fips label_fips
label define label_fips 46 "South Dakota", add
label values fips label_fips
label define label_fips 47 "Tennessee", add
label values fips label_fips
label define label_fips 48 "Texas", add
label values fips label_fips
label define label_fips 49 "Utah", add
label values fips label_fips
label define label_fips 50 "Vermont", add
label values fips label_fips
label define label_fips 51 "Virginia", add
label values fips label_fips
label define label_fips 53 "Washington", add
label values fips label_fips
label define label_fips 54 "West Virginia", add
label values fips label_fips
label define label_fips 55 "Wisconsin", add
label values fips label_fips
label define label_fips 56 "Wyoming", add
label values fips label_fips
label define label_fips 60 "American Samoa", add
label values fips label_fips
label define label_fips 64 "Federated States of Micronesia", add
label values fips label_fips
label define label_fips 66 "Guam", add
label values fips label_fips
label define label_fips 68 "Marshall Islands", add
label values fips label_fips
label define label_fips 69 "Northern Marianas", add
label values fips label_fips
label define label_fips 70 "Palau", add
label values fips label_fips
label define label_fips 72 "Puerto Rico", add
label values fips label_fips
label define label_fips 78 "Virgin Islands", add
label values fips label_fips
label define label_obereg 0 "US Service schools"
label values obereg label_obereg
label define label_obereg 1 "New England CT ME MA NH RI VT", add
label values obereg label_obereg
label define label_obereg 2 "Mid East DE DC MD NJ NY PA", add
label values obereg label_obereg
label define label_obereg 3 "Great Lakes IL IN MI OH WI", add
label values obereg label_obereg
label define label_obereg 4 "Plains IA KS MN MO NE ND SD", add
label values obereg label_obereg
label define label_obereg 5 "Southeast AL AR FL GA KY LA MS NC SC TN", add
label values obereg label_obereg
label define label_obereg 6 "Southwest AZ NM OK TX", add
label values obereg label_obereg
label define label_obereg 7 "Rocky Mountains CO ID MT UT WY", add
label values obereg label_obereg
label define label_obereg 8 "Far West AK CA HI NV OR WA", add
label values obereg label_obereg
label define label_obereg 9 "Outlying areas AS FM GU MH MP PR PW VI", add
label values obereg label_obereg
label define label_opeflag 1 "Title IV participating"
label values opeflag label_opeflag
label define label_opeflag 2 "Unlisted branch/system office of partici", add
label values opeflag label_opeflag
label define label_opeflag 3 "Title IV participating, deferment only", add
label values opeflag label_opeflag
label define label_opeflag 5 "Not currently participating", add
label values opeflag label_opeflag
label define label_opeflag 6 "Not participating and is not listed on P", add
label values opeflag label_opeflag
label define label_sector 0 "Central office or Administrative Unit"
label values sector label_sector
label define label_sector 1 "4-year public", add
label values sector label_sector
label define label_sector 2 "4-year private, not-for-profit", add
label values sector label_sector
label define label_sector 3 "4-year private, for-profit", add
label values sector label_sector
label define label_sector 4 "2-year public", add
label values sector label_sector
label define label_sector 5 "2-year private, not-for-profit", add
label values sector label_sector
label define label_sector 6 "2-year private, for-profit", add
label values sector label_sector
label define label_sector 7 "Less than 2-year public", add
label values sector label_sector
label define label_sector 8 "Less than 2-year private, not-for-profit", add
label values sector label_sector
label define label_sector 9 "Less than 2-year private, for-profit", add
label values sector label_sector
label define label_sector 99 "sector not known", add
label values sector label_sector
label define label_iclevel 1 "Four or more years"
label values iclevel label_iclevel
label define label_iclevel 2 "At least 2 but less than 4 years", add
label values iclevel label_iclevel
label define label_iclevel 3 "Less than 2 years (below associate)", add
label values iclevel label_iclevel
label define label_iclevel -3 "{Not available}", add
label values iclevel label_iclevel
label define label_control 1 "Public"
label values control label_control
label define label_control 2 "Private, not-for-profit", add
label values control label_control
label define label_control 3 "Private, for-profit", add
label values control label_control
label define label_control -3 "{Not available}", add
label values control label_control
label define label_affil 1 "Public"
label values affil label_affil
label define label_affil 2 "Private, for-profit", add
label values affil label_affil
label define label_affil 3 "Private, not for-profit, no religious af", add
label values affil label_affil
label define label_affil 4 "Private, not for-profit, religious affil", add
label values affil label_affil
label define label_affil -3 "{Not available}", add
label values affil label_affil
label define label_hloffer 0 "Other"
label values hloffer label_hloffer
label define label_hloffer 1 "Award of less than one academic year", add
label values hloffer label_hloffer
label define label_hloffer 2 "At least 1, but less than 2 academic yea", add
label values hloffer label_hloffer
label define label_hloffer 3 "Associate^s degree", add
label values hloffer label_hloffer
label define label_hloffer 4 "At least 2, but less than 4 academic yea", add
label values hloffer label_hloffer
label define label_hloffer 5 "Bachelor^s degree", add
label values hloffer label_hloffer
label define label_hloffer 6 "Postbaccalaureate certificate", add
label values hloffer label_hloffer
label define label_hloffer 7 "Master^s degree", add
label values hloffer label_hloffer
label define label_hloffer 8 "Post-master^s certificate", add
label values hloffer label_hloffer
label define label_hloffer 9 "Doctor^s degree", add
label values hloffer label_hloffer
label define label_hloffer -2 "{Not applicable, first-professional only", add
label values hloffer label_hloffer
label define label_hloffer -3 "{Not available}", add
label values hloffer label_hloffer
label define label_ugoffer 1 "Undergraduate degree or certificate offe"
label values ugoffer label_ugoffer
label define label_ugoffer 2 "No undergraduate degree or certificate o", add
label values ugoffer label_ugoffer
label define label_ugoffer -3 "{Not available}", add
label values ugoffer label_ugoffer
label define label_groffer 1 "Graduate degree or certificate offered"
label values groffer label_groffer
label define label_groffer 2 "No graduate degree or certificate offere", add
label values groffer label_groffer
label define label_groffer -3 "{Not available}", add
label values groffer label_groffer
label define label_fpoffer 1 "First-professional degree or certificate"
label values fpoffer label_fpoffer
label define label_fpoffer 2 "No first-professional degree or certific", add
label values fpoffer label_fpoffer
label define label_fpoffer -3 "{Not available}", add
label values fpoffer label_fpoffer
label define label_hdegoffr 0 "Non-degree granting"
label values hdegoffr label_hdegoffr
label define label_hdegoffr 1 "First-professional only", add
label values hdegoffr label_hdegoffr
label define label_hdegoffr 10 "Doctoral", add
label values hdegoffr label_hdegoffr
label define label_hdegoffr 11 "Doctoral and first-professional", add
label values hdegoffr label_hdegoffr
label define label_hdegoffr 20 "Master^s", add
label values hdegoffr label_hdegoffr
label define label_hdegoffr 21 "Master^s and first-professional", add
label values hdegoffr label_hdegoffr
label define label_hdegoffr 30 "Bachelor^s", add
label values hdegoffr label_hdegoffr
label define label_hdegoffr 31 "Bachelor^s and first-professional", add
label values hdegoffr label_hdegoffr
label define label_hdegoffr 40 "Associate^s", add
label values hdegoffr label_hdegoffr
label define label_hdegoffr -3 "{Not available}", add
label values hdegoffr label_hdegoffr
label define label_deggrant 1 "Degree-granting"
label values deggrant label_deggrant
label define label_deggrant 2 "Nondegree-granting, primarily postsecond", add
label values deggrant label_deggrant
label define label_deggrant 3 "Not primarily postsecondary institutions", add
label values deggrant label_deggrant
label define label_deggrant 4 "Institution is not an educational entity", add
label values deggrant label_deggrant
label define label_deggrant -3 "{Not available}", add
label values deggrant label_deggrant
label define label_hbcu 1 "Yes"
label values hbcu label_hbcu
label define label_hbcu 2 "No", add
label values hbcu label_hbcu
label define label_hospital 1 "Yes"
label values hospital label_hospital
label define label_hospital 2 "No", add
label values hospital label_hospital
label define label_medical 1 "Yes"
label values medical label_medical
label define label_medical 2 "No", add
label values medical label_medical
label define label_medical -1 "{Not reported}", add
label values medical label_medical
label define label_medical -2 "{Item not applicable}", add
label values medical label_medical
label define label_tribal 1 "Yes"
label values tribal label_tribal
label define label_tribal 2 "No", add
label values tribal label_tribal
label define label_carnegie 15 "Doctoral or Research Universities--Extensive"
label values carnegie label_carnegie
label define label_carnegie 16 "Doctoral or Research Universities--Intensive", add
label values carnegie label_carnegie
label define label_carnegie 21 "Master^s Colleges and Universities I", add
label values carnegie label_carnegie
label define label_carnegie 22 "Master^s (Comprehensive) Colleges and Universities II", add
label values carnegie label_carnegie
label define label_carnegie 31 "Baccalaureate Colleges--Liberal Arts", add
label values carnegie label_carnegie
label define label_carnegie 32 "Baccalaureate Colleges--General", add
label values carnegie label_carnegie
label define label_carnegie 33 "Baccalaureate/Associate^s Colleges", add
label values carnegie label_carnegie
label define label_carnegie 40 "Associate^s Colleges", add
label values carnegie label_carnegie
label define label_carnegie 51 "Theological seminaries and other special", add
label values carnegie label_carnegie
label define label_carnegie 52 "Medical schools and medical centers", add
label values carnegie label_carnegie
label define label_carnegie 53 "Other separate health profession schools", add
label values carnegie label_carnegie
label define label_carnegie 54 "Schools of engineering and technology", add
label values carnegie label_carnegie
label define label_carnegie 55 "Schools of business and management", add
label values carnegie label_carnegie
label define label_carnegie 56 "Schools of art, music, and design", add
label values carnegie label_carnegie
label define label_carnegie 57 "Schools of law", add
label values carnegie label_carnegie
label define label_carnegie 58 "Teachers colleges", add
label values carnegie label_carnegie
label define label_carnegie 59 "Other specialized institutions", add
label values carnegie label_carnegie
label define label_carnegie 60 "Tribal Colleges and Universities", add
label values carnegie label_carnegie
label define label_carnegie -3 "{Not available}", add
label values carnegie label_carnegie
label define label_locale 1 "Large city"
label values locale label_locale
label define label_locale 2 "Mid-size city", add
label values locale label_locale
label define label_locale 3 "Urban fringe of large city", add
label values locale label_locale
label define label_locale 4 "Urban fringe of mid-size city", add
label values locale label_locale
label define label_locale 5 "Large town", add
label values locale label_locale
label define label_locale 6 "Small town", add
label values locale label_locale
label define label_locale 7 "Rural", add
label values locale label_locale
label define label_locale 9 "Not assigned", add
label values locale label_locale
label define label_locale -3 "{Not available}", add
label values locale label_locale
label define label_openpubl 1 "Insititution is open to the public"
label values openpubl label_openpubl
label define label_openpubl 2 "Insititution is not open to the public", add
label values openpubl label_openpubl
label define label_openpubl -3 "{Not available}", add
label values openpubl label_openpubl
/* label define label_act A "Active - institution active and not a ne"
label values act label_act
label define label_act B "IPEDS scope not determined", add
label values act label_act
label define label_act C "Combined - merged with another inst", add
label values act label_act
label define label_act D "Delete - institution is out of business", add
label values act label_act
label define label_act M "Death with data - closed in current year", add
label values act label_act
label define label_act N "New - added during the current year", add
label values act label_act
label define label_act O "Out-of-scope - not within scope of unive", add
label values act label_act
label define label_act P "Potential add - might be added", add
label values act label_act
label define label_act Q "Potential restore - might be restored", add
label values act label_act
label define label_act R "Restore - restored to the current univer", add
label values act label_act
label define label_act U "Duplicate - UNITID previously assigned", add
label values act label_act
label define label_act W "Potential add that was not added", add
label values act label_act
 */
/* label define label_newid c ""
label values newid label_newid
label define label_newid -2 "{Item not applicable}", add
label values newid label_newid
 */
/* label define label_deathyr 2000 "Processing year 2000"
label values deathyr label_deathyr
label define label_deathyr 2001 "Processing year 2001", add
label values deathyr label_deathyr
label define label_deathyr -2 "{Item not applicable}", add
label values deathyr label_deathyr
 */
label define label_cyactive 1 "Yes"
label values cyactive label_cyactive
label define label_cyactive 2 "No", add
label values cyactive label_cyactive
label define label_pseflag 1 "Active postsecondary institution"
label values pseflag label_pseflag
label define label_pseflag 2 "Not primarily postsec or not open to pub", add
label values pseflag label_pseflag
label define label_pseflag 3 "Not active", add
label values pseflag label_pseflag
label define label_pset4flg 1 "Title IV postsecondary institution"
label values pset4flg label_pset4flg
label define label_pset4flg 2 "Non-Title IV postsecondary institution", add
label values pset4flg label_pset4flg
label define label_pset4flg 3 "Title IV NOT primarily postsecondary ins", add
label values pset4flg label_pset4flg
label define label_pset4flg 4 "Non-Title IV NOT primarily postsecondary", add
label values pset4flg label_pset4flg
label define label_pset4flg 6 "Non-Title IV postsecondary, not open to", add
label values pset4flg label_pset4flg
label define label_pset4flg 9 "Institution is not active in current uni", add
label values pset4flg label_pset4flg
label define label_ocrmsi 0 "No"
label values ocrmsi label_ocrmsi
label define label_ocrmsi 1 "Yes, Minority serving (MSI)", add
label values ocrmsi label_ocrmsi
label define label_ocrmsi -1 "{Enrollment data not reported}", add
label values ocrmsi label_ocrmsi
label define label_ocrmsi -2 "{Not applicable, institution is not in-scope of MSI calculation}", add
label values ocrmsi label_ocrmsi
label define label_ocrhsi 0 "No"
label values ocrhsi label_ocrhsi
label define label_ocrhsi 1 "Yes, Hispanic serving (HSI)", add
label values ocrhsi label_ocrhsi
label define label_ocrhsi -1 "{Enrollment data not reported}", add
label values ocrhsi label_ocrhsi
label define label_ocrhsi -2 "{Not applicable, institution is not in-scope of HSI calculation}", add
label values ocrhsi label_ocrhsi

tab stabbr
tab fips
tab obereg
tab opeflag
tab sector
tab iclevel
tab control
tab affil
tab hloffer
tab ugoffer
tab groffer
tab fpoffer
tab hdegoffr
tab deggrant
tab hbcu
tab hospital
tab medical
tab tribal
tab carnegie
tab locale
tab openpubl
tab act
tab newid
tab deathyr
tab cyactive
tab pseflag
tab pset4flg
tab ocrmsi
tab ocrhsi

summarize pctmin1
summarize pctmin2
summarize pctmin3
summarize pctmin4
summarize h011
summarize h012
summarize h021
summarize h022
summarize f2b05
summarize f2b07
summarize f3b05
summarize f3b06


save "data/temporary/labeled_IPEDS_2001", replace