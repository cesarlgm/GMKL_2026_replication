#===============================================================================
# Do Elite Universities Overpay Their Faculty?
#===============================================================================
# Authors:  César Garro-Marín (cgarrom@ed.ac.uk)
#           Shulamit Kahn (skahn@bu.edu)
#           Kevin Lang (lang@bu.edu)
#
# Description: Implements the Postel-Vinay KSS-style variance correction for
#   institution effects. Starting from the leave-one-out connected set, adds
#   origin institution identifiers, then performs five iterative rounds of
#   network pruning (using flag_identified() to drop observations with
#   unidentified coefficients). After pruning, estimates gamma_hat on actual
#   log real salaries and computes naive variance decomposition quantities for
#   current and origin institution effects. Final results are held in memory
#   only; no output file is written. Run directly from the NORC secure enclave.
#
# Input files:
#   - code/R_setup.R
#   - code/build_database/kss_functions.R
#   - code/build_database/postel_vinay.R
#   - data/additional_processing/kss/leave_one_out.RData
#
# Output files:
#   - data/additional_processing/KSS/dkss_data.RData  (intermediate: dataset
#       with origin institution added)
#   - data/additional_processing/kss/z_matrix.RData   (intermediate: Z design
#       matrix saved after first pruning round)
#   - var_current, var_origin, n_obs, n_people, n_dest, n_orig (in memory only)
#===============================================================================

source("code/R_working_directories.R")

setwd(working_dir)

source("code/R_setup.R")

#variance correction
library("tidyverse")
library("lfe")
library("reshape")
library("lattice")
library("gridExtra")
library("ggplot2")
library("dplyr")
library("tidyverse")
library("testit")
library("Rfast")
library("ff")
library("stringr")
library("plyr")
library("panelr")

source("code/build_database/kss_functions.R")
source("code/build_database/postel_vinay.R")

load("data/additional_processing/kss/leave_one_out.RData")

dkss_data <- get_origin_institution(leave_one_out)

dkss_data <- dkss_data%>%
  arrange(panelid,refyr)

rm(leave_one_out)

save(dkss_data,file="data/additional_processing/KSS/dkss_data.RData")


load("data/additional_processing/KSS/dkss_data.RData")


#dkss_data <- leave_one_out

###############
#getting Z matrix
children <- dkss_data %>% 
  select(starts_with("has_")|starts_with("int_")) %>% 
  colnames() %>% 
  paste(.,collapse=" + ")


#standard errors are clustered at the institution level
controls <- paste("married+years_since_phd+years_since_phd_sq+tenured_f+faculty_rank_f+",children,"|0|0|","instcod",sep="")

model <- formula(paste("l_r_salary~0+",controls,sep=""))



#First round of network pruning
##############################################################################
z_matrix <- create_full_z_matrix(dkss_data,model)

save(z_matrix,file="data/additional_processing/kss/z_matrix.RData")

#Simulating gamma
load("data/additional_processing/kss/z_matrix.RData")


gamma_sim <- simulate_gamma(z_matrix)
gamma_hat <- estimate_gamma_hat(z_matrix,gamma_sim$y_sim)


identified_coefs <- as.data.frame(flag_identified(z_matrix,gamma_sim$gamma_sim,gamma_hat))

#Select appropriate columns from z_matrix
dkss_data$obs_drop <- rowsums(z_matrix[,!identified_coefs])>0

dkss_data <- dkss_data%>%
  filter(!obs_drop)


#Second round of network pruning
##############################################################################
z_matrix <- create_full_z_matrix(dkss_data,model)

gamma_sim <- simulate_gamma(z_matrix)
gamma_hat <- estimate_gamma_hat(z_matrix,gamma_sim$y_sim)

identified_coefs <- as.data.frame(flag_identified(z_matrix,gamma_sim$gamma_sim,gamma_hat))

#Select appropriate columns from z_matrix
dkss_data$obs_drop <- rowsums(z_matrix[,!identified_coefs])>0


dkss_data <- dkss_data%>%
  filter(!obs_drop)


#Third round of network pruning
##############################################################################
z_matrix <- create_full_z_matrix(dkss_data,model)

gamma_sim <- simulate_gamma(z_matrix)
gamma_hat <- estimate_gamma_hat(z_matrix,gamma_sim$y_sim)

identified_coefs <- as.data.frame(flag_identified(z_matrix,gamma_sim$gamma_sim,gamma_hat))

#Select appropriate columns from z_matrix
dkss_data$obs_drop <- rowsums(z_matrix[,!identified_coefs])>0

dkss_data <- dkss_data%>%
  filter(!obs_drop)

#Fourth round of network pruning
##############################################################################
z_matrix <- create_full_z_matrix(dkss_data,model)

gamma_sim <- simulate_gamma(z_matrix)
gamma_hat <- estimate_gamma_hat(z_matrix,gamma_sim$y_sim)

identified_coefs <- as.data.frame(flag_identified(z_matrix,gamma_sim$gamma_sim,gamma_hat))

#Select appropriate columns from z_matrix
dkss_data$obs_drop <- rowsums(z_matrix[,!identified_coefs])>0

dkss_data <- dkss_data%>%
  filter(!obs_drop)

#Fifth round of network pruning
###############################################################################
z_matrix <- create_full_z_matrix(dkss_data,model)

gamma_sim <- simulate_gamma(z_matrix)
gamma_hat <- estimate_gamma_hat(z_matrix,gamma_sim$y_sim)

identified_coefs <- as.data.frame(flag_identified(z_matrix,gamma_sim$gamma_sim,gamma_hat))

#Select appropriate columns from z_matrix
dkss_data$obs_drop <- rowsums(z_matrix[,!identified_coefs])>0

dkss_data <- dkss_data%>%
  filter(!obs_drop)

###############################################################################
#At this point I can identify all the coefficients
###############################################################################
z_matrix <- create_full_z_matrix(dkss_data,model)

gamma_hat <- estimate_gamma_hat(z_matrix,dkss_data$l_r_salary)
rownames(gamma_hat) <- colnames(z_matrix)

#Get indexes for variance decompositions
current_indexes <-startsWith(colnames(z_matrix),"instcod")
origin_indexes <-startsWith(colnames(z_matrix),"origin")

a_current <- get_A_phi(dkss_data,current_indexes)
a_lambda <- get_A_lambda(dkss_data,origin_indexes)


#Finally I compute the corrections
var_current <- get_naive_estimate(a_current,gamma_hat)
var_origin <- get_naive_estimate(a_lambda,gamma_hat)

n_obs <- nrow(dkss_data)
n_people <- length(unique(dkss_data$panelid))
n_dest <- length(unique(dkss_data$instcod))
n_orig <- length(unique(dkss_data$origin_instcod))
