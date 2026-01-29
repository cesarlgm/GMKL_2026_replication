#===============================================================================
# Do Elite Universities Overpay Their Faculty?
#===============================================================================
#
#	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
#				Shulamit Kahn (skahn@bu.edu)
#				Kevin Lang (lang@bu.edu)
#
#	Description: 	loads programs required for setting up R
#
#===============================================================================

# UPDATE THIS LINE
# Add the appropiate R library path this line
library_path <- "\\\\de4.norc.org/NCSES/Home/marin-cesar/Documents/R/win-library/4.1"
# Modify the working directory
working_dir <- "K:/Research/Kahn_BU/AKM_SDR"

.libPaths(c(library_path))

if(!require("pacman")) install.packages("pacman")

library("pacman")

pacman::p_load("stringdist","tidyr", "stringr", "tidyverse", "openintro","igraph", "lfe")


setwd(working_dir)

