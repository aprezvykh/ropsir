#!/usr/bin/Rscript
library(rtracklayer,warn.conflicts = FALSE,quietly = TRUE)
library(stringr,warn.conflicts = FALSE,quietly = TRUE)
library(parallel,warn.conflicts = FALSE,quietly = TRUE)
library(plyr,warn.conflicts = FALSE,quietly = TRUE)
library(dplyr,warn.conflicts = FALSE,quietly = TRUE)
library(ggplot2,warn.conflicts = FALSE,quietly = TRUE)
library(gridExtra,warn.conflicts = FALSE,quietly = TRUE)

args <- commandArgs()

dir <- args[6]
gtf.path <- args[7]
prefix <- args[8]
threads <- args[9]
seed.mismatch <- args[10]
non.seed.mismatch <- args[11]

seed.mismatch <- as.numeric(seed.mismatch)
non.seed.mismatch <- as.numeric(non.seed.mismatch)

cl <- makeCluster(threads,type = "FORK")
setwd(dir)

print(paste("Using", threads, "threads!"))

tab <- read.delim("blast.outfmt6",header = F,stringsAsFactors = F)
pam <- read.delim("blast.tsv",header = F, stringsAsFactors = F)
df <- bind_cols(tab,pam)

letter.freq <- function(x){
  ss <- summary(as.factor(unlist(strsplit(x, NULL))))
  gc <- 100*((ss[3] + ss[2])/23)
  return(gc)
}

get.mm.pos <- function(x){
  paste(as.character(gregexpr(pattern ='X',x)[[1]]), collapse = ",")
}

parse.mismatch.string <- function(x){
  cc.cp <- as.numeric(strsplit(x, ",")[[1]])
  if(length(which(cc.cp < 10))> non.seed.mismatch){
    return("novalid")
  } else if(length(which(cc.cp > 10)) > seed.mismatch){
    return("novalid")
  } else {
    return("valid")
  }
  
}

reconstruct.cigar <- function(x){
  st <- x[["sticks"]]
  ll <- seq(x[["qstart"]], x[["qend"]])
  ll.min <- as.numeric(min(ll))
  ll.max <- as.numeric(max(ll))
  right.ll <- length(seq(ll.max,23))
  left.ll <- length(seq(1,ll.min))
  pp <- paste(paste(rep(" ", left.ll), sep = "", collapse = ""),
              st,
              paste(rep(" ", right.ll),sep = "", collapse = ""),
              collapse = "", sep = "")
  pp <- str_sub(pp, start=2)
  pp <- gsub('.$', "", pp)
  return(pp)
}

count.total.mismatches <- function(x){
  str_count(x,pattern = "X")
}

get.loci <- function(x){
  sgtf <- gtf[gtf[["seqnames"]] == x[["sseqid"]],]
  sub.sgtf <- sgtf[sgtf[["start"]] <= x[["sstart"]],]
  sub.sgtf <- sub.sgtf[sub.sgtf[["end"]] >= x[["send"]],]
  ret.gene <- unique(sub.sgtf[["gene_id"]])
  ret.regions <- paste(as.character(unique(sub.sgtf[["type"]])),collapse = ",")  
  if(identical(ret.gene, character(0))){
    ret.gene <- c("intergenic")
  } else {
    ret.gene <- unique(sub.sgtf[["gene_id"]])
  }
  return(paste(ret.gene[1]))
}

exit <- function() {
  .Internal(.invokeRestart(list(NULL, NULL), NULL))
}


gtf <- as.data.frame(import(gtf.path))
fasta <- read.delim("ngg.headers.fasta", header = F)
energies <- read.table("energies.txt", header = F)
headers <- as.character(fasta[grep(">", fasta$V1),])
seqs <- as.character(fasta[grep(">", fasta$V1, invert = T),])
spacer.seqs <- data.frame(headers,seqs)
spacer.seqs$headers <- gsub(">", "", spacer.seqs$headers)
#energies[nrow(spacer.seqs) + 1,] <- 0
energies$name <- spacer.seqs$headers
names(energies) <- c("val", "name")

names(df) <- c("qseqid",
               "sseqid",
               "pident",
               "length",
               "mismatch",
               "gapopen", 
               "qstart", 
               "qend", 
               "sstart", 
               "send", 
               "evalue", 
               "bitscore",
               "aa",
               "bb",
               "cc",
               "dd",
               "ee",
               "seq",
               "sticks")
