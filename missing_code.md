# Missing Code Files in Replication Package

This document lists all do files and programs that are called in the replication code but are not currently present in the `replication_package/code/` directory.

## Missing Do Files from build_database/

### Manual Correction Programs
- **correct_inconsistent_instcods_v2.do**
  - Called from: add_indicator_solved_id.do
  - Purpose: Corrects inconsistent institution codes

- **add_old_modification_lists.do**
  - Called from: add_indicator_solved_id.do
  - Purpose: Adds old modification lists to the data

- **add_leave_check_v4.do**
  - Called from: add_indicator_solved_id.do
  - Purpose: Adds leave episode checks

- **add_new_corrected_people.do**
  - Called from: add_indicator_solved_id.do
  - Purpose: Adds newly corrected people to the database

### Institution Code Processing
- **global_instcod_merge.do** *(not approved)*
  - Called from: clean_non_switchers.do, clean_non_switchers_censored.do, first_round_spell_cleaning.do
  - Purpose: Performs global institution code merges

- **drop_special_instcods.do** *(not approved)*
  - Called from: clean_non_switchers.do, clean_non_switchers_censored.do, clean_switchers.do
  - Purpose: Drops special institution codes from the dataset

- **institution_code_corrections.do** *(not approved)*
  - Called from: clean_non_switchers.do, clean_non_switchers_censored.do, clean_switchers.do
  - Purpose: Applies institution code corrections

- **update_inst_labels.do** *(not approved)*
  - Called from: clean_non_switchers.do, clean_non_switchers_censored.do, clean_switchers.do, create_check_database.do, recompute_spell_level_variables.do, extract_spell_revision.do
  - Purpose: Updates institution labels

### Data Cleaning Programs
- **add_final_code_drops.do**
  - Called from: clean_wages.do
  - Purpose: Applies final code-based drops to the dataset

- **exclude_outliers.do**
  - Called from: clean_wages.do (3 times with different parameters)
  - Purpose: Excludes wage outliers from the dataset

- **remaining_filters.do** *(not approved)*
  - Called from: create_individual_databases.do
  - Purpose: Applies remaining data filters

### KSS Corrections
- **output_KSS_datasets.do**
  - Called from: correct_KSS_master.do
  - Purpose: Outputs datasets for KSS corrections

- **get_number_schools_per_type.do**
  - Called from: correct_KSS_master.do
  - Purpose: Computes number of schools per type for KSS

### Manual Checking and Flagging
- **add_old_corrections.do**
  - Called from: create_check_database.do
  - Purpose: Adds old corrections to check database

- **flag_people_for_correction.do**
  - Called from: create_check_database.do
  - Purpose: Flags individuals who need manual correction

### Ranking and Name Processing
- **fix_ranking_fe_names.do** *(not approved)*
  - Called from: create_table_ranking_imputation_censored.do, create_regression_database.do, create_regression_database_censored.do
  - Purpose: Fixes ranking fixed effect names

- **fix_ranking_database_names.do** *(not approved)*
  - Called from: create_table_ranking_imputation_censored.do, create_regression_database.do, create_regression_database_censored.do
  - Purpose: Fixes ranking database names

- **fix_university_ranking_names.do** *(not approved)*
  - Called from: import_rankings.do
  - Purpose: Fixes university ranking names

- **fix_college_ranking_names.do** *(not approved)*
  - Called from: import_rankings.do
  - Purpose: Fixes college ranking names

### Additional Estimation Programs
- **create_iped_ranking_cw.do** 
  - Called from: master_build.do
  - Purpose: Creates IPED ranking crosswalk

- **create_two_step_estimates_varying.do**
  - Called from: master_build.do
  - Purpose: Creates two-step estimates with time-varying effects

- **prepare_medical_drop.do**
  - Called from: master_build.do
  - Purpose: Prepares medical schools filtering

- **create_cwd_estimates.do**
  - Called from: master_build.do (commented out - possibly deprecated)
  - Purpose: Creates compensating wage differential estimates

## Missing Do Files from data_analysis/

### Main Analysis Files (only _censored versions exist)

### Missing Analysis Files
- **create_table_transition.do**
  - Called from: master_tables_and_figures.do
  - Purpose: Creates transition tables

- **number_inconsistent_movers.do**
  - Called from: master_tables_and_figures.do (commented out)
  - Note: output_number_inconsistent_movers.do exists but this variant is called

- **regression_var_relabel.do**
  - Called from: create_one_step_estimates.do
  - Purpose: Relabels regression variables

## Files with Confidentiality Markers Needing Attention

The following files contain confidentiality markers (????/XXXX) but do not have the `_censored` suffix. However, censored versions of these files already exist in the codebase:

### build_database/
- add_institution_dummies.do (censored version exists)
- add_manual_rechecks.do (censored version exists)
- clean_non_switchers.do (censored version exists)
- create_grouped_estimates.do (censored version exists)
- create_institution_estimates.do (censored version exists)
- create_job_satisfaction_estimates.do (censored version exists)
- create_regression_database.do (censored version exists)
- create_tenured_only_estimates.do (censored version exists)
- regression_programs.do (regression_programs_censured.do exists - note spelling)
- residualize_field.do (censored version exists)

**Recommendation:** Remove or archive the non-censored versions of these files to avoid accidental use with confidential data markers.

## Summary

- **Total missing do files:** 37 files
- **Files with only censored versions available:** 10 files
- **Files needing confidentiality review:** 10 files

Most missing files appear to be helper programs for data cleaning, manual corrections, and specific data transformations that may have been developed outside the replication package directory.
