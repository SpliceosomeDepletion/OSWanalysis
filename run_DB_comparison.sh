cd ~/mysonas/PRPF8/data/databaseComparison

# create simlink to 2 exemplary DDA files
ln -s ../DDAsearch/heuselm_L180129_021.mzXML .
ln -s ../DDAsearch/heuselm_L180129_022.mzXML .

# get iRT and crap fasta from custom DB
cat PRPF8_protgen_combined_1FPKM.fasta | grep "RT-Kit" -A 1 > iRT.fasta
cat PRPF8_protgen_combined_1FPKM.fasta | grep -E 'cRAP|StrepHA-Tag|3xHA_tag|Streptactin|Clonetech|TRYP_PIG' -A 1 > crap.fasta

# append iRT and crap fasta to uniprot DBs
for file in uniprot_human_trembl.fasta uniprot_human_sprot_variants.fasta uniprot_human_sprot_canonical.fasta
do
  cat ${file} iRT.fasta crap.fasta > ${file%.*}_iRTcrap.fasta
done

# append reverse decoys to all DBs
# ctermpep: c-terminus of each peptide is fixed and the remaining sequence reversed LHIK -> IHLK
# -enz 1: Trypsin
for file in PRPF8_protgen_combined_1FPKM.fasta uniprot_human_trembl_iRTcrap.fasta uniprot_human_sprot_variants_iRTcrap.fasta uniprot_human_sprot_canonical_iRTcrap.fasta
do
  bsub decoyv2.pl -db ${file} -out ${file%.*}_reverse.fasta -decoy ctermpep -enz 1
done

# create comet parameter file for all DBs
for file in PRPF8_protgen_combined_1FPKM_reverse.fasta uniprot_human_trembl_iRTcrap_reverse.fasta uniprot_human_sprot_variants_iRTcrap_reverse.fasta uniprot_human_sprot_canonical_iRTcrap_reverse.fasta
do
  cp template_comet.params ${file%.*}_comet.params
  sed -i -e "s/db.fasta/${file}/g" ${file%.*}_comet.params
done

# run comet search for all DBs
i=0
for file in PRPF8_protgen_combined_1FPKM_reverse_comet.params uniprot_human_trembl_iRTcrap_reverse_comet.params uniprot_human_sprot_variants_iRTcrap_reverse_comet.params uniprot_human_sprot_canonical_iRTcrap_reverse_comet.params
do
  let i+=1
  bsub -R "rusage[mem=80000,scratch=80000]" -W 24:00 -J "22_comet${i}" comet -P${file} -N${file%.*}_022 heuselm_L180129_022.mzXML
  bsub -R "rusage[mem=80000,scratch=80000]" -W 24:00 -J "21_comet${i}" comet -P${file} -N${file%.*}_021 heuselm_L180129_021.mzXML
done

# run peptideProphet
bsub -R "rusage[mem=20000,scratch=20000]" -J "xinteract_1FPKM" xinteract -dreverse_ -OARPd -Ninteract_1FPKM PRPF8_protgen_combined_1FPKM_reverse_comet*.pep.xml
bsub -R "rusage[mem=20000,scratch=20000]" -W 24:00 -J "xinteract_trembl" xinteract -dreverse_ -OARPd -Ninteract_trembl uniprot_human_trembl_iRTcrap_reverse_comet*.pep.xml
bsub -R "rusage[mem=20000,scratch=20000]" -J "xinteract_sprot_variants" xinteract -dreverse_ -OARPd -Ninteract_sprot_variants uniprot_human_sprot_variants_iRTcrap_reverse_comet*.pep.xml
bsub -R "rusage[mem=20000,scratch=20000]" -J "xinteract_sprot_canonical" xinteract -dreverse_ -OARPd -Ninteract_sprot_canonical uniprot_human_sprot_canonical_iRTcrap_reverse_comet*.pep.xml

# write PSM counts in summary file
echo "file fdr psm_count" > psm_summary.txt
for file in interact-interact_*.pep.xml
do
  psmCount_1fdr=`head -n 100 ${file} | grep 'error="0.0100"' | grep -Po '.*num_corr="\K.*?(?=".*)'`
  psmCount_5fdr=`head -n 100 ${file} | grep 'error="0.0500"' | grep -Po '.*num_corr="\K.*?(?=".*)'`
  psmCount_10fdr=`head -n 100 ${file} | grep 'error="0.1000"' | grep -Po '.*num_corr="\K.*?(?=".*)'`
  echo "${file} 0.01 ${psmCount_1fdr}" >> psm_summary.txt
  echo "${file} 0.05 ${psmCount_5fdr}" >> psm_summary.txt
  echo "${file} 0.10 ${psmCount_10fdr}" >> psm_summary.txt
done

# plot PSM summary
module load new
module load /cluster/apps/imsb/modules
module load r/3.4.0
module load mpfr
module load open_mpi
bsub -J psm_summary -R "rusage[mem=5000,scratch=5000]" -W 4:00 Rscript --vanilla ../OSWanalysis/get_psm_summary_plots.R
