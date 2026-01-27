/*
*===============================================================================
*Project: Do Elite Universities Overpay Their Faculty?
*===============================================================================
*Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*			Shulamit Kahn (skahn@bu.edu)
*			Kevin Lang (lang@bu.edu) 
*
*Description: master do file for creating all tables and figures in the paper, orchestrating the complete data analysis pipeline from summary statistics to final results
*
*Input files:
*	- (Various files through called programs - see individual programs for details)
*
*Output files:
*	- (All tables and figures - see individual programs for complete list)
*===============================================================================
*/

*Table: Summary stats table (raw/clean)
do "code/data_analysis/create_table_summary_stats.do"

*Table: FE variance (raw clean)
do "code/data_analysis/create_table_variance_decomp.do"

*Table: Rankings and FE, main results
do "code/data_analysis/create_table_premiums_rankings.do"

*Table: Rankings and endowment
do "code/data_analysis/create_table_premiums_endowment.do"

*Table: Compensating wage differentials
do "code/data_analysis/create_table_cwd.do"

*Table: Results using job satisfaction as dependent variable
do "code/data_analysis/create_table_job_satisfaction.do"

*Figure: Institution pay premium and rank
do "code/data_analysis/create_figure_main_binscatter.do"

*Table: postel-vinay results
do "code/data_analysis/create_table_one_step_estimates_w_origin.do"

*Table: first stage AKM results (raw/clean)
do "code/data_analysis/create_table_AKM_first_stage.do"

*Table: creates tables summarizing direction of moves
do "code/data_analysis/create_table_mobility_stats.do"

*Figure: creates graphs summarizing direction of moves and salaries
do "code/data_analysis/create_figure_mobility_summary.do"

*Wilcoxon test
do "code/data_analysis/create_test_wilcoxon.do"

*Table: premiums for tenured faculty only
do "code/data_analysis/create_table_tenured.do"

*Table and figure: results for bio/eng phds
do "code/data_analysis/create_table_field_specific_results.do"

*Table: salary change/probability/people count by transition type
do "code/data_analysis/create_table_transition.do"

*Table: salary change/probability/people by quintile of coworker salary rank
do "code/data_analysis/create_table_transition_coworker.do"

*Ranking imputation regressions
do "code/data_analysis/create_table_ranking_imputation.do"

*Figure: binscatters grouped institutions, weighted by number of movers
do "code/data_analysis/create_figure_binscatter_additional.do"

*Figure: event studies around the move
do "code/data_analysis/create_figure_event_studies.do"

/*
*===============================================================================
*Compute additional numbers written on the text
*===============================================================================
do "code/data_analysis/output_number_leaves.do"

do "code/data_analysis/number_inconsistent_movers.do"

do "code/data_analysis/get_n_for_profit_schools.do"

do "code/data_analysis/compute_wage_prestige_elasticity.do"



