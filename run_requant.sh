# module load /cluster/apps/imsb/modules/msproteomicstools/
DIR=~/mysonas/PRPF8/data/DIAsearch/output
cd ${DIR}

for file in *.chrom.mzML
do
  bsub -J tric -R "rusage[mem=20000,scratch=20000]" -W 24:00 \
  requantAlignedValues.py \
  --do_single_run $file \
  --peakgroups_infile aligned_filtered_fixed.csv \
  --out aligned_requantified.csv \
  --method singleShortestPath \
  --realign_runs lowess_cython
done

# concatinate all output files
