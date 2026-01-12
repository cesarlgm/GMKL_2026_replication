use "data/raw/IPEDS_v2", clear 

gcollapse (min) sector, by(instcod)

tostring instcod, replace

tempfile sector
save `sector'


use "data/output/institution_level_database_clean.dta", clear
merge 1:1 instcod using `sector', keep(3) nogen


table sector