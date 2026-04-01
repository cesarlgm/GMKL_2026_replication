# Cross-File Dependency Audit: Missing Code Files

**Replication package root:** `replication_package/`
**Date:** 2026-03-17
**Auditor:** Stata Audit Agent
**Scope:** All `do`, `run`, `include`, and `rscript using` calls in every `.do` file under `replication_package/code/`

**Key rule applied:** If `foo.do` is called and only `foo_censored.do` exists, the call is classified as "covered by censored version" (Section 3), not as missing. If neither exists, it is truly missing (Section 1).

---

## Section 1 — Truly Missing Files

Files that are called from within the replication package and have **no** counterpart (plain or `_censored`) anywhere under `replication_package/code/`.

### 1a. Missing do-files

| # | Missing file (as called) | Called from | Line(s) |
|---|---|---|---|
| 1 | `code/build_database/global_instcod_merge.do` | `clean_switchers.do`, `clean_non_switchers_censored.do` | 43, 48 |
| 2 | `code/build_database/institution_code_corrections.do` | `clean_switchers.do`, `clean_non_switchers_censored.do` | 289, 52 |
| 3 | `code/build_database/drop_special_instcods.do` | `clean_switchers.do`, `clean_non_switchers_censored.do` | 297, 50 |
| 4 | `code/build_database/update_inst_labels.do` | `clean_switchers.do`, `clean_non_switchers_censored.do` | 410, 54 |
| 5 | `code/build_database/remaining_filters.do` | `create_individual_databases.do` | 35 |
| 6 | `code/build_database/create_one_step_estimates_varying.do` | `master_build.do` | 169 |
| 7 | `code/build_database/prepare_medical_drop.do` | `master_build.do` | 186 |
| 8 | `code/build_database/fix_ranking_fe_names.do` | `create_regression_database.do`, `create_regression_database_censored.do`, `create_table_ranking_imputation_censored.do` | 199, 199, 189 |
| 9 | `code/build_database/fix_ranking_database_names.do` | `create_regression_database.do`, `create_regression_database_censored.do`, `create_table_ranking_imputation_censored.do` | 207, 207, 197 |

### 1b. Missing R scripts

Called via `rscript using` but absent from the package:

| # | Missing R file | Called from | Line |
|---|---|---|---|
| 10 | `code/build_database/kss_correction_full.R` | `correct_KSS_master.do` | 30 |
| 11 | `code/build_database/connectedness_tenured_faculty.R` | `create_tenured_only_estimates_censored.do` | 95 |
| 12 | `code/build_database/connectedness_job_satisfaction.R` | `create_job_satisfaction_estimates_censored.do` | 75 |

R files confirmed present: `code/build_database/variance_correction.R`, `code/install_R_packages.R`, `code/R_setup.R`.

---

## Section 2 — Typos and Path Errors

### 2a. `_censured` misspelling in `master_build.do`

`master_build.do` calls five files using the misspelled suffix `_censured`. The correctly spelled `_censored` variants exist on disk and will not be found because Stata filename matching is exact.

| Called path (broken) | Correct file that exists | Line in `master_build.do` |
|---|---|---|
| `code/build_database/regression_programs_censured.do` | `regression_programs_censored.do` | 39 |
| `code/build_database/clean_non_switchers_censured.do` | `clean_non_switchers_censored.do` | 77 |
| `code/build_database/add_institution_dummies_censured.do` | `add_institution_dummies_censored.do` | 112 |
| `code/build_database/create_institution_estimates_censured` | `create_institution_estimates_censored.do` (also missing `.do` extension) | 118 |
| `code/build_database/create_regression_database_censured.do` | `create_regression_database_censored.do` | 123 |

**Fix:** In `master_build.do`, replace all five occurrences of `_censured` with `_censored`. Also add `.do` to line 118.

### 2b. Wrong-folder path for `regression_var_relabel.do`

`create_one_step_estimates.do` at line 53 calls:

```stata
do "code/data_analysis/regression_var_relabel.do"
```

The file does not exist under `data_analysis/`. It exists at:

```
code/build_database/regression_var_relabel.do
```

**Fix:** Change the path in `create_one_step_estimates.do` line 53 to `"code/build_database/regression_var_relabel.do"`.

---

## Section 3 — Calls Covered by `_censored` Version

These files are called without the `_censored` suffix, but only the `_censored` variant exists in the package. Per the audit rule, these are classified as covered — not missing — because the censored version provides the functional equivalent.

### 3a. Analysis scripts — called from `master_tables_and_figures.do`

`master_tables_and_figures.do` calls the plain (non-censored) names throughout. The orchestrator must be updated to call the `_censored` variants for the package to be executable.

| Called file (plain, broken) | `_censored` equivalent present | Line |
|---|---|---|
| `code/data_analysis/create_table_summary_stats.do` | `create_table_summary_stats_censored.do` | 20 |
| `code/data_analysis/create_table_premiums_rankings.do` | `create_table_premiums_rankings_censored.do` | 26 |
| `code/data_analysis/create_table_premiums_endowment.do` | `create_table_premiums_endowment_censored.do` | 29 |
| `code/data_analysis/create_table_one_step_estimates_w_origin.do` | `create_table_one_step_estimates_w_origin_censored.do` | 41 |
| `code/data_analysis/create_table_tenured.do` | `create_table_tenured_censored.do` | 56 |
| `code/data_analysis/create_table_field_specific_results.do` | `create_table_field_specific_results_censored.do` | 59 |
| `code/data_analysis/create_table_transition.do` | `create_table_transition_censored.do` | 62 |
| `code/data_analysis/create_table_transition_coworker.do` | `create_table_transition_coworker_censored.do` | 65 |
| `code/data_analysis/create_table_ranking_imputation.do` | `create_table_ranking_imputation_censored.do` | 68 |
| `code/data_analysis/create_figure_event_studies.do` | `create_figure_event_studies_censored.do` | 74 |

> Lines 80–89 of `master_tables_and_figures.do` are inside a `/* ... */` block comment and are not executed.

### 3b. Build-database scripts — called from `master_build.do`

| Called file (plain, broken) | `_censored` equivalent present | Line |
|---|---|---|
| `code/build_database/create_iped_ranking_cw.do` | `create_iped_ranking_cw_censored.do` | 99 |
| `code/build_database/create_institution_estimates` (no `.do`) | `create_institution_estimates_censored.do` | 142 |

---

## Section 4 — Recommended Actions

| Priority | Action |
|---|---|
| High | In `master_build.do`, fix all 5 `_censured` → `_censored` typos (lines 39, 77, 112, 118, 123). Also add `.do` extension on line 118. |
| High | In `master_tables_and_figures.do`, update all 10 plain-name calls (lines 20–74) to their `_censored` equivalents. |
| High | In `create_one_step_estimates.do` line 53, correct the path from `code/data_analysis/regression_var_relabel.do` to `code/build_database/regression_var_relabel.do`. |
| Medium | Document items 1–9 (truly missing do-files) explicitly. These are likely NORC-enclave-only scripts. Add a README note or stub files explaining they require NORC access. |
| Medium | Provide `kss_correction_full.R`, `connectedness_tenured_faculty.R`, and `connectedness_job_satisfaction.R` (items 10–12) or document that they run inside NORC. |
| Low | The hardcoded `cd "K:\Research\Kahn_BU\AKM_SDR"` at line 28 of `master_do_file.do` will fail for any external replicator. Replace with an instruction to set the working directory manually. |
