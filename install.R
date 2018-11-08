#!/usr/bin/Rscript
print ("This script will automatically install packages!")

need.pack <- c("rtracklayer","stringr", "parallel", "plyr", "dplyr", "Biostrings", "ggplot2", "gridExtra")
inst <- installed.packages()

for (f in need.pack){
  g <- grep(f, inst)
  if(length(g)<1){
    print(paste(f, "is not found in you system! Installing..."))
    install.packages(f)
  } else {
    print(paste(f, "is found!"))
  }
  
}


print("All R packages installed!")
