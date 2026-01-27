
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	this file executes all the data cleaning
					

*===============================================================================
*/


//# Setting the list of SDR files 
global SDR_list   $sdr19   $sdr17 $sdr15 $sdr13 $sdr10 $sdr08 $sdr06  $sdr03 ///
				 $sdr01 $sdr99 $sdr97 $sdr95 $sdr93


/*
TODO: review if I can erase this line
*===============================================================================
*LOCATIONS OF DRF FILES
*===============================================================================

global DRF_list  $drf17 $drf15 $drf13 $drf10 $drf08 $drf06 $drf03 ///
				$drf01 $drf99 $drf97 $drf93

*/
*===============================================================================
*PROCESSING SDR, APPENDING FILES AND RESTRICTING THE SAMPLE
*===============================================================================


*Loading basic regression-related programs used across the code (CLEANED) (DEPENDENCES EXPORTED)
do "code/build_database/regression_programs.do"


*Processing individual waves from the SDR and appending them into a unique dataset
*Run time: 12 minutes (CLEANED) (DEPENDENCES EXPORTED)
qui do "code/build_database/process_sdr_files.do" $SDR_list
	
di "Processed of SDR files", as result		


*Adding IPEDs codes and cretting a file with a more restricted sample (CLEANED)   (DEPENDENCES EXPORTED)
*Run time: 5.7 minutes
qui do "code/build_database/create_work_history_input.do"


*===============================================================================
*CLEANING THE WORK HISTORY
*===============================================================================
*Execution time: about 1 minute (CLEANED)  (DEPENDENCES EXPORTED)
qui do "code/build_database/depurate_dates_missing_ipeds"


*Here I separate the file into switchers and anybody else
*Output switcher_file.dta and non_switcher_file.dta
*Execution time 4.6 minutes (CLEANED)  (DEPENDENCES EXPORTED)
qui do "code/build_database/first_round_spell_cleaning.do"


*Clean the database of people who switched institutions
*Execution time 4.5 minutes (CLEANED)  (DEPENDENCES EXPORTED)
qui do "code/build_database/clean_switchers.do"
	
di "Created and cleaned switcher file", as result		



*Clean the database of people who did not switch institutions
*Execution time 2.4 minutes (CLEANED)  (DEPENDENCES EXPORTED)
qui do "code/build_database/clean_non_switchers.do"


*Execution time 2 minutes
*This creates the database that includes all wage observations (CLEANED)  (DEPENDENCES EXPORTED)
qui do "code/build_database/create_individual_databases.do" raw	


*This creates the database that excludes wage outliers
*Execution time 2 minutes (CLEANED)  (DEPENDENCES EXPORTED)
qui do "code/build_database/create_individual_databases.do" clean
di "Created individual database, first", as result		

*======================================================================
*Cleaning IPEDS database
*======================================================================	
*Cleaning ranking names (EXPORTED) (CLEANED)
*<1 minute
qui do "code/build_database/import_rankings.do"

*Adding IPED codes and rankings (EXPORTED) (CLEANED) 
*<1 minute 
qui do "code/build_database/create_iped_ranking_cw.do" 
	
*Cleaning data on university characteristics (CLEANED)
*<1 minute
qui do "code/build_database/clean_ipeds.do"


*======================================================================
*Create database for regressions
*======================================================================	
*Here I need to filter the database twice to arrive to the right set 
*of institutions (CLEANED)
*<1 minute
qui do "code/build_database/add_institution_dummies.do" temporary


*I create temporary AKM estimates to limit the sample and get the right
*connected set (CLEANED)
*3.4 minutes
qui do "code/build_database/create_institution_estimates" temporary
di "Created individual database, second", as result		
 

*<1 minute (EXPORTED)
qui do "code/build_database/create_regression_database.do" temporary
	
*Once I have these estimates, I go back to invidual level data and limit the sample.
*Then I estimate them a final time. (EXPORTED)
*< 1 minute
do "code/build_database/limit_to_estimation_sample.do"
 


*My adhoc solution to limiting the sample is the following (EXPORTED)
*< 1 minute
do "code/build_database/add_institution_dummies.do" final


*======================================================================
*This outputs the main AKM results
*======================================================================	
*And then I go on and recompute my final database (CLEANED)
*3.4 minutes
do "code/build_database/create_institution_estimates" final
di "Created institution estimates", as result


*======================================================================
*This outputs the database I use for the university level regressions 
*======================================================================	
*This is not a mistake, I have to do it twice to arrive to the correct number of 653 schools.
*<1 minute (CLEANED)
do "code/build_database/create_regression_database.do" additional_processing
di "Created institution-level dataset", as result


*This prepares and creates the estimates using job satisfaction data (CLEANED)
do "code/build_database/create_job_satisfaction_estimates.do"


*===========================================================================
*Note: create regression database MUST be run before all the do files below. However, the dofiles below are independent from eachother, so they can run in any order.

*Create individual-level estimates of rank-wage relationship (CLEANED)
*2.6 min
do "code/build_database/create_one_step_estimates.do"
di "Created one-step estimates", as result


*Saving the table with the time varying estimates (CLEANED)
do "code/build_database/create_two_step_estimates_varying.do"

*Estimates net of field (CLEANED)
*4 secs
do "code/build_database/residualize_field.do" 
di "Residualized field", as result

 
*Creating estimates restricted to tenured faculty (REQUESTED)
*1.5 min
do "code/build_database/create_tenured_only_estimates.do"
di "Created tenured-only estimates", as result

 
*This bit creates a list of medical schools that is dropped from the second stage
*Takes seconds
do "code/build_database/prepare_medical_drop.do"	
 

*This bit creates estimates with grouped schools (CLEANED)
*40 seconds
do "code/build_database/create_grouped_estimates.do"	


*This bid cleans the field specific rankings from USNWR (CLEANED)
do "code/build_database/clean_field_rankings.do"


di "Starting variance correction. This can take up to 2 hours. DO NOT CLOSE THE DOS WINDOW", as result


*Andrews et al variance_correction
*Execution time: 1.7 hours
{
	do "code/build_database/output_R_dataset.do" //CLEANED
	
	rscript using "code/build_database/variance_correction.R" //CLEANED
}

*Creating simulation of compensating differentials (LIKELY DEPRECATED)
*do "code/build_database/create_cwd_estimates.do"



di "Finished building do file", as result