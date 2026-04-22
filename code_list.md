# Replication Package Code List

Track whether each file has been reviewed/modified for the resubmission.

---

## Root (`code/`)

- [ ] `install_R_packages.R`
- [X] `master_do_file.do`
- [ ] `R_setup.R`
- [ ] `R_working_directories.R`
- [X] `stata_setup.do`

---

## `code/ado_files/`

- [ ] `grscheme.ado`
- [ ] `grscheme.sthlp`
- [ ] `leanesttab.ado`
- [ ] `leanesttab.sthlp`
- [ ] `texspec.ado`
- [ ] `texspec.sthlp`
- [ ] `textablefoot.ado`
- [ ] `textablefoot.sthlp`
- [ ] `textablehead.ado`
- [ ] `textablehead.sthlp`
- [ ] `wregress.ado`
- [ ] `wregress.sthlp`
- [ ] `writeln.ado`
- [ ] `writeln.sthlp`

---

## `code/build_database/`

- [X] `add_indicator_solved_id.do`
- [X] `add_individual_data.do`
- [X] `add_institution_dummies.do`
- [X] `add_institution_dummies_censored.do`
- [X] `add_iped_codes.do`
- [X] `add_leave_check_v4_censored.do`
- [X] `add_manual_rechecks_censored.do`
- [X] `add_new_corrected_people.do`
- [X] `add_old_corrections.do`
- [X] `add_old_modification_lists_censored.do`
- [X] `check_n_movers.do`
- [X] `clean_field_rankings.do`
- [X] `clean_ipeds.do`
- [X] `clean_non_switchers.do`
- [X] `clean_non_switchers_censored.do`
- [X] `clean_wages.do`
- [X] `connected_set_execute.R`
- [X] `connected_set_functions.R`
- [X] `connectedness_job_satisfaction.R`
- [X] `connectedness_tenured_faculty.R`
- [X] `correct_inconsistent_instcods_v2_censored.do`
- [X] `correct_KSS_master.do`
- [X] `correct_variances_execute.R`
- [X] `correct_variances_functions.R`
- [X] `create_check_database.do`
- [X] `create_demographics.do`
- [X] `create_grouped_estimates.do`
- [X] `create_individual_databases.do`
- [X] `create_institution_estimates.do`
- [X] `create_iped_ranking_cw_censored.do`
- [X] `create_job_satisfaction_estimates.do`
do`
- [X] `create_one_step_estimates.do`
- [X] `create_panel_variables.do`
- [X] `create_regression_database.do`
- [X] `create_tenured_only_estimates.do`
- [X] `create_work_history_input.do`
- [X] `create_work_variables.do`
- [X] `depurate_dates_missing_ipeds.do`
- [X] `destring_numeric_variables.do`
- [X] `drop_unconnected_unis.do`
- [X] `exclude_outliers.do`
- [X] `extract_spell_revision.do`
- [X] `first_round_spell_cleaning.do`
- [X] `flag_leave_episodes.do`
- [X] `flag_people_for_correction.do`
- [X] `flag_spell_inconsistencies.do`
- [X] `get_number_schools_per_type.do`
- [X] `import_rankings.do`
- [X] `impute_rankings.do`
- [X] `limit_to_estimation_sample.do`
- [X] `master_build.do`
- [X] `output_connected_set.do`
- [X] `output_KSS_datasets.do`
- [X] `output_n_problem_obs.do`
- [X] `output_R_dataset.do`
- [X] `postel_vinay.R`
- [X] `process_sdr_files.do`
- [X] `recode_dummy_variables.do`
- [X] `recompute_spell_level_variables.do`
- [X] `regression_programs.do`
- [X] `relabel_restricted_file.do`
- [X] `residualize_field.do`
- [X] `residualize_field_censored.do`
- [ ] `simul_variance_correction.R`
- [X] `state_names_rankings.do`
- [X] `update_acad_spell_id.do`
- [X] `update_observation_type.do`

---

## `code/data_analysis/`

- [X] `compute_wage_prestige_elasticity_censored.do`
- [X] `create_figure_binscatter_additional.do`
- [X] `create_figure_event_studies_censored.do`
- [X] `create_figure_main_binscatter.do`
- [X] `create_figure_mobility_summary.do`
- [X] `create_table_AKM_first_stage.do`
- [ ] `create_table_cwd.do`
- [X] `create_table_field_specific_results_censored.do`
- [X] `create_table_job_satisfaction.do`
- [X] `create_table_mobility_stats.do`
- [X] `create_table_one_step_estimates_w_origin_censored.do`
- [X] `create_table_one_step_time_varying.do`
- [X] `create_table_premiums_endowment_censored.do`
- [X] `create_table_premiums_rankings_censored.do`
- [ ] `create_table_ranking_imputation_censored.do`
- [ ] `create_table_summary_stats_censored.do`
- [ ] `create_table_tenured_censored.do`
- [ ] `create_table_transition_censored.do`
- [ ] `create_table_transition_coworker_censored.do`
- [ ] `create_table_variance_decomp.do`
- [ ] `create_test_wilcoxon.do`
- [ ] `get_n_for_profit_schools.do`
- [ ] `master_tables_and_figures.do`
- [ ] `output_number_inconsistent_movers.do`
- [ ] `output_number_leaves.do`
- [ ] `regression_var_relabel.do`
