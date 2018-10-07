# module load /cluster/apps/imsb/modules/msproteomicstools/
DIR=~/mysonas/PRPF8/data/DIAsearch/output
cd ${DIR}

module load new
module load /cluster/apps/imsb/modules
module load r/3.4.0
module load mpfr
module load open_mpi

bsub -J fix -R "rusage[mem=200000,scratch=200000]" -W 24:00 Rscript --vanilla ../../OSWanalysis/reformat_tric_forRequant.R

module unload msproteomicstools/master
module load msproteomicstools/master_isa

#for file in heuselm_L171224_020.chrom.mzML
#for file in heuselm_L180103_032.chrom.mzML
for file in *.chrom.mzML
do
  bsub -J tric -R "rusage[mem=20000,scratch=20000]" -w "done(fix)" -W 24:00 \
  requantAlignedValues.py \
  --do_single_run $file \
  --peakgroups_infile aligned_filtered_fixed.csv \
  --out ${file%.*.*}_aligned_requantified.csv \
  --method singleShortestPath \
  --realign_runs lowess_cython
done

# concatinate all output files
