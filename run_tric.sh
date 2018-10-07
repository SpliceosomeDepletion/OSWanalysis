
#DIR=~/mysonas/PRPF8/data/DIAsearch/output
DIR=~/mysonas/PRPF8/data/DIAsearch/output
cd ${DIR}

module load new
module load /cluster/apps/imsb/modules
module load r/3.4.0
module load mpfr
module load open_mpi

bsub -J filter -R "rusage[mem=200000,scratch=200000]" -W 24:00 Rscript --vanilla ../../OSWanalysis/filter_pyprophet_export.R

bsub -J tric -R "rusage[mem=200000,scratch=200000]" -w "done(filter)" -W 24:00 \
feature_alignment.py \
--in merged_protein_export_filtered.tsv \
--out aligned_filtered.csv \
--method LocalMST \
--realign_method lowess_cython \
--max_rt_diff 60 \
--mst:useRTCorrection True \
--mst:Stdev_multiplier 3.0 \
--target_fdr -1 \
--fdr_cutoff 0.01 \
--max_fdr_quality 0.1 \
--alignment_score 0.01
