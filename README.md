**ROPSIR**
This software is made to find degenerate CRISPR-CAS9 gRNA targets in genome. It was developed a software to test <br/>
different modificated Cas9 types. Main aim of ropsir is  
**Software requirements:** <br/>
*Linux system* (tested in Ubuntu 16.04, kernel version 4.15.0-30-generic, 64 cores, 1TB RAM) <br/>
*Multicore* (8+) <br/>
*Ncbi-blast+* (install - sudo apt-get install ncbi-blast+ on Ubuntu/Debian systems) <br/>
*samtools* (install - sudo apt-get install samtools) <br/>
*R language* (install - sudo apt-get install Rscript) <br/>
*blastxmlparser* (install - sudo gem install blastxmlparser) <br/>
*RNAfold* (install - sudo apt-get install rnafold) <br/>
*ssconvert* (optional, converts csv file to xls, install - sudo apt-get install ssconvert) <br/>
*gffread* (need to convert genome file to CDS sequences) - see https://github.com/gpertea/gffread <br/>

**R packages: (will be installed automatically)** <br/>
*Biostrings* <br/>
*rtracklayer* <br/>
*stringr* <br/>
*parallel* <br/>
*plyr* <br/>
*dplyr* <br/>

**Run options**
-g - genome file in FASTA file, file <br/>
-a - annotation file in GTF format, file <br/>
-s - length of a spacer sequence exclude PAM site (20, for example), integer <br/>
-u - sequence that not allowed in spacer sequence (TTT, for example), string <br/>
-p - PAM sequence, that unallowed (AA, for example), string <br/>
-t - threads number, integer <br/>
-w - size of the word in blast, integer <br/>
-d - uses only first 10 PAM sequences (T/F), bool <br/>
-pr - prefix for output csv file (string) <br/>
-k - do not delete supplementary (T/F), bool files <br/>
-sm - number of mismatches in seed region, integer <br/>
-nm - number of mismatches in non-seed region, integer <br/>
-tg - test specific gRNA sequence to find targets (GATTATAATATTCCTTGTGTTAG, for example), string <br/>
-pc - use only protein-coding sequences, ignore intergenic region (T/F), bool <br/>

**Sample run:** <br/>
*git clone https://github.com/aprezvykh/ropsir* <br/>
*install.R* <br/>
*./ropsir.sh -g data/genome.fa -a data/genome.gtf -w 7 -d T -t 16 -p AA -u TTT -pr testrun* <br/>

If you found an issue, please, report it in current repository or email me: <br/>
*aprezvykh@yandex.ru*
