module load checkv/1.0.1
module load vibrant/1.2.1
module load anaconda3/2023.03
module load virbot/20230718
module load virsorter2/2.2.4
module load seqtk/1.3
module load seqkit/0.13.2

# This script assesses the contigs for their "viralness", allowing us to discard contigs based on contaminants. Assessment is done by 4 different software packages, checkV, VIBRANT, VirBot, and VirSorter2. See README for links.
# 
# Note that some of these programs might interfere with eachother. If experiencing issues, try purging/changing your environment.
#
# Below is a custom criteria selection from the outputs of each software. Your preferences may wary depending on how conservative you wish your virome to be.
#
# Before running make sure filepaths are correct for checkV, VIBRANT, and VirSorter2


checkv end_to_end h_qual_contigs.fa -d <FILE_PATH_TO_DATABASE> QC_CHECKV -t 22
VIBRANT_run.py -i h_qual_contigs.fa -t 22 -virome -d <FILE_PATH_TO_DATABASE> -m <FILE_PATH_TO_FILES> -folder QC_VIBRANT
VirBot.py --input h_qual_contigs.fa --output QC_VIRBOT
virsorter run -d <FILE_PATH_TO_DATABASE> -w QC_VIRSORTER2 -i h_qual_contigs.fa -j 22 --include-groups dsDNAphage,NCLDV,RNA,ssDNA,lavidaviridae


cat QC_CHECKV/quality_summary.tsv | cut -f 1,8 | awk '{ if ($2=="High-quality" || $2=="Medium-quality" || $2=="Complete") print }' | cut -f 1 | sed 's/_fragment/*/g' | sed 's/*/'"$TAB"'/g' | cut -f 1 > sQC_CHECKV.txt
cat QC_VIRSORTER2/final-viral-score.tsv | cut -f 1,7 | awk '{ if ($2=="1.000") print }' | grep "full" | sed 's/|/'"${TAB}"'/g' | cut -f 1 | sed 's/_fragment/*/g' | sed 's/*/'"$TAB"'/g' | cut -f 1 | sed 's/full//g' | sed 's/_partial//g' > sQC_VIRSORTER.txt
cat QC_VIBRANT/VIBRANT_h_qual_contigs/VIBRANT_results_h_qual_contigs/VIBRANT_genome_quality_h_qual_contigs.tsv | cut -f 1,3 | awk '{ if ($2=="complete" || $2=="high" || $2=="medium") print $1 }' | sed 's/_fragment/*/g' | sed 's/*/'"$TAB"'/g' > sQC_VIBRANT.txt
tail QC_VIRBOT/pos_contig_score.csv --lines=+2 | cut -f 1 -d, > sQC_VIRBOT.txt


cat sQC* | cut -f1 | sort -u > h_qual_clean_contigs.txt
seqtk subseq h_qual_contigs.fa h_qual_clean_contigs.txt | seqkit sort -l -r -o h_qual_clean_contigs.fa


rm sQC*
