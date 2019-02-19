cd ~/mysonas/PRPF8/data/DDAsearch

IDs='20180125034955881-1368832 20180125071256764-1368866 20180125091455947-1368889
20180125172128554-1368968 20180125200328599-1368996 20180125224730134-1369040
20180126013828710-1369062 20180126045228631-1369103 20180126070528777-1369133
20180126093828713-1369158 20180126122029482-1369199 20180126160428736-1369244
20180126183628754-1369259 20180126212828881-1369283 20180126235028771-1369297
20180127031228755-1369316 20180127055428838-1369338 20180127080629574-1369353
20180127111128865-1369379 20180127141429630-1369406 20180127170828862-1369429
20180127192128908-1369452 20180127222528900-1369488 20180129172830462-1369750
20180129200329317-1369792 20180129222730047-1369884 20180130010529363-1369926
20180130044129621-1369991 20180130064829399-1370025 20180130092331580-1370057
20180130120831597-1370160 20180130150529851-1370205 20180130183129829-1370250
20180130204529863-1370273 20180130234030552-1370301 20180131025429921-1370332
20180131050829899-1370367 20180131081230216-1370401 20180131110629987-1370559
20180131140129984-1370594 20180131163430005-1370618 20180131191930774-1370693
20180131215231478-1370752 20180201063330107-1370886 20180201090637457-1370925
20180201122337658-1370976 20180201150736960-1371014 20180202195936356-1371328
20180203021537529-1371390 20180203051936406-1371431 20180203073337181-1371458
20180203100737523-1371490 20180203132036433-1371518 20180203211038254-1371597
20180203235636531-1371631 20180204024137653-1371662 20180204051437005-1371687
20180204081136576-1371729 20180204105636944-1371763 20180204132937467-1371789
20180204162536699-1371818 20180204192249366-1371858 20180204213750192-1371880
20180205003150198-1371910 20180205030549598-1371936 20180205062249422-1371976
20180205090549444-1371998 20180205114849719-1372022 20180205141049760-1372040
20180205173349620-1372073 20180205201549640-1372091 20180205224849686-1372125
20180125010655991-1368806 20180201005630048-1370787 20180201035230072-1370832'

for id in ${IDs}
do
  file=`ls ~/mysonas/html/openBIS/${id}/heuselm*.mzXML.gz`
  cp ${file} .
done

gunzip *.mzXML.gz

for id in ${IDs}
do
  dir=~/mysonas/html/openBIS/${id}/
  rm -R ${dir}
done

