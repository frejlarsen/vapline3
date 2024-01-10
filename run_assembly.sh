#!/bin/bash
module load java/1.8.0-openjdk
module load pigz/2.3.4
module load trimmomatic/0.38
module load seqkit/0.13.2
module load bbmap/38.90
module load anaconda3/4.4.0
module load spades/3.13.0
module load seqtk/1.3


# This script preprocesses demultiplexed reads and assembles them into contigs. The contigs are size selected (sequences <1KB are discarded)
#
# Input should be a single forward and reverse read file ending in 1.fq.gz and 2.fq.gz. If your file has a different suffix, make sure to change the script (or filename) accordingly.
#
# trimmomatic and bbduk.sh requires sequences for Illumina adaptors and the phiX174 genome respectively. Make sure to update the filepaths to match the file locations on your system.


string=$(basename *1.fq.gz .fq.gz)
echo $string


trimmomatic PE -threads 22 -phred33 *1.fq.gz *2.fq.gz PF1.fq UF1.fq PF2.fq UF2.fq ILLUMINACLIP:<PATH_TO_FILE_LOCATION>/NexteraPE-PE.fa:2:30:10 LEADING:20 TRAILING:20 MINLEN:50
cat PF1.fq UF1.fq > forward.fq
cat PF2.fq UF2.fq > reverse.fq
rm PF1.fq UF1.fq PF2.fq UF2.fq


seqkit rmdup forward.fq -s -o DPF1.fq -j 12
seqkit rmdup reverse.fq -s -o DPF2.fq -j 12
rm forward.fq
rm reverse.fq


bbduk.sh in=DPF1.fq out=forward.fq  ref=<PATH_TO_FILE_LOCATION>/phi_X174_phage.fa k=31 hdist=1
bbduk.sh in=DPF2.fq out=reverse.fq  ref=<PATH_TO_FILE_LOCATION>/phi_X174_phage.fa k=31 hdist=1
rm DPF1.fq
rm DPF2.fq


repair.sh in=forward.fq in2=reverse.fq out=forward.fq.paired.fq out2=reverse.fq.paired.fq  outs=unpaired.fq
rm forward.fq
rm reverse.fq


spades.py --pe1-1 forward.fq.paired.fq --pe1-2 reverse.fq.paired.fq --pe1-s unpaired.fq -o spades_folder -t 26 -m 110  --only-assembler


seqkit seq spades_folder/scaffolds.fasta -m 1000 -g > contigs.fasta
seqtk rename contigs.fasta contig-${string}_ > contigs_${string}.fa


cat forward.fq.paired.fq reverse.fq.paired.fq  unpaired.fq | seqtk seq -a  | cut -d ' ' -f 1  >  tmp ; seqtk rename tmp ${string}_ > reads_${string}.fa

rm contigs.fasta forward.fq.paired.fq reverse.fq.paired.fq unpaired.fq tmp
