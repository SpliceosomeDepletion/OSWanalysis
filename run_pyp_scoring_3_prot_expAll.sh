# load data from merge and scoring
cp merged_protein.osw $TMPDIR
mv $TMPDIR/merged_protein.osw $TMPDIR/merged_protein_export.osw

pyprophet export --in=$TMPDIR/merged_protein_export.osw \
--out=$TMPDIR/merged_protein_export_expAll.tsv \
--format=legacy_merged \
--no-ipf \
--max_rs_peakgroup_qvalue=0.1 \
--max_rs_peakgroup_pep=1 \
--peptide \
--max_global_peptide_qvalue=0.05 \
--protein \
--max_global_protein_qvalue=0.01 \

cp $TMPDIR/merged_protein_export_expAll.tsv .
