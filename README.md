**ROPSIR**
This software is made to find degenerate CRISPR-CAS9 gRNA targets in genome! <br/>
**Software requirements:** <br/>
Linux system (tested in Ubuntu 16.04, kernel version 4.15.0-30-generic, 64 cores, 1TB RAM) <br/>
Multicore (8+) <br/>
Ncbi-blast+ (install - sudo apt-get install ncbi-blast+ on Ubuntu/Debian systems) <br/>
samtools (install - sudo apt-get install samtools) <br/>
R language (install - sudo apt-get install Rscript) <br/>
blastxmlparser (install - sudo gem install blastxmlparser) <br/>
RNAfold (install - sudo apt-get install rnafold) <br/>
ssconvert (optional, converts csv file to xls, install - sudo apt-get install ssconvert) <br/>

**R packages: (will be installed automatically)** <br/>
Biostrings <br/>
rtracklayer <br/>
stringr <br/>
parallel <br/>
plyr <br/>
dplyr <br/>

-g - genome file in FASTA file, file <br/>
-a - annotation file in GTF format, file <br/>
-s - length of a spacer sequence exclude PAM site (20, for example), integer <br/>
-u - sequence that not allowed in spacer sequence (TTT, for example), string <br/>
-p - PAM sequence, that unallowed (AA, for example), string <br/>
-t - threads number, integer <br/>
-w - size of the word in blast, integer <br/>
-d - uses only first 10 PAM sequences (T/F), bool <br/>
-pr - prefix for output csv file (string) <br/>


**Sample run:** <br/>
./ropsir.sh -g data/genome.fa -a data/genome.gtf -w 7 -d T -t 16 -p AA -u TTT -pr testrun <br/>
