# Dataset Rename Tracker

Last updated: 2026-04-01

## Renamed Datasets

### 1. `people_to_check_new` → `people_to_check_new_cases_corrected`

| File | Line | Code |
|------|------|------|
| `code/build_database/add_indicator_solved_id.do` | 91 | `use "data/raw/people_to_check_new_cases_corrected", clear` |
| `code/build_database/add_manual_rechecks_censored.do` | 43 | `use "data/raw/people_to_check_new_cases_corrected", clear` |

---

### 2. `people_to_check_new_proc` → `people_to_check_new_cases_second_pass_corrected`

| File | Line | Code |
|------|------|------|
| `code/build_database/add_new_corrected_people.do` | 33 | `use "data/raw/people_to_check_new_cases_second_pass_corrected.dta", clear` |
