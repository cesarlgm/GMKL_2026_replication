#===============================================================================
# Do Elite Universities Overpay Their Faculty?
#===============================================================================
# Authors:  César Garro-Marín (cgarrom@ed.ac.uk)
#           Shulamit Kahn (skahn@bu.edu)
#           Kevin Lang (lang@bu.edu)
#
# Description: Pure function library implementing the Postel-Vinay variance
#   identification procedure. Defines six functions used to build the design
#   matrix Z, simulate and estimate gamma coefficients via preconditioned
#   conjugate gradient, and flag identified coefficients. Has no side effects
#   when sourced; all functions return values to the caller.
#
# Input files:
#   - None (pure function definitions; requires the cPCG library)
#
# Output files:
#   - None
#
# Called by:  code/build_database/execute_postel_vinay.R
#===============================================================================
set.seed(123)

library("cPCG")



verify_leverage <- function(z_matrix,y_matrix){
  gamma_hat <- estimate_gamma_hat(z_matrix,y_matrix)
  
  y_hat <- z_matrix%*%gamma_hat
  
  high_leverage=abs(y_matrix-y_hat)<1/1000
  
  return(high_leverage)
}



simulate_gamma <- function(z_matrix){
  n_param <- ncol(z_matrix)
  
  gamma_sim <- rnorm(n_param,mean=0,sd=1)
  
  y_sim <- z_matrix%*%gamma_sim
  
  results <- list("y_sim"=y_sim,"gamma_sim"=gamma_sim)
}



get_instcod_pos <- function(z_matrix){
  to_select <- str_detect(colnames(z_matrix),"^instcod")
  
  names <- gsub("instcod|origin_instcod","",colnames(z_matrix))
  
  instcod_codes <- names[to_select]
  
  instcod_table <- as.data.frame(instcod_codes)
  colnames(instcod_table) <- c("code")
  instcod_table$type <- "instcod"
  
  to_select <-  str_detect(colnames(z_matrix),"^origin")
  origin_codes <- names[to_select]
  
  origin_table <- as.data.frame(origin_codes)
  colnames(origin_table) <- c("code")
  origin_table$type <- "origin_instcod"
  
  to_select <- str_detect(colnames(z_matrix),"^(instcod|origin_instcod)")
  
  result <- list("table"=rbind(instcod_table,origin_table),"index"=to_select)
  return(result)
}


#Have not finished setting up this function
estimate_gamma_hat <- function(z_matrix,y_sim){
  A_matrix <- crossprod(z_matrix,z_matrix)
  
  b_matrix <- crossprod(z_matrix,y_sim)
  
  
  gamma_hat <-pcgsolve(A_matrix,b_matrix) 
  return(gamma_hat)
}


flag_identified <- function(z_matrix,gamma_sim,gamma_hat){
  
  identified_flag <- abs(gamma_hat-gamma_sim)<=0.01

  rownames(identified_flag) <- colnames(z_matrix)
  
  return(identified_flag)
}



get_origin_institution <- function(estimation_data){
  data <- estimation_data%>%
    select(panelid, acad_spell_id,instcod)%>%
    distinct()%>%
    arrange(panelid, acad_spell_id)%>%
    add_count(panelid,name="n_periods")%>%
    filter(n_periods>1)%>%
    select(-n_periods)
  
  panel <-data%>%
    panel_data(id=panelid,wave=acad_spell_id)%>%
    group_by(panelid)%>%
    arrange(acad_spell_id)
  
  lag <- panel%>%
    mutate(acad_spell_id=acad_spell_id+1)%>%
    dplyr::rename(origin_instcod=instcod)
    
  
  panel <- merge(panel,lag,by=c("panelid","acad_spell_id"),all.x=TRUE)
  
  levels(panel$origin_instcod) <- c(levels(panel$origin_instcod),"school")
  
  panel$origin_instcod[is.na(panel$origin_instcod)] <- "school"
  
  panel <- panel%>%
    select(-instcod)
  
  result <- merge(estimation_data,panel,by=c("panelid","acad_spell_id"))
  
  return(result)
}


create_full_z_matrix <- function(estimation_data, model){
  #This is the design matrix for the main variables
  S_temp <- felm(model,data=estimation_data,keepX=TRUE,cmethod="reghdfe")$X
  
  S_temp2 <- model.matrix(~0+instcod,data=estimation_data)
  S_temp2 <- S_temp2[,colMeans(S_temp2)!=0]
  S_temp2 <- S_temp2[,-1]
  S_temp3 <- model.matrix(~0+panelid,data=estimation_data)
  S_temp3 <- S_temp3[,colMeans(S_temp3)!=0]
  S_temp3 <- S_temp3[,-1]
  S_temp4 <- model.matrix(~0+origin_instcod,data=estimation_data)
  S_temp4 <- S_temp4[,colMeans(S_temp4)!=0]  
  S_temp4 <- S_temp4[,-1]
  
  S_temp2 <- cbind(S_temp2,S_temp4,S_temp3)
  
  rm(S_temp3)
  
  Z <- cbind(S_temp2,S_temp)  
  
  return(Z)
}


#next, I need to erase all observations with unidenfied effects.


