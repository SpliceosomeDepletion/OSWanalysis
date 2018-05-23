# load data from merge and scoring
cp merged_for_scoring.osw $TMPDIR
cp merged.osw $TMPDIR
mv $TMPDIR/merged.osw $TMPDIR/merged_ms2.osw

pyprophet score --in=$TMPDIR/merged_ms2.osw --apply_weights=$TMPDIR/merged_for_scoring.osw --level=ms2

cp $TMPDIR/merged_ms2* .
