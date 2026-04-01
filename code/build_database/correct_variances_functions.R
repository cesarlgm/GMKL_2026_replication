#===============================================================================
# Do Elite Universities Overpay Their Faculty?
#===============================================================================
# Authors:  César Garro-Marín (cgarrom@ed.ac.uk)
#           Shulamit Kahn (skahn@bu.edu)
#           Kevin Lang (lang@bu.edu)
#
# Description: Pure function library for AKM variance decomposition. Defines
#   four functions: correct_variances() runs a two-way FE regression via felm
#   and applies the Gaure (2013) leave-one-out bias correction via fevcov;
#   simul_correct_variances() repeats this pipeline for simulated compensating
#   differential variables; get_name() is a filename-construction helper;
#   write_output() serialises corrected/uncorrected variance-covariance matrices
#   and correlation matrices to CSV and RDS. No side effects when sourced.
#
# Input files:
#   - none — all functions receive data as arguments
#
# Output files (written by write_output and simul_correct_variances):
#   - results/tables/corrected_variances*.csv
#   - results/tables/collapsed_corrected_variances*.csv
#   - results/tables/uncorrected_variances*.csv
#   - results/tables/collapsed_uncorrected_variances*.csv
#   - results/tables/uncollapsed_corrected_correlations*.csv
#   - results/tables/uncollapsed_uncorrected_correlations*.csv
#   - results/tables/collapsed_corrected_correlations*.csv
#   - results/tables/collapsed_uncorrected_correlations*.csv
#   - results/tables/simul_corrected_variances_i.csv
#   - results/tables/simul_uncorrected_variances_i.csv
#   - results/uncollapsed_variance_corrected*.RDS
#   - results/collapsed_variance_corrected*.RDS
#
# Called by:
#   - replication_package/code/build_database/variance_correction.R
#   - replication_package/code/build_database/simul_variance_correction.R
#===============================================================================


correct_variances <- function(data,cluster=0,collapsed=0, nosen=0){
  
  #declare paneil id as factor
  data$panelid <- data$panelid %>% 
    as.factor()
  
  #declare institution code as factor
  data$instcod <-data$instcod %>% 
    as.factor() %>% 
    relevel(ref="166027")
  
  #creating specification of children dummies
  children <- data %>% 
    select(starts_with("has_")|starts_with("int_")) %>% 
    colnames() %>% 
    paste(.,collapse=" + ")
  
  #controls in the regression
  if (collapsed==0){ 
    #declare reference year as factor
    data$refyr <-data$refyr %>% 
      as.factor()
    
    controls <- paste("refyr+married+years_since_phd+years_since_phd_sq+tenured_f+faculty_rank_f+",children,sep="")
  }
  else {
    controls <- paste("married+years_since_phd+years_since_phd_sq+tenured_f+faculty_rank_f+",children,sep="")
  }
  #regression formula. Standard errors are clustered at the individual level
  if (nosen==0) {
    model <- formula(paste("l_r_salary~years_since_phd+years_since_phd_sq+time_current_job_f+",controls,"|instcod+panelid|0|",cluster,sep=""))
  }
  else {
    model <- formula(paste("l_r_salary~years_since_phd+years_since_phd_sq+",controls,"|instcod+panelid|0|",cluster,sep=""))
  }
  
  #estimate fixed effect regression
  estimates <- felm(model,data,cmethod = 'reghdfe',keepX=TRUE,cmethod="reghdfe")
  
  fixed_effects <- getfe(estimates)
  
  #Perform variance correction following Gaure (2013)
  corrected_variances<- fevcov(estimates,fixed_effects)
  
  
  results <- list(estimates, fixed_effects,corrected_variances)
  return(results)
}

###########################

#function for variance correction with simulated compensating differentials


