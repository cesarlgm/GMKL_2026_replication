*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	César Garro-Maín
	Description: 	install required ados for replication package
*/
*===============================================================================

*This has to be run at least once before the master_do_file.do is run


*This packages are the ones available at the NORC server. They are not the latest
*versions available at ssc
global texspace \hspace{3mm}

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
