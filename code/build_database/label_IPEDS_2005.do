/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Imports the IPEDS 2005 institutional characteristics CSV, applies variable and value labels for key categorical fields (sector, control, Carnegie classification, locale, endowment, etc.), and saves the labeled dataset to data/temporary/.

*===============================================================================
*/
insheet using "data/raw/IPEDS_2005.csv", clear
label data STATA_RV_8192024_911
label variable unitid "UNITID"
label variable instnm "Institution Name"
label variable year "Survey year 2005"
label variable city "City location of institution"
label variable stabbr "State abbreviation"
label variable zip "ZIP code"
label variable fips "FIPS state code"
label variable obereg "Geographic region"
label variable opeflag "OPE Title IV eligibility indicator code"
label variable sector "Sector of institution"
label variable iclevel "Level of institution"
label variable control "Control of institution"
label variable hloffer "Highest level of offering"
label variable ugoffer "Undergraduate offering"
label variable groffer "Graduate offering"
label variable fpoffer "First-professional offering"
label variable hdegoffr "Highest degree offered"
label variable deggrant "Degree-granting status"
label variable hbcu "Historically Black College or University"
label variable hospital "Institution has hospital"
label variable medical "Institution grants a medical degree"
label variable tribal "Tribal college"
label variable locale "Degree of urbanization (Urban-centric locale)"
label variable openpubl "Institution open to the general public"
label variable act "Status of institution"
label variable deathyr "Year institution was deleted from IPEDS"
label variable cyactive "Institution is active in current year"
label variable postsec "Primarily postsecondary indicator"
label variable pseflag "Postsecondary institution indicator"
label variable pset4flg "Postsecondary and Title IV institution indicator"
label variable rptmth "Reporting method (academic year or program)"
label variable carnegie "Carnegie Classification 2000"
label variable lock_ic "Status of IC component when institution was migrated"
label variable stat_ic "Response status -  Institutional characteristics component"
label variable enrtot "Total  enrollment"
label variable f2h01 "Value of endowment assets at the beginning of the fiscal year"
label variable f2h02 "Value of endowment assets at the end of the fiscal year"
label variable f3b06 "Equity, beginning of year"
label variable f3b08 "Equity, end of year"
label variable f1h01 "Value of endowment assets at the beginning of the fiscal year"
label variable f1h02 "Value of endowment assets at the end of the fiscal year"
label variable stabbr "State abbreviation"
label variable fips "FIPS state code"
label variable obereg "Geographic region"
label variable instsize "Institution size category"
label variable sector "Sector of institution"
label variable iclevel "Level of institution"
label variable control "Control of institution"
label variable tenursys "Does institution have a tenure system"
label variable deggrant "Degree-granting status"
label variable hbcu "Historically Black College or University"
label variable tribal "Tribal college"
label variable locale "Degree of urbanization (Urban-centric locale)"
label variable pset4flg "Postsecondary and Title IV institution indicator"
label variable instcat "Institutional category"
label variable ccbasic "Carnegie Classification 2005: Basic"
label variable ccipug "Carnegie Classification 2005: Undergraduate Instructional Program"
label variable ccipgrad "Carnegie Classification 2005: Graduate Instructional Program"
label variable ccugprof "Carnegie Classification 2005: Undergraduate Profile"
label variable ccenrprf "Carnegie Classification 2005: Enrollment Profile"
label variable ccsizset "Carnegie Classification 2005: Size and Setting"
label variable landgrnt "Land Grant Institution"
label variable carnegie "Carnegie Classification 2000"
label variable dfrcgid "Data Feedback Report comparison group category"

/* cap label define label_stabbr AL "Alabama"
label values stabbr label_stabbr
cap label define label_stabbr AK "Alaska", add
label values stabbr label_stabbr
cap label define label_stabbr AZ "Arizona", add
label values stabbr label_stabbr
cap label define label_stabbr AR "Arkansas", add
label values stabbr label_stabbr
cap label define label_stabbr CA "California", add
label values stabbr label_stabbr
cap label define label_stabbr CO "Colorado", add
label values stabbr label_stabbr
cap label define label_stabbr CT "Connecticut", add
label values stabbr label_stabbr
cap label define label_stabbr DE "Delaware", add
label values stabbr label_stabbr
cap label define label_stabbr DC "District of Columbia", add
label values stabbr label_stabbr
cap label define label_stabbr FL "Florida", add
label values stabbr label_stabbr
cap label define label_stabbr GA "Georgia", add
label values stabbr label_stabbr
cap label define label_stabbr HI "Hawaii", add
label values stabbr label_stabbr
cap label define label_stabbr ID "Idaho", add
label values stabbr label_stabbr
cap label define label_stabbr IL "Illinois", add
label values stabbr label_stabbr
cap label define label_stabbr IN "Indiana", add
label values stabbr label_stabbr
cap label define label_stabbr IA "Iowa", add
label values stabbr label_stabbr
cap label define label_stabbr KS "Kansas", add
label values stabbr label_stabbr
cap label define label_stabbr KY "Kentucky", add
label values stabbr label_stabbr
cap label define label_stabbr LA "Louisiana", add
label values stabbr label_stabbr
cap label define label_stabbr ME "Maine", add
label values stabbr label_stabbr
cap label define label_stabbr MD "Maryland", add
label values stabbr label_stabbr
cap label define label_stabbr MA "Massachusetts", add
label values stabbr label_stabbr
cap label define label_stabbr MI "Michigan", add
label values stabbr label_stabbr
cap label define label_stabbr MN "Minnesota", add
label values stabbr label_stabbr
cap label define label_stabbr MS "Mississippi", add
label values stabbr label_stabbr
cap label define label_stabbr MO "Missouri", add
label values stabbr label_stabbr
cap label define label_stabbr MT "Montana", add
label values stabbr label_stabbr
cap label define label_stabbr NE "Nebraska", add
label values stabbr label_stabbr
cap label define label_stabbr NV "Nevada", add
label values stabbr label_stabbr
cap label define label_stabbr NH "New Hampshire", add
label values stabbr label_stabbr
cap label define label_stabbr NJ "New Jersey", add
label values stabbr label_stabbr
cap label define label_stabbr NM "New Mexico", add
label values stabbr label_stabbr
cap label define label_stabbr NY "New York", add
label values stabbr label_stabbr
cap label define label_stabbr NC "North Carolina", add
label values stabbr label_stabbr
cap label define label_stabbr ND "North Dakota", add
label values stabbr label_stabbr
cap label define label_stabbr OH "Ohio", add
label values stabbr label_stabbr
cap label define label_stabbr OK "Oklahoma", add
label values stabbr label_stabbr
cap label define label_stabbr OR "Oregon", add
label values stabbr label_stabbr
cap label define label_stabbr PA "Pennsylvania", add
label values stabbr label_stabbr
cap label define label_stabbr RI "Rhode Island", add
label values stabbr label_stabbr
cap label define label_stabbr SC "South Carolina", add
label values stabbr label_stabbr
cap label define label_stabbr SD "South Dakota", add
label values stabbr label_stabbr
cap label define label_stabbr TN "Tennessee", add
label values stabbr label_stabbr
cap label define label_stabbr TX "Texas", add
label values stabbr label_stabbr
cap label define label_stabbr UT "Utah", add
label values stabbr label_stabbr
cap label define label_stabbr VT "Vermont", add
label values stabbr label_stabbr
cap label define label_stabbr VA "Virginia", add
label values stabbr label_stabbr
cap label define label_stabbr WA "Washington", add
label values stabbr label_stabbr
cap label define label_stabbr WV "West Virginia", add
label values stabbr label_stabbr
cap label define label_stabbr WI "Wisconsin", add
label values stabbr label_stabbr
cap label define label_stabbr WY "Wyoming", add
label values stabbr label_stabbr
cap label define label_stabbr AS "American Samoa", add
label values stabbr label_stabbr
cap label define label_stabbr FM "Federated States of Micronesia", add
label values stabbr label_stabbr
cap label define label_stabbr GU "Guam", add
label values stabbr label_stabbr
cap label define label_stabbr MH "Marshall Islands", add
label values stabbr label_stabbr
cap label define label_stabbr MP "Northern Marianas", add
label values stabbr label_stabbr
cap label define label_stabbr PW "Palau", add
label values stabbr label_stabbr
cap label define label_stabbr PR "Puerto Rico", add
label values stabbr label_stabbr
cap label define label_stabbr VI "Virgin Islands", add
label values stabbr label_stabbr
 */
