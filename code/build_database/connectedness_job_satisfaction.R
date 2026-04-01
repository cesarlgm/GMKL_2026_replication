#===============================================================================
# Do Elite Universities Overpay Their Faculty?
#===============================================================================
# Authors:  César Garro-Marín (cgarrom@ed.ac.uk)
#           Shulamit Kahn (skahn@bu.edu)
#           Kevin Lang (lang@bu.edu)
#
# Description: Entry-point R script called via rscript from a Stata do-file in
#   the NORC secure enclave. Sources extract_connected_set.R to obtain the
#   extract_connected_set() function, runs it on the job-satisfaction mover
#   transition file (origin/destination institution pairs), and writes the
#   resulting connected-component membership back to a CSV.
#
# Input files:
#   - code/R_setup.R
#   - code/build_database/connected_set_functions.R
#   - data/temporary/job_satisfaction_R_clean.csv
#
# Output files:
#   - data/temporary/job_satisfaction_R_clean_connectedness.csv
#===============================================================================

source("code/R_setup.R")

source("code/build_database/connected_set_functions.R")

input_file <- "data/temporary/job_satisfaction_R_clean.csv"
output_file <- "data/temporary/job_satisfaction_R_clean_connectedness.csv"
connected <- extract_connected_set(input_file)

write.csv(connected,output_file,row.names = FALSE)


print("Code has finished sucessfully")
