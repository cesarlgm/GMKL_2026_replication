
#===============================================================================
# Do Elite Universities Overpay Their Faculty?
#===============================================================================
#
#	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
#				Shulamit Kahn (skahn@bu.edu)
#				Kevin Lang (lang@bu.edu)
#
#	Description: 	performs Andrews et al. variance correction for AKM estimates
#
#   Input: data/temporary/file_for_R_regression_*.csv
#          data/temporary/file_for_R_regression_collapsed_*.csv
#          code/build_database/correct_variances.R
#   Output: results/uncollapsed_variance_corrected_*.RDS
#           results/collapsed_variance_corrected_*.RDS
#					
#
#===============================================================================

source("code/R_setup.R")

#variance correction
library("lfe")
library("tidyverse")


#raw database
######################################################################
data <- read.csv("data/temporary/file_for_R_regression_raw.csv")
data_collapsed <- read.csv("data/temporary/file_for_R_regression_collapsed_raw.csv")


source("code/build_database/correct_variances.R")


all_variance <- correct_variances(data,cluster="panelid")
collapsed_variance <- correct_variances(data_collapsed,collapsed=1)

write_output(all_variance,collapsed_variance,0,"_raw")


saveRDS(all_variance,"results/uncollapsed_variance_corrected_raw.RDS")
saveRDS(collapsed_variance,"results/collapsed_variance_corrected_raw.RDS")


all_variance_nosen <- correct_variances(data,cluster="panelid",nosen=1)
collapsed_variance_nosen <- correct_variances(data_collapsed,collapsed=1,nosen=1)

write_output(all_variance_nosen,collapsed_variance_nosen,0,"_raw_nosen")

saveRDS(all_variance,"results/uncollapsed_variance_corrected_raw_nosen.RDS")
saveRDS(collapsed_variance,"results/collapsed_variance_corrected_raw_nosen.RDS")






#clean database
######################################################################
data <- read.csv("data/temporary/file_for_R_regression_clean.csv")
data_collapsed <- read.csv("data/temporary/file_for_R_regression_collapsed_clean.csv")


source("code/build_database/correct_variances.R")


all_variance <- correct_variances(data,cluster="panelid")
collapsed_variance <- correct_variances(data_collapsed,collapsed=1)

write_output(all_variance,collapsed_variance,0,"_clean")

saveRDS(all_variance,"results/uncollapsed_variance_corrected_clean.RDS")
saveRDS(collapsed_variance,"results/collapsed_variance_corrected_clean.RDS")


all_variance_nosen <- correct_variances(data,cluster="panelid",nosen=1)
collapsed_variance_nosen <- correct_variances(data_collapsed,collapsed=1,nosen=1)

write_output(all_variance_nosen,collapsed_variance_nosen,0,"_clean_nosen")

saveRDS(all_variance,"results/uncollapsed_variance_corrected_clean_nosen.RDS")
saveRDS(collapsed_variance,"results/collapsed_variance_corrected_clean_nosen.RDS")
