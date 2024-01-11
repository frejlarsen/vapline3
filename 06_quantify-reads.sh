module load seqkit/0.13.2
module load bowtie2/2.5.0
module load samtools/1.11



bowtie2-build -f h_qual_clean_contigs.fa dbname


for file in reads*.fa
do
echo $file
bowtie2 -x dbname -f $file -p 24 |  samtools view -bS - > ${file}_tmp
samtools sort ${file}_tmp  -o ${file}.bam -@ 24
samtools index ${file}.bam
echo -e 'vOTU\t'"${file}"'' > ${file}_header
samtools idxstats ${file}.bam | cut -f1,3 | sed '/*/d' > ${file}_tmp
cat ${file}_header ${file}_tmp > ${file}.stats
done


seqkit fx2tab -l -n h_qual_clean_contigs.fa > tmp1
echo 'vOTU\tsize' > tmp2
cat tmp2 tmp1 > h_qual_clean_contigs_sizes.txt


rm *tmp* *header dbname*
