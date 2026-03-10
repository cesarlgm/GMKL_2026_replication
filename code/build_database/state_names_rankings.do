/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Maps string variable state_name to numeric FIPS-like codes,
*				covering all 50 US states, DC, and US territories (American
*				Samoa, Guam, Northern Mariana Islands, Puerto Rico, US Virgin
*				Islands, Baker Island, Howland Island).

*   Input: 		Default frame in memory (must contain string variable state_name)
*   Output: 	Default frame modified in place: adds state_rank (numeric
*				FIPS-like state/territory code)
					

*===============================================================================
*/


*Create state names
generate state_rank=.

replace state_rank=1 if state_name=="alabama"
replace state_rank=2 if state_name=="alaska"
replace state_rank=4 if state_name=="arizona"
replace state_rank=5 if state_name=="arkansas"
replace state_rank=6 if state_name=="california"
replace state_rank=8 if state_name=="colorado"
replace state_rank=9 if state_name=="connecticut"
replace state_rank=10 if state_name=="delaware"
replace state_rank=11 if state_name=="district of columbia"
replace state_rank=12 if state_name=="florida"
replace state_rank=13 if state_name=="georgia"
replace state_rank=15 if state_name=="hawaii"
replace state_rank=16 if state_name=="idaho"
replace state_rank=17 if state_name=="illinois"
replace state_rank=18 if state_name=="indiana"
replace state_rank=19 if state_name=="iowa"
replace state_rank=20 if state_name=="kansas"
replace state_rank=21 if state_name=="kentucky"
replace state_rank=22 if state_name=="louisiana"
replace state_rank=23 if state_name=="maine"
replace state_rank=24 if state_name=="maryland"
replace state_rank=25 if state_name=="massachusetts"
replace state_rank=26 if state_name=="michigan"
replace state_rank=27 if state_name=="minnesota"
replace state_rank=28 if state_name=="mississippi"
replace state_rank=29 if state_name=="missouri"
replace state_rank=30 if state_name=="montana"
replace state_rank=31 if state_name=="nebraska"
replace state_rank=32 if state_name=="nevada"
replace state_rank=33 if state_name=="new hampshire"
replace state_rank=34 if state_name=="new jersey"
replace state_rank=35 if state_name=="new mexico"
replace state_rank=36 if state_name=="new york"
replace state_rank=37 if state_name=="north carolina"
replace state_rank=38 if state_name=="north dakota"
replace state_rank=39 if state_name=="ohio"
replace state_rank=40 if state_name=="oklahoma"
replace state_rank=41 if state_name=="oregon"
replace state_rank=42 if state_name=="pennsylvania"
replace state_rank=44 if state_name=="rhode island"
replace state_rank=45 if state_name=="south carolina"
replace state_rank=46 if state_name=="south dakota"
replace state_rank=47 if state_name=="tennessee"
replace state_rank=48 if state_name=="texas"
replace state_rank=49 if state_name=="utah"
replace state_rank=50 if state_name=="vermont"
replace state_rank=51 if state_name=="virginia"
replace state_rank=53 if state_name=="washington"
replace state_rank=54 if state_name=="west virginia"
replace state_rank=55 if state_name=="wisconsin"
replace state_rank=56 if state_name=="wyoming"
replace state_rank=60 if state_name=="american samoa"
replace state_rank=66 if state_name=="guam"
replace state_rank=69 if state_name=="northern mariana islands"
replace state_rank=72 if state_name=="puerto rico"
replace state_rank=78 if state_name=="u.s. virgin islands"
replace state_rank=81 if state_name=="baker island"
replace state_rank=82 if state_name=="howland island"
