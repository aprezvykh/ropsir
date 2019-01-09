**ROPSIR**
This software is made to find degenerate CRISPR-CAS9 gRNA targets in genome. It was developed a software to test <br/>
different modificated Cas9 types. Main aim of ropsir is ...
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
-ts - test specific gene to find gRNA for its sequence (gene identifyer format should be <br/>
from "gene_id" column from gtf), character <br/>
-o - search for paralogs for gene (T/F) - works with -ts option, script will try to find paralogs for gene specifyed in -ts option <br/>
-c - paralogs cutoff (evalue scoring cutoff for paralogs blast) - float

**Minimum required arguments**
-g - genome file in FASTA file, file <br/>
-a - annotation file in GTF format, file <br/>
-pc - use only protein-coding sequences, ignore intergenic region (T/F), bool <br/>
-o - search for paralogs for gene (T/F)
-d - debug mode (T/F)

**Sample runs:** <br/>
*git clone https://github.com/aprezvykh/ropsir* <br/>
*sudo install.R* <br/>
1) Running ropsir to find gRNAs and targets for only protein-coding sequences <br/>
*~/ropsir_location/./ropsir.sh -g ~/ropsir_location/data/genome.fasta -a ~/ropsir_location/data/genome.gtf -t 32 -d T -t 32 -pc T -o F -pr test.1* <br/>

2) Running ropsir to find gRNAs for specific gene and find paralogs in cDNA-sequences (also finds off-targets in intergenic regions) <br/>
*~/ropsir_location/./ropsir.sh -g ~/ropsir_location/data/genome.fasta -a ~/ropsir_location/data/genome.gtf -t 32 -d T -t 32 -pc T -o T -ts YAL005C -pr test.2* <br/>

3) Running ropsir to find target genes for specific gRNA, genome-wide <br/>
*~/ropsir_location/./ropsir.sh -g ~/ropsir_location/data/genome.fasta -a ~/ropsir_location/data/genome.gtf -t 32 -d T -t 32 -pc F -tg GGTAAGATGAAGGAAACTGCCGA -o F -pr test.5 <br/>



If you found an issue, please, report it in current repository or email me: <br/>
*aprezvykh@yandex.ru*