# run comet search
cp ../databaseComparison/PRPF8_protgen_combined_1FPKM_reverse.fasta .
cp ../databaseComparison/PRPF8_protgen_combined_1FPKM_reverse_comet.params .
for file in *mzXML
do
  name=${file##*/}
  bsub -R "rusage[mem=200000,scratch=200000]" -J "comet" comet -PPRPF8_protgen_combined_1FPKM_reverse_comet.params -N${name%.*}.comet ${file}
done

# run Xtandem search
for i in *mzXML
do
  echo $i
  j=$(basename $i .mzXML)
  echo $j
  cp input_PRPF8_protgen_combined_1FPKM_5600_native_semi.xml $j.tandem.params
  sed -i -e "s/input_file_name/$i/g" $j.tandem.params
  sed -i -e "s/output_file_name/$j.tandem.xml/g" $j.tandem.params
  bsub -R "rusage[mem=20000,scratch=20000]" -W 24:00 -J "xtandem" -n 1 tandem $j.tandem.params
done

# wait
#convert 2 pepxml
for i in *mzXML
do
  echo $i
  j=$(basename $i .mzXML)
  echo $j
  bsub  -R "rusage[mem=20000,scratch=20000]" -J "xtrandem_convert" Tandem2XML $j.tandem.xml $j.tandem.pep.xml
done

# peptideProphet
# comet
bsub -R "rusage[mem=200000,scratch=200000]" -W 24:00 -J "xinteract_1FPKM_comet" \
xinteract -dreverse_ -OARPd -Ninteract_1FPKM_comet heuselm*.comet.pep.xml

# xTandem
bsub -R "rusage[mem=200000,scratch=200000]" -W 24:00 -J "xinteract_1FPKM_xtandem" \
xinteract -dreverse_ -OARPd -Ninteract_1FPKM_xtandem heuselm*.tandem.pep.xml

# wait for both search engines to finish and look at output before running iProphet

# iProphet
bsub -R "rusage[mem=200000,scratch=200000]" -W 24:00 -J "iprophet_1FPKM" \
InterProphetParser DECOY=reverse_ *interact_1FPKM_comet.pep.xml *interact_1FPKM_xtandem.pep.xml iprophet_1FPKM_cometANDxtandem.pep.xml

# use iProphet peptide FDR of 1%
probCutoff=`head -n 100 iprophet_1FPKM_cometANDxtandem.pep.xml | grep 'error="0.0100"' | grep -Po '.*min_prob="\K.*?(?=".*)'`
echo $probCutoff

# spectrast library creation and iRT normalization
bsub -R "rusage[mem=200000,scratch=200000]" -J spectrast_irt \
spectrast -cNSpecLib \
-cICID-QTOF \
-cf 'Protein!~reverse_' \
-cP$probCutoff \
-c_IRTirtkit.txt \
-c_IRR \
iprophet_1FPKM_cometANDxtandem.pep.xml

# spectrast consensus spectrum generation
bsub -R "rusage[mem=200000,scratch=200000]" -J spectrast_cons -W 24:00 \
spectrast -cNSpecLib_cons_all \
-cICID-QTOF \
-cAC \
-cM \
SpecLib.splib

# exchange modifications from Xtandem to be conforming with OpenSWATH
cp SpecLib_cons_all.mrm SpecLib_cons_all_unimod.mrm

sed -i -e 's/n\[43\]/\(Acetyl\)./' \
    -e 's/C\[160\]/C\(Carbamidomethyl\)/' \
    -e 's/C\[143\]/\(Pyro-carbamidomethyl\)\.C/' \
    -e 's/E\[111\]/(Glu->pyro-Glu).E/' \
    -e 's/Q\[111\]/(Gln->pyro-Glu).Q/' \
    SpecLib_cons_all_unimod.mrm

# change ProteinName to ENSEMBL gene id
# remove non-genotypic peptides
module load new
module load /cluster/apps/imsb/modules
module load r/3.4.0
module load mpfr
module load open_mpi
bsub -J genotypic_lib -R "rusage[mem=5000,scratch=5000]" -W 4:00 Rscript --vanilla ../OSWanalysis/generate_genotypic_library.R

# Import from SpectraST MRM and convert to TraML
bsub -n 8 -R "rusage[mem=5000,scratch=5000]" -J toTraML \
TargetedFileConverter \
-in SpecLib_cons_all_unimod_genotypic.mrm \
-out transitionlist.TraML \
-threads 8

# Target assay generation
bsub -n 8 -R "rusage[mem=4096,scratch=8192]" -J "AssayGenerator" -w "done(toTraML)" \
OpenSwathAssayGenerator \
-in transitionlist.TraML \
-out transitionlist_optimized.TraML \
-swath_windows_file swath64_withHeader.txt \
-threads 8

# Decoy generation
bsub -n 8 -R "rusage[mem=4096,scratch=8192]" -J "DecoyGenerator" -w "done(AssayGenerator)" \
OpenSwathDecoyGenerator \
-in transitionlist_optimized.TraML \
-out transitionlist_optimized_decoys.TraML \
-method shuffle \
-switchKR true \
-threads 8

# convert to pqp format for OpenSWATH
bsub -R "rusage[mem=4096,scratch=8192]" -J "conversion_to_pqp" -w "done(DecoyGenerator)" \
TargetedFileConverter \
-in transitionlist_optimized_decoys.TraML \
-out transitionlist_optimized_decoys.pqp

# convert target library to tsv for manual inspection and Skyline usage
bsub -R "rusage[mem=4096,scratch=8192]" -J "conversion_to_csv" -w "done(DecoyGenerator)" \
TargetedFileConverter \
-in transitionlist_optimized_decoys.TraML \
-out transitionlist_optimized_decoys.tsv
