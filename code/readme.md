# Code Folder

- `code/master_do_file.do` executes all the data cleaning and creates the tables and figures.
- `code/build_database` contains all the data cleaning programs.
  `code/build_database/master_build.do` calls the programs in the required order.
- Programs in `code/data_analysis` create all tables and figures in the paper.
  `code/data_analysis/master_tables_and_figures.do` calls all the required sub-programs.