{smcl}
{* version 1.0 2026-03-17}{...}
{title:Title}

{p2colset 5 24 26 2}{...}
{p2col:{cmd:textablefoot} {hline 2}}Close a LaTeX regression table environment{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:textablefoot} {cmd:using} {it:filename}{cmd:,}
    [{opt notes(string)}
     {opt fontsize(string)}
     {opt nodate}
     {opt dofile(string)}
     {opt landscape}
     {opt scheme(string)}]


{title:Description}

{pstd}
{cmd:textablefoot} writes the closing LaTeX markup for a regression table to
an existing fragment file. It must be called after {cmd:textablehead} (which
opens the environments) and after all body rows have been written (typically
via {cmd:leanesttab}).

{pstd}
{cmd:textablefoot} appends two {cmd:\bottomrule} lines, closes the
{cmd:tabular} environment, optionally writes a {cmd:tablenotes} block, and
then closes the enclosing environments.  The exact closing sequence depends
on the {opt scheme()} option:

{pstd}
{bf:Default scheme.} Closes {cmd:threeparttable}, {cmd:adjustbox}, and
{cmd:center}.

{pstd}
{bf:AEA scheme} ({opt scheme(aea)}). Closes the {cmd:table} environment
using a different tablenotes syntax compatible with the AEA journal style.

{pstd}
If {opt landscape} is specified, a {cmd:\end{landscape}} line is appended
after all other closing markup.


{title:Options}

{phang}
{opt notes(string)} text to include as table notes inside a
{cmd:tablenotes} block. A trailing timestamp (and optionally the do-file
name) is appended to this text automatically unless {opt nodate} is given.
If omitted, no {cmd:tablenotes} block is written.

{phang}
{opt fontsize(string)} LaTeX font-size command for the notes text
(e.g., {cmd:\small}, {cmd:\scriptsize}). Default is {cmd:\footnotesize}.

{phang}
{opt nodate} suppresses the automatic "Table generated on ..." timestamp in
the table notes.

{phang}
{opt dofile(string)} if provided (and {opt nodate} is not set), appends
"Table generated with do file {it:filename}" to the table notes.

{phang}
{opt landscape} appends {cmd:\end{landscape}} as the final line of the file,
matching the {cmd:\begin{landscape}} written by {cmd:textablehead , landscape}.

{phang}
{opt scheme(string)} output scheme. Currently recognized value:
{cmd:aea} — switches to AEA-journal table environments and note formatting.
Omit for the default threeparttable layout.


{title:Examples}

{pstd}
Close a table with a note and a timestamp:

{phang2}{cmd:. textablefoot using "output/tab_main.tex", ///}{p_end}
{phang3}{cmd:notes("Standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01.")}{p_end}

{pstd}
Close a table without any notes or timestamp:

{phang2}{cmd:. textablefoot using "output/tab_main.tex", nodate}{p_end}

{pstd}
Close a landscape table in AEA style:

{phang2}{cmd:. textablefoot using "output/tab_app.tex", ///}{p_end}
{phang3}{cmd:notes("Robust standard errors.") scheme(aea) landscape}{p_end}


{title:See also}

{pstd}
{help textablehead}, {help leanesttab}


{title:Authors}

{pstd}
César Garro-Marín ({browse "mailto:cgarrom@ed.ac.uk":cgarrom@ed.ac.uk}){break}
Shulamit Kahn ({browse "mailto:skahn@bu.edu":skahn@bu.edu}){break}
Kevin Lang ({browse "mailto:lang@bu.edu":lang@bu.edu})

{pstd}
Paper: "Do Elite Universities Overpay Their Faculty?"
