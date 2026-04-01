{smcl}
{* *! version 1.0  2025}{...}
{viewerjumpto "Syntax" "writeln##syntax"}{...}
{viewerjumpto "Description" "writeln##description"}{...}
{viewerjumpto "Examples" "writeln##examples"}{...}

{title:Title}
{phang}
{bf:writeln} {hline 2} Append a line of text to a file

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:writeln} {it:filename} [{it:"text"}]

{marker description}{...}
{title:Description}

{pstd}
{bf:writeln} appends a single line of text to {it:filename}, followed by a
newline. If {it:filename} does not yet exist it is created. The file is opened
in append mode so that successive calls accumulate content.

{pstd}
{it:text} is optional; omitting it appends a blank line.

{pstd}
{bf:writeln} is the low-level building block used internally by
{help latexfigure}, {help textablehead}, {help textablefoot}, {help leanesttab},
{help texbf}, {help texspec}, {help writelntc}, and {help write_summ_stats}.

{pstd}
Original implementation by Johannes F. Schmieder, Columbia University.

{marker examples}{...}
{title:Examples}

{phang2}{cmd:. writeln output/notes.tex "\textit{Notes:} Robust standard errors."}{p_end}

{phang2}{cmd:. writeln output/table.tex "\midrule"}{p_end}

{title:Also see}
{psee}{help writelntc}, {help writetext}{p_end}

{title:Author}
{pstd}Johannes F. Schmieder, Columbia University
