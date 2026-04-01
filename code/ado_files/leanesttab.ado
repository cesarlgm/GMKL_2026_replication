/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Defines the leanesttab program, a wrapper around esttab that
*					writes regression output to a LaTeX fragment file. Optionally
*					inserts a mid-table column header row (midhead) or an explicit
*					extra header row (exhead) before calling esttab. The noest
*					option suppresses the esttab call so only the header rows are
*					written.

*   Input: 	Stored estimates (via esttab); the using() file must already exist
*             or be initialized by textablehead
*   Output: 	Appends LaTeX tabular rows to the specified using() file


*===============================================================================
*/

capture program drop leanesttab
program define leanesttab
    syntax [anything]  using/, [format(string) midhead(str asis) EXhead(str asis) CTformat(string) Firsttitle(str) CEllalign(str) ncols(str) noest * ] 

    if "`format'"==""{
        local format 2
    }

	if "`cellalign'"=="" {
		local cellalign="c"
	}

	
    if "`collabels'"=="" {
        local collabels collabels(none)
    }

    local coltitle="`ctformat' `firsttitle'"

    if `"`midhead'"'!="" {
        tokenize  `"`midhead'"'
        if "`ncols'"=="" {
            local ncols: word count `anything'
            local ncols = `ncols'+1
        }
        forvalues col=1/`ncols' {
		    local coltitle="`coltitle'"+"&"+"`ctformat' \makecell[`cellalign']{`bottom' ``col''}"
        }

        if "`exhead'"!="" {
            writeln "`using'"  "`exhead'"
            writeln "`using'" "`coltitle' \\"  
        }
        else {
            writeln "`using'" "\midrule `coltitle' \\"
        }    
        
        writeln "`using'" "\midrule"    
    }

	if "`noest'"=="" {
		esttab `anything' using `using',  label f collabels(none) ///
			nomtitles plain  par  b(%9.`format'fc) se(%9.`format'fc) `options'
	}
end


