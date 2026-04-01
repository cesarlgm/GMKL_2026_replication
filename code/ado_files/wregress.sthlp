{smcl}
{* version 1.0 2026-03-17}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{cmd:wregress} {hline 2}}Feasible GLS regression with estimated analytic weights{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:wregress} {it:depvar} [{it:indepvars}] [{cmd:if} {it:exp}]{cmd:,}
    {opt se(varname)}
    [{opt stub(string)}]
    [{it:regress_options}]


{title:Description}

{pstd}
{cmd:wregress} implements a two-step feasible GLS estimator in which the
observation-level weights are derived from the data rather than supplied
externally.

{pstd}
{bf:Step 1 (first-stage OLS).} An OLS regression of {it:depvar} on
{it:indepvars} is run and the sample indicator is recorded. Squared OLS
residuals are computed as a proxy for conditional variance.

{pstd}
{bf:Step 2 (variance model).} The squared OLS residuals are regressed on the
square of the variable named in {opt se()}. The predicted values from this
regression are used as estimates of conditional variance. Observations with a
negative predicted variance trigger a warning message.

{pstd}
{bf:Step 3 (WLS).} A WLS regression of {it:depvar} on {it:indepvars} is
estimated using analytic weights equal to the inverse of the predicted
conditional variance (1/{it:fitted_variance}).

{pstd}
All three regressions are stored as estimates using {cmd:eststo}, named
{it:stub}{cmd:fs} (first-stage OLS), {it:stub}{cmd:resid} (variance model),
and {it:stub}{cmd:ss} (final WLS).

{pstd}
This estimator is appropriate when the researcher has a natural instrument for
heteroskedasticity — for example, when AKM worker or firm fixed-effect standard
errors estimated on different-sized cells are used as precision weights in a
second-stage regression.


{title:Options}

{phang}
{opt se(varname)} specifies the variable whose squared value is used as the
regressor in the variance model (Step 2). This is typically the standard error
of an AKM fixed-effect estimate. Required.

{phang}
{opt stub(string)} prefix for the three stored estimate names. Stored estimates
will be named {it:stub}{cmd:fs}, {it:stub}{cmd:resid}, and {it:stub}{cmd:ss}.
If omitted, estimate names default to {cmd:fs}, {cmd:resid}, and {cmd:ss}.

{phang}
{it:regress_options} any additional options accepted by {cmd:regress} are
passed to all three regression steps.


{title:Saved results}

{pstd}
{cmd:wregress} is declared {cmd:eclass}. After the call, {cmd:e()} contains
the results of the final WLS regression ({it:stub}{cmd:ss}).

{pstd}
The following temporary variables are left in the dataset (within the
estimation sample):

{synoptset 16 tabbed}{...}
{synopt:{cmd:_in_sample}}indicator for observations in the first-stage sample{p_end}
{synopt:{cmd:_u_fs}}OLS residuals from Step 1{p_end}
{synopt:{cmd:_var_fs}}squared OLS residuals{p_end}
{synopt:{cmd:_e_var_fs}}predicted conditional variance from Step 2{p_end}
{synopt:{cmd:weight}}analytic weight = 1/{cmd:_e_var_fs}{p_end}
{synoptline}


{title:Examples}

{pstd}
Run a precision-weighted regression of log wages on AKM firm effects, using
the standard error of the firm effect as the heteroskedasticity instrument:

{phang2}{cmd:. wregress lnwage firm_fe, se(firm_fe_se) stub(main)}{p_end}

{pstd}
Inspect stored estimates:

{phang2}{cmd:. esttab mainfs mainss, se}{p_end}


{title:Authors}

{pstd}
César Garro-Marín ({browse "mailto:cgarrom@ed.ac.uk":cgarrom@ed.ac.uk}){break}
Shulamit Kahn ({browse "mailto:skahn@bu.edu":skahn@bu.edu}){break}
Kevin Lang ({browse "mailto:lang@bu.edu":lang@bu.edu})

{pstd}
Paper: "Do Elite Universities Overpay Their Faculty?"
