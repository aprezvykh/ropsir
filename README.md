# ropsir
This software is made to find degenerate CRISPR-CAS9 gRNA targets in genome!
Software requirements:
Linux system (tested in Ubuntu 16.04, kernel version 4.15.0-30-generic, 64 cores, 1TB RAM)
Multicore (8+)
Ncbi-blast+ (install - sudo apt-get install ncbi-blast+ on Ubuntu/Debian systems)
samtools (install - sudo apt-get install samtools)
R language (install - sudo apt-get install Rscript)
blastxmlparser (install - sudo gem install blastxmlparser)
RNAfold (install - sudo apt-get install rnafold)
ssconvert (optional, converts csv file to xls, install - sudo apt-get install ssconvert)

R packages: (will be installed automatically)
Biostrings
rtracklayer
stringr
parallel
plyr
dplyr