simul_correct_variances <- function(data, s_start,s_end,nosen=0){
  #declare paneil id as factor
  data$panelid <- data$panelid %>% 
    as.factor()
  
  #declare institution code as factor
  data$instcod <-data$instcod %>% 
    as.factor() %>% 
    relevel(ref="166027")
  
  #creating specification of children dummies
  children <- data %>% 
    select(starts_with("has_")|starts_with("int_")) %>% 
    colnames() %>% 
    paste(.,collapse=" + ")
  
  #controls in the regression
  #declare reference year as factor
  data$refyr <-data$refyr %>% 
    as.factor()
  ##### NEW

  controls <- paste("refyr+married+years_since_phd+years_since_phd_sq+tenured_f+faculty_rank_f+",children,sep="")
  
  #regression formula. Standard errors are clustered at the individual level
  results=list()
  for (i in s_start:s_end) {
    dependent_variable <- paste("total_compensation",i, sep="")
      if (nosen==0) {
        model <- formula(paste(dependent_variable,"~years_since_phd+years_since_phd_sq+ time_current_job_f+",controls,"|instcod+panelid|0|","panelid",sep=""))
        stub <- ""
      }
      else {
        model <- formula(paste(dependent_variable,"~years_since_phd+years_since_phd_sq+",controls,"|instcod+panelid|0|","panelid",sep=""))
        stub <- "_nosen"
      }
     #estimate fixed effect regression
    estimates <- felm(model,data,cmethod = 'reghdfe',keepX=TRUE,cmethod="reghdfe")
    
    fixed_effects <- getfe(estimates)
    
    #Perform variance correction following Gaure (2013)
    output<- fevcov(estimates,fixed_effects)
    
    corrected_variances <- as.data.frame(output)
    uncorrected_variances <- as.data.frame(output+attr(output,"bias"))
    
    #store the results
    result_iter <-list(fixed_effects,corrected_variances,uncorrected_variances) 
    names(result_iter) <- c("fixed_effects", "corrected_varcov", "uncorrected_varcov")
    
    # this writes a csv w corrected variances
    file_name <- paste("results/tables/simul_corrected_variances_",i,stub,".csv",sep="")
    write_csv(corrected_variances,file_name) 
    
    # this writes a csv w uncorrected variances
    file_name <- paste("results/tables/simul_uncorrected_variances_",i,stub,".csv",sep="")
    write_csv(uncorrected_variances,file_name) 
    results [[i]] <- result_iter
  }
  return(results) 
}
  

get_name <- function(root,stub,extension,add_stub=""){
  name <- paste(root,add_stub,stub,extension,sep="")
  
  return(name)
}
  
write_output <- function(uncollapsed_output,collapsed_output,nosen=0,add_stub="") {
  if (nosen==1) {
    stub <-"_nosen"
  }
  else {
    stub <- ""
  }
  
  file_name <- get_name("results/tables/corrected_variances",stub,".csv",add_stub)
  write_csv(as.data.frame(uncollapsed_output[[3]]),file_name)
  
  file_name <- get_name("results/tables/collapsed_corrected_variances",stub,".csv",add_stub)
  write_csv(as.data.frame(collapsed_output[[3]]),file_name)
  
  #uncorrected variances
  uncorrected_variance <- uncollapsed_output[[3]]+attr(uncollapsed_output[[3]],"bias")
  uncorrected_variance_collapsed <- collapsed_output[[3]]+attr(collapsed_output[[3]],"bias")
  
  file_name <- get_name("results/tables/uncorrected_variances",stub,".csv",add_stub)
  write_csv(as.data.frame(uncorrected_variance),file_name)
  
  file_name <- get_name("results/tables/collapsed_uncorrected_variances",stub,".csv",add_stub) 
  write_csv(as.data.frame(uncorrected_variance_collapsed),file_name)
  
  
  file_name <- get_name("results/tables/uncollapsed_corrected_correlations",stub,".csv",add_stub)   
  write_csv(as.data.frame(cov2cor(uncollapsed_output[[3]])),file_name)
  
  file_name <- get_name("results/tables/uncollapsed_uncorrected_correlations",stub,".csv",add_stub)  
  write_csv(as.data.frame(cov2cor(uncorrected_variance)),file_name)
  
  
  file_name <- get_name("results/tables/collapsed_corrected_correlations",stub,".csv",add_stub)
  write_csv(as.data.frame(cov2cor(collapsed_output[[3]])),file_name)
  
  file_name <- get_name("results/tables/collapsed_uncorrected_correlations",stub,".csv",add_stub)
  write_csv(as.data.frame(cov2cor(uncorrected_variance_collapsed)),file_name)
  
  
  file_name <- get_name("results/uncollapsed_variance_corrected",stub,".RDS",add_stub)
  saveRDS(uncollapsed_output,file_name)
  
  file_name <- get_name("results/collapsed_variance_corrected",stub,".RDS",add_stub)
  saveRDS(collapsed_output,file_name)
}
  
  
  