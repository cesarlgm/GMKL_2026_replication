{smcl}
{* version 1.0 2026-03-17}{...}
{title:Title}

{p2colset 5 24 26 2}{...}
{p2col:{cmd:textablehead} {hline 2}}Create the opening LaTeX markup for a regression table{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:textablehead} {cmd:using} {it:filename}{cmd:,}
    [{opt coltitles(strings)}
     {opt firsttitle(string)}
     {opt title(string)}
     {opt colalignment(char)}
     {opt key(string)}
     {opt dropcolnums}
     {opt supertitle(string)}
     {opt exhead(string)}
     {opt fullalignment(string)}
     {opt landscape}
     {opt invert}
     {opt nocaption}
     {opt adjust(#)}
     {opt scheme(string)}
     {opt ctformat(string)}
     {opt cellalign(char)}
     {opt doublerule}
     {opt ncols(#)}]


{title:Description}

{pstd}
{cmd:textablehead} creates (or replaces) a LaTeX table fragment file with the
opening markup for a regression table. It writes the full preamble — including
the enclosing environments, the optional caption and label, optional spanning
supertitle, column-number row, and column-title row — and closes with
{cmd:\midrule} so that the body rows can be appended immediately.

{pstd}
The program supports two output schemes:

{pstd}
{bf:Default scheme.} Wraps the table in {cmd:center}, {cmd:adjustbox}, and
{cmd:threeparttable} environments. Column numbers appear as (1), (2), ... in
a dedicated row above the column titles.

{pstd}
{bf:AEA scheme} ({opt scheme(aea)}). Uses a {cmd:table} environment with
{cmd:\resizebox} instead of {cmd:adjustbox}, following AEA journal formatting.

{pstd}
{cmd:textablehead} must be paired with {cmd:textablefoot} to close the
environments it opens. Table body rows are typically written using
{cmd:leanesttab}.


{title:Options}

{phang}
{opt coltitles(strings)} space-separated list of column header strings, one
per regression column. Each token is placed in a {cmd:\makecell}. If omitted,
{opt ncols()} must be specified.

{phang}
{opt firsttitle(string)} label placed in the first (variable-name) column of
the column-title and column-number rows. Default is empty.

{phang}
{opt title(string)} text for the {cmd:\caption{}} command. If omitted, no
caption is written (equivalent to {opt nocaption}).

{phang}
{opt colalignment(char)} alignment character for the regression columns in the
{cmd:tabular} column specification ({cmd:l}, {cmd:c}, or {cmd:r}). Default is
{cmd:c}. The first (label) column is always left-aligned.

{phang}
{opt key(string)} text for the {cmd:\label{}} command. Written only when
{opt title()} is also provided and {opt nocaption} is not set.

{phang}
{opt dropcolnums} suppresses the column-number row (the (1), (2), ...  row).
Only the column-title row (from {opt coltitles()}) is written.

{phang}
{opt supertitle(string)} a LaTeX string written as a spanning header above
the column titles, wrapped in {cmd:\multicolumn} across all regression
columns. A {cmd:\cline} is drawn beneath it.

{phang}
{opt exhead(string)} a raw LaTeX row string written immediately after
{cmd:\toprule} (and before the column rows). Useful for custom multi-row
spanning headers.

{phang}
{opt fullalignment(string)} overrides {opt colalignment()} for all columns,
including the first. Accepts any valid LaTeX column-spec string.

{phang}
{opt landscape} prepends {cmd:\begin{landscape}} before all other markup.
Must be matched with {opt landscape} in {cmd:textablefoot}.

{phang}
{opt invert} reverses the order of the column-number and column-title rows:
column numbers are written first, column titles second.

{phang}
{opt nocaption} suppresses the {cmd:\caption} and {cmd:\label} lines even
when {opt title()} is provided.

{phang}
{opt adjust(#)} sets the {cmd:adjustbox} max-width multiplier. Default is
{cmd:.9} (i.e., {cmd:max width=.9\textwidth}). In AEA mode, sets the
{cmd:\resizebox} width multiplier.

{phang}
{opt scheme(string)} output scheme. Currently recognized value: {cmd:aea}.
Omit for the default threeparttable layout.

{phang}
{opt ctformat(string)} a LaTeX formatting command (e.g., {cmd:\small}) applied
to all column-title and column-number cells.

{phang}
{opt cellalign(char)} alignment character for {cmd:\makecell} cells in the
column-title row. Default is {cmd:c}.

{phang}
{opt doublerule} adds a second {cmd:\toprule} immediately after the first,
producing a double horizontal rule at the top of the table.

{phang}
{opt ncols(#)} explicitly sets the number of regression columns. If omitted,
the count is derived from the number of tokens in {opt coltitles()}.


{title:Examples}

{pstd}
Create a table header with two regression columns, a caption, and a label:

{phang2}{cmd:. textablehead using "output/tab_main.tex", ///}{p_end}
{phang3}{cmd:coltitles("Baseline" "Extended") title("Main Results") key(tab:main)}{p_end}

{pstd}
Create an AEA-style landscape table with a supertitle:

{phang2}{cmd:. textablehead using "output/tab_app.tex", ///}{p_end}
{phang3}{cmd:coltitles("Men" "Women" "Men" "Women") ///}{p_end}
{phang3}{cmd:supertitle("OLS \& IV Estimates") title("Appendix Table") ///}{p_end}
{phang3}{cmd:key(tab:app) scheme(aea) landscape}{p_end}

{pstd}
Create a header without column numbers, using a custom column format:

{phang2}{cmd:. textablehead using "output/tab_rob.tex", ///}{p_end}
{phang3}{cmd:coltitles("(1)" "(2)" "(3)") dropcolnums firsttitle("Outcome")}{p_end}


{title:See also}

{pstd}
{help textablefoot}, {help leanesttab}


{title:Authors}

{pstd}
César Garro-Marín ({browse "mailto:cgarrom@ed.ac.uk":cgarrom@ed.ac.uk}){break}
Shulamit Kahn ({browse "mailto:skahn@bu.edu":skahn@bu.edu}){break}
Kevin Lang ({browse "mailto:lang@bu.edu":lang@bu.edu})

{pstd}
Paper: "Do Elite Universities Overpay Their Faculty?"
