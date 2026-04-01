#===============================================================================
# Do Elite Universities Overpay Their Faculty?
#===============================================================================
# Authors:  César Garro-Marín (cgarrom@ed.ac.uk)
#           Shulamit Kahn (skahn@bu.edu)
#           Kevin Lang (lang@bu.edu)
#
# Description: Command-line wrapper called by drop_unconnected_unis.do via
#   rscript. Accepts two arguments (input_file, output_file), loads the
#   extract_connected_set() function, computes the connected set of
#   institutions from a mover transition CSV, and writes the result to a
#   new CSV with a network indicator column.
#
# Input files:
#   - code/R_setup.R (sourced — package loading and environment setup)
#   - code/build_database/connected_set_functions.R (sourced — defines
#       extract_connected_set())
#   - data/temporary/<file_name>.csv (args[1] — mover transition list with
#       origin/destination institution pairs, semicolon-delimited)
#
# Output files:
#   - data/temporary/<file_name>_executed.csv (args[2] — connected set
#       institution list with network indicator)
#===============================================================================

source("code/R_setup.R")

source("code/build_database/connected_set_functions.R")

args <- commandArgs(trailingOnly = TRUE)

print(length(args))

if (length(args)>0){ 
  input_file <- args[1]
  output_file <- args[2]
  
  connected_set <- extract_connected_set(input_file)
  
  write.csv(connected_set,output_file,row.names = FALSE)
}



print("Connected set computed successfully")
