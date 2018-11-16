#!/usr/bin/Rscript
options(warn = -1)
print("This script will automatically install R packages and software!")
need.soft <- c("python", "blastn", "ruby", "gem", "blastxmlparser", "Rscript", "RNAfold")

install.python <- function(){
  system("sudo apt-get install python")
}
install.blast <- function(){
  system("sudo apt-get install ncbi-blast+")
}
install.ruby <- function(){
  system("sudo apt-get install ruby ruby-dev")
}
install.gem <- function(){
  system("sudo apt-get install gem")
}
install.blastxmlparser <- function(){
  system("sudo gem install bio-blastxmlparser")
}
install.r <- function(){
  system("sudo gem install r-base r-base-core")
}
install.rnafold <- function(){
  system("sudo apt-add-repository ppa:j-4/vienna-rna")
  system("sudo apt-get update")
  system("sudo apt-get install vienna-rna")
}

for(f in need.soft) {
  soft <- system(paste("which", f, sep = " "), intern = T)
  if(length(as.character(soft))<1){
    print(paste(f, "is not installed! Installing..."))
    if(soft == "python"){
      install.python()
    } else if (soft == "blastn"){
      install.blast()
    } else if (soft == "ruby"){
      install.ruby() 
    } else if (soft == "gem"){
      install.gem()
    } else if (soft == "blastxmlparser"){
      install.blastxmlparser
    } else if (soft == "Rscript"){
        install.r()
    } else if (soft == "RNAfold"){
      install.rnafold()
    }
  print(paste(f, "is installed in", soft))
  }
}


zz <- system("which kek", intern = T)

local({r <- getOption("repos")
       r["CRAN"] <- "http://cran.r-project.org" 
       options(repos=r)
})

need.pack <- c("rtracklayer","stringr", "parallel", "plyr", "dplyr", "Biostrings", "ggplot2", "gridExtra")
inst <- installed.packages()

for (f in need.pack){
  g <- grep(f, inst[,2])
  if(length(g)<1){
    print(paste(f, "is not found in you system! Installing..."))
    install.packages(f)
  } else {
    print(paste(f, "is found!"))
  }
  
}


print("All R packages installed!")
