import pandas as pd
import glob


statfiles = glob.glob("*.stats")

reads_raw = pd.DataFrame()
for statfile in statfiles:
    reads_raw = reads_raw.merge(pd.read_csv(statfile, sep="\t").set_index("vOTU"), left_index=True, right_index=True, how="outer")
    
reads_raw.fillna(0, inplace=True)




contig_lengths = pd.read_csv("h_qual_clean_contigs_sizes.txt", sep="\t", index_col=0)
contig_lengths["KB"] = contig_lengths["size"] / 1000

reads_RPK = reads_raw.div(contig_lengths["KB"], axis=0)

pm_scaling = reads_RPK.sum(axis="rows") / 10**6 # per mil scaling factor

reads_tpm = reads_RPK.div(pm_scaling, axis=1)


reads_raw.to_csv("raw_vOTU_table.tsv", sep="\t")
reads_tpm.to_csv("tpm_vOTU_table.tsv", sep="\t")
