*Outputting the number of leave episodes
use "data/raw/leave_check_v4_renamed.dta", clear

summ panelid if proper_leave==1

local file_name "results/text/n_leaves.tex"

cap rm "`file_name'"
writeln "`file_name'" "`r(N)'"