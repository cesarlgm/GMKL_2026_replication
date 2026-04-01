#===============================================================================
# Do Elite Universities Overpay Their Faculty?
#===============================================================================
# Authors:  César Garro-Marín (cgarrom@ed.ac.uk)
#           Shulamit Kahn (skahn@bu.edu)
#           Kevin Lang (lang@bu.edu)
#
# Description: Defines the extract_connected_set() function, which reads a
#   semicolon-delimited CSV of institution-to-institution mover transitions,
#   builds an undirected igraph network from the origin-destination edges, and
#   returns a data frame mapping each institution code to its connected-component
#   ID. Pure function library — no side effects when sourced.
#
# Input files:
#   - None (pure function definition; the function argument `input` is a path
#     to data/temporary/<file>.csv, supplied at call time by the caller)
#
# Output files:
#   - None (returns a data frame to the caller; output is written by
#     code/build_database/exe_connected_set_extract.R)
#
# Called by: code/build_database/exe_connected_set_extract.R
#   (which is itself invoked via rscript from
#    code/build_database/drop_unconnected_unis.do)
#===============================================================================

extract_connected_set <- function(input) {
  dataset  <- read.csv(input,sep=";",stringsAsFactors = FALSE)

  
  edges <- dataset%>%
    select(instcod_origin, instcod_dest)
  
  #mapping the network
  routes_igraph <- graph_from_data_frame(d=edges,directed = FALSE)
  

  #extract the membership
  connected_set <- data.frame(clusters(routes_igraph)$membership)
  connected_set$instcod <- row.names(connected_set)
  
  row.names(connected_set) <- NULL
  colnames(connected_set) <- c("network","instcod")
  
  
  return(connected_set)
}
