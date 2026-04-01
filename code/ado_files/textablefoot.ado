/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Defines the textablefoot program, which closes a LaTeX table
*					environment opened by textablehead. Writes the closing
*					\bottomrule, \end{tabular}, tablenotes (if provided), and the
*					enclosing threeparttable/adjustbox/center or AEA-style table
*					environments. Supports an optional landscape mode. Optionally
*					suppresses the date stamp (nodate) or embeds the name of the
*					calling do-file in the table notes (dofile()).

*   Input: 	The using() .tex file, which must already exist (opened by textablehead)
*   Output: 	Appends closing LaTeX markup to the specified using() file

*	Modification list:
*	Jun 12, 2019: Added option to include do-file name in the output notes.

*===============================================================================
*/

cap program drop textablefoot
program define textablefoot
	version 14.2
	*notes just adds the string passed to it as a table note
	syntax using/, [notes(str) Fontsize(str) NODate dofile(str) LANDscape SCHeme(str)]
	
	tempname textable
	file open `textable' using `using', append write
	file close `textable'

	writeln `using' "\bottomrule"
	writeln `using' "\bottomrule"
	writeln `using' "\end{tabular}"
	if "`fontsize'"==""{
		local fontsize \footnotesize
	}
	
	if "`nodate'"=="" {
		local timeLegend= "Table generated on `c(current_date)' at `c(current_time)'."
	}
	else {
		local timeLegend= ""
	}
	
	if "`dofile'"!=""&"`nodate'"=="" {
		local do_note= " Table generated with do file `dofile'"
	}
	else {
		local do_note= ""
	}

	if "`scheme'"!="aea"{	
		if "`notes'"!="" {
			writeln `using' "\begin{tablenotes}"
			writeln `using' "\item `fontsize' \textit{Notes:} `notes'. `timeLegend'`do_note'"
			writeln `using' "\end{tablenotes}"
		}
		
		writeln `using' "\end{threeparttable}"
		writeln `using' "\end{adjustbox}"
		writeln `using' "\end{center}"
	}
	else {
		writeln `using' "}"
		if "`notes'"!="" {
			writeln `using' "\begin{tablenotes}[Notes]"
			writeln `using' "`notes'. `timeLegend'`do_note'"
			writeln `using' "\end{tablenotes}"
		}
		writeln `using' "\end{table}"
	}

	if "`landscape'"!=""{ 
		writeln `using' "\end{landscape}"
	}

end
