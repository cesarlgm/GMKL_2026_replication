/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Defines the grscheme program, which initializes a consistent
*					graph style for all figures in the project. Sets the plotplain
*					scheme, applies a user-specified color palette with 60% opacity,
*					and assigns lean symbols. No side effects beyond graph style
*					when called.

*   Input: 	None (no datasets read or written)
*   Output: 	Modifies active graph scheme settings in memory


*===============================================================================
*/

capture program drop grscheme
program define grscheme
    syntax, ncolor(string) palette(string) 

    
	grstyle init
	
	grstyle scheme plotplain

    grstyle set color `palette', n(`n_colors') opacity(60)
	
	symbolpalette lean, nogr
	
	grstyle set symbol `r(p)'
	
	
end
