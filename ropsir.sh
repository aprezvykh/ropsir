#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
echo "This script is used to found degenerate gRNA in CRISPR-Cas9 system"
echo "Developed by Alexander Rezvykh, aprezvykh@yandex.ru"
echo "______________________________________________________________________________________________________________________________"
echo "Arguments:"
echo "-g|--genome_fasta (filepath) - genome file in FASTA file"
echo "-s|--spacer_length (integer) - length of a spacer sequence exclude PAM site (20, for example)"
echo "-u|--unallowed_spacer_string (character) - sequence that not allowed in spacer sequence (TTT, for example)"
echo "-p|--unallowed_pam_end (character) - PAM sequence, that unallowed (AA, for example)"
echo "-t|--number_of_threads (integer) - threads number"
echo "-w|--word_size (integer) - size of the word in blast (increasing word size will increase number of short and gapped alignments) "
echo "-a|--annotation_file (filepath) - annotation file in GTF format"
echo "-d|--debug (logical, T/F) - uses only first 10 PAM sequences "
echo "-pr|-prefix (will be used in final result file)"
echo "-k|--keep_all_files - used for debug. Do not delete all supplementary files"
echo "-sm|--seed_mismatch - number of mismatches in seed region"
echo "-nm|--non_seed_mismatch - number of mismatches in non-seed region"
echo "-tg| --test_grna - read gRNA sequence and find targets for specified genome ang GTF"
echo "-pc|--protein_coding_only - use only proteing-coding sequences if T, if F - use all genome (including intergenic) "

banner ROPSIR

###Positional args parse

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -g|--genome)
    genome="$2"
    shift
    shift
    ;;
    -s|--spacer_length)
    spacer_length="$2"
    shift
    shift 
    ;;
    -u|--unallowed_spacer_string)
    unallowed_spacer_string="$2"
    shift
    shift 
    ;;
    -p|--unallowed_pam_end)
    unallowed_pam_end="$2"
    shift
    shift
    ;;
    -t|--numbwer_of_threads)
    threads="$2"
    shift 
    shift
    ;;
   -w|--word_size)
    word_size="$2"
    shift
    shift
    ;;
    -d|--debug)
    debug="$2"
    shift
    shift
    ;;
    -a|--annotation_file)
    annotation_file="$2"
    shift
    shift
    ;;
    -pr|--prefix)
    prefix="$2"
    shift
    shift
    ;;
    -k|--keep_all_files)
    prefix="$2"
    shift
    shift
    ;;
    -sm|--seed_mismatch)
    seed_mismatch="$2"
    shift
    shift
    ;;
    -nm|--non_seed_mismatch)
    non_seed_mismatch="$2"
    shift
    shift
    ;;
    -tg|--test_grna)
    test_grna="$2"
    shift
    shift
    ;;
    -pc|--protein_coding_only)
    protein_coding_only="$2"
    shift
    shift
    ;;

esac
done

curr_exec_dir=$(pwd)
script_dir=$(dirname $0 | tr -d '.')
#echo $curr_exec_dir
#echo $script_dir

###testing if positional args missing

if [[ -z "$genome" ]]
	then
		echo "Genome must be specified, nowhere to look for spacer sites!"
		exit 0
	fi

if [[ -z "$prefix" ]]
        then
                echo "Prefix non set! Setting..."
                prefix=$(date +"%m-%d-%Y-%H-%M")
        fi


if [[ -z "$annotation_file" ]]
	then
		echo "Genome annotation file must be specified!"
		exit 0
	fi

if [[ -z "$spacer_length" ]]
	then
		echo "Spacer length not set! Setting default (20)"
		spacer_length=20
	fi

if [[ -z "$unallowed_spacer_string" ]]
	then
		echo "Unallowed spacer string not set! Setting default (TTT)"
		unallowed_spacer_string="TTT"
	fi

if [[ -z "$unallowed_pam_end" ]]
	then
		echo "Unallowed PAM end has not set! Setting default (AA)"
		unallowed_pam_end="AA"
	fi

if [[ -z "$threads"  ]]
	then
		echo "Threads variable not set! Setting default (nproc output)"
		threads= $( $(nproc) / 2)
	fi

if [[ -z "$word_size"  ]]
        then
                echo "BLAST word size is not set! Setting default (10)"
                word_size=10
        fi

if [[ -z "$seed_mismatch"  ]]
        then
                echo "Seed mismatch threshold is not set! Setting default (2)"
                seed_mismatch=2
        fi

if [[ -z "$non_seed_mismatch"  ]]
        then
                echo "Non seed mismatch threshold is not set! Setting default (4)"
                non_seed_mismatch=4
        fi