cap label define label_fips 1 "Alabama"
label values fips label_fips
cap label define label_fips 2 "Alaska", add
label values fips label_fips
cap label define label_fips 4 "Arizona", add
label values fips label_fips
cap label define label_fips 5 "Arkansas", add
label values fips label_fips
cap label define label_fips 6 "California", add
label values fips label_fips
cap label define label_fips 8 "Colorado", add
label values fips label_fips
cap label define label_fips 9 "Connecticut", add
label values fips label_fips
cap label define label_fips 10 "Delaware", add
label values fips label_fips
cap label define label_fips 11 "District of Columbia", add
label values fips label_fips
cap label define label_fips 12 "Florida", add
label values fips label_fips
cap label define label_fips 13 "Georgia", add
label values fips label_fips
cap label define label_fips 15 "Hawaii", add
label values fips label_fips
cap label define label_fips 16 "Idaho", add
label values fips label_fips
cap label define label_fips 17 "Illinois", add
label values fips label_fips
cap label define label_fips 18 "Indiana", add
label values fips label_fips
cap label define label_fips 19 "Iowa", add
label values fips label_fips
cap label define label_fips 20 "Kansas", add
label values fips label_fips
cap label define label_fips 21 "Kentucky", add
label values fips label_fips
cap label define label_fips 22 "Louisiana", add
label values fips label_fips
cap label define label_fips 23 "Maine", add
label values fips label_fips
cap label define label_fips 24 "Maryland", add
label values fips label_fips
cap label define label_fips 25 "Massachusetts", add
label values fips label_fips
cap label define label_fips 26 "Michigan", add
label values fips label_fips
cap label define label_fips 27 "Minnesota", add
label values fips label_fips
cap label define label_fips 28 "Mississippi", add
label values fips label_fips
cap label define label_fips 29 "Missouri", add
label values fips label_fips
cap label define label_fips 30 "Montana", add
label values fips label_fips
cap label define label_fips 31 "Nebraska", add
label values fips label_fips
cap label define label_fips 32 "Nevada", add
label values fips label_fips
cap label define label_fips 33 "New Hampshire", add
label values fips label_fips
cap label define label_fips 34 "New Jersey", add
label values fips label_fips
cap label define label_fips 35 "New Mexico", add
label values fips label_fips
cap label define label_fips 36 "New York", add
label values fips label_fips
cap label define label_fips 37 "North Carolina", add
label values fips label_fips
cap label define label_fips 38 "North Dakota", add
label values fips label_fips
cap label define label_fips 39 "Ohio", add
label values fips label_fips
cap label define label_fips 40 "Oklahoma", add
label values fips label_fips
cap label define label_fips 41 "Oregon", add
label values fips label_fips
cap label define label_fips 42 "Pennsylvania", add
label values fips label_fips
cap label define label_fips 44 "Rhode Island", add
label values fips label_fips
cap label define label_fips 45 "South Carolina", add
label values fips label_fips
cap label define label_fips 46 "South Dakota", add
label values fips label_fips
cap label define label_fips 47 "Tennessee", add
label values fips label_fips
cap label define label_fips 48 "Texas", add
label values fips label_fips
cap label define label_fips 49 "Utah", add
label values fips label_fips
cap label define label_fips 50 "Vermont", add
label values fips label_fips
cap label define label_fips 51 "Virginia", add
label values fips label_fips
cap label define label_fips 53 "Washington", add
label values fips label_fips
cap label define label_fips 54 "West Virginia", add
label values fips label_fips
cap label define label_fips 55 "Wisconsin", add
label values fips label_fips
cap label define label_fips 56 "Wyoming", add
label values fips label_fips
cap label define label_fips 60 "American Samoa", add
label values fips label_fips
cap label define label_fips 64 "Federated States of Micronesia", add
label values fips label_fips
cap label define label_fips 66 "Guam", add
label values fips label_fips
cap label define label_fips 68 "Marshall Islands", add
label values fips label_fips
cap label define label_fips 69 "Northern Marianas", add
label values fips label_fips
cap label define label_fips 70 "Palau", add
label values fips label_fips
cap label define label_fips 72 "Puerto Rico", add
label values fips label_fips
cap label define label_fips 78 "Virgin Islands", add
label values fips label_fips
cap label define label_obereg 0 "US Service schools"
label values obereg label_obereg
cap label define label_obereg 1 "New England CT ME MA NH RI VT", add
label values obereg label_obereg
cap label define label_obereg 2 "Mid East DE DC MD NJ NY PA", add
label values obereg label_obereg
cap label define label_obereg 3 "Great Lakes IL IN MI OH WI", add
label values obereg label_obereg
cap label define label_obereg 4 "Plains IA KS MN MO NE ND SD", add
label values obereg label_obereg
cap label define label_obereg 5 "Southeast AL AR FL GA KY LA MS NC SC TN VA WV", add
label values obereg label_obereg
cap label define label_obereg 6 "Southwest AZ NM OK TX", add
label values obereg label_obereg
cap label define label_obereg 7 "Rocky Mountains CO ID MT UT WY", add
label values obereg label_obereg
cap label define label_obereg 8 "Far West AK CA HI NV OR WA", add
label values obereg label_obereg
cap label define label_obereg 9 "Outlying areas AS FM GU MH MP PR PW VI", add
label values obereg label_obereg
cap label define label_opeflag 1 "Participates in Title IV federal financial aid programs"
label values opeflag label_opeflag
cap label define label_opeflag 2 "Branch campus of a main campus that participates in Title IV", add
label values opeflag label_opeflag
cap label define label_opeflag 3 "Deferment only - limited participation", add
label values opeflag label_opeflag
cap label define label_opeflag 5 "Not currently participating in Title IV, has an OPE ID number", add
label values opeflag label_opeflag
cap label define label_opeflag 6 "Not currently participating in Title IV, does not have OPE ID number", add
label values opeflag label_opeflag
cap label define label_opeflag 7 "Stopped participating during the survey year", add
label values opeflag label_opeflag
cap label define label_sector 0 "Administrative Unit"
label values sector label_sector
cap label define label_sector 1 "Public, 4-year or above", add
label values sector label_sector
cap label define label_sector 2 "Private not-for-profit, 4-year or above", add
label values sector label_sector
cap label define label_sector 3 "Private for-profit, 4-year or above", add
label values sector label_sector
cap label define label_sector 4 "Public, 2-year", add
label values sector label_sector
cap label define label_sector 5 "Private not-for-profit, 2-year", add
label values sector label_sector
cap label define label_sector 6 "Private for-profit, 2-year", add
label values sector label_sector
cap label define label_sector 7 "Public, less-than 2-year", add
label values sector label_sector
cap label define label_sector 8 "Private not-for-profit, less-than 2-year", add
label values sector label_sector
cap label define label_sector 9 "Private for-profit, less-than 2-year", add
label values sector label_sector
cap label define label_sector 99 "Sector unknown (not active)", add
label values sector label_sector
cap label define label_iclevel 1 "Four or more years"
label values iclevel label_iclevel
cap label define label_iclevel 2 "At least 2 but less than 4 years", add
label values iclevel label_iclevel
cap label define label_iclevel 3 "Less than 2 years (below associate)", add
label values iclevel label_iclevel
cap label define label_iclevel -3 "{Not available}", add
label values iclevel label_iclevel
cap label define label_control 1 "Public"
label values control label_control
cap label define label_control 2 "Private not-for-profit", add
label values control label_control
cap label define label_control 3 "Private for-profit", add
label values control label_control
cap label define label_control -3 "{Not available}", add
label values control label_control
cap label define label_hloffer 1 "Award of less than one academic year"
label values hloffer label_hloffer
cap label define label_hloffer 2 "At least 1, but less than 2 academic yrs", add
label values hloffer label_hloffer
cap label define label_hloffer 3 "Associate''s degree", add
label values hloffer label_hloffer
cap label define label_hloffer 4 "At least 2, but less than 4 academic yrs", add
label values hloffer label_hloffer
cap label define label_hloffer 5 "Bachelor''s degree", add
label values hloffer label_hloffer
cap label define label_hloffer 6 "Postbaccalaureate certificate", add
label values hloffer label_hloffer
cap label define label_hloffer 7 "Master''s degree", add
label values hloffer label_hloffer
cap label define label_hloffer 8 "Post-master''s certificate", add
label values hloffer label_hloffer
cap label define label_hloffer 9 "Doctor''s degree", add
label values hloffer label_hloffer
cap label define label_hloffer -2 "Not applicable, first-professional only", add
label values hloffer label_hloffer
cap label define label_hloffer -3 "{Not available}", add
label values hloffer label_hloffer
cap label define label_ugoffer 1 "Undergraduate degree or certificate offering"
label values ugoffer label_ugoffer
cap label define label_ugoffer 2 "No undergraduate offering", add
label values ugoffer label_ugoffer
cap label define label_ugoffer -3 "{Not available}", add
label values ugoffer label_ugoffer
cap label define label_groffer 1 "Graduate degree or certificate offering"
label values groffer label_groffer
cap label define label_groffer 2 "No graduate offering", add
label values groffer label_groffer
cap label define label_groffer -3 "{Not available}", add
label values groffer label_groffer
cap label define label_fpoffer 1 "First-professional degree/certificate"
label values fpoffer label_fpoffer
cap label define label_fpoffer 2 "No first-professional offering", add
label values fpoffer label_fpoffer
cap label define label_fpoffer -3 "{Not available}", add
label values fpoffer label_fpoffer
cap label define label_hdegoffr 0 "Non-degree granting"
label values hdegoffr label_hdegoffr
cap label define label_hdegoffr 1 "First-professional only", add
label values hdegoffr label_hdegoffr
cap label define label_hdegoffr 10 "Doctoral", add
label values hdegoffr label_hdegoffr
cap label define label_hdegoffr 11 "Doctoral and first-professional", add
label values hdegoffr label_hdegoffr
cap label define label_hdegoffr 20 "Masters", add
label values hdegoffr label_hdegoffr
cap label define label_hdegoffr 21 "Masters and first-professional", add
label values hdegoffr label_hdegoffr
cap label define label_hdegoffr 30 "Bachelors", add
label values hdegoffr label_hdegoffr
cap label define label_hdegoffr 31 "Bachelors and first-professional", add
label values hdegoffr label_hdegoffr
cap label define label_hdegoffr 40 "Associates", add
label values hdegoffr label_hdegoffr
cap label define label_hdegoffr -3 "{Not available}", add
label values hdegoffr label_hdegoffr
cap label define label_deggrant 1 "Degree-granting"
label values deggrant label_deggrant
cap label define label_deggrant 2 "Nondegree-granting, primarily postsecondary", add
label values deggrant label_deggrant
cap label define label_deggrant -3 "{Not available}", add
label values deggrant label_deggrant
cap label define label_hbcu 1 "Yes"
label values hbcu label_hbcu
cap label define label_hbcu 2 "No", add
label values hbcu label_hbcu
cap label define label_hbcu -3 "{Not available}", add
label values hbcu label_hbcu
cap label define label_hospital 1 "Yes"
label values hospital label_hospital
cap label define label_hospital 0 "No", add
label values hospital label_hospital
cap label define label_hospital -1 "Not reported", add
label values hospital label_hospital
cap label define label_hospital -2 "Not applicable", add
label values hospital label_hospital
cap label define label_medical 1 "Yes"
label values medical label_medical
cap label define label_medical 2 "No", add
label values medical label_medical
cap label define label_medical -1 "Not reported", add
label values medical label_medical
cap label define label_medical -2 "Not applicable", add
label values medical label_medical
cap label define label_tribal 1 "Yes"
label values tribal label_tribal
cap label define label_tribal 2 "No", add
label values tribal label_tribal
cap label define label_tribal -3 "{Not available}", add
label values tribal label_tribal
cap label define label_locale 11 "City: Large"
label values locale label_locale
cap label define label_locale 12 "City: Midsize", add
label values locale label_locale
cap label define label_locale 13 "City: Small", add
label values locale label_locale
cap label define label_locale 21 "Suburb: Large", add
label values locale label_locale
cap label define label_locale 22 "Suburb: Midsize", add
label values locale label_locale
cap label define label_locale 23 "Suburb: Small", add
label values locale label_locale
cap label define label_locale 31 "Town: Fringe", add
label values locale label_locale
cap label define label_locale 32 "Town: Distant", add
label values locale label_locale
cap label define label_locale 33 "Town: Remote", add
label values locale label_locale
cap label define label_locale 41 "Rural: Fringe", add
label values locale label_locale
cap label define label_locale 42 "Rural: Distant", add
label values locale label_locale
cap label define label_locale 43 "Rural: Remote", add
label values locale label_locale
cap label define label_locale -3 "{Not available}", add
label values locale label_locale
cap label define label_openpubl 1 "Institution is open to the public"
label values openpubl label_openpubl
cap label define label_openpubl 0 "Institution is not open to the public", add
label values openpubl label_openpubl
/* cap label define label_act A "Active - institution active and not an add"
label values act label_act
cap label define label_act C "Combined with other institution", add
label values act label_act
cap label define label_act D "Delete out of business", add
label values act label_act
cap label define label_act M "Death with data - closed in current yr", add
label values act label_act
cap label define label_act N "New - added during the current year", add
label values act label_act
cap label define label_act P "Potential new/add institution", add
label values act label_act
cap label define label_act Q "Potential restore institution", add
label values act label_act
cap label define label_act R "Restore - restored to the current universe", add
label values act label_act
cap label define label_act W "Potential add not within scope of IPEDS", add
label values act label_act
cap label define label_act X "Potential restore not within scope of IPEDS", add
label values act label_act
 */
