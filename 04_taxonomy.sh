module load mmseqs2/release_14-7e284


# Executes a DNA-to-protein alignment between the qualified contigs and a protein database.
#
# We are using a custom database (see README file).
#
# Before running, ensure that your protein database is correctly formatted and that the file paths are correctly added to the script.


mmseqs createdb h_qual_clean_contigs.fa h_qual_clean_contigs.DB --dbtype 2

mmseqs search -e 1e-6 --search-type 4 h_qual_clean_contigs.DB <FILE_PATH_TO_DATABASE> alnDB tmp
mmseqs convertalis h_qual_clean_contigs.DB <FILE_PATH_TO_DATABASE> alnDB blastout.txt


cut blastout.txt -f 2 | rev | cut -f 1 -d_ --complement | rev > vog
cut blastout.txt -f 1 > votu
cut blastout.txt -f 12 > score

paste votu vog score | sort -k 1,1 -k 2,2 > blast_sorted

awk '{arr[$1 "\t" $2]+=$3}END{for (a in arr) print a "\t" arr[a]}' blast_sorted | sort -k1,1 -k3,3nr > all_hits

cat all_hits | sort -u -k1,1 | cut -f1,2 | sort -k2,2 -k1,1 > blastout_highscore_sorted.tsv

join -1 2 -2 1 -t $'\t' blastout_highscore_sorted.tsv <FILE_PATH_TO_TAXONOMY_FILE> | cut -f1 --complement > taxonomy.tsv

rm -r tmp votu score vog blast_sorted blastout_highscore_sorted.tsv blastout.txt alnDB* h_qual_clean_contigs.DB*