df$ee <- NULL

mm.sum <- as.numeric(seed.mismatch + non.seed.mismatch)
clusterExport(cl, "gtf")
print("reconstructing cigar...")
df$recon.cigar <- parApply(cl = cl, X = df, MARGIN = 1, FUN = reconstruct.cigar)
df$recon.cigar <- gsub(" ", "X", df$recon.cigar)
print("Counting mismatches...")
df$total.mm <- unlist(lapply(df$recon.cigar, count.total.mismatches))
df <- df[df$total.mm < mm.sum,]
print("getting mismatch position...")
df$mm.pos <- unlist(parLapply(cl = cl, X = df$recon.cigar,fun = get.mm.pos))
print("parsing mismatch string...")
df$val <- unlist(parLapply(cl = cl, X = df$mm.pos, fun = parse.mismatch.string))
print("parsing annotation file. This can take a while...")
df$loc <- parApply(cl = cl, X = df, MARGIN = 1, FUN = get.loci)
print("Constructing final data frame!")
final.df <- data.frame()

for(f in unique(df$qseqid)){
#  print(f)
  sa <- df[df$qseqid == f,]
  en <- energies[energies$name == f,]
  en$val
  sa$energy <- en$val
  sa$pam.fasta <- spacer.seqs[spacer.seqs$headers == f,]$seqs
  sa <- data.frame(sa, stringsAsFactors = F)
  sa$gc.content <- letter.freq(unique(as.character(sa$pam.fasta)))
  final.df <- rbind(sa, final.df)
}

final.df <- final.df[grep("XXX$|XX$", final.df$recon.cigar, invert = T),]
final.df$mm.pos <- gsub("-1", "0", final.df$mm.pos)

final.df$aa <- NULL
final.df$bb <- NULL
final.df$cc <- NULL
final.df$dd <- NULL

#final.df$total.mm <- unlist(lapply(final.df$recon.cigar, count.total.mismatches))
#final.df <- final.df[final.df$total.mm < 7,]

print("Creating pictures!")
chr.hist <- data.frame(table(t(final.df$sseqid)), stringsAsFactors = F)
names(chr.hist) <- c("chr", "freq")

g1 <- ggplot(data=chr.hist) + geom_bar(aes(x = chr, y = freq), stat = "identity") + 
  ggtitle("Frequency of spacers per chromosome") + 
  theme_bw()

genes.hist <- data.frame(table(t(final.df$loc)), stringsAsFactors = F)
names(genes.hist) <- c("gene", "freq")
genes.hist <- genes.hist[order(genes.hist$freq, decreasing = T),][1:10,]
g2 <- ggplot(data=genes.hist) + geom_bar(aes(x = gene, y = freq), stat = "identity") + 
  ggtitle("Frequency of features (genes or intergenic, top 10)") + 
  theme_bw()

g3 <- ggplot(data = final.df, aes(y = gc.content, x = energy)) + 
  stat_density2d(aes(fill = ..density..^0.25), geom = "tile", contour = FALSE, n = 200) + 
  scale_fill_continuous(low = "white", high = "dodgerblue4") + 
  ggtitle("GC-content / energy plot") + 
  theme_bw()

text.on.plot = paste(length(unique(final.df$qseqid)), " spacers", "\n",
                     nrow(final.df), " alignments", "\n",
                     round(mean(final.df$length),1), " mean alignment legnth", "\n",
                     nrow(final.df[final.df$val == "novalid",]), " novalid alignments", "\n",
                     round(mean(final.df$gc.content),1), "% mean GC content", "\n",
                     round(mean(final.df$energy),1), " mean gRNA energy", "\n",
                     length(unique(final.df$loc))-1, " genes",
                     sep = "")

g4 <- ggplot() + geom_text(aes(x = 2, y = 3), label = text.on.plot, size = 7) + 
  theme_bw() +
  theme(panel.grid.major=element_blank(),
        panel.grid.minor=element_blank())

pdf(paste(prefix,"-pic.pdf", sep = ""), width = 12, height = 12, family = "Helvetica")
grid.arrange(g1,g2,g3,g4,ncol = 2)
dev.off()

write.csv(final.df, paste(prefix, "-results.csv", sep = ""))
stopCluster(cl = cl)
