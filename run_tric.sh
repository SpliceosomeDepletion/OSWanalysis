
#DIR=~/mysonas/PRPF8/data/DIAsearch/output
DIR=~/mysonas/PRPF8/data/DIAsearch/output
cd ${DIR}

bsub -R "rusage[mem=40000]" Rscript --vanilla ../../OSWanalysis/filter_pyprophet_export.R

bsub -J tric -R "rusage[mem=200000,scratch=200000]" -W 24:00 \
feature_alignment.py \
--in merged_peptide_export_filtered.tsv \
--out aligned_filtered.csv \
--method LocalMST \
--realign_method lowess_cython \
--max_rt_diff 60 \
--mst:useRTCorrection True \
--mst:Stdev_multiplier 3.0 \
--target_fdr -1 \
--fdr_cutoff 0.01 \
--max_fdr_quality 0.2 \
--alignment_score 0.01
