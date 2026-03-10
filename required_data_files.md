# Required Data Files for Replication Package

This document lists all data files that are called, loaded, merged, or saved during the execution of the replication code. These files need to be present in the appropriate directories for successful replication.

## data/raw/

Raw input data files that are loaded but not modified:

### Individual-level Corrections
- **people_to_check_medical.dta**
  - Used in: add_indicator_solved_id.do, add_manual_rechecks.do, add_manual_rechecks_censored.do
  - Purpose: Contains medical school corrections for manual review

- **people_to_check_new.dta**
  - Used in: add_indicator_solved_id.do, add_manual_rechecks.do, add_manual_rechecks_censored.do
  - Purpose: Contains new corrections for manual review

### Institutional Crosswalks
- **osep_to_iped_rev2014.dta**
  - Used in: add_iped_codes.do
  - Purpose: Maps OSEP codes to IPED codes (2014 revision)

- **inst_labels.dta**
  - Used in: add_iped_codes.do, create_table_ranking_imputation_censored.do
  - Purpose: Contains institution names and labels

### Historical Work History Data
- **switcher_file_coding_mistake.dta**
  - Used in: clean_switchers.do
  - Purpose: Contains old switcher file with coding mistakes for comparison

- **manual_check_v1_processed.dta**
  - Used in: clean_switchers.do
  - Purpose: Processed manual corrections version 1

### Rankings Data
- **USNWR_bio_rankings_processed.dta**
  - Used in: clean_field_rankings.do
  - Purpose: US News & World Report rankings for biological sciences

- **USNWR_eng_rankings_processed.dta**
  - Used in: clean_field_rankings.do
  - Purpose: US News & World Report rankings for engineering

- **us_news_rankings_v2.dta**
  - Used in: create_table_ranking_imputation_censored.do
  - Purpose: US News general rankings version 2

### Institutional Characteristics
- **IPEDS_v2.dta**
  - Used in: clean_ipeds.do
  - Purpose: Integrated Postsecondary Education Data System data version 2

### Additional Files
- **leave_check_v4_renamed.dta**
  - Referenced in code comments
  - Purpose: Leave episode checking data

## data/output/

Processed output files created during analysis and used in subsequent steps:

### Individual-level Databases
- **individual_database_raw.dta**
  - Created by: create_individual_databases.do
  - Used in: add_institution_dummies.do, add_institution_dummies_censored.do, clean_field_rankings.do
  - Purpose: Individual-level database with all observations (raw)

- **individual_database_clean.dta**
  - Created by: create_individual_databases.do
  - Used in: add_institution_dummies.do, add_institution_dummies_censored.do
  - Purpose: Individual-level database excluding outliers (clean)

### Individual Databases with Institution Dummies
- **final_database_raw_with_dummies.dta**
  - Created by: add_institution_dummies.do, add_institution_dummies_censored.do
  - Used in: Various analysis programs
  - Purpose: Final individual-level data with institution dummies (raw)

- **final_database_clean_with_dummies.dta**
  - Created by: add_institution_dummies.do, add_institution_dummies_censored.do
  - Used in: Multiple analysis programs including create_figure_main_binscatter.do, create_figure_binscatter_additional.do, create_table_mobility_stats.do, compute_wage_prestige_elasticity_censored.do, create_table_summary_stats_censored.do, create_grouped_estimates.do
  - Purpose: Final individual-level data with institution dummies (clean)

- **final_database_clean_tenured_only.dta**
  - Purpose: Final database restricted to tenured faculty only

### Institution-level Databases
- **institution_level_database_raw.dta**
  - Created by: create_regression_database.do
  - Used in: create_table_summary_stats_censored.do, create_table_premiums_rankings_censored.do, clean_field_rankings.do
  - Purpose: Institution-level regression database (raw sample)

- **institution_level_database_clean.dta**
  - Created by: create_regression_database.do
  - Used in: Multiple analysis programs including create_table_summary_stats_censored.do, create_table_premiums_rankings_censored.do, create_figure_main_binscatter.do, create_figure_binscatter_additional.do, create_table_mobility_stats.do, create_grouped_estimates.do
  - Purpose: Institution-level regression database (clean sample)