set -- "${POSITIONAL[@]}" # restore positional parameters

echo GENOME FILE IS SET TO = "${genome}"
echo SPACER LENGTH IS SET TO   = "${spacer_length}"
echo UNALLOWED STRINGS IN SPACERS IS SET TO    = "${unallowed_spacer_string}"
echo UNALLOWER PAM END IS SET TO         = "${unallowed_pam_end}"
echo THREADS IS SET TI = "${threads}"
echo SCRIPT EXECUTION DIR IS $pwd

all_ngg_sequences=$curr_exec_dir/potential_ngg.fasta
all_ngg_sequences_dbg=$curr_exec_dir/potential_dbg_ngg.fasta
all_ngg_sequences_space=$curr_exec_dir/potential_ngg.fasta.parsed
final_spacers=$curr_exec_dir/ngg.headers.fasta

###checking dependenciesт

cpu_n=$(nproc)
if [[ $cpu_n -lt 5 ]]
	then
		echo "${RED}WARNING! CPU CORES ON YOUR SYSTEM IS LESS THEN 4! EXECUTING OF THIS SCRIPT MAY TAKE A WHILE!${NC}"
	else
		echo "Thread number is $cpu_n"
	fi


is_blastn=$(which blastn | wc -l)
if [[ $is_blastn -eq 1 ]]
	then
		echo "blastn found!"
	elif [[ $is_blastn -ge 1 ]]
	then
		echo "Multiple blastn versions found "
	elif [[ $is_blastn -eq 0 ]]
	then
		echo -e "Cannot found blastn in system! Install blastn: ${RED}sudo apt-get install ncbi-blast+${NC}"
		exit 0
	fi

is_rlang=$(which Rscript | wc -l)
if [[ $is_rlang -eq 1 ]]
        then
                echo "rscript found!"
        elif [[ $is_rlang -ge 1 ]]
        then
                echo "Multiple rscript versions found "
        elif [[ $is_rlang -eq 0 ]]
        then
                echo -e "Cannot found blastn in system! Install rscript: ${RED}sudo apt-get install r-base-core${NC}"
                exit 0
        fi

is_blast2bam=$(which blastxmlparser | wc -l)
if [[ $is_blast2bam -eq 1 ]]
        then
                echo "blastxmlparser found!"
        elif [[ $is_blast2bam -eq 0 ]]
        then
                echo -e "Cannot found blastxmlparser in system! Install blastxmlparser: ${RED}sudo gem instal blastxmlparser${NC}"
                exit 0
        fi

is_rnafold=$(which RNAfold | wc -l)
if  [[ $is_rnafold -eq 1 ]]
	then
		echo "RNAfold found"
	else
		echo "RNAfold not found! Install RNAfold: ${RED}sudo apt-get install rnafold${NC}"

	fi

is_ssconvert=$(which ssconvert | wc -l)
if  [[ $is_rnafold -eq 1 ]]
        then
                echo "ssconvert found"
        else
                echo "ssconvert not found! Install RNAfold: ${RED}sudo apt-get install ssconvert${NC}"

        fi


genome_size=$(cat $genome | wc | awk '{print $3-$1}')
spacer_regexp=$(yes '.' | head -n $spacer_length | tr -d '\n')

if [ $protein_coding_only = "T" ] || [ $protein_coding_only = "t" ]
	then
		echo "Using only protein-coding sequences!"
		genome_cds=$curr_exec_dir/genome_cds.fasta
		gffread -w $genome_cds -W -O -E -L -F -g $genome $annotation_file
		genome=$genome_cds
	elif [ $protein_coding_only = "F" ] || [ $protein_coding_only = "F" ]
		then
			echo "Using all genome!"
fi

