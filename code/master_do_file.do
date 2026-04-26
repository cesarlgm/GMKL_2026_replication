
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	this do file replicates the paper
					

*===============================================================================
*/

version 17


/*
*===============================================================================
*REPLICATOR: MODIFY THE PATHS BELOW
*===============================================================================
*
*/

//# Set the appropriate working directory and R library path
cd	"C:\Users\thecs\Dropbox\1_boston_university\8-Research Assistantship\AKM_SDR\replication_package"
global R_library "\\\\de4.norc.org/NCSES/Home/kahn_shulamit/Documents/R/win-library/4.0"


global run_kss "yes"		//"yes" or "no" - whether to run the KSS corrections or not

//# Before executing also modify the paths in the file code/R_setup.R

*===============================================================================
*STATA SETUP AND DEPENDENCIES
*===============================================================================

*This line installs all the required package dependencies.
*It also loads the two setup programs we call below
do "code/stata_setup.do" 

*Setting global variables
set_global_vars

*Intalling all state packages
*Comment this line if you don't want to install Stata dependences
install_stata_dep

*Create and clean the folder structure 
*WARNING: this line of code erases all output and temporary folders.
*     If you don't want to start from scratch, set erase to no or comment this line
clean_folders, erase(yes)



clear

*===============================================================================
*R SETUP AND DEPENDENCIES
*===============================================================================

//! MAKE SURE THAT YOU HAVE UPDATED THE PATHS IN THE FILE code/R_setup.R

*Installing packages from R
*Execution time varies depending on how many packages are actually installed. Could take 5 minutes or more
rscript using "code/install_R_packages.R", ///
	args($R_library)

/*
*===============================================================================
*EXECUTION OF THE ANALYSIS
*===============================================================================
*/

//#This program is not included in the replication package due to NCSES disclosure rules.
*Load censoring programs
do "code/censoring_programs.do"


*Clean the databse and create the AKM regressions
*Execution time: approx 3.2 hours
do "code/build_database/master_build.do"  


if "$run_kss"=="yes" {
	*This bit of code takes approximately 5 days
	do "code/build_database/correct_KSS_master.do"
}

*Creates all the tables and figures
do "code/data_analysis/master_tables_and_figures.do"