### Fixed Effects Estimates
- **dummy_estimates_file_clean.dta**
  - Created by: create_institution_estimates.do
  - Used in: create_table_ranking_imputation_censored.do
  - Purpose: Institution fixed effects from dummy variable regression (clean)

- **dummy_estimates_file_clean_grouped.dta**
  - Created by: create_grouped_estimates.do
  - Used in: create_figure_binscatter_additional.do
  - Purpose: Grouped institution fixed effects estimates

- **dummy_estimates_file_clean_nosen.dta**
  - Purpose: Institution fixed effects without seniority controls

### Individual Fixed Effects
- **indiv_fe_estimates_clean.dta**
  - Created by: create_institution_estimates.do
  - Used in: residualize_field_censored.do, create_table_field_specific_results_censored.do, create_table_premiums_rankings_censored.do, create_table_premiums_endowment_censored.do
  - Purpose: Individual fixed effects from AKM estimation (clean)

- **indiv_fe_estimates_clean_grouped.dta**
  - Created by: create_grouped_estimates.do
  - Purpose: Grouped individual fixed effects

### Specialized Estimations
- **tenured_only_estimates_clean.dta**
  - Created by: create_tenured_only_estimates.do, create_tenured_only_estimates_censored.do
  - Used in: create_table_tenured_censored.do
  - Purpose: Institution fixed effects estimated on tenured faculty only

- **compensation_diff_file.dta**
  - Used in: create_table_cwd.do
  - Purpose: Compensating wage differentials estimates

### Rankings and Crosswalks
- **iped_university_rank_cw.dta**
  - Created by: create_iped_ranking_cw.do (missing)
  - Used in: create_table_ranking_imputation_censored.do
  - Purpose: IPED to university ranking crosswalk

- **iped_college_rank_cw.dta**
  - Created by: create_iped_ranking_cw.do (missing)
  - Used in: create_table_ranking_imputation_censored.do
  - Purpose: IPED to college ranking crosswalk

- **clean_ipeds.dta**
  - Created by: clean_ipeds.do
  - Used in: create_table_ranking_imputation_censored.do
  - Purpose: Cleaned IPEDS data

### Institution Lists
- **final_institution_list.dta**
  - Purpose: Final list of institutions in the estimation sample

## data/temporary/

Intermediate files created during data processing:

### Switcher/Non-Switcher Files
- **switcher_file.dta**
  - Created by: first_round_spell_cleaning.do
  - Used in: clean_switchers.do
  - Purpose: Individuals who switched institutions

- **switcher_file_fixed.dta**
  - Created by: clean_switchers.do
  - Used in: clean_wages.do
  - Purpose: Cleaned switcher file

- **non_switcher_file.dta**
  - Created by: first_round_spell_cleaning.do
  - Used in: clean_non_switchers.do, clean_non_switchers_censored.do
  - Purpose: Individuals who did not switch institutions

- **non_switcher_file_part2.dta**
  - Created by: clean_switchers.do
  - Used in: clean_non_switchers.do, clean_non_switchers_censored.do
  - Purpose: Additional non-switchers identified during switcher cleaning

- **non_switcher_file_fixed.dta**
  - Created by: clean_non_switchers.do, clean_non_switchers_censored.do
  - Used in: clean_wages.do
  - Purpose: Cleaned non-switcher file

### Auxiliary Files
- **auxiliary_vars.dta**
  - Created by: clean_switchers.do
  - Purpose: Auxiliary variables from old switcher file

- **file_with_sample_restrictions.dta**
  - Used in: add_individual_data.do
  - Purpose: Sample restriction indicators

- **file_cleaned_dates.dta**
  - Purpose: Work history with cleaned dates

### Manual Check Files
- **people_to_check_o.dta**
  - Created by: create_check_database.do
  - Purpose: Original list of people to check

- **people_to_check_bug_o.dta**
  - Created by: create_check_database.do
  - Purpose: People flagged due to bugs

- **people_to_check_new_o.dta**
  - Created by: create_check_database.do
  - Purpose: Newly identified people to check

- **people_to_check_medical_o.dta**
  - Created by: create_check_database.do
  - Purpose: Medical school cases to check

### Institution Crosswalks
- **institution_dummy_crosswalk_clean.dta**
  - Created by: add_institution_dummies.do, add_institution_dummies_censored.do
  - Used in: residualize_field_censored.do
  - Purpose: Maps institution codes to dummy variable numbers (clean)

