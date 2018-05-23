
#DIR=~/mysonas/PRPF8/data/DIAsearch/output
DIR=~/mysonas/PRPF8/data/DIAsearch/output_old
cd ${DIR}

#bsub -J tric -R "rusage[mem=200000,scratch=200000]" -W 24:00 \
#feature_alignment.py \
#--in merged_protein_export.tsv \
#--out aligned.csv \
#--method LocalMST --realign_method lowess_cython --max_rt_diff 60 \
#--mst:useRTCorrection True --mst:Stdev_multiplier 3.0 \
#--target_fdr 0.01 --max_fdr_quality -1 --alignment_score 0.01

bsub -J tric -R "rusage[mem=200000,scratch=200000]" -W 24:00 \
feature_alignment.py \
--in merged_protein_export_filtered.tsv \
--out aligned_filtered.csv \
--method LocalMST --realign_method lowess_cython --max_rt_diff 60 \
--mst:useRTCorrection True --mst:Stdev_multiplier 3.0 \
--fdr_cutoff 0.01 --max_fdr_quality -1 --alignment_score 0.01