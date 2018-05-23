# load data
cp merged_peptide.osw $TMPDIR
mv $TMPDIR/merged_peptide.osw $TMPDIR/merged_protein.osw

pyprophet protein --in=$TMPDIR/merged_protein.osw --context=experiment-wide \
protein --in=$TMPDIR/merged_protein.osw --context=global

cp $TMPDIR/merged_protein* .
