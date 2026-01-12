*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Description: 	this do file creates and executes the analysis from the paper
					[add paper name here].
					
					The execution has two parts: 
						- data construction
						- data analysis
*/
*===============================================================================

version 17

*===============================================================================
*PARAMETERS FOR USER MODIFICATION
*===============================================================================
*working directory
global user cesar
if "$user"=="cesar"{
	cd	"K:\Research\Kahn_BU\AKM_SDR"
	global R_library "\\\\de4.norc.org/NCSES/Home/marin-cesar/Documents/R/win-library/4.1"
}
else if "user"=="shu" {
	global R_library "\\\\de4.norc.org/NCSES/Home/kahn-shulamit/Documents/R/win-library/4.0" 
	cd	"K:\Research\Kahn_BU\AKM_SDR\"
}

global texspace="\hspace{3mm}"

*location of Survey of Doctorate Recipients (SDR files)
global stem 	"data/raw"
global sdr93	"${stem}/esdr93.dta"
global sdr95	"${stem}/esdr95.dta"
global sdr97	"${stem}/esdr97.dta"
global sdr99	"${stem}/esdr99.dta"
global sdr01	"${stem}/esdr01.dta"
global sdr03	"${stem}/esdr03.dta"
global sdr06	"${stem}/esdr06.dta"
global sdr08	"${stem}/esdr08.dta"
global sdr10	"${stem}/esdr10.dta"
global sdr13	"${stem}/esdr13.dta"
global sdr15	"${stem}/esdr15.dta"
global sdr17	"${stem}/esdr17.dta"
global sdr19 	"${stem}/esdr19.dta"


set scheme s1color, permanently

*===============================================================================
*CODE EXECUTION
*===============================================================================


*After first run please comment this line.
*This line installs all the required package dependencies.
do "code/stata_setup.do" 

*Comment this line if you don't want to install Stata dependences
install_stata_dep


*WARNING: this line of code erases all output and temporary folders.
*     If you don't want to start from scratch, set erase to no or comment this line
clean_folders, erase(yes)

clear

*Installing packages from R
*Execution time varies depending on how many packages are actually installed. Could take 5 minutes or more
rscript using "code/install_R_packages.R", ///
	args($R_library)

	
*Clean the databse and create the AKM regressions
*Execution time: approx 3.2 hours
do "code/build_database/master_build.do"  


*This bit of code takes approximately two days
do "code/build_database/correct_KSS_master.do"


*Creates all the tables and figures
do "code/data_analysis/master_tables_and_figures.do"

