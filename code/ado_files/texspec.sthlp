{smcl}
{* *! version 1.0  2025}{...}
{viewerjumpto "Syntax" "texspec##syntax"}{...}
{viewerjumpto "Description" "texspec##description"}{...}
{viewerjumpto "Options" "texspec##options"}{...}
{viewerjumpto "Examples" "texspec##examples"}{...}

{title:Title}
{phang}
{bf:texspec} {hline 2} Append a specification indicator row to a LaTeX table

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:texspec} {cmd:using} {it:filename}{cmd:,}
{opt spec(str asis)}
{opt label(str)}

{synoptset 14 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt spec(str asis)}}space-separated list of {bf:y} and {bf:n} indicators, one per data column{p_end}
{synopt:{opt label(str)}}text for the first (label) column of the row{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{bf:texspec} appends a single row to {it:filename} that indicates which
specifications include a particular control, fixed effect, or other feature.
For each token in {opt spec()}, a {cmd:y} produces a {\tt \checkmark} in the
corresponding column and an {cmd:n} produces an empty cell. The row label is
placed in the first column.

{pstd}
The output row takes the form:

{phang2}{it:label} {bf:&} \checkmark {bf:&} {bf:&} \checkmark {bf:\\}

{pstd}
Requires the {it:amssymb} LaTeX package for {\tt \checkmark}.

{marker options}{...}
{title:Options}

{phang}
{opt spec(str asis)} a space-separated list of indicators, one per data column.
Use {cmd:y} where the specification applies and {cmd:n} where it does not.

{phang}
{opt label(str)} the row label placed in the first column. May contain LaTeX
markup.

{marker examples}{...}
{title:Examples}

{pstd}Three-column table with controls and fixed effects rows:{p_end}
{phang2}{cmd:. texspec using output/tab/reg.tex, spec(y y n) label(Individual controls)}{p_end}
{phang2}{cmd:. texspec using output/tab/reg.tex, spec(n y y) label(Firm FE)}{p_end}
{phang2}{cmd:. texspec using output/tab/reg.tex, spec(y y y) label(Year FE)}{p_end}

{title:Also see}
{psee}{help textablehead}, {help textablefoot}, {help texbf}{p_end}

{title:Author}
{pstd}César Garro-Marín, University of Edinburgh, cgarrom@ed.ac.uk
