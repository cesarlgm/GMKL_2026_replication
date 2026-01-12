*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	Garro-Marín, Kahn, and Lang
				
	Outputs:    executes all the data cleaning
*/
*==============================================================================


global SDR_list   $sdr19   $sdr17 $sdr15 $sdr13 $sdr10 $sdr08 $sdr06  $sdr03 ///
				 $sdr01 $sdr99 $sdr97 $sdr95 $sdr93


*===============================================================================
*LOCATIONS OF DRF FILES
*===============================================================================

global DRF_list  $drf17 $drf15 $drf13 $drf10 $drf08 $drf06 $drf03 ///
				$drf01 $drf99 $drf97 $drf93

*===============================================================================
*PROCESSING SDR, APPENDING FILES AND RESTRICTING THE SAMPLE
*===============================================================================


*Start by loading regression-related programs
do "code/build_database/regression_programs.do"


*Processing individual waves from the SDR and appending them into a unique dataset
*Run time: 12 minutes
qui do "code/build_database/process_sdr_files.do" $SDR_list
	
di "Processed of SDR files", as result		


*This bit add IPEDs codes and creates a file with a more restricted sample
*Run time: 5.7 minutes
qui do "code/build_database/create_work_history_input.do"


*===============================================================================
*CLEANING THE WORK HISTORY
*===============================================================================
*Execution time: about 1 minute
qui do "code/build_database/depurate_dates_missing_ipeds"


*Here I separate the file into switchers and anybody else
*Output switcher_file.dta and non_switcher_file.dta
*Execution time 4.6 minutes
qui do "code/build_database/first_round_spell_cleaning.do"


*Clean the database of people who switched institutions
*Execution time 4.5 minutes
qui do "code/build_database/clean_switchers.do"
	
di "Created and cleaned switcher file", as result		



*Clean the database of people who did not switch institutions
*Execution time 2.4 minutes
qui do "code/build_database/clean_non_switchers.do"


*Execution time 2 minutes
*This creates the database that includes all wage observations
qui do "code/build_database/create_individual_databases.do" raw	


*This creates the database that excludes wage outliers
*Execution time 2 minutes
qui do "code/build_database/create_individual_databases.do" clean
di "Created individual database, first", as result		

*======================================================================
*Cleaning IPEDS database
*======================================================================	
*Cleaning ranking names
*<1 minute
qui do "code/build_database/import_rankings.do"

*Adding IPED codes and rankings
*<1 minute
qui do "code/build_database/create_iped_ranking_cw.do" 
	
*Cleaning data on university characteristics
*<1 minute
qui do "code/build_database/clean_ipeds.do"


*======================================================================
*Create database for regressions
*======================================================================	
*Here I need to filter the database twice to arrive to the right set of institutions
*<1 minute
qui do "code/build_database/add_institution_dummies.do" temporary


*I create temporary AKM estimates to limit the sample and get the right
*connected set
*3.4 minutes
qui do "code/build_database/create_institution_estimates" temporary
di "Created individual database, second", as result		

*<1 minute
qui do "code/build_database/create_regression_database.do" temporary
	
*Once I have these estimates, I go back to invidual level data and limit the sample.
*Then I estimate them a final time.
*< 1 minute
do "code/build_database/limit_to_estimation_sample.do"
 


*My adhoc solution to limiting the sample is the following
*< 1 minute
do "code/build_database/add_institution_dummies.do" final


*======================================================================
*This outputs the main AKM results
*======================================================================	
*And then I go on and recompute my final database
*3.4 minutes
do "code/build_database/create_institution_estimates" final
di "Created institution estimates", as result


*======================================================================
*This outputs the database I use for the university level regressions 
*======================================================================	
*This is not a mistake, I have to do it twice to arrive to the correct number of 653 schools.
*<1 minute
do "code/build_database/create_regression_database.do" additional_processing
di "Created institution-level dataset", as result


*This prepares and creates the estimates using job satisfaction data
do "code/build_database/create_job_satisfaction_estimates.do"


*===========================================================================
*Note: create regression database MUST be run before all the do files below. However, the dofiles below are independent from eachother, so they can run in any order.

*Create individual-level estimates of rank-wage relationship 
*2.6 min
do "code/build_database/create_one_step_estimates.do"
di "Created one-step estimates", as result


*Estimates net of field
*4 secs
do "code/build_database/residualize_field.do"
di "Residualized field", as result

 
*Creating estimates restricted to tenured faculty
*1.5 min
do "code/build_database/create_tenured_only_estimates.do"
di "Created tenured-only estimates", as result

 
*This bit creates a list of medical schools that is dropped from the second stage	
*Takes seconds
do "code/build_database/prepare_medical_drop"	
 

*This bit creates estimates with grouped schools
*40 seconds
do "code/build_database/create_grouped_estimates.do"	


*This bid cleans the field specific rankings from USNWR
do "code/build_database/clean_field_rankings.do"


di "Starting variance correction. This can take up to 
2 hours", as result
*Andrews et al variance_correction
*Execution time: 1.7 hours
{
	do "code/build_database/output_R_dataset.do"
	
	rscript using "code/build_database/variance_correction.R"
}

*Creating simulation of compensating differentials
do "code/build_database/create_cwd_estimates.do"



di "Finished building do file", as result