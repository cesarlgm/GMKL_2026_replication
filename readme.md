
# Replication Package for Do Elite Universities Overpay their Faculty? (Garro-Marin, Kahn, and Lang, 2026)

## Quick Readme

### Package Overview
This public replication package contains the majority of the code required for replicating
[Garro-Marín, Kahn, and Lang (2026)](https://cesarlgm.github.io/documents/papers/AKM_paper_v1.pdf).
The analysis uses restricted-use data from the NCSES [Survey of Doctorate
Recipients](https://www.norc.org/research/projects/survey-of-doctorate-recipients.html) that cannot
be published in the package.

Full replication of the paper requires accessing the restricted-use data plus a set code scripts
that cannot be published due to the NCSES disclosure rules. See the detailed readme file contained
within this package for a full list of the undisclosed files.  These files, along with the
restricted-use data, can be accessesed through a [data-use
license](https://ncses.nsf.gov/licensing). 


### Folder structure

- `code/` contains all the code. 
   - Programs in `code/build_database` do all the data cleaning/
   - Programs in `code/data_analysis` create all tables and figures in the paper.
- All data is contained in the `data/` folder.
   - `data/raw/` contains all the raw files required to replicate the dataset.
   - `data/additional_processing/` contains intermediate files produced during the execution that are
     kept for record.
   - `data/temporary/` contains intermediate files produced during the execution that are erased afterwards.
   - `data/output/` contains all final files used for creating the tables.

Each folder contans a `readme.md` gives a quick description of the objective and structure of the folder.

### Instructions for Replication

1. Edit the **working directory** and **R library** path at the top of `code/master_do_file.do`. The lines that must be edited are appropriately indicated at the top of the code.
2. Edit the **working directory** and default **R package library path** in `code/R_setup.R`. The lines that must be edited are appropriately indicated at the top of the code. 
3. Run `code/test_R_config.do` to test that the R configuration in Stata works. If everything is
   okay, the program will display the message "R was configured successfully". 
4. Run `code/master_do_file.do`.


**Estimated runtime:** 4-5 days in the NORC servers.

### Advice:   

`code/master_do_file.do` executes replicates all the program and calls three main subroutines:
- `code/build_database/master_build.do`: cleans all the data.
- `code/build_database/correct_KSS_master.do`: computes KSS variance correction.
- `code/data_analysis/master_tables_and_figures.do`: creates all tables and figures.

`correct_KSS_master.do` is the most compuation- and time-intensive part of the code. It can take up
to 4 four days. The results from this correction are just cited in the text and are not required for
any of the tables. Replicates can **comment out** or set ``run_kss'' to "no" at the top of the
``master_do_file.do`` to run the replication without this section.


### Questions?

Any questions with this package can be referred to César Garro-Marín [(cgarrom@ed.ac.uk)](mailto:cgarrom@ed.ac.uk)

