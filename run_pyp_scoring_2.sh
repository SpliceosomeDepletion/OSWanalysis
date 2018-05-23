# load data
cp merged_ms2.osw $TMPDIR
mv $TMPDIR/merged_ms2.osw $TMPDIR/merged_peptide.osw

pyprophet peptide --in=$TMPDIR/merged_peptide.osw --context=experiment-wide \
peptide --in=$TMPDIR/merged_peptide.osw --context=global

cp $TMPDIR/merged_peptide* .
