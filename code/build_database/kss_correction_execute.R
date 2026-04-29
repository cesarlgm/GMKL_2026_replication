# ==============================================================================
# Do Elite Universities Overpay Their Faculty?
# ==============================================================================
#
#   Authors:    César Garro-Marín (cgarrom@ed.ac.uk)
#               Shulamit Kahn (skahn@bu.edu)
#               Kevin Lang (lang@bu.edu)
#
#   Description: Orchestrates the KSS bias correction for AKM wage
#                decompositions. Loads required libraries, sources helper
#                functions, and executes the correction for both non-collapsed
#                and collapsed mobility-group specifications.
#
#   Note: Data I/O is handled within the sourced scripts:
#         - code/build_database/kss_functions.R
#         - code/build_database/KSS_correction_not_collapsed.R
#         - code/build_database/kss_collapsed.R
#
# ==============================================================================

# --- Working directory setup --------------------------------------------------
# When called from Stata via shell, R_setup.R sets the working directory.
# When running interactively from R, comment out the source() line and set the
# working directory manually using the two lines below.
source("code/R_setup.R")

#working_dir <- "your/working/directory/here"
#setwd(working_dir)

# --- Dependencies -------------------------------------------------------------
library ("lfe")
library ("tidyverse")
library ("lattice")
library ("gridExtra")
library ("ggplot2")
library ("gmm")
library ("dplyr")
library ("testit")
library ("Rfast")
library ("ff")
library ("stringr")
library ("plyr")
library ("igraph")
library ("broom")

# --- Source KSS correction functions and implementations ----------------------
source("code/build_database/kss_functions.R")
source("code/build_database/KSS_correction_not_collapsed.R")
source("code/build_database/kss_collapsed.R")

# --- Execute corrections ------------------------------------------------------
# Run KSS correction on person-year level data (not collapsed to person means)
kss_not_collapsed()
# Run KSS correction on data collapsed to person-level means
kss_collapsed()