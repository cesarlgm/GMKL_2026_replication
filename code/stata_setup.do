
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	loads programs required for setting up stata
					

*===============================================================================
*/


*This packages are the ones available at the NORC server. They are not the latest
*versions available at ssc

cap program drop install_stata_dep
program define install_stata_dep
	net install l/labutil, replace

	net install f/ftools, replace

	net install r/reghdfe, replace

	net install r/rscript, replace

	net install f/fs, replace

	net install s/sankey, replace

	*net install g/graphfunction, replace

	net install g/grstyle, replace

	net install r/regsave, replace

	net install p/parmest, replace

	net install p/parmest, replace

	net install u/unique, replace

	net install g/gtools, replace

	net install e/erepost, replace

	net install b/binscatter, replace
end

*Adding path for wregress
adopath + "code/build_database"

adopath + "code/data_analysis"

adopath + "code/ado_files"


cap program drop clean_folders
program define clean_folders
	syntax, erase(str)
	if "`erase'"=="yes" {
		clear
	
		cap fs "data/temporary/*"
		
		foreach file in `r(files)' {
			cap erase "data/temporary/`file'"
		}
		
		cap fs "data/additional_processing/*"
		
		cap fs "data/output/*"
		
		foreach file in `r(files)' {
			cap erase "data/output/`file'"
		}
		
		foreach file in `r(files)' {
			cap erase "data/additional_processing/`file'"
		}
		
		cap fs "results/figures/*"
		
		foreach file in `r(files)' {
			cap erase "results/figures/`file'"
		}
		
		cap fs "results/tables/*"
		
		foreach file in `r(files)' {
			cap erase "results/tables/`file'"
		}
		
		cap fs "results/regressions/*"
		
		foreach file in `r(files)' {
			cap erase "results/regressions/`file'"
		}
		
		cap fs "results/text/*"
		
		foreach file in `r(files)' {
			cap erase "results/text/`file'"
		}
		
		cap fs "results/log_files/*"
		
		foreach file in `r(files)' {
			cap erase "results/log_files/`file'"
		}
		
		
		cap mkdir "data/temporary"
		cap mkdir "data/additional_processing"
		cap mkdir "data/output"
		cap mkdir "results/figures"
		cap mkdir "results/tables"
		cap mkdir "results/regressions"
		cap mkdir "results/text"
		cap mkdir "results/log_files"
	}
end 

cap program drop set_global_vars
program define set_global_vars
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
end 