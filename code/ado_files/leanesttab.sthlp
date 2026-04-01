{smcl}
{* version 1.0 2026-03-17}{...}
{title:Title}

{p2colset 5 22 24 2}{...}
{p2col:{cmd:leanesttab} {hline 2}}Write a LaTeX regression table body via esttab{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:leanesttab} [{it:namelist}] {cmd:using} {it:filename}{cmd:,}
    [{opt format(#)}
     {opt midhead(strings)}
     {opt exhead(string)}
     {opt ctformat(string)}
     {opt firsttitle(string)}
     {opt cellalign(char)}
     {opt ncols(#)}
     {opt noest}
     {it:esttab_options}]


{title:Description}

{pstd}
{cmd:leanesttab} is a wrapper around {cmd:esttab} that appends regression
output as LaTeX tabular rows to an existing table fragment file. The file
is typically opened (with its preamble) by {cmd:textablehead} and closed by
{cmd:textablefoot}.

{pstd}
When {opt midhead()} is specified, {cmd:leanesttab} inserts a mid-table
column-header row, separated by a {cmd:\midrule}, before the estimation
output. This is used to divide a single table into labelled panels or groups
of columns. When {opt exhead()} is also specified, that string is written
as a raw LaTeX row in place of the automatic {cmd:\midrule} that would
otherwise precede the column titles.

{pstd}
Unless {opt noest} is given, {cmd:esttab} is called with options that produce
plain (no stars), labeled output with parenthesized standard errors and the
column-label row suppressed ({cmd:collabels(none)}).


{title:Options}

{phang}
{opt format(#)} sets the number of decimal places for coefficients and
standard errors. Passed to {cmd:esttab} as {cmd:b(%9.#fc)} and
{cmd:se(%9.#fc)}. Default is {cmd:2}.

{phang}
{opt midhead(strings)} a space-separated list of column header strings (one
per estimation column). When provided, a header row is constructed and written
to the file before the estimation output. Each token is placed in a
{cmd:\makecell} and separated by {cmd:&}.

{phang}
{opt exhead(string)} a raw LaTeX string written to the file in place of the
automatic leading {cmd:\midrule} when {opt midhead()} is active. Useful for
multi-row spanning headers.

{phang}
{opt ctformat(string)} a LaTeX formatting command (e.g., {cmd:\small}) applied
to all column-title cells in the header row.

{phang}
{opt firsttitle(string)} text placed in the first (label) column of the header
row. Defaults to empty.

{phang}
{opt cellalign(char)} alignment character for {cmd:\makecell} cells in the
header row ({cmd:l}, {cmd:c}, or {cmd:r}). Default is {cmd:c}.

{phang}
{opt ncols(#)} overrides the automatic column count (which defaults to the
number of names in {it:namelist}) when constructing the header row. Useful
when the header spans columns not covered by the namelist.

{phang}
{opt noest} suppresses the {cmd:esttab} call. Only the header rows specified
via {opt midhead()} or {opt exhead()} are written. Useful for inserting
divider rows between panels.

{phang}
{it:esttab_options} any additional options are passed through to {cmd:esttab}.


{title:Examples}

{pstd}
Write two stored estimates to a table body:

{phang2}{cmd:. leanesttab m1 m2 using "output/tab_main.tex", format(3)}{p_end}

{pstd}
Insert a mid-table panel header before a second pair of estimates:

{phang2}{cmd:. leanesttab m3 m4 using "output/tab_main.tex", ///}{p_end}
{phang3}{cmd:midhead("OLS" "IV") format(3)}{p_end}

{pstd}
Write only a divider row with a spanning label, no estimates:

{phang2}{cmd:. leanesttab using "output/tab_main.tex", ///}{p_end}
{phang3}{cmd:exhead("& \multicolumn{4}{c}{Panel B: Men} \\") noest}{p_end}


{title:Dependencies}

{pstd}
Requires {cmd:esttab} (part of {cmd:estout}), available from SSC:

{phang2}{cmd:. ssc install estout}{p_end}

{pstd}
Requires the project's {cmd:writeln} utility (also in {cmd:ado_files/}).


{title:Authors}

{pstd}
César Garro-Marín ({browse "mailto:cgarrom@ed.ac.uk":cgarrom@ed.ac.uk}){break}
Shulamit Kahn ({browse "mailto:skahn@bu.edu":skahn@bu.edu}){break}
Kevin Lang ({browse "mailto:lang@bu.edu":lang@bu.edu})

{pstd}
Paper: "Do Elite Universities Overpay Their Faculty?"