- **institution_dummy_crosswalk_raw.dta**
  - Created by: add_institution_dummies.do, add_institution_dummies_censored.do
  - Purpose: Maps institution codes to dummy variable numbers (raw)

### Specialized Databases
- **job_satisfaction.dta**
  - Purpose: Job satisfaction variables

- **estimates_jobsat_fe_sat_vsat.dta**
  - Purpose: Job satisfaction fixed effects (very satisfied)

- **estimates_jobsat_fe_sat_sat.dta**
  - Purpose: Job satisfaction fixed effects (satisfied)

### Field-Specific Rankings
- **USNWR_bio_rankings_clean.dta**
  - Created by: clean_field_rankings.do
  - Used in: create_table_field_specific_results_censored.do
  - Purpose: Cleaned biological sciences rankings matched to institutions

- **USNWR_eng_rankings_clean.dta**
  - Created by: clean_field_rankings.do
  - Used in: create_table_field_specific_results_censored.do
  - Purpose: Cleaned engineering rankings matched to institutions

### SDR Processing Files (by wave)
Multiple temporary files created during SDR processing:
- cleaned_wave[year].dta
- variables_left_handle.dta
- recoded_dummies_file.dta
- converted_variables.dta

## data/additional_processing/

Files created and used for estimation procedures:

### Estimation Sample Keys
- **estimation_sample_raw_key.dta**
  - Created by: create_institution_estimates.do, create_institution_estimates_censored.do
  - Used in: add_institution_dummies.do, add_institution_dummies_censored.do
  - Purpose: Key identifying observations in estimation sample (raw)

- **estimation_sample_clean_key.dta**
  - Created by: create_institution_estimates.do, create_institution_estimates_censored.do
  - Used in: add_institution_dummies.do, add_institution_dummies_censored.do
  - Purpose: Key identifying observations in estimation sample (clean)

### Institution Dummy Crosswalks
- **institution_dummy_crosswalk_clean.dta**
  - Created by: add_institution_dummies.do, add_institution_dummies_censored.do
  - Used in: residualize_field_censored.do
  - Purpose: Institution to dummy number mapping (clean)

- **institution_dummy_crosswalk_raw.dta**
  - Created by: add_institution_dummies.do, add_institution_dummies_censored.do
  - Purpose: Institution to dummy number mapping (raw)

### Individual Fixed Effects
- **indiv_fe_estimates_clean.dta**
  - Created by: create_institution_estimates.do
  - Used in: create_table_premiums_rankings_censored.do, create_table_premiums_endowment_censored.do
  - Purpose: Individual fixed effects (clean)

- **indiv_fe_estimates_clean_grouped.dta**
  - Created by: create_grouped_estimates.do
  - Purpose: Grouped individual fixed effects (clean)

- **indiv_fe_estimates_raw.dta**
  - Created by: create_institution_estimates.do
  - Purpose: Individual fixed effects (raw)

### Connected Set Files
- **connected_set_after_final_switch.dta**
  - Created by: clean_switchers.do
  - Purpose: Connected set after final switching corrections

- **connected_set_[various filters].dta**
  - Created by: output_connected_set.do
  - Purpose: Connected set at various stages of filtering

### Medical School Lists
- **final_institution_list_medical.dta**
  - Used in: Multiple analysis programs
  - Purpose: List of institutions excluding/including medical schools

### Aggregation Files
- **agg_instcods.dta**
  - Created by: create_grouped_estimates.do
  - Used in: create_grouped_estimates.do
  - Purpose: Grouped institution codes for aggregation

### Rankings
- **university_rankings.dta**
  - Purpose: University rankings for regression analysis

- **college_rankings.dta**
  - Purpose: College rankings for regression analysis

## Summary Statistics

- **data/raw/**: ~15 essential input files
- **data/output/**: ~15 major output files
- **data/temporary/**: ~30+ intermediate processing files
- **data/additional_processing/**: ~15 estimation-specific files

## Notes

1. Many files are created and consumed within the same do file using temporary local macros
2. Files with '_raw' and '_clean' suffixes represent different sample restrictions
3. Connected set files track the evolution of the sample through various filtering stages
4. Institution dummy crosswalks are essential for AKM estimation and must be preserved
5. SDR wave-specific temporary files are numerous but follow a consistent naming pattern
