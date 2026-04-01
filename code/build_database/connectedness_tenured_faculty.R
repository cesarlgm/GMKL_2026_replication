#===============================================================================
# Do Elite Universities Overpay Their Faculty?
#===============================================================================
# Authors:  César Garro-Marín (cgarrom@ed.ac.uk)
#           Shulamit Kahn (skahn@bu.edu)
#           Kevin Lang (lang@bu.edu)
#
# Description: Entry-point script called via Stata's rscript. Extracts the
#   largest connected set of institutions from the tenured-faculty mover
#   transition file by sourcing extract_connected_set.R and writing the
#   component-membership result to a CSV.
#
# Input files:
#   - code/R_setup.R
#   - code/build_database/connected_set_functions.R (defines extract_connected_set())
#   - data/temporary/tenured_only_R_clean.csv (tenured-faculty mover transition list)
#
# Output files:
#   - data/temporary/tenured_only_R_clean_connectedness.csv
#===============================================================================

source("code/R_setup.R")

source("code/build_database/connected_set_functions.R")

input_file <- "data/temporary/tenured_only_R_clean.csv"
output_file <- "data/temporary/tenured_only_R_clean_connectedness.csv"
connected <- extract_connected_set(input_file)

write.csv(connected,output_file,row.names = FALSE)


print("Code has finished sucessfully")
