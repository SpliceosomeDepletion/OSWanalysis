# load data from merge and scoring
cp merged_peptide.osw $TMPDIR
mv $TMPDIR/merged_peptide.osw $TMPDIR/merged_peptide_export.osw

pyprophet export --in=$TMPDIR/merged_peptide_export.osw \
--out=$TMPDIR/merged_peptide_export_expAll.tsv \
--format=legacy_merged \
--no-ipf \
--max_rs_peakgroup_qvalue=0.1 \
--max_rs_peakgroup_pep=1 \
--peptide \
--max_global_peptide_qvalue=0.01 \
--no-protein \
--max_global_protein_qvalue=1

cp $TMPDIR/merged_peptide_export_expAll.tsv .