if [[ ! -z "$test_grna" ]]
	then
		parse_tsv_flag=TRUE
		testgrna_file=testgrna.fasta
		echo "Testing gRNA with sequence $test_grna"
		echo ">test_gRNA" > testgrna.fasta
		echo $test_grna > testgrna.fasta
		blastb_dir=$(dirname $genome)
		is_blastdb=$(ls $blastdb_dir | grep ".nin" | wc -l)
		if [[ $is_blastdb -eq 0 ]]
        		then
                		echo "BLAST database not found! Creating..."
               		 	makeblastdb -in $genome -dbtype nucl
        		else
                		echo "BLAST database found! Using existing..."
        	fi
		echo "Aligning spacer seqiences to reference genome! Evaluating XML blast output"
		echo "XML blast"
		blastn -task 'blastn-short' -db $genome -query $testgrna_file -num_threads $threads -word_size $word_size -outfmt 5 -evalue 100 > blast.xml
		echo "tabular BLAST"
		blastn -task 'blastn-short' -db $genome -query $testgrna_file -num_threads $threads -word_size $word_size -outfmt 6 -evalue 100 > blast.outfmt6
		blastxmlparser --threads $threads -n 'hit.score, hsp.evalue, hsp.qseq, hsp.midline' blast.xml > blast.tsv
		RNAfold $testgrna_file --noPS | grep ". (" | awk '{print $3}' | sed 's/)//' > energies.txt
		$script_dir/./parse_tsv_single_gRNA.R $(pwd) $annotation_file $prefix $threads $seed_mismatch $non_seed_mismatch
		echo "Done! Purging..."
		rm blast.xml blast.tsv blast.outfmt6 energies.txt testgrna.fasta
		ls *.csv | parallel 'ssconvert {} {.}.xls'
		exit 0
fi



echo "Regular expression used in search is $spacer_regexp"
cat $genome | grep -oh "$spacer_regexp.[AG][AG]" | grep -v "$unallowed_spacer_string" | grep -v "$unallowed_pam_end$" > $all_ngg_sequences

ngg_length=$(cat $all_ngg_sequences | wc -l)

echo "Genome size is $genome_size"

if [[ $ngg_length -eq 0 ]]
	then
		echo "Genome file is not valid, lengh of spacer sequences is 0! Check genome file"
		exit 0
	else
		echo "We got $ngg_length spacer sequences! Good! Let's move on!"
	fi


#add empty lines to sites file

if [ $debug = "T" ] || [ $debug = "t" ]
	then
		echo "Debug mode is true, cutting $all_ngg_sequences"
		head -n 60 $all_ngg_sequences > $all_ngg_sequences_dbg
	elif [[ $debug -eq "F" ]]
		then
			echo "Debug mod off! Do nothing!"
fi

echo "Adding empty lines to $all_ngg_sequences"

if [ $debug = "T" ] || [ $debug = "t" ]
	then
		awk ' {print;} NR % 1 == 0 { print ">"; }' $all_ngg_sequences_dbg > $all_ngg_sequences_space
	else
		awk ' {print;} NR % 1 == 0 { print ">"; }' $all_ngg_sequences > $all_ngg_sequences_space
fi

echo "Executing R script, adding fasta headers for each spacer and GC content calculation!"
echo "Some useless information may be printed below:"


$script_dir/./enter_fasta_headers.R $curr_exec_dir

blastb_dir=$(dirname $genome)
is_blastdb=$(ls $blastdb_dir | grep ".nin" | wc -l)

if [[ $is_blastdb -eq 0 ]]
	then
		echo "BLAST database not found! Creating..."
		makeblastdb -in $genome -dbtype nucl
	else
		echo "BLAST database found! Using existing..."
	fi

echo "Aligning spacer seqiences to reference genome! Evaluating XML blast output"
echo "XML blast"
blastn -task 'blastn-short' -db $genome -query $final_spacers -num_threads $threads -word_size $word_size -outfmt 5 -evalue 100 > blast.xml
echo "tabular blast"
blastn -task 'blastn-short' -db $genome -query $final_spacers -num_threads $threads -word_size $word_size -outfmt 6 -evalue 100 > blast.outfmt6
echo "Evaluating XML parser"
blastxmlparser --threads $threads -n 'hit.score, hsp.evalue, hsp.qseq, hsp.midline' blast.xml > blast.tsv

blastn_x=$(cat blast.tsv | wc -l)
blast_f=$(cat blast.outfmt6 | wc -l)

echo "Executing RNAfold!"
RNAfold $final_spacers --noPS | grep "\\." | sed 's/[^ ]* //' | sed 's/)//' | sed 's/(//' > energies.txt

echo "Executing final R script!"
$script_dir/./parse_tsv.R $(pwd) $annotation_file $prefix $threads $seed_mismatch $non_seed_mismatch $protein_coding_only

echo "Done! Purging..."

rm $curr_exec_dir/blast.xml $curr_exec_dir/blast.tsv $curr_exec_dir/blast.outfmt6 $curr_exec_dir/energies.txt $curr_exec_dir/potential_dbg_ngg.fasta $curr_exec_dir/potential_ngg.fasta $curr_exec_dir/potential_ngg.fasta.parsed $curr_exec_dir/ngg.headers.fasta $script_dir/genome_cds.*

echo "Converting to XLS! (ssconvert warning about X11 display is non-crucial, just skip it :) )"
ls *.csv | parallel 'ssconvert {} {.}.xls'
