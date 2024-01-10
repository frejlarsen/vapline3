module load genomad/1.3.3
module load seqkit/0.13.2
module load seqtk/1.3

#
#
#


genomad end-to-end --cleanup h_qual_contigs.fa OUTPUT_ALL <FILE_PATH_TO_GENOMAD_DATABASE>


cat OUTPUT_ALL/h_qual_contigs_summary/h_qual_contigs_virus_summary.tsv | awk -F "\t" '{if ($7>0.9) {print}}' > genomad_output.tsv
cut -f1 genomad_output.tsv > h_qual_clean_contigs.txt
cut -f1,2 genomad_output.tsv > h_qual_clean_contigs_sizes.txt


seqtk subseq h_qual_contigs.fa h_qual_clean_contigs.txt | seqkit sort -l -r -o h_qual_clean_contigs.fa
