#===============================================================================
# Do Elite Universities Overpay Their Faculty?
#===============================================================================
# Authors:  César Garro-Marín (cgarrom@ed.ac.uk)
#           Shulamit Kahn (skahn@bu.edu)
#           Kevin Lang (lang@bu.edu)
#
# Description: Entry-point script called via rscript from a Stata do-file in
#   the NORC secure enclave. Reads two command-line arguments: simul_end (last
#   simulation index) and no_seniority (0/1 flag to exclude seniority
#   controls). Loads the compensating-differentials dataset and calls
#   simul_correct_variances() (defined in correct_variances.R), which iterates
#   AKM variance corrections over simulated total compensation variables
#   total_compensation_1 ... total_compensation_simul_end.
#
# Input files:
#   - code/R_setup.R
#   - code/build_database/correct_variances_functions.R  (defines simul_correct_variances)
#   - data/temporary/file_for_R_regression_compensating_diff.csv
#
# Output files (written by simul_correct_variances inside correct_variances.R):
#   - results/tables/simul_corrected_variances_i.csv    for i in 1:simul_end
#   - results/tables/simul_uncorrected_variances_i.csv  for i in 1:simul_end
#   - (suffix _nosen appended to all outputs when no_seniority = 1)
#===============================================================================

args <- commandArgs(trailingOnly = TRUE)
simul_end <- as.numeric(args[1])
no_seniority <- as.numeric(args[2])

#setwd("K:/Research/Kahn_BU/AKM_SDR")


source("code/R_setup.R")

#variance correction
library("lfe")
library("tidyverse")

#load all the required functions

source("code/build_database/correct_variances_functions.R")

#getting the dataset
####
data <- read.csv("data/temporary/file_for_R_regression_compensating_diff.csv")

simulated_results <- simul_correct_variances(data,s_start=1,s_end=simul_end,nosen=no_seniority)

