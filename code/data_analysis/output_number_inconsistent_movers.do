*Output the number of inconsistent movers
use "data/temporary/switcher_file", clear

do "code/build_database/flag_spell_inconsistencies.do"


summ panelid if inconsistent_instcod==1

local file_name "results/text/n_leaves.tex"

rm "`file_name'"
writeln "`file_name'" "`r(N)'"