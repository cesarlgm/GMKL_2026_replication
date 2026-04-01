{smcl}
{* version 1.0 2026-03-17}{...}
{title:Title}

{p2colset 5 22 24 2}{...}
{p2col:{cmd:grscheme} {hline 2}}Initialize project graph style scheme{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:grscheme}{cmd:,} {opt ncolor(#)} {opt palette(name)}


{title:Description}

{pstd}
{cmd:grscheme} initializes a consistent graph style for all figures in the
"Do Elite Universities Overpay Their Faculty?" project. It calls {cmd:grstyle init},
sets the base scheme to {it:plotplain}, applies the requested color palette
(at 60% opacity) via {cmd:grstyle set color}, and assigns lean marker symbols
via {cmd:symbolpalette lean}. This program has no side effects beyond modifying
the active graph style settings. It should be called once at the top of any
do-file that produces figures.

{pstd}
{cmd:grscheme} requires the community-contributed packages {cmd:grstyle} and
{cmd:palettes} (with the {cmd:colorpalette} and {cmd:symbolpalette} sub-commands).


{title:Options}

{phang}
{opt ncolor(#)} specifies the number of colors to request from the palette.
This is passed directly as the {it:n()} argument to {cmd:grstyle set color}.
Required.

{phang}
{opt palette(name)} specifies the name of the color palette to use, as
understood by {cmd:colorpalette} (e.g., {it:Set1}, {it:tableau}, {it:cblind}).
Required.


{title:Examples}

{pstd}
Initialize a 4-color Set1 palette:

{phang2}{cmd:. grscheme, ncolor(4) palette(Set1)}{p_end}

{pstd}
Initialize a 2-color colorblind-safe palette:

{phang2}{cmd:. grscheme, ncolor(2) palette(cblind)}{p_end}


{title:Dependencies}

{pstd}
Requires {cmd:grstyle} (Jann 2018) and {cmd:palettes} (Jann 2018), both
available from SSC:

{phang2}{cmd:. ssc install grstyle}{p_end}
{phang2}{cmd:. ssc install palettes}{p_end}
{phang2}{cmd:. ssc install colrspace}{p_end}


{title:Authors}

{pstd}
César Garro-Marín ({browse "mailto:cgarrom@ed.ac.uk":cgarrom@ed.ac.uk}){break}
Shulamit Kahn ({browse "mailto:skahn@bu.edu":skahn@bu.edu}){break}
Kevin Lang ({browse "mailto:lang@bu.edu":lang@bu.edu})

{pstd}
Paper: "Do Elite Universities Overpay Their Faculty?"
