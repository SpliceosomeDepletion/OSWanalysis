
OUT_DIR=~/mysonas/PRPF8/data/DIAsearch/output
cd ${OUT_DIR}

# merge and score input files
# had to split merging and scoring, because otherwise cross validation gets stuck in scoring
bsub -J pypMerge_for_scoring -R "rusage[mem=20000,scratch=20000]" -W 24:00 ../../OSWanalysis/run_pyp_merge_for_scoring.sh
#bsub -J pypSubscoring -n 12 -w "done(pypMerge_for_scoring)" -R "rusage[mem=20000,scratch=20000]" -W 24:00 ../../OSWanalysis/run_pyp_subscoring.sh
bsub -J pypSubscoring -n 12 -R "rusage[mem=5000,scratch=5000]" -W 4:00 ../../OSWanalysis/run_pyp_subscoring.sh

# merge all files
bsub -J pypMerge -R "rusage[mem=200000,scratch=200000]" -W 24:00 ../../OSWanalysis/run_pyp_merge_fast.sh

# run scoring on full merged file
bsub -J scoring_1 -R "rusage[mem=500000,scratch=500000]" -W 4:00 ../../OSWanalysis/run_pyp_scoring_1.sh
bsub -J scoring_2 -R "rusage[mem=500000,scratch=500000]" -w "done(scoring_1)" -W 4:00 ../../OSWanalysis/run_pyp_scoring_2.sh
bsub -J scoring_3 -R "rusage[mem=500000,scratch=500000]" -w "done(scoring_2)" -W 4:00 ../../OSWanalysis/run_pyp_scoring_3_prot.sh
bsub -J scoring_exp -R "rusage[mem=500000,scratch=500000]" -w "done(scoring_3)" -W 120:00 ../../OSWanalysis/run_pyp_scoring_3_prot_expAll.sh