cap label define label_deathyr -2 "Not applicable"
label values deathyr label_deathyr
cap label define label_deathyr 2005 "2005", add
label values deathyr label_deathyr
cap label define label_cyactive 1 "Yes"
label values cyactive label_cyactive
cap label define label_cyactive 2 "No, potential add or restore", add
label values cyactive label_cyactive
cap label define label_cyactive 3 "No, closed, combined, or out-of-scope", add
label values cyactive label_cyactive
cap label define label_postsec 1 "Primarily postsecondary institution"
label values postsec label_postsec
cap label define label_postsec 2 "Not primarily postsecondary", add
label values postsec label_postsec
cap label define label_pseflag 1 "Active postsecondary institution"
label values pseflag label_pseflag
cap label define label_pseflag 2 "Not primarily postsecondary or open to public", add
label values pseflag label_pseflag
cap label define label_pseflag 3 "Not active", add
label values pseflag label_pseflag
cap label define label_pset4flg 1 "Title IV postsecondary institution"
label values pset4flg label_pset4flg
cap label define label_pset4flg 2 "Non-Title IV postsecondary institution", add
label values pset4flg label_pset4flg
cap label define label_pset4flg 3 "Title IV NOT primarily postsecondary institution", add
label values pset4flg label_pset4flg
cap label define label_pset4flg 4 "Non-Title IV NOT primarily postsecondary institution", add
label values pset4flg label_pset4flg
cap label define label_pset4flg 6 "Non-Title IV postsecondary institution that is NOT open to the public", add
label values pset4flg label_pset4flg
cap label define label_pset4flg 9 "Institution is not active in current universe", add
label values pset4flg label_pset4flg
cap label define label_rptmth 1 "Academic year"
label values rptmth label_rptmth
cap label define label_rptmth 2 "Reports by program", add
label values rptmth label_rptmth
cap label define label_rptmth -1 "Not reported", add
label values rptmth label_rptmth
cap label define label_rptmth -2 "Not applicable", add
label values rptmth label_rptmth
cap label define label_carnegie 15 "Doctoral/Research Universities--Extensive"
label values carnegie label_carnegie
cap label define label_carnegie 16 "Doctoral/Research Universities--Intensive", add
label values carnegie label_carnegie
cap label define label_carnegie 21 "Masters Colleges and Universities I", add
label values carnegie label_carnegie
cap label define label_carnegie 22 "Masters Colleges and Universities II", add
label values carnegie label_carnegie
cap label define label_carnegie 31 "Baccalaureate Colleges--Liberal Arts", add
label values carnegie label_carnegie
cap label define label_carnegie 32 "Baccalaureate Colleges--General", add
label values carnegie label_carnegie
cap label define label_carnegie 33 "Baccalaureate/Associates Colleges", add
label values carnegie label_carnegie
cap label define label_carnegie 40 "Associates Colleges", add
label values carnegie label_carnegie
cap label define label_carnegie 51 "Theological seminaries and other specialized faith-related institutions", add
label values carnegie label_carnegie
cap label define label_carnegie 52 "Medical schools and medical centers", add
label values carnegie label_carnegie
cap label define label_carnegie 53 "Other separate health profession schools", add
label values carnegie label_carnegie
cap label define label_carnegie 54 "Schools of engineering and technology", add
label values carnegie label_carnegie
cap label define label_carnegie 55 "Schools of business and management", add
label values carnegie label_carnegie
cap label define label_carnegie 56 "Schools of art, music, and design", add
label values carnegie label_carnegie
cap label define label_carnegie 57 "Schools of law", add
label values carnegie label_carnegie
cap label define label_carnegie 58 "Teachers colleges", add
label values carnegie label_carnegie
cap label define label_carnegie 59 "Other specialized institutions", add
label values carnegie label_carnegie
cap label define label_carnegie 60 "Tribal colleges", add
label values carnegie label_carnegie
cap label define label_carnegie -3 "{Item not available}", add
label values carnegie label_carnegie
cap label define label_lock_ic 0 "No data"
label values lock_ic label_lock_ic
cap label define label_lock_ic 1 "Has entered  data", add
label values lock_ic label_lock_ic
cap label define label_lock_ic 8 "Complete, final lock applied", add
label values lock_ic label_lock_ic
cap label define label_lock_ic -2 "Not applicable", add
label values lock_ic label_lock_ic
cap label define label_stat_ic 1 "Respondent"
label values stat_ic label_stat_ic
cap label define label_stat_ic 4 "Nonrespondent, imputed", add
label values stat_ic label_stat_ic
cap label define label_stat_ic 6 "Nonrespondent, submitted a MINI IC in winter or spring", add
label values stat_ic label_stat_ic
cap label define label_stat_ic 5 "Nonrespondent, not imputed", add
label values stat_ic label_stat_ic
cap label define label_stat_ic -8 "Not active-hurricane related problems", add
label values stat_ic label_stat_ic
cap label define label_stat_ic -9 "Not active", add
label values stat_ic label_stat_ic
/* cap label define label_stabbr AL "Alabama"
label values stabbr label_stabbr
cap label define label_stabbr AK "Alaska", add
label values stabbr label_stabbr
cap label define label_stabbr AZ "Arizona", add
label values stabbr label_stabbr
cap label define label_stabbr AR "Arkansas", add
label values stabbr label_stabbr
cap label define label_stabbr CA "California", add
label values stabbr label_stabbr
cap label define label_stabbr CO "Colorado", add
label values stabbr label_stabbr
cap label define label_stabbr CT "Connecticut", add
label values stabbr label_stabbr
cap label define label_stabbr DE "Delaware", add
label values stabbr label_stabbr
cap label define label_stabbr DC "District of Columbia", add
label values stabbr label_stabbr
cap label define label_stabbr FL "Florida", add
label values stabbr label_stabbr
cap label define label_stabbr GA "Georgia", add
label values stabbr label_stabbr
cap label define label_stabbr HI "Hawaii", add
label values stabbr label_stabbr
cap label define label_stabbr ID "Idaho", add
label values stabbr label_stabbr
cap label define label_stabbr IL "Illinois", add
label values stabbr label_stabbr
cap label define label_stabbr IN "Indiana", add
label values stabbr label_stabbr
cap label define label_stabbr IA "Iowa", add
label values stabbr label_stabbr
cap label define label_stabbr KS "Kansas", add
label values stabbr label_stabbr
cap label define label_stabbr KY "Kentucky", add
label values stabbr label_stabbr
cap label define label_stabbr LA "Louisiana", add
label values stabbr label_stabbr
cap label define label_stabbr ME "Maine", add
label values stabbr label_stabbr
cap label define label_stabbr MD "Maryland", add
label values stabbr label_stabbr
cap label define label_stabbr MA "Massachusetts", add
label values stabbr label_stabbr
cap label define label_stabbr MI "Michigan", add
label values stabbr label_stabbr
cap label define label_stabbr MN "Minnesota", add
label values stabbr label_stabbr
cap label define label_stabbr MS "Mississippi", add
label values stabbr label_stabbr
cap label define label_stabbr MO "Missouri", add
label values stabbr label_stabbr
cap label define label_stabbr MT "Montana", add
label values stabbr label_stabbr
cap label define label_stabbr NE "Nebraska", add
label values stabbr label_stabbr
cap label define label_stabbr NV "Nevada", add
label values stabbr label_stabbr
cap label define label_stabbr NH "New Hampshire", add
label values stabbr label_stabbr
cap label define label_stabbr NJ "New Jersey", add
label values stabbr label_stabbr
cap label define label_stabbr NM "New Mexico", add
label values stabbr label_stabbr
cap label define label_stabbr NY "New York", add
label values stabbr label_stabbr
cap label define label_stabbr NC "North Carolina", add
label values stabbr label_stabbr
cap label define label_stabbr ND "North Dakota", add
label values stabbr label_stabbr
cap label define label_stabbr OH "Ohio", add
label values stabbr label_stabbr
cap label define label_stabbr OK "Oklahoma", add
label values stabbr label_stabbr
cap label define label_stabbr OR "Oregon", add
label values stabbr label_stabbr
cap label define label_stabbr PA "Pennsylvania", add
label values stabbr label_stabbr
cap label define label_stabbr RI "Rhode Island", add
label values stabbr label_stabbr
cap label define label_stabbr SC "South Carolina", add
label values stabbr label_stabbr
cap label define label_stabbr SD "South Dakota", add
label values stabbr label_stabbr
cap label define label_stabbr TN "Tennessee", add
label values stabbr label_stabbr
cap label define label_stabbr TX "Texas", add
label values stabbr label_stabbr
cap label define label_stabbr UT "Utah", add
label values stabbr label_stabbr
cap label define label_stabbr VT "Vermont", add
label values stabbr label_stabbr
cap label define label_stabbr VA "Virginia", add
label values stabbr label_stabbr
cap label define label_stabbr WA "Washington", add
label values stabbr label_stabbr
cap label define label_stabbr WV "West Virginia", add
label values stabbr label_stabbr
cap label define label_stabbr WI "Wisconsin", add
label values stabbr label_stabbr
cap label define label_stabbr WY "Wyoming", add
label values stabbr label_stabbr
cap label define label_stabbr AS "American Samoa", add
label values stabbr label_stabbr
cap label define label_stabbr FM "Federated States of Micronesia", add
label values stabbr label_stabbr
cap label define label_stabbr GU "Guam", add
label values stabbr label_stabbr
cap label define label_stabbr MH "Marshall Islands", add
label values stabbr label_stabbr
cap label define label_stabbr MP "Northern Marianas", add
label values stabbr label_stabbr
cap label define label_stabbr PW "Palau", add
label values stabbr label_stabbr
cap label define label_stabbr PR "Puerto Rico", add
label values stabbr label_stabbr
cap label define label_stabbr VI "Virgin Islands", add
label values stabbr label_stabbr
 */
