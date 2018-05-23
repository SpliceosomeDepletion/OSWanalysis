# load data
cp merged_protein.osw $TMPDIR
mv $TMPDIR/merged_protein.osw $TMPDIR/merged_protein_export.osw

pyprophet export --in=$TMPDIR/merged_protein_export.osw \
--out=$TMPDIR/merged_protein_export.tsv --no-ipf \
--no-transition_quantification --max_rs_peakgroup_qvalue=1 \
--max_global_peptide_qvalue=0.01 --max_global_protein_qvalue=1

cp $TMPDIR/merged_protein_export* .
