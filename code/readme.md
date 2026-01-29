# Code Folder

- `code/master_do_file.do` executes all the data cleaning and creates the tables and figures.
- `code/build_database` contains all the data cleaning programs.
  `code/build_database/master_build.do` calls the programs in the required order.
- Programs in `code/data_analysis` create all tables and figures in the paper.
  `code/data_analysis/master_tables_and_figures.do` calls all the required sub-programs.

## Correspondence Between Tables/Figures and Programs

| Exhibit | Panel (if applicable) | Program |
| --- | --- | --- |
| Main Figure: Figure 1 | A | `create_figure_main_binscatter.do` |
| Main Figure: Figure 1 | B | `create_figure_binscatter_additional.do` |
| Main Figure: Figure 2 |  | `create_figure_mobility_summary.do` |
| Main Table: Table 1 |  | `create_table_summary_stats.do` |
| Main Table: Table 2 |  | `create_table_variance_decomp.do` |
| Main Table: Table 3 |  | `create_table_premiums_rankings.do` |
| Main Table: Table 4 |  | `create_table_premiums_endowment.do` |
| Appendix Figure: Figure C1 |  | `create_figure_mobility_summary.do` |
| Appendix Figure: Figure C2 |  | `create_figure_mobility_summary.do` |
| Appendix Figure: Figure C3 | A | `create_figure_event_studies.do` |
| Appendix Figure: Figure C3 | B | `create_figure_event_studies.do` |
| Appendix Figure: Figure C4 | A | `create_figure_main_binscatter.do` |
| Appendix Figure: Figure C4 | B | `create_figure_binscatter_additional.do` |
| Appendix Figure: Figure C5 | A | `create_table_field_specific_results.do` |
| Appendix Figure: Figure C5 | B | `create_table_field_specific_results.do` |
| Appendix Figure: Figure C5 | C | `create_table_field_specific_results.do` |
| Appendix Figure: Figure C5 | D | `create_table_field_specific_results.do` |
| Appendix Figure: Figure C6 |  | `create_figure_event_studies.do` |
| Appendix Table: Table B1 |  | `create_table_summary_stats.do` |
| Appendix Table: Table B2 |  | `create_table_variance_decomp.do` |
| Appendix Table: Table B3 |  | `create_table_premiums_rankings.do` |
| Appendix Table: Table B4 |  | `create_table_premiums_endowment.do` |
| Appendix Table: Table B5 |  | `create_table_transition.do` |
| Appendix Table: Table B6 |  | `create_table_transition.do` |
| Appendix Table: Table B7 |  | `create_table_transition.do` |
| Appendix Table: Table B8 |  | `create_table_transition.do` |
| Appendix Table: Table B9 |  | `create_table_AKM_first_stage.do` |
| Appendix Table: Table B10 |  | `create_table_tenured.do` |
| Appendix Table: Table B11 |  | `create_table_field_specific_results.do` |
| Appendix Table: Table B12 |  | `create_table_one_step_time_varying.do` |
| Appendix Table: Table B13 |  | `create_table_one_step_estimates_w_origin.do` |
| Appendix Table: Table B14 |  | `create_table_job_satisfaction.do` |
| Appendix Table: Table B15 |  | `create_table_transition_coworker.do` |
| Appendix Table: Table B16 |  | `create_table_transition_coworker.do` |
| Appendix Table: Table A2 |  | `create_table_ranking_imputation.do` |