cap label define label_fips 1 "Alabama"
label values fips label_fips
cap label define label_fips 2 "Alaska", add
label values fips label_fips
cap label define label_fips 4 "Arizona", add
label values fips label_fips
cap label define label_fips 5 "Arkansas", add
label values fips label_fips
cap label define label_fips 6 "California", add
label values fips label_fips
cap label define label_fips 8 "Colorado", add
label values fips label_fips
cap label define label_fips 9 "Connecticut", add
label values fips label_fips
cap label define label_fips 10 "Delaware", add
label values fips label_fips
cap label define label_fips 11 "District of Columbia", add
label values fips label_fips
cap label define label_fips 12 "Florida", add
label values fips label_fips
cap label define label_fips 13 "Georgia", add
label values fips label_fips
cap label define label_fips 15 "Hawaii", add
label values fips label_fips
cap label define label_fips 16 "Idaho", add
label values fips label_fips
cap label define label_fips 17 "Illinois", add
label values fips label_fips
cap label define label_fips 18 "Indiana", add
label values fips label_fips
cap label define label_fips 19 "Iowa", add
label values fips label_fips
cap label define label_fips 20 "Kansas", add
label values fips label_fips
cap label define label_fips 21 "Kentucky", add
label values fips label_fips
cap label define label_fips 22 "Louisiana", add
label values fips label_fips
cap label define label_fips 23 "Maine", add
label values fips label_fips
cap label define label_fips 24 "Maryland", add
label values fips label_fips
cap label define label_fips 25 "Massachusetts", add
label values fips label_fips
cap label define label_fips 26 "Michigan", add
label values fips label_fips
cap label define label_fips 27 "Minnesota", add
label values fips label_fips
cap label define label_fips 28 "Mississippi", add
label values fips label_fips
cap label define label_fips 29 "Missouri", add
label values fips label_fips
cap label define label_fips 30 "Montana", add
label values fips label_fips
cap label define label_fips 31 "Nebraska", add
label values fips label_fips
cap label define label_fips 32 "Nevada", add
label values fips label_fips
cap label define label_fips 33 "New Hampshire", add
label values fips label_fips
cap label define label_fips 34 "New Jersey", add
label values fips label_fips
cap label define label_fips 35 "New Mexico", add
label values fips label_fips
cap label define label_fips 36 "New York", add
label values fips label_fips
cap label define label_fips 37 "North Carolina", add
label values fips label_fips
cap label define label_fips 38 "North Dakota", add
label values fips label_fips
cap label define label_fips 39 "Ohio", add
label values fips label_fips
cap label define label_fips 40 "Oklahoma", add
label values fips label_fips
cap label define label_fips 41 "Oregon", add
label values fips label_fips
cap label define label_fips 42 "Pennsylvania", add
label values fips label_fips
cap label define label_fips 44 "Rhode Island", add
label values fips label_fips
cap label define label_fips 45 "South Carolina", add
label values fips label_fips
cap label define label_fips 46 "South Dakota", add
label values fips label_fips
cap label define label_fips 47 "Tennessee", add
label values fips label_fips
cap label define label_fips 48 "Texas", add
label values fips label_fips
cap label define label_fips 49 "Utah", add
label values fips label_fips
cap label define label_fips 50 "Vermont", add
label values fips label_fips
cap label define label_fips 51 "Virginia", add
label values fips label_fips
cap label define label_fips 53 "Washington", add
label values fips label_fips
cap label define label_fips 54 "West Virginia", add
label values fips label_fips
cap label define label_fips 55 "Wisconsin", add
label values fips label_fips
cap label define label_fips 56 "Wyoming", add
label values fips label_fips
cap label define label_fips 60 "American Samoa", add
label values fips label_fips
cap label define label_fips 64 "Federated States of Micronesia", add
label values fips label_fips
cap label define label_fips 66 "Guam", add
label values fips label_fips
cap label define label_fips 68 "Marshall Islands", add
label values fips label_fips
cap label define label_fips 69 "Northern Marianas", add
label values fips label_fips
cap label define label_fips 70 "Palau", add
label values fips label_fips
cap label define label_fips 72 "Puerto Rico", add
label values fips label_fips
cap label define label_fips 78 "Virgin Islands", add
label values fips label_fips
cap label define label_obereg 0 "US Service schools"
label values obereg label_obereg
cap label define label_obereg 1 "New England CT ME MA NH RI VT", add
label values obereg label_obereg
cap label define label_obereg 2 "Mid East DE DC MD NJ NY PA", add
label values obereg label_obereg
cap label define label_obereg 3 "Great Lakes IL IN MI OH WI", add
label values obereg label_obereg
cap label define label_obereg 4 "Plains IA KS MN MO NE ND SD", add
label values obereg label_obereg
cap label define label_obereg 5 "Southeast AL AR FL GA KY LA MS NC SC TN VA WV", add
label values obereg label_obereg
cap label define label_obereg 6 "Southwest AZ NM OK TX", add
label values obereg label_obereg
cap label define label_obereg 7 "Rocky Mountains CO ID MT UT WY", add
label values obereg label_obereg
cap label define label_obereg 8 "Far West AK CA HI NV OR WA", add
label values obereg label_obereg
cap label define label_obereg 9 "Outlying areas AS FM GU MH MP PR PW VI", add
label values obereg label_obereg
cap label define label_instsize 1 "Under 1,000"
label values instsize label_instsize
cap label define label_instsize 2 "1,000 - 4,999", add
label values instsize label_instsize
cap label define label_instsize 3 "5,000 - 9,999", add
label values instsize label_instsize
cap label define label_instsize 4 "10,000 - 19,999", add
label values instsize label_instsize
cap label define label_instsize 5 "20,000 and above", add
label values instsize label_instsize
cap label define label_instsize -1 "Not reported", add
label values instsize label_instsize
cap label define label_instsize -2 "Not applicable", add
label values instsize label_instsize
cap label define label_sector 0 "Administrative Unit"
label values sector label_sector
cap label define label_sector 1 "Public, 4-year or above", add
label values sector label_sector
cap label define label_sector 2 "Private not-for-profit, 4-year or above", add
label values sector label_sector
cap label define label_sector 3 "Private for-profit, 4-year or above", add
label values sector label_sector
cap label define label_sector 4 "Public, 2-year", add
label values sector label_sector
cap label define label_sector 5 "Private not-for-profit, 2-year", add
label values sector label_sector
cap label define label_sector 6 "Private for-profit, 2-year", add
label values sector label_sector
cap label define label_sector 7 "Public, less-than 2-year", add
label values sector label_sector
cap label define label_sector 8 "Private not-for-profit, less-than 2-year", add
label values sector label_sector
cap label define label_sector 9 "Private for-profit, less-than 2-year", add
label values sector label_sector
cap label define label_sector 99 "Sector unknown (not active)", add
label values sector label_sector
cap label define label_iclevel 1 "Four or more years"
label values iclevel label_iclevel
cap label define label_iclevel 2 "At least 2 but less than 4 years", add
label values iclevel label_iclevel
cap label define label_iclevel 3 "Less than 2 years (below associate)", add
label values iclevel label_iclevel
cap label define label_iclevel -3 "{Not available}", add
label values iclevel label_iclevel
cap label define label_control 1 "Public"
label values control label_control
cap label define label_control 2 "Private not-for-profit", add
label values control label_control
cap label define label_control 3 "Private for-profit", add
label values control label_control
cap label define label_control -3 "{Not available}", add
label values control label_control
cap label define label_tenursys 1 "Has tenure system"
label values tenursys label_tenursys
cap label define label_tenursys 0 "No tenure system", add
label values tenursys label_tenursys
cap label define label_tenursys -1 "Not reported", add
label values tenursys label_tenursys
cap label define label_tenursys -2 "Not applicable", add
label values tenursys label_tenursys
cap label define label_deggrant 1 "Degree-granting"
label values deggrant label_deggrant
cap label define label_deggrant 2 "Nondegree-granting, primarily postsecondary", add
label values deggrant label_deggrant
cap label define label_deggrant -3 "{Not available}", add
label values deggrant label_deggrant
cap label define label_hbcu 1 "Yes"
label values hbcu label_hbcu
cap label define label_hbcu 2 "No", add
label values hbcu label_hbcu
cap label define label_hbcu -3 "{Not available}", add
label values hbcu label_hbcu
cap label define label_tribal 1 "Yes"
label values tribal label_tribal
cap label define label_tribal 2 "No", add
label values tribal label_tribal
cap label define label_tribal -3 "{Not available}", add
label values tribal label_tribal
cap label define label_locale 11 "City: Large"
label values locale label_locale
cap label define label_locale 12 "City: Midsize", add
label values locale label_locale
cap label define label_locale 13 "City: Small", add
label values locale label_locale
cap label define label_locale 21 "Suburb: Large", add
label values locale label_locale
cap label define label_locale 22 "Suburb: Midsize", add
label values locale label_locale
cap label define label_locale 23 "Suburb: Small", add
label values locale label_locale
cap label define label_locale 31 "Town: Fringe", add
label values locale label_locale
cap label define label_locale 32 "Town: Distant", add
label values locale label_locale
cap label define label_locale 33 "Town: Remote", add
label values locale label_locale
cap label define label_locale 41 "Rural: Fringe", add
label values locale label_locale
cap label define label_locale 42 "Rural: Distant", add
label values locale label_locale
cap label define label_locale 43 "Rural: Remote", add
label values locale label_locale
cap label define label_locale -3 "{Not available}", add
label values locale label_locale
cap label define label_pset4flg 1 "Title IV postsecondary institution"
label values pset4flg label_pset4flg
cap label define label_pset4flg 2 "Non-Title IV postsecondary institution", add
label values pset4flg label_pset4flg
cap label define label_pset4flg 3 "Title IV NOT primarily postsecondary institution", add
label values pset4flg label_pset4flg
cap label define label_pset4flg 4 "Non-Title IV NOT primarily postsecondary institution", add
label values pset4flg label_pset4flg
cap label define label_pset4flg 6 "Non-Title IV postsecondary institution that is NOT open to the public", add
label values pset4flg label_pset4flg
cap label define label_pset4flg 9 "Institution is not active in current universe", add
label values pset4flg label_pset4flg
cap label define label_instcat 1 "Degree-granting, graduate with no undergraduate degrees"
label values instcat label_instcat
cap label define label_instcat 2 "Degree-granting, primarily baccalaureate or above", add
label values instcat label_instcat
cap label define label_instcat 3 "Degree-granting, other baccalaureate granting", add
label values instcat label_instcat
cap label define label_instcat 4 "Degree-granting, associate''s and certificates", add
label values instcat label_instcat
cap label define label_instcat 5 "Nondegree-granting, above the baccalaureate", add
label values instcat label_instcat
cap label define label_instcat 6 "Nondegree-granting, sub-baccalaureate", add
label values instcat label_instcat
cap label define label_instcat -1 "Not reported", add
label values instcat label_instcat
cap label define label_instcat -2 "Not applicable", add
label values instcat label_instcat
cap label define label_ccbasic 1 "Associate''s--Public Rural-serving Small"
label values ccbasic label_ccbasic
cap label define label_ccbasic 2 "Associate''s--Public Rural-serving Medium", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 3 "Associate''s--Public Rural-serving Large", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 4 "Associate''s--Public Suburban-serving Single Campus", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 5 "Associate''s--Public Suburban-serving Multicampus", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 6 "Associate''s--Public Urban-serving Single Campus", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 7 "Associate''s--Public Urban-serving Multicampus", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 8 "Associate''s--Public Special Use", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 9 "Associate''s--Private Not-for-profit", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 10 "Associate''s--Private For-profit", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 11 "Associate''s--Public 2-year colleges under 4-year universities", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 12 "Associate''s--Public 4-year Primarily Associate''s", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 13 "Associate''s--Private Not-for-profit 4-year Primarily Associate''s", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 14 "Associate''s--Private For-profit 4-year Primarily Associate''s", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 15 "Research Universities (very high research activity)", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 16 "Research Universities (high research activity)", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 17 "Doctoral/Research Universities", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 18 "Master''s Colleges and Universities (larger programs)", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 19 "Master''s Colleges and Universities (medium programs)", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 20 "Master''s Colleges and Universities (smaller programs)", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 21 "Baccalaureate Colleges--Arts & Sciences", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 22 "Baccalaureate Colleges--Diverse Fields", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 23 "Baccalaureate/Associate''s Colleges", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 24 "Special Focus Institutions--Theological seminaries, Bible colleges, and other faith-related institutions", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 25 "Special Focus Institutions--Medical schools and medical centers", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 26 "Special Focus Institutions--Other health professions schools", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 27 "Special Focus Institutions--Schools of engineering", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 28 "Special Focus Institutions--Other technology-related schools", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 29 "Special Focus Institutions--Schools of business and management", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 30 "Special Focus Institutions--Schools of art, music, and design", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 31 "Special Focus Institutions--Schools of law", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 32 "Special Focus Institutions--Other special-focus institutions", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 33 "Tribal Colleges", add
label values ccbasic label_ccbasic
cap label define label_ccbasic 0 "Not classified", add
label values ccbasic label_ccbasic
cap label define label_ccbasic -3 "Not applicable, not in Carnegie universe (not accredited or nondegree-granting)", add
label values ccbasic label_ccbasic
cap label define label_ccipug 1 "Associates"
label values ccipug label_ccipug
cap label define label_ccipug 2 "Associates Dominant", add
label values ccipug label_ccipug
cap label define label_ccipug 3 "Arts & sciences focus, no graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 4 "Arts & sciences focus, some graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 5 "Arts & sciences focus, high graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 6 "Arts & sciences plus professions, no graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 7 "Arts & sciences plus professions, some graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 8 "Arts & sciences plus professions, high graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 9 "Balanced arts & sciences/professions, no graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 10 "Balanced arts & sciences/professions, some graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 11 "Balanced arts & sciences/professions, high graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 12 "Professions plus arts & sciences, no graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 13 "Professions plus arts & sciences, some graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 14 "Professions plus arts & sciences, high graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 15 "Professions focus, no graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 16 "Professions focus, some graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 17 "Professions focus, high graduate coexistence", add
label values ccipug label_ccipug
cap label define label_ccipug 0 "Not classified", add
label values ccipug label_ccipug
cap label define label_ccipug -1 "Not applicable, graduate institution", add
label values ccipug label_ccipug
cap label define label_ccipug -2 "Not applicable, special focus institution", add
label values ccipug label_ccipug
cap label define label_ccipug -3 "Not applicable, not in Carnegie universe (not accredited or nondegree-granting)", add
label values ccipug label_ccipug
cap label define label_ccipgrad 1 "Single postbaccalaureate (education)"
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 2 "Single postbaccalaureate (business)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 3 "Single postbaccalaureate (other field)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 4 "Postbaccalaureate comprehensive", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 5 "Postbaccalaureate, arts & sciences dominant", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 6 "Postbaccalaureate with arts & sciences (education dominant)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 7 "Postbaccalaureate with arts & sciences (business dominant)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 8 "Postbaccalaureate with arts & sciences (other dominant fields)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 9 "Postbaccalaureate professional (education dominant)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 10 "Postbaccalaureate professional (business dominant)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 11 "Postbaccalaureate professional (other dominant fields)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 12 "Single doctoral (education)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 13 "Single doctoral (other field)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 14 "Comprehensive doctoral with medical/veterinary", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 15 "Comprehensive doctoral (no medical/veterinary)", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 16 "Doctoral, humanities/social sciences dominant", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 17 "STEM dominant", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 18 "Doctoral, professional dominant", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad 0 "Not classified", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad -1 "Not applicable", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad -2 "Not applicable, special focus institution", add
label values ccipgrad label_ccipgrad
cap label define label_ccipgrad -3 "Not applicable, not in Carnegie universe (not accredited or nondegree-granting)", add
label values ccipgrad label_ccipgrad
cap label define label_ccugprof 1 "Higher part-time two-year"
label values ccugprof label_ccugprof
cap label define label_ccugprof 2 "Mixed part/full-time two-year", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 3 "Medium full-time two-year", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 4 "Higher full-time two-year", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 5 "Higher part-time four-year", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 6 "Medium full-time four-year, inclusive", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 7 "Medium full-time four-year, selective, lower transfer-in", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 8 "Medium full-time four-year, selective, higher transfer-in", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 9 "Full-time four-year, inclusive", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 10 "Full-time four-year, selective, lower transfer-in", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 11 "Full-time four-year, selective, higher transfer-in", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 12 "Full-time four-year, more selective, lower transfer-in", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 13 "Full-time four-year, more selective, higher transfer-in", add
label values ccugprof label_ccugprof
cap label define label_ccugprof 0 "Not classified", add
label values ccugprof label_ccugprof
cap label define label_ccugprof -1 "Not applicable", add
label values ccugprof label_ccugprof
cap label define label_ccugprof -2 "Not applicable, special focus institution", add
label values ccugprof label_ccugprof
cap label define label_ccugprof -3 "Not applicable, not in Carnegie universe (not accredited or nondegree-granting)", add
label values ccugprof label_ccugprof
cap label define label_ccenrprf 1 "Exclusively undergraduate two-year"
label values ccenrprf label_ccenrprf
cap label define label_ccenrprf 2 "Exclusively undergraduate four-year", add
label values ccenrprf label_ccenrprf
cap label define label_ccenrprf 3 "Very high undergraduate", add
label values ccenrprf label_ccenrprf
cap label define label_ccenrprf 4 "High undergraduate", add
label values ccenrprf label_ccenrprf
cap label define label_ccenrprf 5 "Majority undergraduate", add
label values ccenrprf label_ccenrprf
cap label define label_ccenrprf 6 "Majority graduate/professional", add
label values ccenrprf label_ccenrprf
cap label define label_ccenrprf 7 "Exclusively graduate/professional", add
label values ccenrprf label_ccenrprf
cap label define label_ccenrprf 0 "Not classified", add
label values ccenrprf label_ccenrprf
cap label define label_ccenrprf -3 "Not applicable, not in Carnegie universe (not accredited or nondegree-granting)", add
label values ccenrprf label_ccenrprf
cap label define label_ccsizset 1 "Very small two-year"
label values ccsizset label_ccsizset
cap label define label_ccsizset 2 "Small two-year", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 3 "Medium two-year", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 4 "Large two-year", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 5 "Very large two-year", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 6 "Very small four-year, primarily nonresidential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 7 "Very small four-year, primarily residential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 8 "Very small four-year, highly residential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 9 "Small four-year, primarily nonresidential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 10 "Small four-year, primarily residential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 11 "Small four-year, highly residential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 12 "Medium four-year, primarily nonresidential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 13 "Medium four-year, primarily residential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 14 "Medium four-year, highly residential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 15 "Large four-year, primarily nonresidential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 16 "Large four-year, primarily residential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 17 "Large four-year, highly residential", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 18 "Exclusively graduate/professional", add
label values ccsizset label_ccsizset
cap label define label_ccsizset 0 "Not classified", add
label values ccsizset label_ccsizset
cap label define label_ccsizset -2 "Not applicable, special focus institution", add
label values ccsizset label_ccsizset
cap label define label_ccsizset -3 "Not applicable, not in Carnegie universe (not accredited or nondegree-granting)", add
label values ccsizset label_ccsizset
cap label define label_landgrnt 1 "Land Grant Institution"
label values landgrnt label_landgrnt
cap label define label_landgrnt 0 "Not a Land Grant Institution", add
label values landgrnt label_landgrnt
cap label define label_carnegie 15 "Doctoral/Research Universities--Extensive"
label values carnegie label_carnegie
cap label define label_carnegie 16 "Doctoral/Research Universities--Intensive", add
label values carnegie label_carnegie
cap label define label_carnegie 21 "Masters Colleges and Universities I", add
label values carnegie label_carnegie
cap label define label_carnegie 22 "Masters Colleges and Universities II", add
label values carnegie label_carnegie
cap label define label_carnegie 31 "Baccalaureate Colleges--Liberal Arts", add
label values carnegie label_carnegie
cap label define label_carnegie 32 "Baccalaureate Colleges--General", add
label values carnegie label_carnegie
cap label define label_carnegie 33 "Baccalaureate/Associates Colleges", add
label values carnegie label_carnegie
cap label define label_carnegie 40 "Associates Colleges", add
label values carnegie label_carnegie
cap label define label_carnegie 51 "Theological seminaries and other specialized faith-related institutions", add
label values carnegie label_carnegie
cap label define label_carnegie 52 "Medical schools and medical centers", add
label values carnegie label_carnegie
cap label define label_carnegie 53 "Other separate health profession schools", add
label values carnegie label_carnegie
cap label define label_carnegie 54 "Schools of engineering and technology", add
label values carnegie label_carnegie
cap label define label_carnegie 55 "Schools of business and management", add
label values carnegie label_carnegie
cap label define label_carnegie 56 "Schools of art, music, and design", add
label values carnegie label_carnegie
cap label define label_carnegie 57 "Schools of law", add
label values carnegie label_carnegie
cap label define label_carnegie 58 "Teachers colleges", add
label values carnegie label_carnegie
cap label define label_carnegie 59 "Other specialized institutions", add
label values carnegie label_carnegie
cap label define label_carnegie 60 "Tribal colleges", add
label values carnegie label_carnegie
cap label define label_carnegie -3 "{Item not available}", add
label values carnegie label_carnegie
cap label define label_dfrcgid 1 "4-yr, Associate of Arts Colleges, public"
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 2 "4-yr, Associate of Arts Colleges, not-for-profit", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 3 "4-yr, Associate of Arts Colleges, for-profit, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 4 "4-yr, Associate of Arts Colleges, for-profit, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 5 "4-yr, Associate of Arts Colleges, for-profit, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 6 "4-yr, Associate of Arts Colleges, for-profit, size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 7 "Tribal Colleges and universities", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 8 "4 yr, Puerto Rico, public", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 9 "4 yr, Puerto Rico, not-for-profit", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 10 "4 yr, Puerto Rico, for-profit", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 11 "2 yr, Puerto Rico", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 12 "<2 yr, Puerto Rico, not-for-profit", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 13 "<2 yr, Puerto Rico, for-profit, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 14 "<2 yr, Puerto Rico, for-profit, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 15 "Graduate-only degree-granting not-for-profit, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 16 "Graduate-only degree-granting not-for-profit, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 17 "Public 4 yr Doctoral/Research Extensive (>100 million research expenses) size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 18 "Public 4 yr Doctoral/Research Extensive (>100 million research expenses) size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 19 "Public 4 yr Doctoral/Research Extensive (<100 million research expenses", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 20 "Public 4 yr Doctoral/Research Intensive size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 21 "Public 4 yr Doctoral/Research Intensive size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 22 "Public 4 yr Masters Colleges and Universities 1, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 23 "Public 4 yr Masters Colleges and Universities 1, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 24 "Public 4 yr Masters Colleges and Universities 1, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 25 "Public 4 yr Masters Colleges and Universities 1, size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 26 "Public 4 yr Masters Colleges and Universities 1, size 5", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 27 "Public 4 yr Masters Colleges and Universities 1, size 6", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 28 "Public 4 yr Masters Colleges and Universities 1, size 7", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 29 "Public 4 yr Masters Colleges and Universities 1, size 8", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 30 "Public 4 yr degree-granting Medical Schools and Centers", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 31 "Public 4 yr Masters II,Other Specialiized, or awards masters size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 32 "Public 4 yr Masters II,Other Specialiized, or awards masters size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 33 "Public 4 yr,Baccalaureate(Liberal Arts/General/Assoc) or Art,music, and design, Teachers College size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 34 "Public 4 yr,Baccalaureate(Liberal Arts/General/Assoc) or Art,music, and design, Teachers College size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 35 "Public 4 yr,Baccalaureate(Liberal Arts/General/Assoc) or Art,music, and design, Teachers College size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 36 "Graduate-only, degree-granting, for-profit", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 37 "Graduate-only, degree-granting, public", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 38 "Graduate-only, degree-granting, law school", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 39 "Graduate only, degree-granting, not-for-profit health/medical size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 40 "Graduate only, degree-granting, not-for-profit health/medical size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 41 "Graduate-only, degree-granting, not-for-profit, theological seminary, Northeast", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 42 "Graduate-only, degree-granting, not-for-profit, theological seminary, South", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 43 "Graduate-only, degree-granting, not-for-profit, theological seminary, Midwest", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 44 "Graduate-only, degree-granting, not-for-profit, theological seminary, West", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 45 "Not-for-profit, 4 yr, Doctoral/Research Extensive size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 46 "Not-for-profit, 4 yr, Doctoral/Research Extensive size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 47 "Not-for-profit, 4 yr, Doctoral/Research Intensive size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 48 "Not-for-profit, 4 yr, Doctoral/Research Intensive size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 49 "Not-for-profit  4 yr, Masters Colleges and Universities I, New England", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 50 "Not-for-profit  4 yr, Masters Colleges and Universities I, Mid East size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 51 "Not-for-profit  4 yr, Masters Colleges and Universities I, Mid East size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 52 "Not-for-profit 4 yr, Masters Colleges and Universities I, Great Lakes", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 53 "Not-for-profit 4 yr, Masters Colleges and Universities I, Plains", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 54 "Not-for-profit 4 yr, Masters Colleges and Universities I, Southeast", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 55 "Not-for-profit 4 yr, Masters Colleges and Universities I, Southwest, Rocky Mountains, Far West, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 56 "Not-for-profit 4 yr, Masters Colleges and Universities I, Southwest, Rocky Mountains, Far West, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 57 "Not-for-profit 4 yr Masters Colleges and Universities II size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 58 "Not-for-profit 4 yr Masters Colleges and Universities II size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 59 "Not-for-profit 4 yr Masters Colleges and Universities II size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 60 "Not-for-profit, 4 yr, Other Masters Universities", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 61 "Not-for-profit 4 yr, Baccalaureate Colleges - Liberal Arts, New England", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 62 "Not-for-profit 4 yr, Baccalaureate Colleges - Liberal Arts, Mid East", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 63 "Not-for-profit 4 yr, Baccalaureate Colleges - Liberal Arts, Great Lakes", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 64 "Not-for-profit 4 yr, Baccalaureate Colleges - Liberal Arts, Plains", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 65 "Not-for-profit 4 yr, Baccalaureate Colleges - Liberal Arts, Southeast, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 66 "Not-for-profit 4 yr, Baccalaureate Colleges - Liberal Arts, Southeast, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 67 "Not-for-profit 4 yr, Baccalaureate Colleges - Liberal Arts, Southwest, Rocky Mountains, Far West", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 68 "Not-for-profit 4 yr, Baccalaureate Colleges - General, New England", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 69 "Not-for-profit 4 yr, Baccalaureate Colleges - General, Mid East", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 70 "Not-for-profit 4 yr, Baccalaureate Colleges - General, Great Lakes", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 71 "Not-for-profit 4 yr, Baccalaureate Colleges - General, Plains", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 72 "Not-for-profit 4 yr, Baccalaureate Colleges - General, Southeast, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 73 "Not-for-profit 4 yr, Baccalaureate Colleges - General, Southeast, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 74 "Not-for-profit 4 yr, Baccalaureate Colleges - General, Southeast, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 75 "Not-for-profit 4 yr, Baccalaureate Colleges - General, Southwest, Rocky Mountains, Far West", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 76 "Not-for-profit 4 yr, Baccalaureate/Associates Colleges", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 77 "Not-for-profit 4 yr, Other Baccalaureate Colleges", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 78 "Not-for-profit 4 yr, Seminaries and Bible Colleges, New England, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 79 "Not-for-profit 4 yr, Seminaries and Bible Colleges, New England, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 80 "Not-for-profit 4 yr, Seminaries and Bible Colleges, Great Lakes", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 81 "Not-for-profit 4 yr, Seminaries and Bible Colleges, Plains", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 82 "Not-for-profit 4 yr, Seminaries and Bible Colleges, Southeast", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 83 "Not-for-profit 4 yr, Seminaries and Bible Colleges, Southwest, Rocky Mountains, Far West", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 84 "Not-for-profit 4 yr, Medical Schools and Centers, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 85 "Not-for-profit 4 yr, Medical Schools and Centers, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 86 "Not-for-profit 4 yr, Schools of Engineering and Technology", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 87 "Not-for-profit 4 yr, Schools of Business and Management", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 88 "Not-for-profit 4 yr, Other specialized institutions, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 89 "Not-for-profit 4 yr, Other specialized institutions, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 90 "For-profit 4 yr, baccalaureate, east, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 91 "For-profit 4 yr, baccalaureate, east, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 92 "For-profit 4 yr, baccalaureate, west, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 93 "For-profit 4 yr, baccalaureate, west, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 94 "For-profit 4 yr, masters, east, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 95 "For-profit 4 yr, masters, east, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 96 "For-profit 4 yr, masters, west, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 97 "For-profit 4 yr, masters, west, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 98 "Public 2 yr, degree-granting, New England", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 99 "Public 2 yr, degree-granting, Mid East, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 100 "Public 2 yr, degree-granting, Mid East, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 101 "Public 2 yr, degree-granting, Mid East, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 102 "Public 2 yr, degree-granting, Great Lakes, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 103 "Public 2 yr, degree-granting, Great Lakes, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 104 "Public 2 yr, degree-granting, Great Lakes, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 105 "Public 2 yr, degree-granting, Great Lakes, size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 106 "Public 2 yr, degree-granting, Plains, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 107 "Public 2 yr, degree-granting, Plains, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 108 "Public 2 yr, degree-granting, Plains, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 109 "Public 2 yr, degree-granting, Southeast, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 110 "Public 2 yr, degree-granting, Southeast, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 111 "Public 2 yr, degree-granting, Southeast, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 112 "Public 2 yr, degree-granting, Southeast, size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 113 "Public 2 yr, degree-granting, Southeast, size 5", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 114 "Public 2 yr, degree-granting, Southeast, size 6", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 115 "Public 2 yr, degree-granting, Southeast, size 7", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 116 "Public 2 yr, degree-granting, Southeast, size 8", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 117 "Public 2 yr, degree-granting, Southeast, size 9", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 118 "Public 2 yr, degree-granting, Southeast, size 10", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 119 "Public 2 yr, degree-granting, Southeast, size 11", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 120 "Public 2 yr, degree-granting, Southwest, Rocky Mountains, Far West, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 121 "Public 2 yr, degree-granting, Southwest, Rocky Mountains, Far West, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 122 "Public 2 yr, degree-granting, Southwest, Rocky Mountains, Far West, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 123 "Public 2 yr, degree-granting, Southwest, Rocky Mountains, Far West, size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 124 "Public 2 yr, degree-granting, Southwest, Rocky Mountains, Far West, size 5", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 125 "Public 2 yr, degree-granting, Southwest, Rocky Mountains, Far West, size 6", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 126 "Public 2 yr, degree-granting, Southwest, Rocky Mountains, Far West, size 7", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 127 "Public 2 yr, degree-granting, Southwest, Rocky Mountains, Far West, size 8", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 128 "Public 2 yr, degree-granting, Southwest, Rocky Mountains, Far West, size 9", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 129 "Public 2 yr, degree-granting, Southwest, Rocky Mountains, Far West, size 10", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 130 "Public, 2-year, non-degree-granting, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 131 "Public, 2-year, non-degree-granting, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 132 "Public, 2-year, non-degree-granting, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 133 "Not-for-profit, 2 yr, degree-granting, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 134 "Not-for-profit, 2 yr, degree-granting, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 135 "Not-for-profit, 2 yr, degree-granting, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 136 "Not-for-profit, 2 yr, degree-granting, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 137 "Not-for-profit 2yr, non-degree-granting, academic year reporters size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 138 "Not-for-profit 2yr, non-degree-granting, academic year reporters size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 139 "Not-for-profit 2yr, non-degree-granting, academic year reporters size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 140 "Not-for-profit, 2-year, non-degree-granting, program year reporters", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 141 "For-profit, 2 yr, degree-granting, academic year reporter New England, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 142 "For-profit, 2 yr, degree-granting, academic year reporter New England, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 143 "For-profit, 2 yr, degree-granting, academic year reporter New England, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 144 "For-profit, 2 yr, degree-granting, academic year reporter, Great Lakes, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 145 "For-profit, 2 yr, degree-granting, academic year reporter, Great Lakes, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 146 "For-profit, 2 yr, degree-granting, academic year reporter, Great Lakes, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 147 "For-profit,2 yr, degree-granting, academic year reporter, Plains", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 148 "For-profit,2 yr, degree-granting, academic year reporter Southeast, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 149 "For-profit,2 yr, degree-granting, academic year reporter Southeast, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 150 "For-profit,2 yr, degree-granting, academic year reporter Southwest, Rocky Mountains, Far West, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 151 "For-profit,2 yr, degree-granting, academic year reporter Southwest, Rocky Mountains, Far West, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 152 "For-profit, 2 yr, degree-granting, largest program-health size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 153 "For-profit, 2 yr, degree-granting, largest program-health size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 154 "For-profit, 2 yr, degree-granting, largest program-health size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 155 "For-profit, 2 yr, degree-granting, largest program-health size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 156 "For-profit, 2 yr, degree-granting, largest program-other 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 157 "For-profit, 2 yr, degree-granting, largest program-other 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 158 "For-profit, 2 yr, non-degree-granting, largest program-other", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 159 "For-profit, 2 yr, non-degree-granting, largest program-cosmetology size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 160 "For-profit, 2 yr, non-degree-granting, largest program-cosmetology size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 161 "For-profit, 2 yr, non-degree-granting, largest program-cosmetology size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 162 "For-profit, 2 yr, non-degree-granting, largest program-cosmetology size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 163 "For-profit, 2 yr, non-degree-granting, largest program-cosmetology size 5", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 164 "For-profit, 2 yr, non-degree-granting, largest program-cosmetology size 6", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 165 "For-profit, 2 yr, non-degree-granting, largest program-health", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 166 "For-profit, 2 yr, non-degree-granting, largest program-other", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 167 "Public <2 yr, non-degree-granting, academic year reporter size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 168 "Public <2 yr, non-degree-granting, academic year reporter size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 169 "Public <2 yr, non-degree-granting, largest program-business", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 170 "Public <2 yr, non-degree-granting, largest program-health, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 171 "Public <2 yr, non-degree-granting, largest program-health, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 172 "Public <2 yr, non-degree-granting, largest program-health, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 173 "Public <2 yr, non-degree-granting, largest program-health, size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 174 "Public <2 yr, non-degree-granting, largest program-other", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 175 "Not-for-profit <2 yr, non-degree-granting, academic year reporters", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 176 "Not-for-profit <2 yr, non-degree-granting, largest program-business", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 177 "Not-for-profit <2 yr, non-degree-granting, largest program-health", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 178 "Not-for-profit <2 yr, non-degree-granting, largest program-other", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 179 "For-profit <2-yr, non-degree-granting, academic year reporters size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 180 "For-profit <2-yr, non-degree-granting, academic year reporters size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 181 "For-profit <2-yr, non-degree-granting, academic year reporters size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 182 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 183 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 184 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 185 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 186 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 5", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 187 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 6", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 188 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 7", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 189 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 8", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 190 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 9", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 191 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 10", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 192 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 11", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 193 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 12", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 194 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 13", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 195 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 14", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 196 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 15", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 197 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 16", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 198 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 15", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 199 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 18", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 200 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 19", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 201 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 20", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 202 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 21", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 203 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 22", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 204 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 23", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 205 "For-profit <2 yr, non-degree-granting, largest program-cosmetology, size 24", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 206 "For-profit <2 yr, non-degree-granting, largest program-health, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 207 "For-profit <2 yr, non-degree-granting, largest program-health, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 208 "For-profit <2 yr, non-degree-granting, largest program-health, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 209 "For-profit <2 yr, non-degree-granting, largest program-health, size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 210 "For-profit <2 yr, non-degree-granting, largest program-health, size 5", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 211 "For-profit <2 yr, non-degree-granting, largest program-health, size 6", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 212 "For-profit <2 yr, non-degree-granting, largest program-health, size 7", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 213 "For-profit <2 yr, non-degree-granting, largest program-health, size 8", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 214 "For-profit <2 yr, non-degree-granting, largest program-health, size 9", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 215 "For-profit <2 yr, non-degree-granting, largest program-health, size 10", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 216 "For-profit <2 yr, non-degree-granting, largest program-health, size 11", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 217 "For-profit <2 yr, non-degree-granting, largest program-other, size 1", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 218 "For-profit <2 yr, non-degree-granting, largest program-other, size 2", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 219 "For-profit <2 yr, non-degree-granting, largest program-other, size 3", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 220 "For-profit <2 yr, non-degree-granting, largest program-other, size 4", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 221 "For-profit <2 yr, non-degree-granting, largest program-other, size 5", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid 222 "Not-for-profit 4 yr non-degree-granting, medical", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid -3 "Not derived due to minimum group size requirement", add
label values dfrcgid label_dfrcgid
cap label define label_dfrcgid -2 "Not applicable", add
label values dfrcgid label_dfrcgid

tab stabbr
tab fips
tab obereg
tab opeflag
tab sector
tab iclevel
tab control
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
tab locale
tab openpubl
tab act
tab deathyr
tab cyactive
tab postsec
tab pseflag
tab pset4flg
tab rptmth
tab carnegie
tab lock_ic
tab stat_ic
tab stabbr
tab fips
tab obereg
tab instsize
tab sector
tab iclevel
tab control
tab tenursys
tab deggrant
tab hbcu
tab tribal
tab locale
tab pset4flg
tab instcat
tab ccbasic
tab ccipug
tab ccipgrad
tab ccugprof
tab ccenrprf
tab ccsizset
tab landgrnt
tab carnegie
tab dfrcgid

summarize enrtot
summarize f2h01
summarize f2h02
summarize f3b06
summarize f3b08
summarize f1h01
summarize f1h02


save "data/temporary/labeled_IPEDS_2005.dta", replace