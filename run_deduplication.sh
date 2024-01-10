module load tools
module load java/1.8.0-openjdk
module load seqkit/0.13.2
module load seqtk/1.3
module load perl
module load kentutils/396


# This script will deduplicate contigs found across all assemblies. Input is the contig files; an appropriate filepath should be supplied in the first line of code.
#
# 


cat <PATH_TO_CONTIG_FILES>/contigs* > All_cross_contigs.fasta

blat All_cross_contigs.fasta All_cross_contigs.fasta contigs.all.blat -out=blast8

cat All_cross_contigs.fasta | f2s | seqlengths | joincol <(cat contigs.all.blat | awk '{if ($1 == $2) print $1 "\t" $12}' | hashsums | tail -n +2) > contigs.all.lengths
cat contigs.all.lengths | awk '$3/$2 > 2.15' | cut -f1 > contigs.all.chimeras.list
cut -f1,2,12 contigs.all.blat | hashsums | tail -n +2 | joincol contigs.all.chimeras.list | awk '{if ($NF == 0) print $1 "\t" $2 "\t" $3}' | joincol contigs.all.lengths | joincol contigs.all.lengths 2 | sort -k4,4nr -k1,1 | awk '{if ($3/$NF >= .90) print $1 "\t" $2}' | perl -lane 'unless (exists($clusters{$F[1]})) {$clusters{$F[1]} = $F[0]; print "$F[1]\t$F[0]"}' > vOTUs.tsv

cat All_cross_contigs.fasta | f2s | joincol <(cut -f2 vOTUs.tsv) | awk '$NF == 1' | cut -f1,2 | s2f > vOTUs.fna

seqkit sort -l -r vOTUs.fna -o deduplicated.fasta
seqtk rename deduplicated.fasta vOTU_ > h_qual_contigs.fa

rm deduplicated.fasta vOTUs.fna vOTUs.tsv contigs.all.chimeras.list contigs.all.lengths contigs.all.blat
