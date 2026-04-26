/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	master script for the KSS variance correction: exports
*					input datasets, runs the R-based correction (up to 10 hours),
*					and tabulates the number of schools per institution type

*   Input: 		Called: code/build_database/output_KSS_datasets.do
*				Called: code/build_database/kss_correction_full.R  (via rscript)
*				Called: code/build_database/get_number_schools_per_type.do
*   Output: 	KSS-corrected variance estimates and school-type tabulation
*				(produced by called scripts)

*===============================================================================
*/

*First I output the datasets for the correction
do "code/build_database/output_KSS_datasets.do"


//#This program is not included in the replication package due to NCSES disclosure rules.
*This can take upto 10 hours
rscript using "code/build_database/kss_correction_execute.R"

*Reviewing the number of schools per type
do "code/build_database/get_number_schools_per_type.do"

