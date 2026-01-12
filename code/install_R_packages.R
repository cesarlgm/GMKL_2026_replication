

args <- commandArgs(trailingOnly = TRUE)
  
if (length(args)>0){ 
  lib_path <- args[1]
  .libPaths(c(lib_path))
  
  install.packages("pacman")
  install.packages("stringdist")
  install.packages("tidyr")
  install.packages("stringr")
  install.packages("tidyverse")
  install.packages("openintro")
  install.packages("igraph")
  install.packages("lfe")
  install.packages("reshape")
  install.packages("lattice")
  install.packages("gridExtra")
  install.packages("ggplot2")
  install.packages("gmm")
  install.packages("dplyr")
  install.packages("tidyverse")
  install.packages("testit")
  install.packages("Rfast")
  install.packages("ff")
  install.packages("stringr")
  install.packages("plyr")
  install.packages("igraph")
  install.packages("broom")
}
